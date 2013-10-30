//
//  KSSChooseDeviceViewController.h
//  SwitchaBLE
//
//  Created by Andrew Branch on 10/29/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KSSChooseDeviceViewController;

@protocol KSSChooseDeviceDelegate <NSObject>
- (void)chooseDeviceViewController:(KSSChooseDeviceViewController *)viewController didChooseDevice:(Device *)device;
@end


@interface KSSChooseDeviceViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate/*, KSSBluetoothDeviceListDelegate*/>

@property (nonatomic, retain) NSMutableArray *savedArray;
@property (nonatomic, retain) NSIndexPath *checkedIndexPath;
@property (weak) id <KSSChooseDeviceDelegate> delegate;

@end
