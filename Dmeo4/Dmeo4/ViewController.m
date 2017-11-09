//
//  ViewController.m
//  Dmeo4
//
//  Created by User on 11/6/17.
//  Copyright © 2017 User. All rights reserved.
//

#import "ViewController.h"
#import "XKWebViewController.h"
#import "XKNavigationController.h"

#import <Masonry.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (IBAction)testPush:(id)sender {
   
}

- (IBAction)testPresent:(id)sender {
    XKWebViewController *vc = [[XKWebViewController alloc] initWithUrl:[NSURL URLWithString:@"https://www.baidu.com"]];
    XKNavigationController *nav = [[XKNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return NO;
}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return UIInterfaceOrientationLandscapeLeft;
//}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

@end
