//
//  KSSDevicesViewController.m
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/8/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "KSSDevicesViewController.h"
#import "KSSAppDelegate.h"
#import "KSSDeviceTableViewCell.h"
#import "KSSDeviceDetailsViewController.h"
#import "Device.h"

@interface KSSDevicesViewController ()
@property (weak) KSSAppDelegate *appDelegate;
@end

@implementation KSSDevicesViewController

@synthesize appDelegate;
@synthesize nearbyArray;
@synthesize savedArray;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    appDelegate = (KSSAppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.devicesViewController = self;
    
    nearbyArray = [[NSMutableArray alloc] init];
    savedArray = [appDelegate getEntityWithName:@"Device"];
    
    if (!appDelegate.bluetoothController) {
        appDelegate.bluetoothController = [[KSSBluetoothController alloc] init];
    }
    
    appDelegate.bluetoothController.deviceListDelegate = self;
    for (CBPeripheral *peripheral in appDelegate.bluetoothController.connectedPeripherals) {
        [self bluetoothController:appDelegate.bluetoothController didConnectToPeripheral:peripheral];
    }
    
    // TODO display a status indicator while waiting for bluetooth update
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)deviceDetailsViewController:(KSSDeviceDetailsViewController *)controller didFinishSavingDevice:(Device *)device {
    Device *tempDevice = [nearbyArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uuid=%@", device.uuid]].firstObject;
    NSIndexPath *destinationPath = [NSIndexPath indexPathForRow:0 inSection:1];
    if (tempDevice != nil) {
        NSIndexPath *sourcePath = [NSIndexPath indexPathForRow:[nearbyArray indexOfObject:tempDevice] inSection:0];
        [nearbyArray removeObject:tempDevice];
        [savedArray insertObject:device atIndex:0];
        [self.tableView beginUpdates];
        ((KSSDeviceTableViewCell *)[self.tableView cellForRowAtIndexPath:sourcePath]).nameLabel.text = device.name;
        [self.tableView moveRowAtIndexPath:sourcePath toIndexPath:destinationPath];
        if (nearbyArray.count == 0) {
            [self.tableView insertRowsAtIndexPaths:@[sourcePath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        if (savedArray.count == 1) {
            [self.tableView deleteRowsAtIndexPaths:@[destinationPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [self.tableView endUpdates];
    } else {
        [savedArray insertObject:device atIndex:0];
        [self.tableView beginUpdates];
        if (savedArray.count == 1) {
            [self.tableView deleteRowsAtIndexPaths:@[destinationPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [self.tableView insertRowsAtIndexPaths:@[destinationPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

- (void)deviceDetailsViewController:(KSSDeviceDetailsViewController *)controller didFinishForgettingDevice:(Device *)device {
    NSIndexPath *sourcePath = [NSIndexPath indexPathForRow:[savedArray indexOfObject:device] inSection:1];
    if (device.peripheral.state == CBPeripheralStateConnected) {
        NSIndexPath *destinationPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [savedArray removeObject:device];
        Device *newDevice = (Device *)[NSEntityDescription insertNewObjectForEntityForName:@"Device" inManagedObjectContext:appDelegate.tempObjectContext];
        newDevice.peripheral = device.peripheral;
        newDevice.uuid = device.peripheral.identifier.UUIDString;
        newDevice.name = device.peripheral.name;
        [nearbyArray insertObject:newDevice atIndex:0];
        [self.tableView beginUpdates];
        ((KSSDeviceTableViewCell *)[self.tableView cellForRowAtIndexPath:sourcePath]).nameLabel.text = newDevice.name;
        [self.tableView moveRowAtIndexPath:sourcePath toIndexPath:destinationPath];
        if (savedArray.count == 0) {
            [self.tableView insertRowsAtIndexPaths:@[sourcePath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        if (nearbyArray.count == 1) {
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [self.tableView endUpdates];
    } else {
        [savedArray removeObject:device];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[sourcePath] withRowAnimation:UITableViewRowAnimationAutomatic];
        if (savedArray.count == 0) {
            [self.tableView insertRowsAtIndexPaths:@[sourcePath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [self.tableView endUpdates];
    }
    [appDelegate saveContext];
}

- (void)deviceDetailsViewController:(KSSDeviceDetailsViewController *)controller didFinishEditingDevice:(Device *)device {
    NSIndexPath *devicePath = [NSIndexPath indexPathForRow:[savedArray indexOfObject:device] inSection:1];
    ((KSSDeviceTableViewCell *)[self.tableView cellForRowAtIndexPath:devicePath]).nameLabel.text = device.name;
    [appDelegate saveContext];
}

- (void)bluetoothController:(KSSBluetoothController *)controller didConnectToPeripheral:(CBPeripheral *)peripheral {
    
    Device *device = [savedArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uuid==%@", peripheral.identifier.UUIDString]].firstObject;
    
    if (device != nil) {
        device.peripheral = peripheral;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[savedArray indexOfObject:device] inSection:1];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        Device *device = (Device *)[NSEntityDescription insertNewObjectForEntityForName:@"Device" inManagedObjectContext:appDelegate.tempObjectContext];
        device.peripheral = peripheral;
        device.uuid = peripheral.identifier.UUIDString;
        device.name = peripheral.name;
        [nearbyArray insertObject:device atIndex:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[nearbyArray indexOfObject:device] inSection:0];
        [self.tableView beginUpdates];
        if (nearbyArray.count == 1) {
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)bluetoothController:(KSSBluetoothController *)controller didDisconnectFromPeripheral:(CBPeripheral *)peripheral {
    
    Device *device = [savedArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uuid==%@", peripheral.identifier.UUIDString]].firstObject;
    
    if (device != nil) {
        device.peripheral = nil;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[savedArray indexOfObject:device] inSection:1];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        
        device = [nearbyArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uuid==%@", peripheral.identifier.UUIDString]].firstObject;
        
        if (device != nil) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[nearbyArray indexOfObject:device] inSection:0];
            [nearbyArray removeObject:device];
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            if (nearbyArray.count == 0) {
                [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            [self.tableView endUpdates];
        }
    }
        
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
//    NSInteger sections = 0;
//    sections += (savedArray.count > 0);
//    sections += (nearbyArray.count > 0);
//    return sections;
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self arrayForSection:section].count ?: 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == 0 ? @"NEW DEVICES NEARBY" : @"SAVED DEVICES";
}

- (NSMutableArray *)arrayForSection:(NSInteger)section {
    return section == 0 ? nearbyArray : savedArray;
}

- (NSInteger)sectionOfArray:(NSMutableArray *)array {
    return [self arrayForSection:0] == array ? 0 : ([self numberOfSectionsInTableView:self.tableView] > 1 ? 1 : -1);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self arrayForSection:indexPath.section].count == 0) {
        return 60;
    } else {
        return 91;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self arrayForSection:indexPath.section].count == 0) {
        static NSString *placeholderCellIdentifier = @"placeholderCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:placeholderCellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:placeholderCellIdentifier];
        }
        ((UILabel *)[cell viewWithTag:100]).text = indexPath.section == 0 ? @"No new devices found" : @"No devices saved";
        
        return cell;
    }
    
    static NSString *deviceCellIdentifier = @"deviceCell";
    KSSDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:deviceCellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[KSSDeviceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:deviceCellIdentifier];
    }
    
    cell.device = (Device *)[[self arrayForSection:indexPath.section] objectAtIndex:indexPath.row];

    if (cell.device.peripheral.state == CBPeripheralStateConnected) {
        cell.statusLabel.text = @"Connected";
        cell.statusLabel.enabled = cell.nameLabel.enabled = YES;
    } else {
        cell.statusLabel.text = @"Not connected";
        cell.statusLabel.enabled = cell.nameLabel.enabled = NO;
    }
    
    cell.nameLabel.text = cell.device.name ?: cell.device.peripheral.name;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    KSSDeviceDetailsViewController *controller = [(UINavigationController *)segue.destinationViewController viewControllers].lastObject;
    CGPoint accessoryPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *pathAtPosition = [self.tableView indexPathForRowAtPoint:accessoryPosition];
    controller.device = (Device *)[[self arrayForSection:pathAtPosition.section] objectAtIndex:pathAtPosition.row];
    controller.deviceIsSaved = pathAtPosition.section == 1;
    controller.delegate = self;
}

@end
