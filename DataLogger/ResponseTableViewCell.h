//
//  ResponseTableViewCell.h
//  DataLogger
//
//  Created by Abhilash Tyagi on 11/23/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ResponseTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *responseNoLbl;
@property (weak, nonatomic) IBOutlet UILabel *estlLHLbl;
@property (weak, nonatomic) IBOutlet UILabel *horzUncLbl;
@property (weak, nonatomic) IBOutlet UILabel *verUncLbl;
@property (weak, nonatomic) IBOutlet UILabel *providerLbl;
@property (weak, nonatomic) IBOutlet UILabel *imsiLbl;
@property (weak, nonatomic) IBOutlet UILabel *gtTimeLbl;
@property (weak, nonatomic) IBOutlet UILabel *gtUnixLbl;
@property (weak, nonatomic) IBOutlet UILabel *locationLbl;
@property (weak, nonatomic) IBOutlet UILabel *messageLbl;
@property (weak, nonatomic) IBOutlet UILabel *rq_st_time_Lbl;
@property (weak, nonatomic) IBOutlet UILabel *rq_Rcvd_Time_Lbl;
@property (weak, nonatomic) IBOutlet UILabel *rq_Rspnd_Lbl;
@property (weak, nonatomic) IBOutlet UILabel *timeFixLbl;


@end

NS_ASSUME_NONNULL_END
