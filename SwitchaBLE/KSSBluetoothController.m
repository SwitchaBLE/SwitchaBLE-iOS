//
//  KSSBluetoothDelegate.m
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/24/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import "KSSBluetoothController.h"
#import "Device.h"
#import "CBPeripheral+SwitchaBLE.h"
#import "NSArray+Map.h"
#import "KSSGlobalManager.h"

@interface KSSBluetoothController ()
@property NSArray *supportedServices;
@property NSMutableArray *SERVICE_UUIDS;
@property CBUUID *SWITCHABLE_BASE;
@property CBUUID *LIGHTSTATE;
@property CBUUID *TEST_NOTIFY;
@end


@implementation KSSBluetoothController

@synthesize connectedPeripherals;
@synthesize SWITCHABLE_BASE;
@synthesize LIGHTSTATE;
@synthesize SERVICE_UUIDS;
@synthesize TEST_NOTIFY;

- (KSSBluetoothController *)init {
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionRestoreIdentifierKey: @"switchableCentralManager"}];
    connectedPeripherals = [[NSMutableArray alloc] init];
    
    ON = [NSData dataWithBytes:(const unsigned char[]){ LightStateOn } length:1];
    OFF = [NSData dataWithBytes:(const unsigned char[]){ LightStateOff } length:1];
    TOGGLE = [NSData dataWithBytes:(const unsigned char[]) {LightStateToggle } length:1];
    PULSE = [NSData dataWithBytes:(const unsigned char[]) { LightStatePulse } length:1];
    STROBE = [NSData dataWithBytes:(const unsigned char[]) { LightStateStrobe } length:1];
    
    return self;
    return self;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBCentralManagerStatePoweredOn) {
        NSMutableArray *supportedServices = [[NSMutableArray alloc] init];
        NSDictionary *uuids = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UUIDs" ofType:@"plist"]];
        [[uuids objectForKey:@"SupportedServices"] enumerateObjectsUsingBlock:^(NSDictionary *service, NSUInteger i, BOOL *stop) {
            [supportedServices addObject:service];
            if ([[service objectForKey:@"Name"] isEqual:@"SwitchaBLE Base"]) {
                SWITCHABLE_BASE = [CBUUID UUIDWithString:[service objectForKey:@"UUID"]];
                LIGHTSTATE = [CBUUID UUIDWithString:[(NSDictionary *)[service objectForKey:@"CharacteristicUUIDs"] objectForKey:@"LightState"]];
                TEST_NOTIFY = [CBUUID UUIDWithString:[(NSDictionary *)[service objectForKey:@"CharacteristicUUIDs"] objectForKey:@"TestNotify"]];
                [KSSGlobalManager sharedManager].serviceUUID = SWITCHABLE_BASE;
                [KSSGlobalManager sharedManager].lightStateUUID = LIGHTSTATE;
            }
        }];
        self.supportedServices = [NSArray arrayWithArray:supportedServices];
        for (NSDictionary *service in self.supportedServices) {
            [SERVICE_UUIDS addObject:[CBUUID UUIDWithString:[service objectForKey:@"UUID"]]];
        }
        [central scanForPeripheralsWithServices:SERVICE_UUIDS options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)state {
    NSArray *peripherals = state[CBCentralManagerRestoredStatePeripheralsKey];
    for (CBPeripheral *peripheral in peripherals) {
        [central connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES}];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    if (![connectedPeripherals containsObject:peripheral]) {
        [central stopScan];
        [connectedPeripherals addObject:peripheral];
        [central connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES}];
        [central scanForPeripheralsWithServices:SERVICE_UUIDS options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    peripheral.delegate = self;
    [peripheral readRSSI];
    [peripheral discoverServices:SERVICE_UUIDS];
    [self.deviceListDelegate bluetoothController:self didConnectToPeripheral:peripheral];
    [self.deviceDelegate bluetoothController:self didConnectToPeripheral:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    [connectedPeripherals removeObject:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [connectedPeripherals removeObject:peripheral];
    [self.deviceListDelegate bluetoothController:self didDisconnectFromPeripheral:peripheral];
    [self.deviceDelegate bluetoothController:self didDisconnectFromPeripheral:peripheral];
    [central connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES}];
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        //TODO handle error
        return;
    }
    for (int i = 0; i < peripheral.services.count; i++) {
        CBService *service = [peripheral.services objectAtIndex:i];
        NSLog(@"found service");
        if ([service.UUID isEqual:SWITCHABLE_BASE]) {
            NSArray *characteristics;
            for (NSDictionary *service in self.supportedServices) {
                if ([[service objectForKey:@"Name"] isEqualToString:@"SwitchaBLE Base"]) {
                    characteristics = [[[service objectForKey:@"CharacteristicUUIDs"] allValues] mapObjectsUsingBlock:^id(NSString *uuid, NSUInteger idx) {
                        return [CBUUID UUIDWithString:uuid];
                    }];
                }
            }
            [peripheral discoverCharacteristics:characteristics forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        //TODO handle error
    } else if ([service.UUID isEqual:SWITCHABLE_BASE]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:LIGHTSTATE]) {
                [peripheral readValueForCharacteristic:characteristic];
            } else if ([characteristic.UUID isEqual:TEST_NOTIFY]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error changing notification state: %@", [error localizedDescription]);
    } else {
        [peripheral readValueForCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error receiving update of characteristic: %@", [error localizedDescription]);
        //TODO handle error
    } else if ([characteristic.UUID isEqual:TEST_NOTIFY]) {
        // Not sure if we need to do something here or not
    }
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    if (error) {
        NSLog(@"Error receiving update of RSSI: %@", [error localizedDescription]);
    } else {
        [self.deviceDelegate bluetoothController:self didUpdateRSSIForPeripheral:peripheral];
    }
}

- (NSTimer *)startPollingRSSIForPeripheral:(CBPeripheral *)peripheral {
    NSTimer *rssiTimer;
    [rssiTimer invalidate];
    rssiTimer = [NSTimer timerWithTimeInterval:1.0 target:peripheral selector:@selector(readRSSI) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:rssiTimer forMode:NSRunLoopCommonModes];
    return rssiTimer;
}

- (void)stopPollingRSSIOnTimer:(NSTimer *)timer {
    [timer invalidate];
}

// NEEDS TO BE TESTED
- (void)turnLightOnForPeripheral:(CBPeripheral *)peripheral {
    [peripheral writeValue:ON forCharacteristic:peripheral.lightCharacteristic type:CBCharacteristicWriteWithResponse];
}

// NEEDS TO BE TESTED
- (void)turnLightOffForPeripheral:(CBPeripheral *)peripheral {
    [peripheral writeValue:OFF forCharacteristic:peripheral.lightCharacteristic type:CBCharacteristicWriteWithResponse];
}

// NEEDS TO BE TESTED
- (void)toggleLightForPeripheral:(CBPeripheral *)peripheral {
    [peripheral writeValue:TOGGLE forCharacteristic:peripheral.lightCharacteristic type:CBCharacteristicWriteWithResponse];
}

// NEEDS TO BE TESTED
- (void)startPulsingLightForPeripheral:(CBPeripheral *)peripheral {
    [peripheral writeValue:PULSE forCharacteristic:peripheral.lightCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)stopScan {
    [self.manager stopScan];
}

@end
