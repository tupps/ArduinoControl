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

- (void) startLookingForConnection;
- (void) stopLookingForConnection; 

- (void) turnLight:(NSInteger)light on:(BOOL)lightOn; 

@end
