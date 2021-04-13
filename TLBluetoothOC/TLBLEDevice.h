//
//  TLBLEDevice.h
//  TLBluetoothOC
//
//  Created by Will on 2020/10/29.
//

#import <Foundation/Foundation.h>

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN



@interface TLBLEDevice : NSObject

///uuid
@property (nonatomic, strong) NSString *uuid;
///mac地址
@property (nonatomic, strong) NSString *macAddress;
///是否连接
@property (nonatomic, assign, readonly) BOOL isConnect;
///设备
@property (nonatomic, strong, readonly) CBPeripheral *peripheral;
///
@property (nonatomic, strong) CBCharacteristic *writeCharacteristic;
///
@property (nonatomic, strong) CBCharacteristic *notifyCharacteristic;

- (instancetype)initWithPeripheral:(nonnull CBPeripheral *)peripheral;


@end

NS_ASSUME_NONNULL_END
