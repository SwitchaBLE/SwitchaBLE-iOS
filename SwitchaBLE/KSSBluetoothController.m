//
//  KSSBluetoothDelegate.m
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/24/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import "KSSBluetoothController.h"
#import "Device.h"

@interface KSSBluetoothController ()
@property NSArray *supportedServices;
@property NSMutableArray *SERVICE_UUIDS;
@property NSData *ON;
@property NSData *OFF;
@property CBUUID *SWITCHABLE_BASE;
@property CBUUID *LIGHTSTATE;
@end

@interface NSArray (Map)
- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block;
@end

@implementation NSArray (Map)
- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:block(obj, idx)];
    }];
    return result;
}
@end

@interface CBPeripheral (SwitchaBLE)
@property (readonly) CBCharacteristic *lightCharacteristic;
 - (CBCharacteristic *)lightCharacteristic;
@end

@implementation CBPeripheral (SwitchaBLE)

- (CBCharacteristic *)lightCharacteristic {
    
    // TODO get rid of the literal uuids
    NSInteger serviceIndex = [self.services indexOfObjectPassingTest:^BOOL(CBService *svc, NSUInteger idx, BOOL *stop) {
        return [svc.UUID isEqual:[CBUUID UUIDWithString:@"00006D59-1B47-929D-0D37-09FB5CE1C126"]];
    }];
    
    if (serviceIndex != NSNotFound) {
        CBService *service = [self.services objectAtIndex:serviceIndex];
        
        NSInteger characteristicIndex = [service.characteristics indexOfObjectPassingTest:^BOOL(CBCharacteristic *c, NSUInteger idx, BOOL *stop) {
            return [c.UUID isEqual:[CBUUID UUIDWithString:@"00006D5A-1B47-929D-0D37-09FB5CE1C126"]];
        }];
        
        if (characteristicIndex != NSNotFound) {
            return [service.characteristics objectAtIndex:characteristicIndex];
        }
    }
    
    return nil;
}

@end


@implementation KSSBluetoothController

@synthesize connectedPeripherals;
@synthesize ON;
@synthesize OFF;
@synthesize SWITCHABLE_BASE;
@synthesize LIGHTSTATE;
@synthesize SERVICE_UUIDS;

- (KSSBluetoothController *)initWithDeviceListDelegate:(id <KSSBluetoothDeviceListDelegate>)delegate {
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.deviceListDelegate = delegate;
    connectedPeripherals = [[NSMutableArray alloc] init];
    
    const unsigned char zero[] = { 0x00 };
    const unsigned char one[] = { 0x01 };
    ON = [NSData dataWithBytes:zero length:1];
    OFF = [NSData dataWithBytes:one length:1];
    
    return self;
}

- (void)refreshWithDeviceListDelegate:(id <KSSBluetoothDeviceListDelegate>)delegate {
    self.deviceListDelegate = delegate;
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
            }
        }];
        self.supportedServices = [NSArray arrayWithArray:supportedServices];
        for (NSDictionary *service in self.supportedServices) {
            [SERVICE_UUIDS addObject:[CBUUID UUIDWithString:[service objectForKey:@"UUID"]]];
        }
        [self.manager scanForPeripheralsWithServices:SERVICE_UUIDS options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    if (![connectedPeripherals containsObject:peripheral]) {
        [self.manager stopScan];
        [connectedPeripherals addObject:peripheral];
        [self.manager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES}];
        [self.manager scanForPeripheralsWithServices:SERVICE_UUIDS options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    peripheral.delegate = self;
    [peripheral discoverServices:SERVICE_UUIDS];
    [self.deviceListDelegate bluetoothController:self didConnectToPeripheral:peripheral];
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
            if ([characteristic.UUID isEqual:LIGHTSTATE] && characteristic.properties & CBCharacteristicPropertyNotify) {
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
    } else if ([characteristic.UUID isEqual:LIGHTSTATE]) {
        // Not sure if we need to do something here or not
    }
}

// NEEDS TO BE TESTED
- (void)toggleLightForPeripheral:(CBPeripheral *)peripheral {
    if (peripheral.lightCharacteristic) {
        BOOL isOn = [peripheral.lightCharacteristic.value isEqualToData:ON];
        [peripheral writeValue:(isOn ? OFF : ON) forCharacteristic:peripheral.lightCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

// NEEDS TO BE TESTED
- (void)identifyPeripheral:(CBPeripheral *)peripheral {
    [self toggleLightForPeripheral:peripheral];
    [self performSelector:@selector(toggleLightForPeripheral:) withObject:peripheral afterDelay:0.2];
}

- (void)stopScan {
    [self.manager stopScan];
}

@end
