//
//  KSSDevicesViewController.h
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/8/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSSBluetoothController.h"
#import "KSSDeviceDetailsViewController.h"

@interface KSSDevicesViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, KSSBluetoothDeviceListDelegate, KSSDeviceDetailsDelegate>

@property (nonatomic, retain) NSMutableArray *nearbyArray;
@property (nonatomic, retain) NSMutableArray *savedArray;

@end
