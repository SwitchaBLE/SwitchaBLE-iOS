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

@protocol KSSBluetoothDelegate <NSObject>

- (void)bluetoothController:(KSSBluetoothController *)controller didConnectToPeripheral:(CBPeripheral *)peripheral;
- (void)bluetoothController:(KSSBluetoothController *)controller didDisconnectFromPeripheral:(CBPeripheral *)peripheral;

@end

@interface KSSBluetoothController : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong, retain) NSMutableArray *connectedPeripherals;
@property (nonatomic, weak) id <KSSBluetoothDelegate> delegate;
@property (readonly) NSArray *supportedServices;

- (KSSBluetoothController *)initWithDelegate:(id)delegate;
- (void)refreshPeripheralListCompletion:(KSSBluetoothRefreshedResult)completion;
- (void)stopScan;

@end
