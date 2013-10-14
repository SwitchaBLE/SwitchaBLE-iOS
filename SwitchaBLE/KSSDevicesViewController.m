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

    nearbyArray = [[NSMutableArray alloc] init];
    appDelegate = (KSSAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.devicesViewController = self;
    appDelegate.bluetoothController = [[KSSBluetoothController alloc] initWithDeviceListDelegate:self];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Device" inManagedObjectContext:appDelegate.managedObjectContext];
    [request setEntity:entity];
    
    NSError *error = nil;
    savedArray = [NSMutableArray arrayWithArray:[[appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy]];
    if (error != nil) {
        //TODO handle the error.
    }
    
    // TODO display a status indicator while waiting for bluetooth update
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)bluetoothController:(KSSBluetoothController *)controller didConnectToPeripheral:(CBPeripheral *)peripheral {
    
    Device *device = [[savedArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uuid==%@", peripheral.identifier.UUIDString]] firstObject];
    if (device != nil) {
        device.peripheral = peripheral;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[savedArray indexOfObject:device] inSection:[self sectionOfArray:savedArray]]] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        Device *device = [[Device alloc] init];
        device.peripheral = peripheral;
        [nearbyArray addObject:device];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[nearbyArray indexOfObject:peripheral] inSection:[self sectionOfArray:nearbyArray]];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[nearbyArray indexOfObject:peripheral] inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)bluetoothController:(KSSBluetoothController *)controller didDisconnectFromPeripheral:(CBPeripheral *)peripheral {
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[peripheralsArray indexOfObject:peripheral] inSection:0];
//    [self.peripheralsArray removeObjectAtIndex:indexPath.row];
//    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSInteger sections = 0;
    sections += (savedArray.count > 0);
    sections += (nearbyArray.count > 0);
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self arrayForSection:section].count;
}

- (NSMutableArray *)arrayForSection:(NSInteger)section {
    return (section == 0 && nearbyArray.count > 0) ? nearbyArray : savedArray;
}

- (NSInteger)sectionOfArray:(NSMutableArray *)array {
    return [self arrayForSection:0] == array ? 0 : ([self numberOfSectionsInTableView:self.tableView] > 1 ? 1 : -1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"deviceCell";
    KSSDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[KSSDeviceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.device = (Device *)[[self arrayForSection:indexPath.section] objectAtIndex:indexPath.row];

    if (cell.device.peripheral != nil) {
        cell.statusLabel.text = @"Connected";
    } else {
        cell.statusLabel.text = @"Not connected";
    }
    
    cell.nameLabel.text = cell.device.name != nil ? cell.device.name : cell.device.peripheral.name;
    
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
    controller.device = (Device *)[[self arrayForSection:self.tableView.indexPathForSelectedRow.section] objectAtIndex:self.tableView.indexPathForSelectedRow.row];
}

@end
