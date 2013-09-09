//
//  Device.h
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/8/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Device : NSManagedObject

@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSSet *alarms;
@end

@interface Device (CoreDataGeneratedAccessors)

- (void)addAlarmsObject:(NSManagedObject *)value;
- (void)removeAlarmsObject:(NSManagedObject *)value;
- (void)addAlarms:(NSSet *)values;
- (void)removeAlarms:(NSSet *)values;

@end
