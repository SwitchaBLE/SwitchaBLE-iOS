//
//  KSSEditAlarmViewController.h
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/17/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Alarm.h"
#import "KSSChooseDeviceViewController.h"
#import "KSSAlarmDetailViewController.h"

@class KSSEditAlarmViewController;

@protocol KSSEditAlarmDelegate <NSObject>

- (void)editAlarmViewController:(KSSEditAlarmViewController *)controller didFinishEditingAlarm:(Alarm *)alarm;
- (void)editAlarmViewController:(KSSEditAlarmViewController *)controller didFinishDeletingAlarm:(Alarm *)alarm;

@end

@interface KSSEditAlarmViewController : UIViewController <KSSAlarmDetailViewControllerDelegate>

@property (nonatomic, weak) id <KSSEditAlarmDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, retain) KSSAlarmDetailViewController *embeddedView;
@property Alarm *alarm;

- (IBAction)saveAlarm:(id)sender;
- (IBAction)deleteAlarm:(id)sender;

@end
