//
//  CheckBoxTableViewCell.h
//  DataLogger
//
//  Created by Madhu A on 7/23/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckBoxTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *commonCellLabelTxt;
@property (weak, nonatomic) IBOutlet UIButton *checkBoxButton;

@end
