//
//  KSSChooseDeviceViewController.m
//  SwitchaBLE
//
//  Created by Andrew Branch on 10/29/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import "KSSAppDelegate.h"
#import "KSSDeviceTableViewCell.h"
#import "KSSChooseDeviceViewController.h"

@interface KSSChooseDeviceViewController ()
@property (weak) KSSAppDelegate *appDelegate;
@end

@implementation KSSChooseDeviceViewController

@synthesize appDelegate;
@synthesize savedArray;

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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleDone target:self action:@selector(clearDeviceSelection)];

    appDelegate = (KSSAppDelegate *)[UIApplication sharedApplication].delegate;
    savedArray = [appDelegate getEntityWithName:@"Device"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clearDeviceSelection {
    if (self.initialDevice) {
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[savedArray indexOfObject:self.initialDevice] inSection:0]].accessoryType = UITableViewCellAccessoryNone;
    }
    [self.delegate chooseDeviceViewController:self didChooseDevice:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return savedArray.count ?: 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (savedArray.count == 0) {
        return 60;
    } else {
        return 91;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (savedArray.count == 0) {
        static NSString *placeholderCellIdentifier = @"placeholderCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:placeholderCellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:placeholderCellIdentifier];
        }
        ((UILabel *)[cell viewWithTag:100]).text = @"No devices saved";
        
        return cell;
    }
    
    static NSString *deviceCellIdentifier = @"deviceCell";
    KSSDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:deviceCellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[KSSDeviceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:deviceCellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.device = (Device *)[savedArray objectAtIndex:indexPath.row];
    
    if (self.initialDevice == cell.device) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (cell.device.peripheral != nil) {
        cell.statusLabel.text = @"Connected";
    } else {
        cell.statusLabel.text = @"Not connected";
    }
    
    cell.nameLabel.text = cell.device.name ?: cell.device.peripheral.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.initialDevice) {
        [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[savedArray indexOfObject:self.initialDevice] inSection:0]].accessoryType = UITableViewCellAccessoryNone;
    }
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    [self.delegate chooseDeviceViewController:self didChooseDevice:[savedArray objectAtIndex:indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
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
