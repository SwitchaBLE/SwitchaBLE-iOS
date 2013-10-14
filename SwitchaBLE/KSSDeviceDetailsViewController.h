//
//  KSSDeviceDetailsViewController.h
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/25/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "KSSAppDelegate.h"
#import "KSSBluetoothController.h"
@class KSSAppDelegate;

@interface KSSDeviceDetailsViewController : UITableViewController <UIAlertViewDelegate, KSSBluetoothDeviceDelegate>

@property (nonatomic, retain) IBOutlet UITableViewCell *nameCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *uuidCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *temperatureCell;
@property (nonatomic) Device *device;

- (IBAction)closeView:(id)sender;
- (IBAction)saveDevice:(id)sender;

@end
