//
//  LTViewController.m
//  ArduinoControl
//
//  Created by Luke Tupper on 6/07/13.
//  Copyright (c) 2013 Tupps.com. All rights reserved.
//

#import "LTViewController.h"
#import "LTRedBearLabsController.h"

@interface LTViewController ()

@end

@implementation LTViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[LTRedBearLabsController sharedLTRedBearLabsController] startLookingForConnection];
}

- (IBAction) lightOneChanged:(UISwitch *)sender {
    [[LTRedBearLabsController sharedLTRedBearLabsController] turnLight:1 on:sender.on];
}

- (IBAction) lightTwoChanged:(UISwitch *)sender {
    [[LTRedBearLabsController sharedLTRedBearLabsController] turnLight:2 on:sender.on];
}

- (IBAction) lightThreeChanged:(UISwitch *)sender {
    [[LTRedBearLabsController sharedLTRedBearLabsController] turnLight:3 on:sender.on];
}

-(void) bleDidUpdateRSSI:(NSNumber *) rssi {
    NSLog(@"Did RSSI: %@", rssi);
}


@end
