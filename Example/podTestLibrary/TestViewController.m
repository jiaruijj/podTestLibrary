//
//  TestViewController.m
//  podTestLibrary
//
//  Created by JR on 08/15/2016.
//  Copyright (c) 2016 JR. All rights reserved.
//

#import "TestViewController.h"
#import "FNDebugManager.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [FNDebugManager shareManager].parentViewController = self;
    [[FNDebugManager shareManager] invocationEvent:FNDebugEventBubble];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
