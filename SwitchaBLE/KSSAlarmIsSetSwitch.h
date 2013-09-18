//
//  KSSAlarmIsSetSwitch.h
//  SwitchaBLE
//
//  Created by Andrew Branch on 9/16/13.
//  Copyright (c) 2013 Killascopes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSSAlarmTableViewCell.h"

@class KSSAlarmTableViewCell;

@interface KSSAlarmIsSetSwitch : UISwitch

@property (weak) IBOutlet KSSAlarmTableViewCell *cell;

@end
