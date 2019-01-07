//
//  ResponseViewController.h
//  DataLogger
//
//  Created by Abhilash Tyagi on 11/23/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ResponseViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tblResponse;
@property (strong, nonatomic) NSMutableArray* arrResponse;
@end

NS_ASSUME_NONNULL_END
