//
//  BTDelegates.m
//  BTDelegates
//
//  Created by britayin on 2017/12/27.
//  Copyright © 2017年 britayin. All rights reserved.
//

#import "BTDelegates.h"

@interface BTDelegates ()

@property (nonatomic, strong) NSPointerArray *delegates;
@property (nonatomic, strong) dispatch_queue_t syncQueue;
@property (nonatomic, assign) BOOL needClean;

@end

@implementation BTDelegates

- (void)dealloc
{
    if (self.syncQueue) {
        self.syncQueue = nil;
    }
    
    self.delegates = nil;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.delegates = [NSPointerArray weakObjectsPointerArray];
        NSString* uuid = [NSString stringWithFormat:@"com.z28j.array_%p", self];
        self.syncQueue = dispatch_queue_create([uuid UTF8String], DISPATCH_QUEUE_CONCURRENT);
        self.needClean = NO;
    }
    return self;
}

- (void)addDelegate:(id)delegate
{
    __weak typeof(self) weakSelf = self;
    dispatch_barrier_async(self.syncQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        for (NSUInteger i = 0; i < strongSelf.delegates.count; i++) {
            id tDelegate = [strongSelf.delegates pointerAtIndex:i];
            if (tDelegate) {
                if (tDelegate == delegate) {
                    return;
                }
            }else{
                self.needClean = YES;
            }
        }
        
        [strongSelf.delegates addPointer:(__bridge void *)(delegate)];
        
        [strongSelf checkNeedClean];
    });
}

- (void)removeDelegate:(id)delegate
{
    __weak typeof(self) weakSelf = self;
    dispatch_barrier_async(self.syncQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        for (NSUInteger i = 0; i < strongSelf.delegates.count; i++) {
            id tDelegate = [strongSelf.delegates pointerAtIndex:i];
            if (tDelegate) {
                if (tDelegate == delegate) {
                    [strongSelf.delegates removePointerAtIndex:i];
                    break;
                }
            }else{
                strongSelf.needClean = YES;
            }
        }
        
        [strongSelf checkNeedClean];
    });
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    __weak typeof(self) weakSelf = self;
    dispatch_sync(_syncQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        for (NSUInteger i = 0; i < strongSelf.delegates.count; i++) {
            id tDelegate = [strongSelf.delegates pointerAtIndex:i];
            if (tDelegate) {
                if ([tDelegate respondsToSelector:anInvocation.selector]) {
                    [anInvocation invokeWithTarget:tDelegate];
                }
            }else{
                strongSelf.needClean = YES;
            }
        }
        
        [strongSelf checkNeedClean];
    });
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    __block BOOL result = NO;
    __weak typeof(self) weakSelf = self;
    dispatch_sync(_syncQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        for (NSUInteger i = 0; i < strongSelf.delegates.count; i++) {
            id tDelegate = [strongSelf.delegates pointerAtIndex:i];
            if (tDelegate) {
                if ([tDelegate respondsToSelector:aSelector]) {
                    result = YES;
                    break;
                }
            }else{
                strongSelf.needClean = YES;
            }
        }
    });
    return result;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    __block NSMethodSignature *sig = [super methodSignatureForSelector:aSelector];
    if(sig) return sig;
    
    __weak typeof(self) weakSelf = self;
    dispatch_sync(_syncQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        for (NSUInteger i = 0; i < strongSelf.delegates.count; i++) {
            NSObject *tDelegate = [strongSelf.delegates pointerAtIndex:i];
            if (tDelegate) {
                NSMethodSignature *tSig = [tDelegate.class instanceMethodSignatureForSelector:aSelector];
                if(tSig) {
                    sig = tSig;
                    break;
                }
            }else{
                strongSelf.needClean = YES;
            }
        }
    });
    
    //return a blank method sig to avoid crash
    return [BTDelegates instanceMethodSignatureForSelector:@selector(blankCall)];
}

- (void)blankCall{}

- (void)checkNeedClean
{
    if (!self.needClean) {
        return;
    }
    
    self.needClean = NO;
    
    [self performSelector:@selector(cleanInvalidObserver) withObject:nil afterDelay:0.2];
}

- (void)cleanInvalidObserver
{
    __weak typeof(self) weakSelf = self;
    dispatch_barrier_async(self.syncQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        for (NSUInteger i = 0; i < strongSelf.delegates.count; i++) {
            id tDelegate = [strongSelf.delegates pointerAtIndex:i];
            if (!tDelegate) {
                [strongSelf.delegates removePointerAtIndex:i];
            }
        }
        strongSelf.needClean = NO;
    });
}


@end
