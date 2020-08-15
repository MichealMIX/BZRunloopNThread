//
//  BZPermenantThread.h
//  BZRunLoop
//
//  Created by brandon on 2020/8/15.
//  Copyright © 2020 brandon_zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BZPermenantThread : NSObject

/**
 开启一个线程
 */
- (void)run;

/**
 在现场中执行任务:两种方式
 */
//- (void)executeTaskWithTarget:(id)target action:(SEL)action object:(id)object;

- (void)executeBlock:(void (^)(void))task;

/**
 结束一个线程
 */
- (void)stop;


@end

NS_ASSUME_NONNULL_END
