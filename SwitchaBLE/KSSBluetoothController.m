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
@end

@interface CBPeripheral (KSSDevice)
@property Device *device;
@property NSDictionary *advertisementInfo;
@property NSString *temperature; //TODO remove these
@end


@implementation KSSBluetoothController

@synthesize connectedPeripherals;

- (KSSBluetoothController *)initWithDelegate:(id)delegate {
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.delegate = delegate;
    connectedPeripherals = [[NSMutableArray alloc] init];
    return self;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBCentralManagerStatePoweredOn) {
        NSMutableArray *supportedServices = [[NSMutableArray alloc] init];
        NSArray *serviceStrings = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SupportedServiceUUIDs" ofType:@"plist"]];
        [serviceStrings enumerateObjectsUsingBlock:^(NSString *service, NSUInteger i, BOOL *stop) {
            [supportedServices addObject:[CBUUID UUIDWithString:service]];
        }];
        self.supportedServices = [NSArray arrayWithArray:supportedServices];
        [self.manager scanForPeripheralsWithServices:supportedServices options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    if (![connectedPeripherals containsObject:peripheral]) {
        [self.manager stopScan];
        [connectedPeripherals addObject:peripheral];
        //peripheral.advertisementInfo = advertisementData;
        [self.manager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES}];
        [self.manager scanForPeripheralsWithServices:self.supportedServices options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    peripheral.delegate = self;
    [peripheral discoverServices:self.supportedServices];
    [self.delegate bluetoothController:self didConnectToPeripheral:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    [connectedPeripherals removeObject:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [connectedPeripherals removeObject:peripheral];
    [self.delegate bluetoothController:self didDisconnectFromPeripheral:peripheral];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering service: %@", [error localizedDescription]);
        //[self cleanup];
        return;
    }
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]]) { //Device Information
            
        }
    }
}

- (void)refreshPeripheralListCompletion:(KSSBluetoothRefreshedResult)completion {
    
}

- (void)stopScan {
    [self.manager stopScan];
}

@end
