//
//  CBPeripheral+IsEqual.h
//  ArduinoControl
//
//  Created by Luke Tupper on 14/07/13.
//  Copyright (c) 2013 Tupps.com. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (IsEqual)

- (BOOL) isEqualToPeripheral:(CBPeripheral *)peripheral;

@end
