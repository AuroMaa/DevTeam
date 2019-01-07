//
//  SettingsViewController.m
//  DataLogger
//
//  Created by Madhu A on 7/19/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import "SettingsViewController.h"

#import "SettingsTableViewCell.h"
#import "CheckBoxTableViewCell.h"
#import "CommonTableViewCell.h"
#import "HeartBeatRemoteConfig.h"
#import "constants.h"

typedef enum {
    ALTS_TESTSETTINGS_SECTIOM,
    DDCI_ALTEST_SECTION,
} SETTINGS_INFO_SECTION;


@interface SettingsViewController () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate> {
    CheckBoxTableViewCell *checkBoxCell;
    NSString *string;
    NSUserDefaults *defaults;
    NSString *UpdatedinitialDelay;
    NSString *updatedBaroRate;
    NSString *updatedLocationRate;
    NSString *updatedConfigID;
    NSString *updateTestConfigUrl;
    NSString *updateForegroundTestUrl;
    NSString *updateBackgroundTestUrl;


    CGFloat _initialTVHeight;
    UITextField *txFldCurrent;

}
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableViewObj;
@property (nonatomic,strong) HeartBeatRemoteConfig *hearbeatConfig;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Settings";
   UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc]
                                       initWithTitle:@"Reload"
                                       style:UIBarButtonItemStylePlain
                                       target:self
                                       action:@selector(reloadConfigID)];
    self.navigationItem.rightBarButtonItem = reloadButton;
   self.navigationController.navigationBar.topItem.rightBarButtonItem = reloadButton;
   
    
    [self.tableViewObj registerNib:[UINib nibWithNibName:@"SettingsTableViewCell" bundle:nil] forCellReuseIdentifier:@"reusableCell"];
    [self.tableViewObj registerNib:[UINib nibWithNibName:@"CheckBoxTableViewCell" bundle:nil] forCellReuseIdentifier:@"checkBoxReuse"];
    [self.tableViewObj registerNib:[UINib nibWithNibName:@"CommonTableViewCell" bundle:nil] forCellReuseIdentifier:@"commonCellReuse"];
    
    defaults = [NSUserDefaults standardUserDefaults];
    updatedConfigID = [defaults objectForKey:@"configId"];
    UpdatedinitialDelay = [defaults objectForKey:@"DelayinMS"];
    updatedBaroRate = [defaults objectForKey:@"BaroUpdateRate"];
    updatedLocationRate = [defaults objectForKey:@"LocationUpdateRate"];
    updateTestConfigUrl = [defaults objectForKey:@"HeartBeatTestUrl"];
    updateForegroundTestUrl = [defaults objectForKey:@"ForegroundTestingUrl"];
    updateBackgroundTestUrl = [defaults objectForKey:@"BackgroundTestingUrl"];

}
- (void)reloadConfigID
{
    [txFldCurrent resignFirstResponder];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(ReloadConfig) userInfo:nil repeats:false];
}
-(void)ReloadConfig
{
    [self.navigationController popViewControllerAnimated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Reload" object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- TableView Delegate Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    switch ((SETTINGS_INFO_SECTION)section) {
        case ALTS_TESTSETTINGS_SECTIOM:
            return 4;
        case DDCI_ALTEST_SECTION:
            return 9;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SettingsTableViewCell *  cell;
    NSDictionary *configSettingsDict = [HeartBeatRemoteConfig sharedConfigSettings].configValuesdict;

    switch ((SETTINGS_INFO_SECTION)indexPath.section) {
        case ALTS_TESTSETTINGS_SECTIOM: {
            switch (indexPath.row) {
                case 0 : {
                    cell = (SettingsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"reusableCell" forIndexPath:indexPath];
                    cell.Header1Label.text = SettingsTableHeader1;
                    cell.header2Label.text = Configid;
                    if (!(updatedConfigID.length == 0)) {
                        cell.TextFldInput.text = updatedConfigID;
                    } else {
                     cell.TextFldInput.text = [NSString stringWithFormat:@"%d",11];
                    }
                    cell.TextFldInput.tag = indexPath.row;
                    cell.TextFldInput.delegate=self;
                    string = @"configId";
                    break;
                }
                case 1 : {
                    CommonTableViewCell *cell = (CommonTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"commonCellReuse" forIndexPath:indexPath];
                    cell.commonLabel1.text = TestingServerConnec;
                    if (!(updateTestConfigUrl.length == 0)) {
                        cell.urlTextView.text = updateTestConfigUrl;
                    } else {
                    cell.urlTextView.text = hearBeatAPIURL;
                    }
                    cell.urlTextView.delegate = self;
                    return cell;
                    break;
                }
                case 2 : {
                    CommonTableViewCell *cell = (CommonTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"commonCellReuse" forIndexPath:indexPath];
                    cell.commonLabel1.text = TestingServerConnec1;
                    if (!(updateForegroundTestUrl.length == 0)) {
                        cell.urlTextView.text = updateForegroundTestUrl;
                    } else {
                        cell.urlTextView.text = locationRequet;
                    }
                    cell.urlTextView.delegate = self;
                    return cell;
                    break;

                } case 3 : {
                    CommonTableViewCell *cell = (CommonTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"commonCellReuse" forIndexPath:indexPath];
                    cell.commonLabel1.text = TestingServerConnec2;
                    if (!(updateBackgroundTestUrl.length == 0)) {
                        cell.urlTextView.text = updateBackgroundTestUrl;
                    } else {
                        cell.urlTextView.text = autoReportRequest;
                    }
                    cell.urlTextView.delegate = self;
                    return cell;
                    break;

                }
                default:
                    break;
            }
            break;
        }
        case DDCI_ALTEST_SECTION: {
            switch (indexPath.row) {
                case 0: {
                    cell = (SettingsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"reusableCell" forIndexPath:indexPath];
                    cell.Header1Label.text = DDataCollectionHeader;
                    cell.header2Label.text = DelayInms;
                    NSString * delayStr = [[configSettingsDict objectForKey:@"Autotest"] objectForKey:@"Initial_delay"];
                    double dval = [delayStr doubleValue];
                    if (!(UpdatedinitialDelay.length == 0)) {
                        cell.TextFldInput.text = [NSString stringWithFormat:@"%@",UpdatedinitialDelay];
                    } else {
                    cell.TextFldInput.text = [NSString stringWithFormat:@"%0.f",dval];
                    }
                    cell.TextFldInput.tag = indexPath.row;
                    cell.TextFldInput.delegate=self;
                    string = @"DelayinMS";

                    break;
                }
                case 1: {
                    checkBoxCell = (CheckBoxTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"checkBoxReuse" forIndexPath:indexPath];
                    checkBoxCell.commonCellLabelTxt.text = EnableBarometer;
                    BOOL enableBaro = [[configSettingsDict objectForKey:@"Autotest"] objectForKey:@"Enable_barometer"];
                    if (enableBaro) {
                        [checkBoxCell.checkBoxButton setImage:[UIImage imageNamed:@"Checked-Checkbox-icon.png"] forState:UIControlStateNormal];
                        checkBoxCell.checkBoxButton.selected = YES;
                    }
                    [checkBoxCell.checkBoxButton addTarget:self action:@selector(checkBoxButtonclicked:) forControlEvents:UIControlEventTouchUpInside];
//                    checkBoxCell.checkBoxButton.selected = NO;
                    return checkBoxCell;
                }
                case 2 : {
                    CommonTableViewCell *cell = (CommonTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"commonCellReuse" forIndexPath:indexPath];
                    cell.commonLabel1.text = BaroUpdateRate;
                    NSString * baroUpdateRateStr = [[configSettingsDict objectForKey:@"Autotest"] objectForKey:@"Baro_update_rate_in_ms"];
                    double bval = [baroUpdateRateStr doubleValue];
                    cell.commonLabel2.hidden=YES;
                    cell.urlTextView.hidden = YES;
                    if (!(updatedBaroRate.length == 0)) {
                        cell.commonTxtFld.text = [NSString stringWithFormat:@"%@",updatedBaroRate];
                    } else {
                    cell.commonTxtFld.text = [NSString stringWithFormat:@"%0.f",bval];
                    }
                    cell.commonTxtFld.delegate = self;
                    cell.commonTxtFld.tag = indexPath.row;
                    string = @"BaroUpdateRate";
                    return cell;

                }
                case 3 : {
                    checkBoxCell = (CheckBoxTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"checkBoxReuse" forIndexPath:indexPath];
                    checkBoxCell.commonCellLabelTxt.text = EnableLocation;
                    BOOL enableLocation = [[configSettingsDict objectForKey:@"Autotest"] objectForKey:@"Enable_location"];
                    if (enableLocation) {
                        [checkBoxCell.checkBoxButton setImage:[UIImage imageNamed:@"Checked-Checkbox-icon.png"] forState:UIControlStateNormal];
                        checkBoxCell.checkBoxButton.selected = YES;
                    }
                    [checkBoxCell.checkBoxButton addTarget:self action:@selector(checkBoxButtonclicked:) forControlEvents:UIControlEventTouchUpInside];
//                    checkBoxCell.checkBoxButton.selected = NO;
                    return checkBoxCell;

                }
                case 4 : {
                    CommonTableViewCell *cell = (CommonTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"commonCellReuse" forIndexPath:indexPath];
                    cell.commonLabel1.text = LocationUpdateRate;
                    NSString * locationUpdateRateStr = [[configSettingsDict objectForKey:@"Autotest"] objectForKey:@"Location_update_rate_in_ms"];
                    double lval = [locationUpdateRateStr doubleValue];
                    cell.commonLabel2.hidden=YES;
                    cell.urlTextView.hidden = YES;
                    if (!(updatedLocationRate.length == 0)) {
                        cell.commonTxtFld.text = [NSString stringWithFormat:@"%@",updatedLocationRate];
                    } else {
                    cell.commonTxtFld.text = [NSString stringWithFormat:@"%0.f",lval];
                    }
                    cell.commonTxtFld.delegate = self;
                    cell.commonTxtFld.tag = indexPath.row;
                    string = @"LocationUpdateRate";
                    return cell;
                }
                    
                case 5 : {
                    CommonTableViewCell *cell = (CommonTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"commonCellReuse" forIndexPath:indexPath];
                    cell.commonLabel1.text = ResultCount;
                    cell.commonLabel2.hidden=YES;
                    cell.urlTextView.hidden = YES;
                    cell.commonTxtFld.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"ResultCount"];
                    cell.commonTxtFld.delegate = self;
                    cell.commonTxtFld.tag = indexPath.row;
                    string = @"LocationUpdateRate";
                    return cell;
                }
                case 6 : {
                   CommonTableViewCell *cell = (CommonTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"commonCellReuse" forIndexPath:indexPath];
                    cell.commonLabel1.text = VersionNumber;
                    cell.commonLabel2.hidden=YES;
                    cell.urlTextView.hidden = YES;
                    cell.commonTxtFld.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
                    cell.commonTxtFld.delegate = self;
                    cell.commonTxtFld.userInteractionEnabled = false;
                    cell.commonTxtFld.tag = indexPath.row;
                    string = @"VersionNumber";
                    return cell;
                }
                case 7 : {
                    CommonTableViewCell *cell = (CommonTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"commonCellReuse" forIndexPath:indexPath];
                    cell.commonLabel1.text = BuildNumber;
                    cell.commonLabel2.hidden=YES;
                    cell.urlTextView.hidden = YES;
                    cell.commonTxtFld.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
                    cell.commonTxtFld.userInteractionEnabled = false;
                    cell.commonTxtFld.delegate = self;
                    cell.commonTxtFld.tag = indexPath.row;
                    string = @"BuildNumber";
                    return cell;
                }
                case 8: {
                    checkBoxCell = (CheckBoxTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"checkBoxReuse" forIndexPath:indexPath];
                    checkBoxCell.commonCellLabelTxt.text = EnableARKit;
                    BOOL enableAR = [defaults boolForKey:@"EnableARKit"];
                    if (enableAR) {
                        [checkBoxCell.checkBoxButton setImage:[UIImage imageNamed:@"Checked-Checkbox-icon.png"] forState:UIControlStateNormal];
                        checkBoxCell.checkBoxButton.selected = YES;
                    }
                    [checkBoxCell.checkBoxButton addTarget:self action:@selector(btnArkitClicked:) forControlEvents:UIControlEventTouchUpInside];
                    return checkBoxCell;
                }
                default:
                    break;
            }
            
            break;
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch ((SETTINGS_INFO_SECTION)indexPath.section) {
        case ALTS_TESTSETTINGS_SECTIOM: {
            break;
        }
        case DDCI_ALTEST_SECTION: {
            switch (indexPath.row) {
                case 1 : {
                    
                    break;
                }
                    
                    break;
                case 3 : {
                    break;
                }
                    
                default:
                    break;
            }
            break;
        }
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch ((SETTINGS_INFO_SECTION)indexPath.section) {
        case ALTS_TESTSETTINGS_SECTIOM: {
            switch (indexPath.row) {
                case 1:
                    return tableView.rowHeight = UITableViewAutomaticDimension;
                    break;
                case 2:
                    return tableView.rowHeight = UITableViewAutomaticDimension;
                    break;
                case 3 :
                    return tableView.rowHeight = UITableViewAutomaticDimension;
                    break;
                default:
                    break;
            }
        }
        case DDCI_ALTEST_SECTION: {
            switch (indexPath.row) {
                case 1:
                    return 45;
                    break;
                case 2:
                    return 75;
                    break;
                case 3 :
                    return 45;
                    break;
                case 4:
                    return 75;
                case 5:
                    return 75;
                case 6:
                    return 75;
                case 7:
                    return 75;
                default:
                    break;
            }
            
            break;
        }
    }
    return 90;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return (action == @selector(paste:));
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(paste:)){
        CommonTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.commonLabel2.text = nil;
        NSString * setUrlString = [UIPasteboard generalPasteboard].string;
        cell.urlTextView.text = setUrlString;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"serverUrlChanged" object:setUrlString];
    }
}
-(void)btnArkitClicked:(UIButton *)button {
    
    if (button.selected == YES) {
        [button setImage:[UIImage imageNamed:@"Unchecked-Checkbox-icon.png"] forState:UIControlStateNormal];
        button.selected = NO;
        [defaults setBool:NO forKey:@"EnableARKit"];
    } else {
        [button setImage:[UIImage imageNamed:@"Checked-Checkbox-icon.png"] forState:UIControlStateNormal];
        button.selected = YES;
        [defaults setBool:YES forKey:@"EnableARKit"];
    }
}

-(void)checkBoxButtonclicked:(UIButton *)button {
    
    if (button.selected == YES) {
        [button setImage:[UIImage imageNamed:@"Unchecked-Checkbox-icon.png"] forState:UIControlStateNormal];
        button.selected = NO;
    } else {
        [button setImage:[UIImage imageNamed:@"Checked-Checkbox-icon.png"] forState:UIControlStateNormal];
        button.selected = YES;
        //Checked-Checkbox-icon.png

    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    txFldCurrent = textField;
    NSIndexPath *indexPath = [self TextFieldIndexpath:textField];
    
    if ((indexPath.section == 1 && indexPath.row == 2)||(indexPath.section == 1 && indexPath.row == 4)||(indexPath.section == 1 && indexPath.row == 5)) {
        CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:self.tableViewObj];
        CGPoint contentOffset = self.tableViewObj.contentOffset;
        contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height);
        NSLog(@"contentOffset is: %@", NSStringFromCGPoint(contentOffset));
        [self.tableViewObj setContentOffset:contentOffset animated:YES];
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSLog(@"Selected Cell is:%ld",(long)textField.tag);
    [textField resignFirstResponder];
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero
                                                  toView: self.tableViewObj];
        NSIndexPath *indexPath = [self.tableViewObj indexPathForRowAtPoint:buttonPosition];
        
        [self.tableViewObj scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    }
    return YES;
}

#pragma mark - Get textfield indexpath
- (NSIndexPath *)TextFieldIndexpath:(UITextField *)textField
{
    CGPoint point = [textField.superview convertPoint:textField.frame.origin toView:self.tableViewObj];
    NSIndexPath * indexPath = [self.tableViewObj indexPathForRowAtPoint:point];
    NSLog(@"Indexpath = %@", indexPath);
    return indexPath;
}


-(void)textFieldDidEndEditing:(UITextField *)textField {

    NSIndexPath *indexPath = [self TextFieldIndexpath:textField];
    
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        if ([self.testingConfigDelegate respondsToSelector:@selector(settingsRemoteConfigValuesChangedfor:withConfigValue:)]) {
            [self.testingConfigDelegate settingsRemoteConfigValuesChangedfor:@"configId" withConfigValue:textField.text];
        }
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        if ([self.testingConfigDelegate respondsToSelector:@selector(settingsRemoteConfigValuesChangedfor:withConfigValue:)]) {
            [self.testingConfigDelegate settingsRemoteConfigValuesChangedfor:@"DelayinMS" withConfigValue:textField.text];
        }
        
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        if ([self.testingConfigDelegate respondsToSelector:@selector(settingsRemoteConfigValuesChangedfor:withConfigValue:)]) {
            [self.testingConfigDelegate settingsRemoteConfigValuesChangedfor:@"BaroUpdateRate" withConfigValue:textField.text];
        }
        
    } else if (indexPath.section == 1 && indexPath.row == 5) {
        if ([self.testingConfigDelegate respondsToSelector:@selector(settingsRemoteConfigValuesChangedfor:withConfigValue:)]) {
            [self.testingConfigDelegate settingsRemoteConfigValuesChangedfor:@"ResultCount" withConfigValue:textField.text];
        }
        
    }else {
        if ([self.testingConfigDelegate respondsToSelector:@selector(settingsRemoteConfigValuesChangedfor:withConfigValue:)]) {
            [self.testingConfigDelegate settingsRemoteConfigValuesChangedfor:@"LocationUpdateRate" withConfigValue:textField.text];
        }
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if([text isEqualToString:@"\n"])
        [textView resignFirstResponder];
    return YES;
}
-(void)textViewDidEndEditing:(UITextView *)textView {
    CGPoint point = [textView.superview convertPoint:textView.frame.origin toView:self.tableViewObj];
    NSIndexPath * indexPath = [self.tableViewObj indexPathForRowAtPoint:point];
    NSLog(@"Indexpath = %@", indexPath);
    if (indexPath.section == 0 && indexPath.row == 1) {
        if ([self.testingConfigDelegate respondsToSelector:@selector(settingsRemoteConfigValuesChangedfor:withConfigValue:)]) {
            [self.testingConfigDelegate settingsRemoteConfigValuesChangedfor:@"HeartBeatTestUrl" withConfigValue:textView.text];
        }
    } else if (indexPath.section == 0 && indexPath.row == 2) {
        if ([self.testingConfigDelegate respondsToSelector:@selector(settingsRemoteConfigValuesChangedfor:withConfigValue:)]) {
            [self.testingConfigDelegate settingsRemoteConfigValuesChangedfor:@"ForegroundTestingUrl" withConfigValue:textView.text];
        }

    } else {
        if ([self.testingConfigDelegate respondsToSelector:@selector(settingsRemoteConfigValuesChangedfor:withConfigValue:)]) {
            [self.testingConfigDelegate settingsRemoteConfigValuesChangedfor:@"BackgroundTestingUrl" withConfigValue:textView.text];
        }
    }

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
