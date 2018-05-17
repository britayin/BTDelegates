//
//  BTDelegates.h
//  BTDelegates
//
//  Created by britayin on 2017/12/27.
//  Copyright © 2017年 britayin. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Usage:
 
 BTDelegates<MyDelegate> *delegates = [BTDelegates delegates];
 //BTDelegates<MyDelegate, OherDelegate> is also OK
 
 //you can add more than one delegate
 [delegates addDelegate:obj0];
 [delegates addDelegate:obj1];
 [delegates addDelegate:obj2];
 
 //You can call the function of the protocol. You need not to check. Call directly.
 [delegates callTheFuncOfMyDelegate:sth];
 
 //you can add remove a delegate
 [delegates removeDelegate:obj1];
 
 */
@interface BTDelegates : NSObject

- (void)addDelegate:(id)delegate;
- (void)removeDelegate:(id)delegate;
- (void)removeAllDelegates;

+ (id)delegates;

@end
