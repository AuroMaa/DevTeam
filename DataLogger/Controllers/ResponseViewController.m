//
//  ResponseViewController.m
//  DataLogger
//
//  Created by Abhilash Tyagi on 11/23/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import "ResponseViewController.h"
#import "DLUploadTestResultsData.h"
#import "ResponseTableViewCell.h"
#import "AppDelegate.h"
@interface ResponseViewController ()<UITableViewDelegate,UITableViewDataSource>
@end

@implementation ResponseViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tblResponse.delegate = self;
    _tblResponse.dataSource = self;
    _arrResponse = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] valueForKey:@"arrResponse"]];
    [_tblResponse reloadData];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(reloadtable:)
     name:@"ResponseReceived"
     object:nil];
    
}
-(void)reloadtable:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_arrResponse = [[NSUserDefaults standardUserDefaults] valueForKey:@"arrResponse"];
        [self->_tblResponse reloadData];
    });
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 490.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ResponseTableViewCell";
    ResponseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                                  forIndexPath:indexPath];
    
    NSData *dictResData = [_arrResponse objectAtIndex:indexPath.row];
    NSError *error = nil;
    NSDictionary *jsondict = [NSJSONSerialization JSONObjectWithData:dictResData options:kNilOptions error:&error];
    NSDictionary *ResultsDict = [jsondict objectForKey:@"response"];
    DLUploadTestResultsData *dictRes = [[DLUploadTestResultsData alloc]initWithDictionary:ResultsDict error:&error];
    
    [cell.responseNoLbl setText:[NSString stringWithFormat:@"%ld",indexPath.row + 1]];
    NSArray *estL = dictRes.estLlh;
    
    [cell.estlLHLbl setText:[NSString stringWithFormat:@"%@",[estL componentsJoinedByString:@", "]]];
    [cell.horzUncLbl setText:[NSString stringWithFormat:@"%ld",[dictRes.horzUnc integerValue]]];
    [cell.verUncLbl setText:[NSString stringWithFormat:@"%ld",[dictRes.vertUnc integerValue]]];
    [cell.providerLbl setText:dictRes.provider];
    NSDictionary *deviceDetails = dictRes.device;
    NSDictionary *groundtruth = dictRes.groundtruth;
    
    [cell.imsiLbl setText:[NSString stringWithFormat:@"%@",[deviceDetails objectForKey:@"imsi"]]];
    [cell.gtTimeLbl setText:[NSString stringWithFormat:@"%@",[groundtruth objectForKey:@"time"]]];
    [cell.gtUnixLbl setText:[NSString stringWithFormat:@"%@",[groundtruth objectForKey:@"request_time_unix"]]];
    [cell.locationLbl setText:dictRes.location_id];
    [cell.messageLbl setText:dictRes.message];
    [cell.rq_st_time_Lbl setText:[NSString stringWithFormat:@"%ld",[dictRes.request_start_time integerValue]]];
    [cell.rq_Rcvd_Time_Lbl setText:[NSString stringWithFormat:@"%ld",[dictRes.request_received_time integerValue]]];
    [cell.rq_Rspnd_Lbl setText:[NSString stringWithFormat:@"%ld",[dictRes.request_respond_time integerValue]]];
    [cell.timeFixLbl setText:[NSString stringWithFormat:@"%ld",[dictRes.time_to_fix integerValue]]];
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrResponse.count;
}

- (IBAction)btnDeleteResponseClicked:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[[NSMutableArray alloc] init] forKey:@"arrResponse"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _arrResponse = [[NSUserDefaults standardUserDefaults] valueForKey:@"arrResponse"];
    [_tblResponse reloadData];
}



@end
