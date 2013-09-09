//
//  KSSAddAlarmViewController.h
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/8/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSSAlarmsViewController.h"

@interface KSSAddAlarmViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;
//@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;
@property KSSAlarmsViewController *alarmsViewController;

- (IBAction)cancelAlarm:(id)sender;
- (IBAction)saveAlarm:(id)sender;

@end