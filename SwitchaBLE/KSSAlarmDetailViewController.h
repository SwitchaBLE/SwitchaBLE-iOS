//
//  KSSEditAlarmTableViewController.h
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/23/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"
#import "KSSChooseDeviceViewController.h"

@class KSSAlarmDetailViewController;

@protocol KSSAlarmDetailViewControllerDelegate <NSObject>
- (void)alarmDetailViewController:(KSSAlarmDetailViewController *)controller didChooseDevice:(Device *)device;
@optional
- (void)alarmDetailViewController:(KSSAlarmDetailViewController *)controller didFinishDeletingAlarmBySender:(id)sender;
@end

@interface KSSAlarmDetailViewController : UITableViewController <KSSChooseDeviceDelegate>

@property (nonatomic, retain) IBOutlet UITableViewCell *deleteCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *deviceCell;
@property (nonatomic, retain) Device *selectedDevice;
@property (weak) id <KSSAlarmDetailViewControllerDelegate> delegate;

@end
