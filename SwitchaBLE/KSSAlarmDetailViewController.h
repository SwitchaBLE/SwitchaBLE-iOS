//
//  KSSEditAlarmTableViewController.h
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/23/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KSSAlarmDetailViewController;

@protocol KSSAlarmDetailViewControllerDelegate <NSObject>

- (void)alarmDetailViewController:(KSSAlarmDetailViewController *)controller didFinishDeletingAlarmBySender:(id)sender;

@end

@interface KSSAlarmDetailViewController : UITableViewController

@property (nonatomic, retain) IBOutlet UITableViewCell *deleteCell;
@property (weak) id <KSSAlarmDetailViewControllerDelegate> delegate;

@end
