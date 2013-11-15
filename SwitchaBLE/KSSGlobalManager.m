//
//  KSSGlobalManager.m
//  SwitchaBLE
//
//  Created by Andrew Branch on 11/14/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import "KSSGlobalManager.h"

@implementation KSSGlobalManager

#pragma mark Singleton Methods

+ (KSSGlobalManager *)sharedManager {
    static KSSGlobalManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

//- (id)init {
//    if (self = [super init]) {
//        //lightStateUUID = [[NSString alloc] initWithString:@"Default Property Value"];
//    }
//    return self;
//}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end