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

@interface KSSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property KSSAlarmsViewController *alarmsViewController;
@property KSSDevicesViewController *devicesViewController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
