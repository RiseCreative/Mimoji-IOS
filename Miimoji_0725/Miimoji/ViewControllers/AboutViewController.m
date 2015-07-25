//
//  AboutViewController.m
//  Miimoji
//
//  Created by Master of IT on 7/2/15.
//  Copyright (c) 2015 Queen. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navibar;
@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navibar setBackgroundImage:[UIImage new]
                       forBarMetrics:UIBarMetricsDefault];
    self.navibar.shadowImage = [UIImage new];
    self.navibar.translucent = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onBtnDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
