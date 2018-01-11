//
//  Pet.m
//  BTDelegates
//
//  Created by britayin on 2018/1/11.
//  Copyright © 2018年 britayin. All rights reserved.
//

#import "Pet.h"
#import "Host.h"

@interface Pet () <HostDelegate>

@property (nonatomic, strong) NSString *name;

@end

@implementation Pet

- (instancetype)initWithName:(NSString *)name
{
    if (self = [super init]) {
        self.name = name;
    }
    return self;
}

#pragma mark - HostDelegate
- (Pet *)onHostGoOut:(Host *)host
{
    NSLog(@"%@", self.name);
    return self;
}

- (Pet *)onHostReturnHome:(Host *)host
{
    NSLog(@"%@", self.name);
    return self;
}

@end
