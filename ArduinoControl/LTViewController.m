//
//  LTViewController.m
//  ArduinoControl
//
//  Created by Luke Tupper on 6/07/13.
//  Copyright (c) 2013 Tupps.com. All rights reserved.
//

#import "LTViewController.h"
#import "LTRedBearLabsController.h"

@interface LTViewController () //<BLEDelegate>

//@property (nonatomic, strong) BLE *ble;

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

-(void) bleDidConnect {
    NSLog(@"Did Connect");
}

-(void) bleDidDisconnect {
    NSLog(@"Did Disconnect");
}

-(void) bleDidUpdateRSSI:(NSNumber *) rssi {
    NSLog(@"Did RSSI: %@", rssi);
}

-(void) bleDidReceiveData:(unsigned char *) data length:(int) length {
    NSLog(@"Did Receive Data");
}


@end
