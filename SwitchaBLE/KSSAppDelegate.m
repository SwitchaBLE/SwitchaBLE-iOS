//
//  KSSAppDelegate.m
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/8/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import "KSSAppDelegate.h"
#import "UIAlertView+Blocks.h"

@implementation KSSAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize tempObjectContext = _tempObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSMutableArray *alarms = [self getEntityWithName:@"Alarm"];
    
    // Turn off alarm that's going off
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification) {
        [self turnOffAlarmFromNotification:notification usingFetchedAlarms:alarms];
    }
    
    // Reschedule past alarms
    for (Alarm *alarm in alarms) {
        
        if (alarm.time < [NSDate date]) {
            
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            
            NSDateComponents *alarmComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[alarm time]];
            NSDateComponents *nowComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
            
            alarmComponents.year = nowComponents.year;
            alarmComponents.month = nowComponents.month;
            alarmComponents.day = nowComponents.day;
            
            NSDate *newAlarmTime = [calendar dateFromComponents:alarmComponents];
            if ([newAlarmTime compare:[NSDate date]] == NSOrderedAscending) {
                newAlarmTime = [newAlarmTime dateByAddingTimeInterval:60 * 60 * 24 * 1];
            }
            
            alarm.time = newAlarmTime;
        }
    }
    
    [self saveContext];
    
    // Restore Bluetooth State
    if (!self.bluetoothController) {
        self.bluetoothController = [[KSSBluetoothController alloc] init];
    }
    
    return YES;
}

- (Alarm *)turnOffAlarmFromNotification:(UILocalNotification *)notification usingFetchedAlarms:(NSMutableArray *)alarms {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid = %@", [notification.userInfo objectForKey:@"alarmUUID"]];
    Alarm *alarm = [alarms filteredArrayUsingPredicate:predicate].firstObject;
    alarm.isSet = NO;
    alarm.time = [alarm.time dateByAddingTimeInterval:60*60*24];
    [self saveContext];
    return alarm;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    void (^updateSwitch)(void) = ^{
        NSString *uuid = [self turnOffAlarmFromNotification:notification usingFetchedAlarms:[self getEntityWithName:@"Alarm"]].uuid;
        if (self.alarmsViewController) {
            self.alarmsViewController.tabBarController.selectedIndex = 0;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid = %@", uuid];
            Alarm *alarm = [self.alarmsViewController.alarmsArray filteredArrayUsingPredicate:predicate].firstObject;
            [self.alarmsViewController editAlarmController:self didFinishEditingAlarm:alarm];
        }
    };
    
    if (application.applicationState == UIApplicationStateActive) {
        [UIAlertView displayAlertWithTitle:@"Alarm" message:[notification.userInfo objectForKey:@"deviceName"] leftButtonTitle:@"Turn Off" leftButtonAction:updateSwitch rightButtonTitle:nil rightButtonAction:nil];
    } else {
        updateSwitch();
    }
}

- (void)scheduleAlarm:(Alarm *)alarm {
        
    NSArray *scheduledNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    UILocalNotification *notification;
    
    if (scheduledNotifications.count) {
        NSInteger i = [scheduledNotifications indexOfObjectPassingTest:^BOOL(UILocalNotification *n, NSUInteger idx, BOOL *stop) {
            return [[n.userInfo objectForKey:@"alarmUUID"] isEqualToString:alarm.uuid];
        }];
        if (i != NSNotFound) {
            notification = scheduledNotifications[i];
        }
    }
    
    if (!alarm.isDeleted && [alarm.isSet boolValue]) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        if (notification) {
            // Update
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
            notification.fireDate = alarm.time;
            notification.timeZone = [NSTimeZone systemTimeZone];
            dateFormatter.dateFormat = @"h:mm a";
            notification.alertBody = [NSString stringWithFormat:@"%@ Alarm", [dateFormatter stringFromDate:alarm.time]];
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        } else {
            // Schedule
            notification = [[UILocalNotification alloc] init];
            notification.fireDate = alarm.time;
            notification.timeZone = [NSTimeZone systemTimeZone];
            dateFormatter.dateFormat = @"h:mm a";
            notification.alertBody = [NSString stringWithFormat:@"%@ Alarm", [dateFormatter stringFromDate:alarm.time]];
            notification.alertAction = @"Dismiss";
            notification.soundName = UILocalNotificationDefaultSoundName;
            notification.userInfo = @{ @"alarmUUID": alarm.uuid, @"deviceName": alarm.device.name ?: @"" };
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
        
    } else {
        // Unschedule
        if (notification) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
    NSLog(@"%i scheduled local notifications", [[UIApplication sharedApplication] scheduledLocalNotifications].count);
    
    if (self.bluetoothController) {
         NSUInteger deviceIndex = [self.bluetoothController.connectedPeripherals indexOfObjectPassingTest:^BOOL(CBPeripheral *p, NSUInteger idx, BOOL *stop) {
            return [p.identifier.UUIDString isEqualToString:alarm.device.uuid];
        }];
        if (deviceIndex != NSNotFound) {
            // Update the device now
        } else {
            // Update the device ASAP
        }
    } else {
        // Initialize DevicesViewController?
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if (managedObjectContext.hasChanges && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectContext *)tempObjectContext {
    if (_tempObjectContext != nil) {
        return _tempObjectContext;
    }
    
    _tempObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_tempObjectContext setParentContext:self.managedObjectContext];
    return  _tempObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SwitchaBLE" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SwitchaBLE.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

- (NSMutableArray *)getEntityWithName:(NSString *)name {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:name inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (error != nil) {
        // TODO handle the error.
    }
    
    return mutableFetchResults;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
