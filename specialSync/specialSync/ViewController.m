//
//  ViewController.m
//  specialSync
//
//  Created by charles on 2017/4/27.
//  Copyright © 2017年 charles. All rights reserved.
//

#import "ViewController.h"
#import <pthread.h>
#import <libkern/OSAtomic.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [self nomal];
//    [self useNested];
//    [self usePthred];
//    [self useResursive];//递归锁,本质没有起到作用
//    [self useOSSpinLock];
//    [self useGCDSingle];
//    [self useGCDSuspendAndResume];
    [self useOperationQueue];
    
}

-(void)nomal{
    [self doSomeThingForFlag:1 finish:nil];
    
    [self doSomeThingForFlag:2 finish:nil];
    
    [self doSomeThingForFlag:3 finish:nil];
    
    [self doSomeThingForFlag:4 finish:nil];
}

/**
 逻辑嵌套
 */
-(void)useNested{
    __weak typeof(self)weakSelf = self;
    [self doSomeThingForFlag:1 finish:^{
        
        [weakSelf doSomeThingForFlag:2 finish:^{
            
            [weakSelf doSomeThingForFlag:3 finish:^{
                
                [weakSelf doSomeThingForFlag:4 finish:nil];
            }];
        }];
    }];
}

/**
 pthread_mutex 互斥锁
 */
-(void)usePthred{
    static pthread_mutex_t pLock;
    pthread_mutex_init(&pLock, NULL);
    
    pthread_mutex_lock(&pLock);
    NSLog(@"1上锁");
    [self doSomeThingForFlag:1 finish:^{
        NSLog(@"1解锁");
        pthread_mutex_unlock(&pLock);
    }];
    
    pthread_mutex_lock(&pLock);
    NSLog(@"2上锁");
    [self doSomeThingForFlag:2 finish:^{
        NSLog(@"2解锁");
        pthread_mutex_unlock(&pLock);
    }];
    
    pthread_mutex_lock(&pLock);
    NSLog(@"3上锁");
    [self doSomeThingForFlag:3 finish:^{
        NSLog(@"3解锁");
        pthread_mutex_unlock(&pLock);
    }];
    
    pthread_mutex_lock(&pLock);
    NSLog(@"4上锁");
    [self doSomeThingForFlag:4 finish:^{
        NSLog(@"4解锁");
        pthread_mutex_unlock(&pLock);
    }];
}

/**
 pthread_mutex(recursive) NSRecursiveLock synchronized 递归锁
 */
-(void)useResursive{
      //pthread_mutex(recursive)
    
//    static pthread_mutex_t pLock;
//    pthread_mutexattr_t attr;
//    pthread_mutexattr_init(&attr); //初始化attr并且给它赋予默认
//    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE); //设置锁类型，这边是设置为递归锁
//    pthread_mutex_init(&pLock, &attr);
//    pthread_mutexattr_destroy(&attr); //销毁一个属性对象，在重新进行初始化之前该结构不能重新使用
//    
//    static void (^RecursiveBlock)(int);
//    __weak typeof(self)weakSelf = self;
//    RecursiveBlock = ^(int value) {
//        pthread_mutex_lock(&pLock);
//        if (value>0) {
//            [weakSelf doSomeThingForFlag:5-value finish:nil];
//            RecursiveBlock(value-1);
//        }
//        pthread_mutex_unlock(&pLock);
//    };
//    RecursiveBlock(4);
    
    
    
      //NSRecursiveLock (NSLock)
    
//    NSRecursiveLock *lock = [[NSRecursiveLock alloc]init];
//    
//    static void (^RecursiveBlock)(int);
//    __weak typeof(self)weakSelf = self;
//    RecursiveBlock = ^(int value) {
//        [lock lock];
//        if (value>0) {
//            [weakSelf doSomeThingForFlag:5-value finish:nil];
//            RecursiveBlock(value-1);
//        }
//        [lock unlock];
//    };
//    RecursiveBlock(4);
    
    //@synchronized
//    static void (^RecursiveBlock)(int);
//    __weak typeof(self)weakSelf = self;
//    RecursiveBlock = ^(int value) {
//        @synchronized (weakSelf) {
//            if (value>0) {
//                [weakSelf doSomeThingForFlag:5-value finish:nil];
//                RecursiveBlock(value-1);
//            }
//        }
//    };
//    RecursiveBlock(4);
}




/**
 OSSpinLock 自旋锁
 */
-(void)useOSSpinLock{
    __block OSSpinLock oslock = OS_SPINLOCK_INIT;
    
    OSSpinLockLock(&oslock);
    NSLog(@"1上锁");
    [self doSomeThingForFlag:1 finish:^{
        NSLog(@"1解锁");
        OSSpinLockUnlock(&oslock);
    }];
    
    OSSpinLockLock(&oslock);
    NSLog(@"2上锁");
    [self doSomeThingForFlag:2 finish:^{
        NSLog(@"2解锁");
        OSSpinLockUnlock(&oslock);
    }];
    
    
    OSSpinLockLock(&oslock);
    NSLog(@"3上锁");
    [self doSomeThingForFlag:3 finish:^{
        NSLog(@"3解锁");
        OSSpinLockUnlock(&oslock);
    }];
    
    OSSpinLockLock(&oslock);
    NSLog(@"4上锁");
    [self doSomeThingForFlag:4 finish:^{
        NSLog(@"4解锁");
        OSSpinLockUnlock(&oslock);
    }];
}

/**
 GCD single
 */
-(void)useGCDSingle{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"1阻塞线程");
    [self doSomeThingForFlag:1 finish:^{
        NSLog(@"1释放线程");
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"2阻塞线程");
    [self doSomeThingForFlag:2 finish:^{
        NSLog(@"2释放线程");
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"3阻塞线程");
    [self doSomeThingForFlag:3 finish:^ {
        NSLog(@"3释放线程");
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"4阻塞线程");
    [self doSomeThingForFlag:4 finish:^{
        NSLog(@"4释放线程");
        dispatch_semaphore_signal(semaphore);
    }];
}


/**
 GCD队列的暂停和恢复
 */
-(void)useGCDSuspendAndResume{
    dispatch_queue_t myqueue = dispatch_queue_create("com.charles.queue", NULL);
    
    dispatch_async(myqueue, ^{
        dispatch_suspend(myqueue);
        [self doSomeThingForFlag:1 finish:^(NSInteger flag) {
            dispatch_resume(myqueue);
        }];
    });
    
    dispatch_async(myqueue, ^{
        dispatch_suspend(myqueue);
        [self doSomeThingForFlag:2 finish:^(NSInteger flag) {
            dispatch_resume(myqueue);
        }];
    });
    
    dispatch_async(myqueue, ^{
        dispatch_suspend(myqueue);
        [self doSomeThingForFlag:3 finish:^(NSInteger flag) {
            dispatch_resume(myqueue);
        }];
    });
    
    dispatch_async(myqueue, ^{
        dispatch_suspend(myqueue);
        [self doSomeThingForFlag:4 finish:^(NSInteger flag) {
            dispatch_resume(myqueue);
        }];
    });
}


/**
 operationQueue的暂停和恢复
 */
-(void)useOperationQueue{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:1];
    
    __weak typeof(self)weakSelf = self;
    NSBlockOperation * operation1 = [NSBlockOperation blockOperationWithBlock:^{
        [queue setSuspended:YES];
        [weakSelf doSomeThingForFlag:1 finish:^(NSInteger flag) {
            [queue setSuspended:NO];
        }];
    }];
    
    NSBlockOperation * operation2 = [NSBlockOperation blockOperationWithBlock:^{
        [queue setSuspended:YES];
        [weakSelf doSomeThingForFlag:2 finish:^(NSInteger flag) {
            [queue setSuspended:NO];
        }];
    }];
    
    NSBlockOperation * operation3 = [NSBlockOperation blockOperationWithBlock:^{
        [queue setSuspended:YES];
        [weakSelf doSomeThingForFlag:3 finish:^(NSInteger flag) {
            [queue setSuspended:NO];
        }];
    }];
    
    NSBlockOperation * operation4 = [NSBlockOperation blockOperationWithBlock:^{
        [queue setSuspended:YES];
        [weakSelf doSomeThingForFlag:4 finish:^(NSInteger flag) {
            [queue setSuspended:NO];
        }];
    }];
    
    [operation4 addDependency:operation3];
    [operation3 addDependency:operation2];
    [operation2 addDependency:operation1];
    
    [queue addOperation:operation1];
    [queue addOperation:operation2];
    [queue addOperation:operation3];
    [queue addOperation:operation4];
}


-(void)doSomeThingForFlag:(NSInteger)flag finish:(void(^)())finshed{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"do:%ld",(long)flag);
        sleep(2+arc4random_uniform(4));
        NSLog(@"finish:%ld",(long)flag);
        if (finshed) {
            finshed();
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
