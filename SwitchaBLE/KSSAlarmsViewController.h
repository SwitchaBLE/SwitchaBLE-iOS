//
//  KSSAlarmsViewController.h
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/8/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Alarm.h"

@interface KSSAlarmsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property NSMutableArray *alarmsArray;
@property IBOutlet UIBarButtonItem *addAlarmButton;
@property (copy) NSComparisonResult (^compareTimesIgnoringDates)(Alarm *a, Alarm *b);

- (void)insertAlarm:(Alarm *)alarm;

@end
