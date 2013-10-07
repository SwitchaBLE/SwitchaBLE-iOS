//
//  KSSAddAlarmViewController.m
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/8/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import "KSSAppDelegate.h"
#import "KSSAddAlarmViewController.h"
#import "Alarm.h"

@interface KSSAddAlarmViewController ()

@end

@implementation KSSAddAlarmViewController

//@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelAlarm:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveAlarm:(id)sender
{
    KSSAppDelegate *appDelegate = (KSSAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    Alarm *alarm = (Alarm *)[NSEntityDescription insertNewObjectForEntityForName:@"Alarm" inManagedObjectContext:managedObjectContext];
    
    [alarm setTime:[self.datePicker date]];
    [alarm setIsSet:@1];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *alarmComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[alarm time]];
    NSDateComponents *nowComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    
    [alarmComponents setYear:[nowComponents year]];
    [alarmComponents setMonth:[nowComponents month]];
    [alarmComponents setDay:[nowComponents day]];
    
    NSDate *newAlarmTime = [calendar dateFromComponents:alarmComponents];
    if (newAlarmTime < [NSDate date]) {
        newAlarmTime = [newAlarmTime dateByAddingTimeInterval:60 * 60 * 24 * 1];
    }
    
    [alarm setTime:newAlarmTime];
    
    NSError *saveError = nil;
    if (![managedObjectContext save:&saveError]) {
        //TODO handle error
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate addAlarmViewController:self didSaveAlarm:alarm];
    }];
}

@end
