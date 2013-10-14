//
//  Device.h
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/8/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface Device : NSManagedObject

@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSSet *alarms;
@property (nonatomic, retain) CBPeripheral *peripheral;

@end

@interface Device (CoreDataGeneratedAccessors)

- (void)addAlarmsObject:(NSManagedObject *)value;
- (void)removeAlarmsObject:(NSManagedObject *)value;
- (void)addAlarms:(NSSet *)values;
- (void)removeAlarms:(NSSet *)values;

@end
