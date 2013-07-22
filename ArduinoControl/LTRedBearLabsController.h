//
//  LTRedBearLabsController.h
//  ArduinoControl
//
//  Created by Luke Tupper on 12/07/13.
//  Copyright (c) 2013 Tupps.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LTRedBearLabsController : NSObject

@property (nonatomic, strong) NSString *bluetoothStatus;


+ (LTRedBearLabsController *) sharedLTRedBearLabsController;

@property (nonatomic, assign) NSInteger value1;
@property (nonatomic, assign) NSInteger value2;
@property (nonatomic, assign) NSInteger value3; 

- (void) startLookingForConnection;
- (void) stopLookingForConnection; 

@end
