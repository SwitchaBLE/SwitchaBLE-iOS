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

- (KSSBluetoothController *)initWithDeviceListDelegate:(id)delegate {
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.deviceListDelegate = delegate;
    connectedPeripherals = [[NSMutableArray alloc] init];
    return self;
}

- (void)getTemperatureCharacteristicForPeripheral:(CBPeripheral *)peripheral deviceDelegate:(id)delegate {
    self.deviceDelegate = delegate;
    if (peripheral) {
        [peripheral discoverServices:self.supportedServices];
    }
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
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"1809"]]) { //Health Thermometer
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"2A1C"]] forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        //TODO handle error
        return;
    } else if ([service.UUID isEqual:[CBUUID UUIDWithString:@"1809"]]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A1C"]]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error receiving update of characteristic: %@", [error localizedDescription]);
        //TODO handle error
        return;
    } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A1C"]]) {
        [self.deviceDelegate peripheral:peripheral didGetTemperatureCharacteristic:characteristic];
    }
}

- (void)refreshPeripheralListCompletion:(KSSBluetoothRefreshedResult)completion {
    
}

- (void)stopScan {
    [self.manager stopScan];
}

@end
