//
//  KSSGlobalManager.h
//  SwitchaBLE
//
//  Created by Andrew Branch on 11/14/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


@interface KSSGlobalManager : NSObject

@property (nonatomic, retain) CBUUID *lightStateUUID;
@property (nonatomic, retain) CBUUID *serviceUUID;

+ (KSSGlobalManager *)sharedManager;

@end

