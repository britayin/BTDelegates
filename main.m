//
//  main.m
//  BTDelegates
//
//  Created by britayin on 2017/12/27.
//  Copyright © 2017年 britayin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Pet.h"
#import "Host.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        Host *host = [[Host alloc] init];
        
        Pet *dog = [[Pet alloc] initWithName:@"Wang! Wang!"];
        Pet *cat = [[Pet alloc] initWithName:@"Miao~ Miao~"];
        
        //add more than one delegate. weak pointer. Usually you don't have to remove it manually.
        [host.delegates addDelegate:dog];
        [host.delegates addDelegate:cat];
        
        [host goOut];
        
        //You can remove delegate manually. Usually you don't have to remove it manually.
        [host.delegates removeDelegate:dog];
        
        [host goHome];
        
    }
    return 0;
}
