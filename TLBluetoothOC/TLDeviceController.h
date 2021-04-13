//
//  TLDeviceController.h
//  TLBluetoothOC
//
//  Created by Will on 2021/3/17.
//

#import "TLViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class CBPeripheral,CBCentralManager;
@interface TLDeviceController : TLViewController

//中心设备管理
@property (nonatomic, weak  ) CBCentralManager *centralManager;

///设备
@property (nonatomic, weak  ) CBPeripheral *peripheral;

@end

NS_ASSUME_NONNULL_END
