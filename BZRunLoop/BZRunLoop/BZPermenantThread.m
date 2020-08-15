//
//  BZPermenantThread.m
//  BZRunLoop
//
//  Created by brandon on 2020/8/15.
//  Copyright © 2020 brandon_zheng. All rights reserved.
//

#import "BZPermenantThread.h"

@interface BZThread : NSThread

@end

@implementation BZThread

- (void)dealloc{
    NSLog(@"----%s----",__func__);
}

@end

@interface BZPermenantThread()

@property(strong,nonatomic)BZThread *innerThread;

@property(assign,nonatomic,getter=isStop) BOOL stopped;

@end

@implementation BZPermenantThread

- (instancetype)init{
    if (self = [super init]) {
        __weak typeof(self) weakSelf = self;
        self.innerThread = [[BZThread alloc] initWithBlock:^{
            [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
            while (weakSelf && !weakSelf.isStop) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
        }];
    }
    return self;
}

- (void)run{
    [self.innerThread start];
}

- (void)executeBlock:(void (^)(void))task{
    if (!self.innerThread || !task) {
        return;
    }
    [self performSelector:@selector(__executeTask:) onThread:self.innerThread withObject:nil waitUntilDone:NO];
}

- (void)stop{
    if (!self.innerThread) {
        return;
    }
    [self performSelector:@selector(__stop) onThread:self.innerThread withObject:nil waitUntilDone:YES];
}


- (void)__stop{
    self.stopped = YES;
    CFRunLoopStop(CFRunLoopGetCurrent());
    self.innerThread = nil;
}

- (void)__executeTask:(void (^)(void))task{
    task();
}

@end
