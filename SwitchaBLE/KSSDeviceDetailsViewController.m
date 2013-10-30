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
    appDelegate = (KSSAppDelegate *)[[UIApplication sharedApplication] delegate];


    self.nameCell.detailTextLabel.text = self.device.name;
    self.uuidCell.detailTextLabel.text = self.device.uuid;
    self.temperatureCell.detailTextLabel.text = @"Waiting...";
    [appDelegate.bluetoothController getTemperatureCharacteristicForPeripheral:self.device.peripheral deviceDelegate:self];
    
    if (self.deviceIsSaved) {
        self.saveButton.title = @"Forget";
        self.saveButton.action = @selector(forgetDevice:);
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

- (void)forgetDevice:(id)sender {
    [appDelegate.managedObjectContext deleteObject:self.device];
    [appDelegate saveContext];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate deviceDetailsViewController:self didFinishForgettingDevice:self.device];
}

- (void)peripheral:(CBPeripheral *)peripheral didGetTemperatureCharacteristic:(CBCharacteristic *)characteristic {
    NSData * updatedValue = characteristic.value;
    uint8_t* dataPointer = (uint8_t*)[updatedValue bytes];
    
    uint8_t flags = dataPointer[0]; dataPointer++;
    int32_t tempData = (int32_t)CFSwapInt32LittleToHost(*(uint32_t*)dataPointer); dataPointer += 4;
    int8_t exponent = (int8_t)(tempData >> 24);
    int32_t mantissa = (int32_t)(tempData & 0x00FFFFFF);
    
    if (tempData == 0x007FFFFF) {
        NSLog(@"Invalid temperature value received");
        return;
    }
    
    float tempValue = (float)(mantissa*pow(10, exponent));
    NSString *measurementType;
    /* measurement type */
    if (flags & 0x01) {
        measurementType = @"ºF";
    } else {
        measurementType = @"ºC";
    }
    
    self.temperatureCell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f%@", tempValue, measurementType];
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
