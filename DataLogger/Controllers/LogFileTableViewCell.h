//
//  LogFileTableViewCell.h
//  DataLogger
//
//  Created by Abhilash Tyagi on 03/01/19.
//  Copyright © 2019 Polaris Wireless Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogFileTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblFileName;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;
@property (weak, nonatomic) IBOutlet UIButton *btnSelect;
@end
