//
//  ViewController.m
//  MultipleThread
//
//  Created by bottle on 15-5-4.
//  Copyright (c) 2015年 bottle. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic,strong) NSOperationQueue *queue;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.queue = [[NSOperationQueue alloc] init];
    [self test8];
}

#pragma mark - GCD
#pragma mark - 同步串行
- (void)test1 {
    dispatch_queue_t q = dispatch_queue_create("hellen.queue", DISPATCH_QUEUE_SERIAL);
    for (int i= 0; i<10; i++) {
        dispatch_sync(q, ^{
            NSLog(@"同步串行%d --- %@",i,[NSThread currentThread]);
//            dispatch_sync(q, ^{
//                NSLog(@"同步串行嵌套%d --- %@",i,[NSThread currentThread]);
//            });
        });
    }
}

#pragma mark - 同步并行
- (void)test2 {
    dispatch_queue_t q = dispatch_queue_create("hellen.queue", DISPATCH_QUEUE_CONCURRENT);
    
    for (int i= 0; i<20; i++) {
        dispatch_sync(q, ^{
            NSLog(@"同步并行%d --- %@",i,[NSThread currentThread]);
        });
    }
}

#pragma mark - 异步串行
- (void)test3 {
    dispatch_queue_t q = dispatch_queue_create("hellen.queue", DISPATCH_QUEUE_SERIAL);
    for (int i= 0; i<10; i++) {
        dispatch_async(q, ^{
            NSLog(@"异步串行%d --- %@",i,[NSThread currentThread]);
            dispatch_async(q, ^{
                NSLog(@"异步串行嵌套%d --- %@",i,[NSThread currentThread]);
            });
        });
    }
}

#pragma mark - 异步并行
- (void)test4 {
    dispatch_queue_t q = dispatch_queue_create("hellen.queue", DISPATCH_QUEUE_CONCURRENT);
    for (int i= 5; i<10; i++) {
        dispatch_async(q, ^{
            NSLog(@"异步并行%d --- %@",i,[NSThread currentThread]);
            dispatch_async(q, ^{
                NSLog(@"异步并行嵌套%d --- %@",i,[NSThread currentThread]);
            });
        });
    }
    for (int i= 0; i<5; i++) {
        dispatch_async(q, ^{
            sleep(1);
            NSLog(@"异步并行%d --- %@",i,[NSThread currentThread]);
            dispatch_async(q, ^{
                NSLog(@"异步并行嵌套%d --- %@",i,[NSThread currentThread]);
            });
        });
    }
    
}

#pragma mark - 全局队列
//类似并行队列
- (void)test5 {
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (int i= 0; i<10; i++) {
        dispatch_async(q, ^{
            NSLog(@"全局异步%d --- %@",i,[NSThread currentThread]);
        });
    }
//    for (int i= 0; i<10; i++) {
//        dispatch_sync(q, ^{
//            NSLog(@"全局同步%d --- %@",i,[NSThread currentThread]);
//        });
//    }
}

#pragma mark - 主队列
//主队列中的操作都应该在主线程上顺序执行的，不存在异步的概念
//主队列中添加的同步操作永远不会被执行，会死锁
- (void)test6 {
    dispatch_queue_t q = dispatch_get_main_queue();
    for (int i=0; i<10; i++) {
        dispatch_async(q, ^{
           NSLog(@"主队列同步%d --- %@",i,[NSThread currentThread]);
        });
    }
//    dispatch_sync(q, ^{
//        NSLog(@"主队列执行同步操作，会死锁");
//    });
}

#pragma mark - NSOperation
#pragma mark - NSOInvokeOperation
- (void)test7 {
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invokeAction:) object:@"hello"];
    NSInvocationOperation *op2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invokeAction:) object:@"hello"];
    [self.queue addOperation:op];
    [self.queue addOperation:op2];
}

- (void)invokeAction:(id)obj {
    NSLog(@"%@",[NSThread currentThread]);
}

#pragma mark - NSBlockOperation
- (void)test8 {
    [self.queue setMaxConcurrentOperationCount:2];
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"do1--%@",[NSThread currentThread]);
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"do2--%@",[NSThread currentThread]);
    }];
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"do3--%@",[NSThread currentThread]);
    }];
    NSBlockOperation *op4 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"do4--%@",[NSThread currentThread]);
    }];
    [op4 addDependency:op3];
    [op3 addDependency:op2];
    [op2 addDependency:op1];
    [self.queue addOperation:op1];
    [self.queue addOperation:op2];
    [self.queue addOperation:op3];
    [self.queue addOperation:op4];
}

@end



















