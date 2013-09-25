//
//  KSSDevicesViewController.h
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/8/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSSBluetoothController.h"

@interface KSSDevicesViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, KSSBluetoothDelegate>

@property (nonatomic, retain) KSSBluetoothController *bluetoothController;
@property (nonatomic, retain) NSMutableArray *peripheralsArray;

@end
