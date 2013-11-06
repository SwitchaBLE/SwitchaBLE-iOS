//
//  KSSAppDelegate.h
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/8/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "KSSAlarmsViewController.h"
#import "KSSDevicesViewController.h"
@class KSSDevicesViewController;

@interface KSSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *tempObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) KSSBluetoothController *bluetoothController;
@property KSSAlarmsViewController *alarmsViewController;   // TODO remove these if possible
@property KSSDevicesViewController *devicesViewController; //

- (void)saveContext;
- (void)scheduleAlarm:(Alarm *)alarm;
- (NSMutableArray *)getEntityWithName:(NSString *)name;
- (NSURL *)applicationDocumentsDirectory;

@end
