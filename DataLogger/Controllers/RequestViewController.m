//
//  RequestViewController.m
//  DataLogger
//
//  Created by Abhilash Tyagi on 11/20/18.
//  Copyright © 2018 Polaris Wireless Inc. All rights reserved.
//

#import "RequestViewController.h"
#import "LogFilesViewController.h"
@interface RequestViewController ()
@end

@implementation RequestViewController
    BOOL isUpdate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(updateRequest:)
     name:@"request"
     object:nil];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;

    isUpdate = true;
}
- (IBAction)btnShowLogFilesClicked:(UIButton *)sender {
    LogFilesViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LogFilesViewController"];
    [self.navigationController pushViewController:vc animated:YES];

}

-(void)updateRequest:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Adding Annotation at %@",[dict valueForKey:@"json"]);
        if (isUpdate)
        {
            self->_txtVwResponse.text = [dict valueForKey:@"json"];
        }

    });
}
- (IBAction)btnStaticClicked:(UIButton *)sender {
    [sender setSelected:!sender.isSelected];
    isUpdate = !sender.isSelected;

}
@end
