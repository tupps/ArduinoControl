//
//  LTRedBearLabsController.m
//  ArduinoControl
//
//  Created by Luke Tupper on 12/07/13.
//  Copyright (c) 2013 Tupps.com. All rights reserved.
//

#import "LTRedBearLabsController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define BLE_DEVICE_SERVICE_UUID @"713D0000-503E-4C75-BA94-3148F18D941E"

@interface LTRedBearLabsController () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *activePeripheral;
@property (assign, nonatomic) BOOL lookForConnection; 

@end

@implementation LTRedBearLabsController

+ (LTRedBearLabsController *) sharedLTRedBearLabsController {
    static dispatch_once_t pred = 0;
    __strong static LTRedBearLabsController *_sharedObject = nil;

    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });

    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.bluetoothStatus = @"Bluetooth powered off";
    }
    return self;
}

- (void) startLookingForConnection {
    if (self.centralManager.state == CBCentralManagerStatePoweredOn) {
        [self.centralManager scanForPeripheralsWithServices:@[BLE_DEVICE_SERVICE_UUID] options:nil];
        self.bluetoothStatus = @"Scanning for peripherals";
    } else {
        self.lookForConnection = YES; 
    }
}

- (void) stopLookingForConnection {
    self.lookForConnection = NO; 
}

#pragma mark - CBCentralManagerDelegate Methods 

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"Update state");
    if (central.state == CBCentralManagerStatePoweredOn) {
        self.bluetoothStatus = @"Bluetooth powered on";
        if (self.lookForConnection)
            [self startLookingForConnection];
    } else if (central.state == CBCentralManagerStatePoweredOff) {
        self.bluetoothStatus = @"Bluetooth powered off";
    } else {
        NSLog(@"Bluetooth state: %d", central.state);
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"Discovered Peripheral: %@", peripheral);
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Did connect");
}

#pragma mark - CBPeripheralDelegate Methods



@end
