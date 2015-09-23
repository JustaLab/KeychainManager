//
//  ViewController.m
//  KeychainSampleApp
//
//  Created by Emilien Stremsdoerfer on 23/09/2015.
//  Copyright © 2015 Justalab. All rights reserved.
//

#import "ViewController.h"
#import "KeychainManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[KeychainManager sharedInstance] saveValue:@"test123" identifier:@"myKey" accessGroup:nil];
    
    NSLog(@"%@",[[KeychainManager sharedInstance] valueWithIdentifer:@"myKey" accessGroup:nil]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
