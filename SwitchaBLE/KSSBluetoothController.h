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

typedef NS_OPTIONS(NSInteger, LightState) {
    LightStateOff    = 0,
    LightStateOn     = 1 << 0,
    LightStateToggle = 1 << 1,
    LightStatePulse  = 1 << 2,
    LightStateStrobe = 1 << 3
};

@interface KSSBluetoothController : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate> {
    NSData *ON;
    NSData *OFF;
    NSData *TOGGLE;
    NSData *PULSE;
    NSData *STROBE;
}

@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong, retain) NSMutableArray *connectedPeripherals;
@property (nonatomic, weak) id <KSSBluetoothDeviceListDelegate> deviceListDelegate;
@property (nonatomic, weak) id <KSSBluetoothDeviceDelegate> deviceDelegate;
@property (readonly) NSArray *supportedServices;
@property (readonly) CBUUID *SWITCHABLE_BASE;


- (NSTimer *)startPollingRSSIForPeripheral:(CBPeripheral *)peripheral;
- (void)stopPollingRSSIOnTimer:(NSTimer *)timer;
- (void)turnLightOnForPeripheral:(CBPeripheral *)peripheral;
- (void)turnLightOffForPeripheral:(CBPeripheral *)peripheral;
- (void)toggleLightForPeripheral:(CBPeripheral *)peripheral;
- (void)startPulsingLightForPeripheral:(CBPeripheral *)peripheral;
- (void)stopScan;

@end
