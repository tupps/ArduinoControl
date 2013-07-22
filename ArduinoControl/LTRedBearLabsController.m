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
    self.activePeripheral = peripheral;
    [self.activePeripheral discoverServices:nil];
}

#pragma mark - CBPeripheralDelegate Methods

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (!error) {
        for (CBService *service in peripheral.services) {
            [peripheral discoverCharacteristics:nil forService:service];
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
    } else
        NSLog(@"Service discovery was unsuccessful!\n");
}

-(UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    unsigned char data[BLE_DEVICE_RX_READ_LEN];
    
    static unsigned char buf[512];
    static int len = 0;
    int data_len;
    
    if (!error) {
        data_len = characteristic.value.length;
        [characteristic.value getBytes:data length:data_len];
        
        if (data_len == 20) {
            memcpy(&buf[len], data, 20);
            len += data_len;
            
            if (len >= 64) {
                NSData *recData = [[NSData alloc] initWithBytes:data length:len];
                NSLog(@"Long Bytes: %@", recData);
                len = 0;
            }
        } else if (data_len < 20) {
            memcpy(&buf[len], data, data_len);
            len += data_len;

            NSData *recData = [[NSData alloc] initWithBytes:data length:len];
            NSLog(@"Bytes: %@", recData);
            UInt16 buffer = 0;
            [recData getBytes:&buffer range:NSMakeRange(1, 2)];
            UInt16 val1 = [self swap:buffer];
            NSLog(@"Val 1: %d", val1);
            self.value1 = val1; 
            [recData getBytes:&buffer range:NSMakeRange(4, 2)];
            UInt16 val2 = [self swap:buffer];
            NSLog(@"Val 2: %d", val2);
            self.value2 = val2;
            [recData getBytes:&buffer range:NSMakeRange(7, 2)];
            UInt16 val3 = [self swap:buffer];
            NSLog(@"Val 3: %d", val3);
            self.value3 = val3;
            
            len = 0;
        }

    } else {
        NSLog(@"Error reading data: %@", error);
    }
    
    unsigned char bytes[] = {0x01};
    NSData *singleByte = [[NSData alloc] initWithBytes:bytes length:1];
    [peripheral writeValue:singleByte forCharacteristic:self.resetCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

@end
