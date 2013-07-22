//
//  LTViewController.m
//  ArduinoControl
//
//  Created by Luke Tupper on 6/07/13.
//  Copyright (c) 2013 Tupps.com. All rights reserved.
//

#import "LTViewController.h"
#import "LTRedBearLabsController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface LTViewController ()

@property LTRedBearLabsController *bleController; 

@end

@implementation LTViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[LTRedBearLabsController sharedLTRedBearLabsController] startLookingForConnection];

    self.bleController = [LTRedBearLabsController sharedLTRedBearLabsController];

    RACBind(self.connectionLabel.text) = RACBind(self.bleController.bluetoothStatus);

    [[RACSignal
      combineLatest:@[ RACAble(self.bleController.value1), RACAble(self.bleController.value2), RACAble(self.bleController.value3)]
      reduce:^(NSNumber *value1, NSNumber *value2, NSNumber *value3) {
          return [UIColor colorWithRed:value1.floatValue / 1024.0f
                                 green:value2.floatValue / 1024.0f
                                  blue:value3.floatValue / 1024.0f
                                 alpha:1.0f];
      }]
     subscribeNext:^(UIColor *backgroundColor) {
         self.view.backgroundColor = backgroundColor;
     }];
}

@end
