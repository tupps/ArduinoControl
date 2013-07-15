//
//  CBPeripheral+IsEqual.m
//  ArduinoControl
//
//  Created by Luke Tupper on 14/07/13.
//  Copyright (c) 2013 Tupps.com. All rights reserved.
//

#import "CBPeripheral+IsEqual.h"

@implementation CBPeripheral (IsEqual)

- (BOOL) isEqualToPeripheral:(CBPeripheral *)peripheral {
    CFUUIDBytes myUUID = CFUUIDGetUUIDBytes(self.UUID);
    CFUUIDBytes otherUUID = CFUUIDGetUUIDBytes(peripheral.UUID);

    if (memcmp(&myUUID, &otherUUID, 16) == 0)
        return YES;
    else
        return NO;
}

@end
