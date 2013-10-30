//
//  KSSDeviceDetailsViewController.h
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/25/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "KSSBluetoothController.h"
@class Device;
@class KSSDeviceDetailsViewController;

@protocol KSSDeviceDetailsDelegate <NSObject>
- (void)deviceDetailsViewController:(KSSDeviceDetailsViewController *)controller didFinishSavingDevice:(Device *)device;
- (void)deviceDetailsViewController:(KSSDeviceDetailsViewController *)controller didFinishForgettingDevice:(Device *)device;
@end

@interface KSSDeviceDetailsViewController : UITableViewController <UIAlertViewDelegate, KSSBluetoothDeviceDelegate>

@property (nonatomic, weak) id <KSSDeviceDetailsDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, retain) IBOutlet UITableViewCell *nameCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *uuidCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *temperatureCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *identifyCell;
@property (nonatomic) Device *device;
@property (nonatomic) BOOL deviceIsSaved;

- (IBAction)closeView:(id)sender;
- (IBAction)saveDevice:(id)sender;
- (void)forgetDevice:(id)sender;

@end
