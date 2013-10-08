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
- (void)peripheral:(CBPeripheral *)peripheral didGetTemperatureCharacteristic:(CBCharacteristic *)characteristic;
@end

@interface KSSBluetoothController : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong, retain) NSMutableArray *connectedPeripherals;
@property (nonatomic, weak) id <KSSBluetoothDeviceListDelegate> deviceListDelegate;
@property (nonatomic, weak) id <KSSBluetoothDeviceDelegate> deviceDelegate;
@property (readonly) NSArray *supportedServices;

- (KSSBluetoothController *)initWithDeviceListDelegate:(id)delegate;
- (void)refreshPeripheralListCompletion:(KSSBluetoothRefreshedResult)completion;
- (void)getTemperatureCharacteristicForPeripheral:(CBPeripheral *)peripheral deviceDelegate:(id)delegate;
- (void)stopScan;

@end
