//
//  KSSAlarmsViewController.m
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/8/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import "KSSAppDelegate.h"
#import "KSSAlarmsViewController.h"
#import "KSSEditAlarmViewController.h"
#import "KSSAlarmTableViewCell.h"
//#import "KSSAlarmIsSetSwitch.h"
#import "Alarm.h"

@interface KSSAlarmsViewController ()
@property (nonatomic, retain) KSSAppDelegate *appDelegate;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@end

@implementation KSSAlarmsViewController

@synthesize appDelegate;
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
        
        return [aDate compare:bDate];
    };
    
    dateFormatter = [[NSDateFormatter alloc] init];
    
    appDelegate = (KSSAppDelegate *)[[UIApplication sharedApplication] delegate];
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

- (void)addAlarmViewController:(KSSAddAlarmViewController *)viewController didSaveAlarm:(Alarm *)alarm
{
    [alarmsArray insertObject:alarm atIndex:0];
    [alarmsArray sortUsingComparator:self.compareTimesIgnoringDates];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[alarmsArray indexOfObject:alarm] inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    // Save first for new alarms so an alarm has a UUID
    [appDelegate saveContext];
    [appDelegate scheduleAlarm:alarm];
}

- (void)editAlarmViewController:(KSSEditAlarmViewController *)controller didFinishEditingAlarm:(Alarm *)alarm {
    KSSAlarmTableViewCell *cell = (KSSAlarmTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:[alarmsArray indexOfObject:alarm] inSection:0]];
    [self formatCell:cell withAlarm:alarm];
    [cell isSetSwitch].on = TRUE;
    
    [appDelegate scheduleAlarm:alarm];
    [appDelegate saveContext];
}

- (void)editAlarmViewController:(KSSEditAlarmViewController *)controller didFinishDeletingAlarm:(Alarm *)alarm {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[alarmsArray indexOfObject:alarm] inSection:0];
    [alarmsArray removeObjectAtIndex:[indexPath row]];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [appDelegate scheduleAlarm:alarm];
    [appDelegate saveContext];
}

- (void)toggleAlarmSet:(UISwitch *)sender {
    CGPoint switchPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    Alarm *alarm = [alarmsArray objectAtIndex:[self.tableView indexPathForRowAtPoint:switchPosition].row];
    [alarm setIsSet:[NSNumber numberWithBool:[sender isOn]]];
    
    [appDelegate scheduleAlarm:alarm];
    [appDelegate saveContext];
}

- (void)formatCell:(KSSAlarmTableViewCell *)cell withAlarm:(Alarm *)alarm {
    
    [dateFormatter setDateFormat:@"h:mm"];
    cell.timeLabel.text = [dateFormatter stringFromDate:alarm.time];
    [cell.timeLabel sizeToFit];
    
    [dateFormatter setDateFormat:@"a"];
    cell.meridiemLabel.text = [dateFormatter stringFromDate:alarm.time];
    CGRect meridiemPosition = cell.meridiemLabel.frame;
    meridiemPosition.origin.x = cell.timeLabel.frame.origin.x + cell.timeLabel.frame.size.width;
    [cell.meridiemLabel removeFromSuperview];
    cell.meridiemLabel.frame = meridiemPosition;
    [cell.contentView addSubview:cell.meridiemLabel];
    
    cell.deviceLabel.text = alarm.device.name ?: @"No deivce selected";
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
    
    Alarm *alarm = (Alarm *)[alarmsArray objectAtIndex:indexPath.row];
    [self formatCell:cell withAlarm:alarm];
    
    cell.alarm = alarm;
    
    [cell.isSetSwitch setOn:[alarm.isSet boolValue]];
    [cell.isSetSwitch addTarget:self action:@selector(toggleAlarmSet:) forControlEvents:UIControlEventValueChanged];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showAddAlarm"]) {
        KSSAddAlarmViewController *controller = [(UINavigationController *)segue.destinationViewController viewControllers].lastObject;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"showEditAlarm"]) {
        KSSEditAlarmViewController *controller = segue.destinationViewController;
        controller.delegate = self;
        controller.alarm = [alarmsArray objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    }
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
        Alarm *alarm = [alarmsArray objectAtIndex:[indexPath row]];
        [appDelegate.managedObjectContext deleteObject:alarm];
        [alarmsArray removeObject:alarm];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [appDelegate scheduleAlarm:alarm];
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
