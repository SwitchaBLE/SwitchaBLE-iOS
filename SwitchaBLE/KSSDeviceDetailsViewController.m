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
@end

@implementation KSSDeviceDetailsViewController

@synthesize appDelegate;

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
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveDevice:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Device Name" message:@"Give device a unique nickname?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
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

- (void)bluetoothController:(KSSBluetoothController *)controller didDisconnectFromPeripheral:(CBPeripheral *)peripheral {
    self.identifyCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.identifyCell.userInteractionEnabled = self.identifyCell.textLabel.enabled = NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.view addGestureRecognizer:self.tapRecognizer];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (!textField.text.length) {
        textField.text = self.device.name;
    } else if ([((KSSDevicesViewController *)self.delegate).savedArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name ==[c] %@) AND (uuid != %@)", textField.text, self.device.uuid]].count) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"A device by that name already exists. Please choose a unique name." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    self.device.name = textField.text;
    [self.delegate deviceDetailsViewController:self didFinishEditingDevice:self.device];
    [self.view removeGestureRecognizer:self.tapRecognizer];
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
