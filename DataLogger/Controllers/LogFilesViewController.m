//
//  LogFilesViewController.m
//  DataLogger
//
//  Created by Abhilash Tyagi on 03/01/19.
//  Copyright © 2019 Polaris Wireless Inc. All rights reserved.
//

#import "LogFilesViewController.h"

@interface LogFilesViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation LogFilesViewController
NSArray *matchingPaths;
BOOL isMultpleSelection;
NSMutableArray *selectlectPaths;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    // Do any additional setup after loading the view.
    
    /*
     NSError *err;
     NSFileManager *fileManager = [NSFileManager defaultManager];
     NSURL *documentDirectoryURL = [fileManager URLForDirectory:NSDocumentDirectory
     inDomain:NSUserDomainMask
     appropriateForURL:nil
     create:false
     error:&err];

    [NSTimer scheduledTimerWithTimeInterval:5 repeats:YES block:^(NSTimer * _Nonnull timer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *err;
            NSMutableArray *files = [[fileManager contentsOfDirectoryAtURL:documentDirectoryURL
                                                includingPropertiesForKeys:@[NSURLCreationDateKey]
                                                                   options:0
                                                                     error:&err] mutableCopy];
            
            BOOL ascending = YES;
            
            [files sortUsingComparator:^(NSURL *lURL, NSURL *rURL) {
                NSDate *lDate, *rDate;
                [lURL getResourceValue:&lDate forKey:NSURLCreationDateKey error:nil];
                [rURL getResourceValue:&rDate forKey:NSURLCreationDateKey error:nil];
                return ascending ? [lDate compare:rDate] : [rDate compare:lDate];
            }];

            matchingPaths = [NSArray arrayWithArray:file];
            [self->_tblFiles reloadData];
        });
        
    }];
   */
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    documentsDirectory = [documentsDirectory stringByAppendingString:@"/Requests"];
    [NSTimer scheduledTimerWithTimeInterval:5 repeats:YES block:^(NSTimer * _Nonnull timer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            matchingPaths = [self listFileAtPath:documentsDirectory];
            [self->_tblFiles reloadData];
        });

    }];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    selectlectPaths = [[NSMutableArray alloc]init];
    UIButton *btnSelect = [UIButton buttonWithType:UIButtonTypeSystem];
    [btnSelect setFrame:CGRectMake(0, 0, 80, 44)];
    [btnSelect setTitle:@"Select" forState:UIControlStateNormal];
    [btnSelect addTarget:self action:@selector(btnSelectMultipleClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *vw = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 44)];
    [vw addSubview:btnSelect];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:vw];

        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Back"
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(btnBackClicked:)];
    self.navigationItem.leftBarButtonItem = backButton;

    self.navigationController.navigationBar.topItem.leftBarButtonItem = backButton;

}
-(void)btnSelectMultipleClicked:(UIButton*)sender
{
    
    isMultpleSelection = !isMultpleSelection;
    
    if (isMultpleSelection)
    {
        [sender setTitle:@"Share" forState:UIControlStateNormal];
    }
    else
    {
        [sender setTitle:@"Select" forState:UIControlStateNormal];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        documentsDirectory = [documentsDirectory stringByAppendingString:@"/Requests/"];
        NSMutableArray *objectsToShare = [[NSMutableArray alloc]init];

        for (int i=0;i<selectlectPaths.count-1;i++)
        {
            NSString *strTemp = [selectlectPaths objectAtIndex:i];
            documentsDirectory = [documentsDirectory stringByAppendingString:strTemp];
            
            NSURL *myWebsite = [NSURL fileURLWithPath:documentsDirectory];
            
            [objectsToShare addObject:myWebsite];
        }
        
        NSArray *arrShare = [NSArray arrayWithArray:objectsToShare];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:arrShare applicationActivities:nil];
        
        [self presentViewController:activityVC animated:YES completion:nil];

    }
    [self.tblFiles reloadData];
    
}
-(void)btnBackClicked:(UIButton*)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSArray *)listFileAtPath:(NSString *)path
{
    int count;
    
    NSMutableArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    
    for (count = 0; count < (int)[directoryContent count]; count++)
    {
        NSString *strDir = [directoryContent objectAtIndex:count];
        
        if ([strDir containsString:@".txt"] == NO)
        {
            [directoryContent removeObjectAtIndex:count];
        }
        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
    }
    return directoryContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"LogFileTableViewCell";
    LogFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                                  forIndexPath:indexPath];
    NSString *strTemp = [matchingPaths objectAtIndex:indexPath.row];
    if (isMultpleSelection)
    {
        cell.btnShare.hidden = YES;
        cell.btnSelect.hidden = NO;
    }
    else
    {
        cell.btnShare.hidden = NO;
        cell.btnSelect.hidden = YES;
    }
    cell.lblFileName.text = strTemp;
    cell.btnShare.tag = 1000+indexPath.row;
    [cell.btnShare addTarget:self action:@selector(btnShareClicked:) forControlEvents:UIControlEventTouchUpInside];

    cell.btnSelect.tag = 10000+indexPath.row;
    [cell.btnSelect addTarget:self action:@selector(btnSelectClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([selectlectPaths containsObject:strTemp])
    {
        cell.btnSelect.selected = YES;
    }
    else
    {
        cell.btnSelect.selected = NO;
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return matchingPaths.count;
}
-(void)btnSelectClicked:(UIButton*)sender
{
    sender.selected = !sender.selected;
    long index = sender.tag - 10000;
    NSString *strTemp = [matchingPaths objectAtIndex:index];
    if (sender.selected)
    {
        [selectlectPaths addObject:strTemp];
    }
    else
    {
        if ([selectlectPaths containsObject:strTemp])
        {
            [selectlectPaths removeObject:strTemp];
        }
    }
}
-(void)btnShareClicked:(UIButton*)sender
{
    long index = sender.tag - 1000;
    NSString *strTemp = [matchingPaths objectAtIndex:index];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    documentsDirectory = [documentsDirectory stringByAppendingString:@"/Requests/"];
    documentsDirectory = [documentsDirectory stringByAppendingString:strTemp];

    NSURL *myWebsite = [NSURL fileURLWithPath:documentsDirectory];
    
    NSArray *objectsToShare = @[myWebsite];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
//    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
//                                   UIActivityTypePrint,
//                                   UIActivityTypeAssignToContact,
//                                   UIActivityTypeSaveToCameraRoll,
//                                   UIActivityTypeAddToReadingList,
//                                   UIActivityTypePostToFlickr,
//                                   UIActivityTypePostToVimeo];
//    
//    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];

}
@end
