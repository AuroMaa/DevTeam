//
//  CommonTableViewCell.h
//  DataLogger
//
//  Created by Madhu A on 7/23/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *commonLabel1;
@property (weak, nonatomic) IBOutlet UILabel *commonLabel2;
@property (weak, nonatomic) IBOutlet UITextField *commonTxtFld;
@property (weak, nonatomic) IBOutlet UITextView *urlTextView;

@end
