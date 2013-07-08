//
//  LTViewController.m
//  ArduinoControl
//
//  Created by Luke Tupper on 6/07/13.
//  Copyright (c) 2013 Tupps.com. All rights reserved.
//

#import "LTViewController.h"
#import "BLE.h"

@interface LTViewController () <BLEDelegate>

@property (nonatomic, strong) BLE *ble; 

@end

@implementation LTViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.ble = [[BLE alloc] init];
    [self.ble controlSetup:1]; //Note the number doesn't seem to do anything!
    self.ble.delegate = self;

    [self tryToConnectToBLEShield];
}

- (void) tryToConnectToBLEShield {
    //Check core bluetooth state
    if (self.ble.CM.state != CBCentralManagerStatePoweredOn)
        [self waitAndTryConnectingToBLE]; 
    
    //Check if any periphrals
    if (self.ble.peripherals.count == 0)
        [self.ble findBLEPeripherals:2.0];
    else
        if (! self.ble.activePeripheral)
            [self.ble connectPeripheral:[self.ble.peripherals objectAtIndex:0]];

    [self waitAndTryConnectingToBLE];
}


- (void) waitAndTryConnectingToBLE {
    if (self.ble.CM.state != CBCentralManagerStatePoweredOn)
        [self performSelector:@selector(tryToConnectToBLEShield) withObject:nil afterDelay:0.25];
    else
        [self performSelector:@selector(tryToConnectToBLEShield) withObject:nil afterDelay:2.0];
}

- (IBAction) lightOneChanged:(UISwitch *)sender {
    //Turn on light one
    UInt8 buf[2] = {0x01, 0x00};

    if (sender.on)
        buf[1] = 0x01;
    else
        buf[1] = 0x00;

    NSData *data = [[NSData alloc] initWithBytes:buf length:2];
    [self.ble write:data];
}

- (IBAction) lightTwoChanged:(UISwitch *)sender {
    //Turn on light one
    UInt8 buf[2] = {0x02, 0x00};

    if (sender.on)
        buf[1] = 0x01;
    else
        buf[1] = 0x00;

    NSData *data = [[NSData alloc] initWithBytes:buf length:2];
    [self.ble write:data];
}

- (IBAction) lightThreeChanged:(UISwitch *)sender {
    //Turn on light one
    UInt8 buf[2] = {0x03, 0x00};

    if (sender.on)
        buf[1] = 0x01;
    else
        buf[1] = 0x00;

    NSData *data = [[NSData alloc] initWithBytes:buf length:2];
    [self.ble write:data];
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
