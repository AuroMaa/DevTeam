//
//  SettingsTableViewCell.h
//  DataLogger
//
//  Created by Madhu A on 7/23/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *Header1Label;
@property (weak, nonatomic) IBOutlet UILabel *header2Label;
@property (weak, nonatomic) IBOutlet UITextField *TextFldInput;

@end
