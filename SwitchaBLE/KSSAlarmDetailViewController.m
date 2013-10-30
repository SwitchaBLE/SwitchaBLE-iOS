//
//  KSSEditAlarmTableViewController.m
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/23/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import "KSSAlarmDetailViewController.h"
#import "KSSChooseDeviceViewController.h"

@interface KSSAlarmDetailViewController ()

@end

@implementation KSSAlarmDetailViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.tableView cellForRowAtIndexPath:indexPath] isEqual:self.deleteCell]) {
        [self.delegate alarmDetailViewController:self didFinishDeletingAlarmBySender:self.deleteCell];
    }
}

- (void)chooseDeviceViewController:(KSSChooseDeviceViewController *)viewController didChooseDevice:(Device *)device {
    self.deviceCell.detailTextLabel.text = device.name;
    [self.delegate alarmDetailViewController:self didChooseDevice:device];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showChooseDevice"]) {
        ((KSSChooseDeviceViewController *)segue.destinationViewController).delegate = self;
    }
}

@end
