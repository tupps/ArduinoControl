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

- (void) updateBackground {
    CGFloat red = [LTRedBearLabsController sharedLTRedBearLabsController].value1 / 2048.0f;
    CGFloat green = [LTRedBearLabsController sharedLTRedBearLabsController].value2 / 2048.0f;
    CGFloat blue = [LTRedBearLabsController sharedLTRedBearLabsController].value3 / 2048.0f;
    self.view.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    [self performSelector:@selector(updateBackground) withObject:nil afterDelay:0.10];
}


-(void) bleDidUpdateRSSI:(NSNumber *) rssi {
    NSLog(@"Did RSSI: %@", rssi);
}

@end
