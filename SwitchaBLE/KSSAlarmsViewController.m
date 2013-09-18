//
//  KSSAlarmsViewController.m
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/8/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import "KSSAppDelegate.h"
#import "KSSAlarmsViewController.h"
#import "KSSAddAlarmNavigationController.h"
#import "KSSEditAlarmViewController.h"
#import "KSSAlarmTableViewCell.h"
#import "KSSAlarmIsSetSwitch.h"
#import "Alarm.h"

@interface KSSAlarmsViewController ()

@property (nonatomic, retain) NSDateFormatter *dateFormatter;

@end

@implementation KSSAlarmsViewController

@synthesize alarmsArray;
@synthesize dateFormatter;

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
    
    self.compareTimesIgnoringDates = ^NSComparisonResult(Alarm *a, Alarm *b) {
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        NSDateComponents *aComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[a time]];
        NSDateComponents *bComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[b time]];
        
        [aComponents setYear:[bComponents year]];
        [aComponents setMonth:[bComponents month]];
        [aComponents setDay:[bComponents day]];
        [aComponents setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
        [bComponents setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
        NSDate *aDate = [aComponents date];
        NSDate *bDate = [bComponents date];
        
        return [aDate compare:bDate]; //TODO account for date
    };
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    
    KSSAppDelegate *appDelegate = (KSSAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    [appDelegate setAlarmsViewController:self];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Alarm" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        //TODO handle the error.
    }
    
    [mutableFetchResults sortUsingComparator:self.compareTimesIgnoringDates];
    
    [self setAlarmsArray:mutableFetchResults];

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

- (void)insertAlarm:(Alarm *)alarm
{
    [alarmsArray insertObject:alarm atIndex:0];
    [alarmsArray sortUsingComparator:self.compareTimesIgnoringDates];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[alarmsArray indexOfObject:alarm] inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[alarmsArray indexOfObject:alarm] inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)editAlarmViewController:(KSSEditAlarmViewController *)controller didFinishEditingAlarm:(Alarm *)alarm {
    KSSAlarmTableViewCell *cell = (KSSAlarmTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:[alarmsArray indexOfObject:alarm] inSection:0]];
    [cell timeLabel].text = [dateFormatter stringFromDate:alarm.time];
    [cell isSetSwitch].on = TRUE;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [alarmsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"alarmCell";
    KSSAlarmTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[KSSAlarmTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
//    static NSDateFormatter *dateFormatter = nil;
//    
//    if (dateFormatter == nil) {
//        dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
//        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
//    }
    
    Alarm *alarm = (Alarm *)[alarmsArray objectAtIndex:indexPath.row];
    
    [cell timeLabel].text = [dateFormatter stringFromDate:alarm.time];
    [cell setAlarm:alarm];
    
    [[cell isSetSwitch] setOn:[alarm.isSet boolValue]];
    [[cell isSetSwitch] setCell:cell];
    [[cell isSetSwitch] addTarget:self action:@selector(toggleAlarmSet:) forControlEvents:UIControlEventValueChanged];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showEditAlarm"]) {
        KSSEditAlarmViewController *controller = segue.destinationViewController;
        controller.delegate = self;
        controller.alarm = [alarmsArray objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    }
}

- (void)toggleAlarmSet:(KSSAlarmIsSetSwitch *)sender {
    
    KSSAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    Alarm *alarm = [[sender cell] alarm];
    [alarm setIsSet:[NSNumber numberWithBool:[sender isOn]]];
    
    [delegate saveContext];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        KSSAppDelegate *appDelegate = (KSSAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
        [managedObjectContext deleteObject:[alarmsArray objectAtIndex:[indexPath row]]];
        [alarmsArray removeObjectAtIndex:[indexPath row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [appDelegate saveContext];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

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
