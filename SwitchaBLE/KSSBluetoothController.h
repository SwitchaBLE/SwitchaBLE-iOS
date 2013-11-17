//
//  KSSBluetoothDelegate.h
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/24/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef void(^KSSBluetoothRefreshedResult)();
@class KSSBluetoothController;

@protocol KSSBluetoothDeviceListDelegate <NSObject>
- (void)bluetoothController:(KSSBluetoothController *)controller didConnectToPeripheral:(CBPeripheral *)peripheral;
- (void)bluetoothController:(KSSBluetoothController *)controller didDisconnectFromPeripheral:(CBPeripheral *)peripheral;
@end

@protocol KSSBluetoothDeviceDelegate <NSObject>
- (void)bluetoothController:(KSSBluetoothController *)controller didConnectToPeripheral:(CBPeripheral *)peripheral;
- (void)bluetoothController:(KSSBluetoothController *)controller didDisconnectFromPeripheral:(CBPeripheral *)peripheral;
- (void)bluetoothController:(KSSBluetoothController *)controller didUpdateRSSIForPeripheral:(CBPeripheral *)peripheral;
@end

@interface KSSBluetoothController : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong, retain) NSMutableArray *connectedPeripherals;
@property (nonatomic, weak) id <KSSBluetoothDeviceListDelegate> deviceListDelegate;
@property (nonatomic, weak) id <KSSBluetoothDeviceDelegate> deviceDelegate;
@property (readonly) NSArray *supportedServices;
@property (readonly) CBUUID *SWITCHABLE_BASE;


- (void)identifyPeripheral:(CBPeripheral *)peripheral;
- (NSTimer *)startPollingRSSIForPeripheral:(CBPeripheral *)peripheral;
- (void)stopPollingRSSIOnTimer:(NSTimer *)timer;
- (void)stopScan;

@end
