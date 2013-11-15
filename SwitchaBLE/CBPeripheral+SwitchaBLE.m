//
//  CBPeripheral+CBPeripheral_SwitchaBLE.m
//  SwitchaBLE
//
//  Created by Andrew Branch on 11/14/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import "CBPeripheral+SwitchaBLE.h"
#import "KSSGlobalManager.h"

@implementation CBPeripheral (SwitchaBLE)

- (CBCharacteristic *)lightCharacteristic {
    
    // TODO get rid of the literal uuids
    NSInteger serviceIndex = [self.services indexOfObjectPassingTest:^BOOL(CBService *svc, NSUInteger idx, BOOL *stop) {
        return [svc.UUID isEqual:[KSSGlobalManager sharedManager].serviceUUID];
    }];
    
    if (serviceIndex != NSNotFound) {
        CBService *service = [self.services objectAtIndex:serviceIndex];
        
        NSInteger characteristicIndex = [service.characteristics indexOfObjectPassingTest:^BOOL(CBCharacteristic *c, NSUInteger idx, BOOL *stop) {
            return [c.UUID isEqual:[KSSGlobalManager sharedManager].lightStateUUID];
        }];
        
        if (characteristicIndex != NSNotFound) {
            return [service.characteristics objectAtIndex:characteristicIndex];
        }
    }
    
    return nil;
}

@end