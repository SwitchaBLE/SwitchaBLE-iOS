//
//  Alarm.h
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/8/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Device;

@interface Alarm : NSManagedObject

@property (nonatomic, retain) NSNumber *isSet;
@property (nonatomic, retain) NSDate *time;
@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, retain) Device *device;

@end
