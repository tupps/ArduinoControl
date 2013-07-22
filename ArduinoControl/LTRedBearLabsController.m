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

#define BLE_DEVICE_SERVICE_UUID     @"713D0000-503E-4C75-BA94-3148F18D941E"
#define BLE_DEVICE_RX_UUID          @"713D0002-503E-4C75-BA94-3148F18D941E"
#define BLE_DEVICE_TX_UUID          @"713D0003-503E-4C75-BA94-3148F18D941E"
#define BLE_DEVICE_RESET_RX_UUID    @"713D0004-503E-4C75-BA94-3148F18D941E"
#define BLE_DEVICE_RX_READ_LEN 20

@interface LTRedBearLabsController () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *activePeripheral;
@property (strong, nonatomic) CBCharacteristic *resetCharacteristic;
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

#pragma mark - CBCentralManagerDelegate Methods 

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
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

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral     advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {

    if (self.activePeripheral == nil || ! [self.activePeripheral isEqualToPeripheral:peripheral]) {
        //Connect to peripheral.
        self.activePeripheral = peripheral; 
        peripheral.delegate = self;
        [self.centralManager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:@YES forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
        self.bluetoothStatus = @"Discovered peripheral";
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    self.activePeripheral = peripheral;
    [self.activePeripheral discoverServices:nil];
    self.bluetoothStatus = @"Connected peripheral";
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    self.bluetoothStatus = @"Peripheral Disconnected";
    if (self.activePeripheral == peripheral) {
        self.activePeripheral = nil;
        [self startLookingForConnection];
    }
}

#pragma mark - CBPeripheralDelegate Methods

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (!error) {
        for (CBService *service in peripheral.services) {
            [peripheral discoverCharacteristics:nil forService:service];
            self.bluetoothStatus = @"Discovered services";
        }
    } else
        NSLog(@"Service discovery was unsuccessful!\n");
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    if (!error) {
        CBUUID *deviceUUID = [CBUUID UUIDWithString:BLE_DEVICE_SERVICE_UUID];
        for (CBCharacteristic *characteristic in service.characteristics) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            if ([service.UUID isEqual:deviceUUID]) {
                CBUUID *resetUUID = [CBUUID UUIDWithString:BLE_DEVICE_RESET_RX_UUID];
                if ([characteristic.UUID isEqual:resetUUID]) {
                    self.resetCharacteristic = characteristic;
                }
            }
        }
        self.bluetoothStatus = @"Discovered characteristics";
    } else
        NSLog(@"Service discovery was unsuccessful!\n");
}

-(UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (!error) {
        NSData *recData = characteristic.value;
        UInt16 buffer = 0;
        [recData getBytes:&buffer range:NSMakeRange(1, 2)];
        UInt16 val1 = [self swap:buffer];
        self.value1 = val1; 
        [recData getBytes:&buffer range:NSMakeRange(4, 2)];
        UInt16 val2 = [self swap:buffer];
        self.value2 = val2;
        [recData getBytes:&buffer range:NSMakeRange(7, 2)];
        UInt16 val3 = [self swap:buffer];
        self.value3 = val3;

        self.bluetoothStatus = @"Updated values";

    } else {
        NSLog(@"Error reading data: %@", error);
    }
    
    unsigned char bytes[] = {0x01};
    NSData *singleByte = [[NSData alloc] initWithBytes:bytes length:1];
    [peripheral writeValue:singleByte forCharacteristic:self.resetCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

@end
