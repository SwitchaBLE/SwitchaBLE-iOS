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


    self.nameCell.detailTextLabel.text = self.device.name;
    self.uuidCell.detailTextLabel.text = self.device.uuid;
    self.temperatureCell.detailTextLabel.text = @"Waiting...";
    
    if (self.deviceIsSaved) {
        self.saveButton.title = @"Forget";
        self.saveButton.action = @selector(forgetDevice:);
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
    }
}

- (void)forgetDevice:(id)sender {
    [appDelegate.managedObjectContext deleteObject:self.device];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate deviceDetailsViewController:self didFinishForgettingDevice:self.device];
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
