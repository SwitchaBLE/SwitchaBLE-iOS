//
//  CBPeripheral+CBPeripheral_SwitchaBLE.h
//  SwitchaBLE
//
//  Created by Andrew Branch on 11/14/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (SwitchaBLE)

@property (readonly) CBCharacteristic *lightCharacteristic;

- (CBCharacteristic *)lightCharacteristic;

@end
