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
	self.datePicker.date = self.alarm.time;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveAlarm:(id)sender {
    
    self.alarm.time = self.datePicker.date;
    self.alarm.isSet = @1;
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *alarmComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:self.alarm.time];
    NSDateComponents *nowComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    
    alarmComponents.year = nowComponents.year;
    alarmComponents.month = nowComponents.month;
    alarmComponents.day = nowComponents.day;
    
    NSDate *newAlarmTime = [calendar dateFromComponents:alarmComponents];
    if ([newAlarmTime compare:[NSDate date]] == NSOrderedAscending) {
        newAlarmTime = [newAlarmTime dateByAddingTimeInterval:60 * 60 * 24 * 1];
    }
    
    self.alarm.time = newAlarmTime;
    
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate editAlarmController:self didFinishEditingAlarm:self.alarm];
    
}

- (void)deleteAlarm:(id)sender {
    
    KSSAppDelegate *appDelegate = (KSSAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.managedObjectContext deleteObject:self.alarm];
    
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate editAlarmController:self didFinishDeletingAlarm:self.alarm];
    
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
        self.embeddedView.delegate = self;
        self.embeddedView.selectedDevice = self.alarm.device;
    }
}

@end
