//
//  BTDelegates.m
//  BTDelegates
//
//  Created by britayin on 2017/12/27.
//  Copyright © 2017年 britayin. All rights reserved.
//

#import "BTDelegates.h"

@interface BTDelegateValue : NSObject

@property (nonatomic, weak) id delegate;
@property (atomic, assign) BOOL deleted;

@end

@implementation BTDelegateValue

+ (BTDelegateValue *)delegateValue:(id)delegate
{
    BTDelegateValue * __autoreleasing value = [BTDelegateValue new];
    value.delegate = delegate;
    return value;
}

- (id)delegate
{
    if (self.deleted) {
        return nil;
    }
    return _delegate;
}

- (void)delete
{
    self.deleted = YES;
}

@end

@interface BTDelegates ()

@property (nonatomic, strong) NSMutableArray<BTDelegateValue *> *delegates;
@property (nonatomic, assign) BOOL needClean;

@end

@implementation BTDelegates

+ (id)delegates
{
    BTDelegates * __autoreleasing delegates = [BTDelegates new];
    return delegates;
}

- (void)dealloc
{
    self.delegates = nil;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.delegates = [NSMutableArray array];
        self.needClean = NO;
    }
    return self;
}

- (id)getDelegateAtIndex:(NSUInteger)index
{
    if (index >= self.delegates.count) {
        return nil;
    }
    BTDelegateValue *value = self.delegates[index];
    return value.delegate;
}

- (void)addDelegate:(id)delegate
{
    for (NSUInteger i = 0; i < self.delegates.count; i++) {
        id tDelegate = [self getDelegateAtIndex:i];
        if (tDelegate) {
            if (tDelegate == delegate) {
                return;
            }
        }else{
            self.needClean = YES;
        }
    }
    
    [self.delegates addObject:[BTDelegateValue delegateValue:delegate]];
    
    [self checkNeedClean];
}

- (void)removeDelegate:(id)delegate
{
    for (NSUInteger i = 0; i < self.delegates.count; i++) {
        BTDelegateValue *value = [self.delegates objectAtIndex:i];
        id tDelegate = value.delegate;
        if (tDelegate) {
            if (tDelegate == delegate) {
                [value delete];
                break;
            }
        }else{
            self.needClean = YES;
        }
    }
    
    [self checkNeedClean];
}

- (void)removeAllDelegates
{
    for (NSUInteger i = 0; i < self.delegates.count; i++) {
        BTDelegateValue *value = self.delegates[i];
        [value delete];
    }
    
    [self checkNeedClean];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    for (NSUInteger i = 0; i < self.delegates.count; i++) {
        id tDelegate = [self getDelegateAtIndex:i];
        if (tDelegate) {
            if ([tDelegate respondsToSelector:anInvocation.selector]) {
                [anInvocation invokeWithTarget:tDelegate];
            }
        }else{
            self.needClean = YES;
        }
    }
    
    [self checkNeedClean];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    BOOL result = NO;
        
    for (NSUInteger i = 0; i < self.delegates.count; i++) {
        id tDelegate = [self getDelegateAtIndex:i];
        if (tDelegate) {
            if ([tDelegate respondsToSelector:aSelector]) {
                result = YES;
                break;
            }
        }else{
            self.needClean = YES;
        }
    }
    
    return result;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    __block NSMethodSignature *sig = [super methodSignatureForSelector:aSelector];
    if(sig) return sig;
    
    for (NSUInteger i = 0; i < self.delegates.count; i++) {
        NSObject *tDelegate = [self getDelegateAtIndex:i];
        if (tDelegate) {
            NSMethodSignature *tSig = [tDelegate.class instanceMethodSignatureForSelector:aSelector];
            if(tSig) {
                sig = tSig;
                break;
            }
        }else{
            self.needClean = YES;
        }
    }
    
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
    
    [self performSelectorOnMainThread:@selector(cleanDeletedDelegates) withObject:nil waitUntilDone:NO];
}

- (void)cleanDeletedDelegates
{
    for (NSUInteger i = 0; i < self.delegates.count; i++) {
        id tDelegate = [self getDelegateAtIndex:i];
        if (!tDelegate) {
            [self.delegates removeObjectAtIndex:i];
        }
    }
    self.needClean = NO;
}


@end
