//
//  ViewController.m
//  BZRunLoop
//
//  Created by brandon on 2020/8/14.
//  Copyright © 2020 brandon_zheng. All rights reserved.
//

#import "ViewController.h"
//#import "BZThread.h"
#import "BZPermenantThread.h"
@interface ViewController ()

//@property (nonatomic,strong)BZThread *thread;

@property (assign,nonatomic,getter=isStop) BOOL stopped;

@property (nonatomic,strong)BZPermenantThread *bzThread;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.stopped = NO;
    
    //写法一：这种写法可能会有点问题，因为即使这个界面销毁了，线程也不会delloc，控制器也不会死
    //initWithTarget会对我们的控制器产生强引用
//    self.thread = [[BZThread alloc] initWithTarget:self selector:@selector(run) object:nil];
//    [self.thread start];

    //写法二：这样我们的控制器就可以正常释放，因为我们的thread将不会再持有target，但是线程依旧还活着，因为线程会一直卡在run这个方法，因此它不会销毁
//    self.thread = [[BZThread alloc] initWithBlock:^{
//        //runloop保活代码，单单写run是无效的，因为没有source，timer等事件runloop会自动退出
//        NSLog(@"%@----begin----",[NSThread currentThread]);
//        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
//        [[NSRunLoop currentRunLoop] run];
//        //我们一直不会执行下面这段代码，因为一旦执行run，就会卡在上面这个循环当中，做事情->睡觉->做事情->睡觉的循环中
//        NSLog(@"%@----end----",[NSThread currentThread]);
//    }];
//    [self.thread start];
    
    
    
    /*写法三：我们想要让线程的生命周期可控就不能使用run这个方法，它在底层会重复调用[[NSRunLoop currentRunLoop] runMode:(nonnull NSRunLoopMode) beforeDate:(nonnull NSDate *)]这个方法，无限循环，它会一直调用这个方法，我们虽然写了stop的方法，但是只停止了一次而已
    
    [[NSRunLoop currentRunLoop] run] == while (1) {
       [[NSRunLoop currentRunLoop] runMode:(nonnull NSRunLoopMode) beforeDate:(nonnull NSDate *)];
    }
     
     因此我们不能调用run这个方法，自己来实现这个循环,[NSDate distantFuture]表示在遥远的未来，这样runloop不会超时
     */
    
   // 我们使用了weak，也就是说delloc时，weak会被设置为nil，所以就又进入这个while循环了，在判断时要增加一个判断
//    __weak typeof(self) weakSelf = self;
//    self.thread = [[BZThread alloc] initWithBlock:^{
//        //runloop保活代码，单单写run是无效的，因为没有source，timer等事件runloop会自动退出
//        NSLog(@"%@----begin----",[NSThread currentThread]);
//        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
//        while (weakSelf && !weakSelf.isStop) {
//            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//        }
//        //我们一直不会执行下面这段代码，因为一旦执行run，就会卡在上面这个循环当中，做事情->睡觉->做事情->睡觉的循环中
//        NSLog(@"%@----end----",[NSThread currentThread]);
//    }];
//    [self.thread start];
    
    self.bzThread = [[BZPermenantThread alloc] init];
    [self.bzThread run];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    /*写法（1）：这种写法会导致执行完任务线程就被销毁，再执行会再创建线程
    BZThread *thread = [[BZThread alloc] initWithTarget:self selector:@selector(test) object:nil];
    [thread start];
    NSLog(@"----%@----",thread);*/
    
    //写法（2）：我想让它每次点击都执行不同的任务，全局定义称为属性就可以每次都用这一个线程，但是我们这样做，虽然线程没有被销毁，但是它还是无法继续执行任务，因为它其实还是死了，只是没有被销毁，因此我们要加入runloop代码，这样就能一直使用此线程
    
//    [self performSelector:@selector(test) onThread:self.thread withObject:nil waitUntilDone:NO];
//    [self.bzThread executeTaskWithTarget:self action:@selector(test) object:nil];
    __weak typeof(self) weakSelf = self;
    [self.bzThread executeBlock:^{
        [weakSelf test];
    }];

}

- (void)test{
    NSLog(@"----%@----",[NSThread currentThread]);
    NSLog(@"----%s----",__func__);
}
//用于停止子线程的runloop
- (void)stopLoop{
//    self.stopped = YES;
//    CFRunLoopStop(CFRunLoopGetCurrent());
    [self.bzThread stop];
}

- (void)stop{
    //这种写法会造成VC销毁时会crash，原因就在这个方法的最后一个参数，这个NO代表不等待，也就是说performSelector这个函数调用完毕，不会等待子线程执行完毕，而是直接往下走，这时VC可能已经delloc了，但是子线程的任务中还在使用self，所以就造成了crash，可以设置为YES
    //    [self performSelector:@selector(stopLoop) onThread:self.thread withObject:nil waitUntilDone:NO];
//    [self performSelector:@selector(stopLoop) onThread:self.thread withObject:nil waitUntilDone:YES];
}

//- (void)run{
//    NSLog(@"----%@----",[NSThread currentThread]);
//    //runloop保活代码，单单写run是无效的，因为没有source，timer等事件runloop会自动退出
//    [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
//    [[NSRunLoop currentRunLoop] run];
//    //我们一直不会执行下面这段代码，因为一旦执行run，就会卡在上面这个循环当中，做事情->睡觉->做事情->睡觉的循环中
//    NSLog(@"----%s----",__func__);
//}

- (void)dealloc{
    
    [self stop];
    //最好是设置为nil
//    self.thread = nil;
}

@end
