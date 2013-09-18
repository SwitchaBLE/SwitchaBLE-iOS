//
//  KSSAlarmTableViewCell.h
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/15/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Alarm.h"
#import "KSSAlarmIsSetSwitch.h"

@class KSSAlarmIsSetSwitch;

@interface KSSAlarmTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet KSSAlarmIsSetSwitch *isSetSwitch;
@property Alarm *alarm;

@end
