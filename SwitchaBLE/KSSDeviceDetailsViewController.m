//
//  KSSDeviceDetailsViewController.m
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/25/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import "KSSDeviceDetailsViewController.h"
#import "Device.h"

@interface KSSDeviceDetailsViewController ()

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

    if (self.peripheral) {
        self.nameCell.detailTextLabel.text = self.peripheral.name;
        self.uuidCell.detailTextLabel.text = self.peripheral.identifier.UUIDString;
    }
    
    appDelegate = (KSSAppDelegate *)[[UIApplication sharedApplication] delegate];
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
    [alert textFieldAtIndex:0].text = self.peripheral.name;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        //TODO save device
        Device *device = [NSEntityDescription insertNewObjectForEntityForName:@"Device" inManagedObjectContext:appDelegate.managedObjectContext];
        device.uuid = self.peripheral.identifier.UUIDString;
        device.name = [alertView textFieldAtIndex:0].text;
        [appDelegate.managedObjectContext insertObject:device];
        [appDelegate saveContext];
    }
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
