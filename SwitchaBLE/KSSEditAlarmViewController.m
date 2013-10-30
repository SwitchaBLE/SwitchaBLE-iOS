//
//  KSSEditAlarmViewController.m
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/17/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import "KSSEditAlarmViewController.h"
#import "KSSAppDelegate.h"
#import "Device.h"

@interface KSSEditAlarmViewController ()

@end

@implementation KSSEditAlarmViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.datePicker setDate:self.alarm.time];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveAlarm:(id)sender {
    
    KSSAppDelegate *appDelegate = (KSSAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.alarm setTime:[self.datePicker date]];
    [self.alarm setIsSet:@1];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *alarmComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[self.alarm time]];
    NSDateComponents *nowComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    
    [alarmComponents setYear:[nowComponents year]];
    [alarmComponents setMonth:[nowComponents month]];
    [alarmComponents setDay:[nowComponents day]];
    
    NSDate *newAlarmTime = [calendar dateFromComponents:alarmComponents];
    if (newAlarmTime < [NSDate date]) {
        newAlarmTime = [newAlarmTime dateByAddingTimeInterval:60 * 60 * 24 * 1];
    }
    
    [self.alarm setTime:newAlarmTime];
    
    [appDelegate saveContext];
    
    //TODO communicate with device
    
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate editAlarmViewController:self didFinishEditingAlarm:self.alarm];
    
}

- (void)deleteAlarm:(id)sender {
    
    KSSAppDelegate *appDelegate = (KSSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.managedObjectContext deleteObject:self.alarm];
    [appDelegate saveContext];
    
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate editAlarmViewController:self didFinishDeletingAlarm:self.alarm];
    
}

- (void)alarmDetailViewController:(KSSAlarmDetailViewController *)controller didFinishDeletingAlarmBySender:(id)sender {
    [self deleteAlarm:sender];
}

- (void)alarmDetailViewController:(KSSAlarmDetailViewController *)controller didChooseDevice:(Device *)device {
    self.alarm.device = device;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"embedEditTableView"]) {
        self.embeddedView = (KSSAlarmDetailViewController *)segue.destinationViewController;
        [self.embeddedView setDelegate:self];
    }
}

@end
