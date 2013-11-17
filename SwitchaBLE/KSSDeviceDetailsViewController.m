//
//  KSSDeviceDetailsViewController.m
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/25/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import "KSSDeviceDetailsViewController.h"
#import "Device.h"
#import "KSSAppDelegate.h"

@interface KSSDeviceDetailsViewController ()
@property (weak) KSSAppDelegate *appDelegate;
@property (nonatomic, retain) NSTimer *rssiTimer;
@end

@implementation KSSDeviceDetailsViewController

@synthesize appDelegate;
@synthesize rssiTimer;
@synthesize alert;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (KSSAppDelegate *)[UIApplication sharedApplication].delegate;


    self.name.text = self.device.name ?: self.device.peripheral.name;
    self.name.delegate = self;
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    if (self.deviceIsSaved) {
        self.saveOrForgetCell.textLabel.text = @"Forget Device";
    } else {
        self.name.enabled = NO;
    }
    
    if (self.device.peripheral.state != CBPeripheralStateConnected) {
        self.identifyCell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.identifyCell.userInteractionEnabled = self.identifyCell.textLabel.enabled = NO;
        self.connectionCell.detailTextLabel.text = @"Not connected";
    } else {
        self.connectionCell.detailTextLabel.text = [self formatRSSI:self.device.peripheral.RSSI];
    }
    
    appDelegate.bluetoothController.deviceDelegate = self;
}

// NEEDS TO BE TESTED
- (void)viewWillAppear:(BOOL)animated {
    if (self.device.peripheral.state == CBPeripheralStateConnected) {
        rssiTimer = [appDelegate.bluetoothController startPollingRSSIForPeripheral:self.device.peripheral];
    }
}

// NEEDS TO BE TESTED
- (void)viewWillDisappear:(BOOL)animated {
    if (rssiTimer) {
        [appDelegate.bluetoothController stopPollingRSSIOnTimer:rssiTimer];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// NEEDS TO BE TESTED
- (NSString *)formatRSSI:(NSNumber *)rssi {
    if (rssi == nil) {
        return @"Waiting for update...";
    } else if (rssi.intValue < -90) {
        return [NSString stringWithFormat:@"Weak (%i dBm)", rssi.intValue];
    } else if (rssi.intValue < -70) {
        return [NSString stringWithFormat:@"Fair (%i dBm)", rssi.intValue];
    } else if (rssi.intValue < -60) {
        return [NSString stringWithFormat:@"Good (%i dBm)", rssi.intValue];
    } else {
        return [NSString stringWithFormat:@"Excellent (%i dBm)", rssi.intValue];
    }
}

- (void)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveDevice:(id)sender {
    alert = [[UIAlertView alloc] initWithTitle:@"Device Name" message:@"Give device a unique nickname?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].delegate = self;
    [alert textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeWords;
    [alert textFieldAtIndex:0].clearButtonMode = UITextFieldViewModeAlways;
    [alert textFieldAtIndex:0].text = self.device.peripheral.name;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        Device *device = (Device *)[NSEntityDescription insertNewObjectForEntityForName:@"Device" inManagedObjectContext:appDelegate.managedObjectContext];
        device.peripheral = self.device.peripheral;
        device.uuid = self.device.uuid;
        device.name = [alertView textFieldAtIndex:0].text;
        [appDelegate saveContext];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.delegate deviceDetailsViewController:self didFinishSavingDevice:device];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView cellForRowAtIndexPath:indexPath] == self.identifyCell) {
        [appDelegate.bluetoothController identifyPeripheral:self.device.peripheral];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if ([tableView cellForRowAtIndexPath:indexPath] == self.saveOrForgetCell) {
        if (self.deviceIsSaved) {
            [self forgetDevice:self.saveOrForgetCell];
        } else {
            [self saveDevice:self.saveOrForgetCell];
        }
    }
}

- (void)forgetDevice:(id)sender {
    [appDelegate.managedObjectContext deleteObject:self.device];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate deviceDetailsViewController:self didFinishForgettingDevice:self.device];
}

- (void)bluetoothController:(KSSBluetoothController *)controller didConnectToPeripheral:(CBPeripheral *)peripheral {
    self.device.peripheral = peripheral;
    self.identifyCell.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.identifyCell.userInteractionEnabled = self.identifyCell.textLabel.enabled = YES;
    rssiTimer = [appDelegate.bluetoothController startPollingRSSIForPeripheral:peripheral];
}

- (void)bluetoothController:(KSSBluetoothController *)controller didDisconnectFromPeripheral:(CBPeripheral *)peripheral {
    self.identifyCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.identifyCell.userInteractionEnabled = self.identifyCell.textLabel.enabled = NO;
    self.connectionCell.detailTextLabel.text = @"Not connected";
    [appDelegate.bluetoothController stopPollingRSSIOnTimer:rssiTimer];
}

- (void)bluetoothController:(KSSBluetoothController *)controller didUpdateRSSIForPeripheral:(CBPeripheral *)peripheral {
    self.connectionCell.detailTextLabel.text = [self formatRSSI:peripheral.RSSI];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.name) {
        [self.view addGestureRecognizer:self.tapRecognizer];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField == [alert textFieldAtIndex:0]) {
        [alert dismissWithClickedButtonIndex:1 animated:YES];
        [self alertView:alert clickedButtonAtIndex:1];
    }
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == self.name) {
        if (!textField.text.length) {
            textField.text = self.device.name;
        } else if ([((KSSDevicesViewController *)self.delegate).savedArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name ==[c] %@) AND (uuid != %@)", textField.text, self.device.uuid]].count) {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:nil message:@"A device by that name already exists. Please choose a unique name." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [errorAlert show];
            return NO;
        }
        self.device.name = textField.text;
        [self.delegate deviceDetailsViewController:self didFinishEditingDevice:self.device];
        [self.view removeGestureRecognizer:self.tapRecognizer];
    }
    return YES;
}

- (void)dismissKeyboard {
    [self.name resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
