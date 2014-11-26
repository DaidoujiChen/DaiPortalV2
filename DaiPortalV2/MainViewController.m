//
//  MainViewController.m
//  DaiPortalV2
//
//  Created by 啟倫 陳 on 2014/11/24.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self portal:@"daidouji"] respond_warp: ^DaiPortalPackage *(NSString *text) {
        NSLog(@"feedback_warp ismainthread : %d", [NSThread isMainThread]);
        NSLog(@"text : %@", text);
        return [DaiPortalPackage items:@(1), @(2), nil];
    }];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[MainViewController portal:@"daidouji2"] respond: ^DaiPortalPackage *{
            NSLog(@"feedback ismainthread : %d", [NSThread isMainThread]);
            return [DaiPortalPackage item:@"hello"];
        }];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"%s", __FUNCTION__);
    
    [[self portal:@"daidouji"] send:[DaiPortalPackage item:@"hello"] completion: ^(NSNumber *a, NSNumber *b) {
        NSLog(@"result ismainthread : %d", [NSThread isMainThread]);
        NSLog(@"%@, %@", a, b);
    }];
    
    [[self portal:@"daidouji2"] completion_warp: ^(NSString *text) {
        NSLog(@"result_warp ismainthread : %d", [NSThread isMainThread]);
        NSLog(@"back text : %@", text);
    }];
}

- (IBAction)pushAction:(id)sender {
    [self.navigationController pushViewController:[MainViewController new] animated:YES];
}

@end
