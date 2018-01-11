//
//  Host.m
//  BTDelegates
//
//  Created by britayin on 2018/1/11.
//  Copyright © 2018年 britayin. All rights reserved.
//

#import "Host.h"

@implementation Host

- (instancetype)init
{
    if (self = [super init]) {
        // The new way. You need to init the delegates.
        self.delegates = [BTDelegates<HostDelegate> new];
        
    }
    return self;
}

- (void)goHome
{
    NSLog(@"Hi, I'm back!");
    
    // The old way. You need to check if it's available.
    if ([self.delegate respondsToSelector:@selector(onHostReturnHome:)]) {
        [self.delegate onHostReturnHome:self];
    }
    
    // The new way. You need not to check. Call directly.
    [self.delegates onHostReturnHome:self];
}

- (void)goOut
{
    NSLog(@"Goodbye, I'm going out.");
    
    // The old way. You need to check if it's available.
    if ([self.delegate respondsToSelector:@selector(onHostGoOut:)]) {
        [self.delegate onHostGoOut:self];
    }
    
    // The new way. You need not to check. Call directly.
    [self.delegates onHostGoOut:self];
}

@end
