//
//  LTRedBearLabsController.m
//  ArduinoControl
//
//  Created by Luke Tupper on 12/07/13.
//  Copyright (c) 2013 Tupps.com. All rights reserved.
//

#import "LTRedBearLabsController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "CBPeripheral+IsEqual.h"

#define BLE_DEVICE_SERVICE_UUID @"713D0000-503E-4C75-BA94-3148F18D941E"
#define BLE_DEVICE_TX_UUID @"713D0003-503E-4C75-BA94-3148F18D941E"

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


        [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:BLE_DEVICE_SERVICE_UUID]] options:nil];
        self.bluetoothStatus = @"Scanning for peripherals";
    } else {
        self.lookForConnection = YES; 
    }
}

- (void) stopLookingForConnection {
    self.lookForConnection = NO; 
}

- (void) turnLight:(NSInteger)light on:(BOOL)lightOn {
    UInt8 buf[2] = {0x01, 0x00};

    buf[0] = (UInt8)light;

    if (lightOn) //default is off
        buf[1] = 0x01;

    NSData *data = [[NSData alloc] initWithBytes:buf length:2];
    [self writeToDevice:data];
}

- (void) writeToDevice:(NSData *)data {

    CBUUID *serviceUUID = [CBUUID UUIDWithString:BLE_DEVICE_SERVICE_UUID];
    CBService *service;

    for (CBService *testService in self.activePeripheral.services) {
        if ([testService.UUID isEqual:serviceUUID])
            service = testService;
    }
    
    if (!service) {
        NSLog(@"WARNING: No service found");
        return;
    }

    CBUUID *characteristicUUID = [CBUUID UUIDWithString:BLE_DEVICE_TX_UUID];
    CBCharacteristic *characteristic;

    for (CBCharacteristic *testCharacteristic in service.characteristics) {
        if ([testCharacteristic.UUID isEqual:characteristicUUID])
            characteristic = testCharacteristic; 
    }

    if (!characteristic) {
        NSLog(@"WARNING: No characteristic found");
        return;
    }

    [self.activePeripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
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

    if (self.activePeripheral == nil || ! [self.activePeripheral isEqualToPeripheral:peripheral]) {
        //Connect to peripheral.
        self.activePeripheral = peripheral; 
        peripheral.delegate = self;
        [self.centralManager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:@YES forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Did connect");
    self.activePeripheral = peripheral;
    [self.activePeripheral discoverServices:nil];
}

#pragma mark - CBPeripheralDelegate Methods

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (!error) {
        for (CBService *service in peripheral.services) {
            [peripheral discoverCharacteristics:nil forService:service];
        }

    } else {
        NSLog(@"Service discovery was unsuccessful!\n");
    }
}

@end
