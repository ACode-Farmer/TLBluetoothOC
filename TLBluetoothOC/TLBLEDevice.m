//
//  TLBLEDevice.m
//  TLBluetoothOC
//
//  Created by Will on 2020/10/29.
//

#import "TLBLEDevice.h"

@implementation TLBLEDevice

- (instancetype)initWithPeripheral:(nonnull CBPeripheral *)peripheral {
    if (self = [super init]) {
        _peripheral = peripheral;
    }
    return self;
}

#pragma mark - Getters

- (BOOL)isConnect {
    if (self.peripheral == nil) {
        return NO;
    }
    return self.peripheral.state == CBPeripheralStateConnected;
}

- (NSString *)uuid {
    if (self.peripheral == nil) {
        return @"";
    }
    return self.peripheral.identifier.UUIDString;
}

@end
