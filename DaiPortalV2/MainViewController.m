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
    
    [[self portal:@"daidouji"] feedback:^DaiPortalPackage *(NSString *text){
        NSLog(@"text : %@", text);
        return [DaiPortalPackage items:@(1), @(2), nil];
    }];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[MainViewController portal:@"daidouji2"] feedback:^DaiPortalPackage *{
            NSLog(@"class recv");
            return [DaiPortalPackage item:@"hello"];
        }];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSLog(@"%s", __FUNCTION__);
    
    [[self portal:@"daidouji"] send:[DaiPortalPackage item:@"hello"] result:^(NSNumber *a, NSNumber *b) {
        NSLog(@"%@, %@", a, b);
    }];
    
    [[self portal:@"daidouji2"] result:^(NSString *text){
        NSLog(@"back text : %@", text);
    }];
}

- (IBAction)pushAction:(id)sender {
    [self.navigationController pushViewController:[MainViewController new] animated:YES];
}

@end
