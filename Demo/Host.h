//
//  Host.h
//  BTDelegates
//
//  Created by britayin on 2018/1/11.
//  Copyright © 2018年 britayin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTDelegates.h"
@class Pet;
@class Host;

@protocol HostDelegate <NSObject>

- (Pet *)onHostReturnHome:(Host *)host;
- (Pet *)onHostGoOut:(Host *)host;

@end

@interface Host : NSObject

@property (nonatomic, weak) id<HostDelegate> delegate;  // The old way. weak pointer. Support only one delegate.

@property (nonatomic, strong) BTDelegates<HostDelegate> *delegates; // The new way. strong pointer. Support more than one delegate.

- (void)goHome;

- (void)goOut;

@end
