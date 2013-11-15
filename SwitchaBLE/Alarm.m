//
//  Alarm.m
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/8/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import "Alarm.h"
#import "Device.h"
#import "KSSAppDelegate.h"


@implementation Alarm

@dynamic isSet;
@dynamic time;
@dynamic uuid;
@dynamic device;

- (void)willSave {
    if (!self.uuid) {
        self.uuid = [[NSProcessInfo processInfo] globallyUniqueString];
    }
    if (self.isUpdated || self.isDeleted) {
        [(KSSAppDelegate *)[UIApplication sharedApplication].delegate scheduleAlarm:self];
    }
}

@end
