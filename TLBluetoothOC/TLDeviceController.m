//
//  TLDeviceController.m
//  TLBluetoothOC
//
//  Created by Will on 2021/3/17.
//

#import "TLDeviceController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#import "TLProgressHUD.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "TLDataModel.h"
#import "UIView+TLImagePicker.h"
#import "TLSettingController.h"

#import "TLDeviceCell.h"

#include "data_decode.h"

#define kHistoryKey @"history_array"

@interface TLDeviceController ()<CBPeripheralDelegate,UICollectionViewDataSource,UICollectionViewDelegate,TLSettingControllerDelegate,UITextViewDelegate>
{
    int _dataLength;
    NSData *_bufferData;
    
    NSTimer *_heartTimer;
}

///
@property (nonatomic, strong) UITextView *leftTextView;
///
@property (nonatomic, strong) UITextView *rightTextView;

///
@property (nonatomic, strong) UIButton *lockButton;
///
@property (nonatomic, strong) UIButton *unlockButton;
///
@property (nonatomic, strong) UIButton *startButton;

///
@property (nonatomic, strong) UICollectionView *collectionView;

///BLE
@property (nonatomic, strong) CBCharacteristic *characteristic;

///
@property (nonatomic, strong) NSArray<NSString *> *items;

///
@property (nonatomic, strong) TLProgressHUD *hud;

@end

@implementation TLDeviceController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.peripheral == nil) {
        TLProgressHUD *hud = [TLProgressHUD progressHUDWithType:TLProgressHUDTypeText];
        [hud showWithText:@"数据错误" time:2];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self.navigationItem setTitle:self.peripheral.name];
    
    self.view.backgroundColor = kRGB(22, 27, 48);
    
    [self dc_setupUI];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat space = 10.0;
    _leftTextView.frame = CGRectMake(space, 64 + 10, (self.view.tl_width - space * 3) / 2, 150);
    _rightTextView.frame = CGRectMake(_leftTextView.tl_right + 10, _leftTextView.tl_top, _leftTextView.tl_width, _leftTextView.tl_height);
    
    _startButton.frame = CGRectMake((self.view.tl_width - 100) * 0.5, _leftTextView.tl_bottom + 30, 100, 100);
    
    _unlockButton.frame = CGRectMake(40, _startButton.tl_centerY - 20, 40, 40);
    
    _lockButton.frame = CGRectMake(self.view.tl_width - 80, _startButton.tl_centerY - 20, 40, 40);
    
    CGFloat collectionViewY = _startButton.tl_bottom + 30;
    self.collectionView.frame = CGRectMake(0, _startButton.tl_bottom + 10, self.view.tl_width, self.view.tl_height - collectionViewY);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.peripheral.delegate = self;
    [self.peripheral discoverServices:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    if (self.peripheral.state != CBPeripheralStateConnected) {
        [self stopHeartbeatTimer];
    }
}

- (void)dealloc {
    /**
     RunLoop会强引用timer
     如果_timer的target是self,会对self进行强引用(即使传入weakSelf也是不行的)，导致self不能释放，也就不会走到dealloc方法里。
     */
    //[self stopHeartbeatTimer];
}

- (void)dc_setupUI {
    UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(dc_settingItemAction:)];
    [self.navigationItem setRightBarButtonItem:settingItem];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"断开连接" style:UIBarButtonItemStylePlain target:self action:@selector(dc_backItemAction:)];
    
    _leftTextView = [UITextView new];

    _rightTextView = [UITextView new];
    //_leftTextView.backgroundColor = _rightTextView.backgroundColor = UIColor.clearColor;
    _leftTextView.textColor = _rightTextView.textColor = UIColor.blackColor;
    _leftTextView.editable = _rightTextView.editable = NO;
    _leftTextView.font = _rightTextView.font = [UIFont systemFontOfSize:16];
    _leftTextView.delegate = _rightTextView.delegate = self;
    
    _startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _startButton.tag = 1000;
    [_startButton setBackgroundImage:[UIImage imageNamed:@"icon_start"] forState:0];
    [_startButton addTarget:self action:@selector(mainButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _unlockButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _unlockButton.tag = 1001;
    [_unlockButton setBackgroundImage:[UIImage imageNamed:@"icon_unlock"] forState:0];
    [_unlockButton addTarget:self action:@selector(mainButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _lockButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _lockButton.tag = 1002;
    [_lockButton setBackgroundImage:[UIImage imageNamed:@"icon_lock"] forState:0];
    [_lockButton addTarget:self action:@selector(mainButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view tl_addSubviews:@[_leftTextView,_rightTextView,
                                _startButton,_unlockButton,_lockButton]];
    
    [self.view addSubview:self.collectionView];
}


- (void)dc_settingItemAction:(UIBarButtonItem *)sender {
    TLSettingController *settigVC = [TLSettingController new];
    settigVC.delegate = self;
    [self.navigationController pushViewController:settigVC animated:YES];
}

- (void)dc_backItemAction:(UIBarButtonItem *)sender {
    [self.centralManager cancelPeripheralConnection:self.peripheral];
    [self stopHeartbeatTimer];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)mainButtonAction:(UIButton *)sender {
    switch (sender.tag - 1000) {
        case 0: {
            [self dc_controlWithCommand:CONTROL_START param:0x0A];
            break;}
        case 1: {
            [self dc_controlWithCommand:CONTROL_LOCK param:0x01];
            break;}
        case 2: {
            [self dc_controlWithCommand:CONTROL_LOCK param:0x00];
            break;}
        default:
            break;
    }
}

- (void)dc_controlWithCommand:(CONTROL_CMD)CMD param:(int)param {
    if (self.characteristic == nil) return;
    /**
     CONTROL_LOCK = 0x01, //中控锁
     CONTROL_HORN = 0x02, //喇叭
     CONTROL_WARNINGLIGHT = 0x03, //危险灯
     CONTROL_WINDOW = 0x04, //车窗
     CONTROL_START = 0x05, //启动
     CONTROL_BOOT = 0x06, //后备箱
     CONTROL_LIGHTHORN = 0x07, //报警控制（同时控制灯和喇叭）
     CONTROL_STOP = 0x08, //熄火
     CONTROL_BIGLIGHT = 0x09, //开大灯
     */
    NSData *bleData;
    if (CMD == CONTROL_STOP) {
        unsigned char data[3];
        data[0] = 0x15;
        data[1] = 0x01;
        data[2] = CMD;
        bleData = ble_getCommand(PASSTHROUGH, data, 3);
    }
    else {
        unsigned char data[4];
        data[0] = 0x15;
        data[1] = 0x02;
        data[2] = CMD;
        data[3] = param;
        bleData = ble_getCommand(PASSTHROUGH, data, 4);
    }
    [self.peripheral writeValue:bleData forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    
    if (self.hud == nil) {
        self.hud = [TLProgressHUD progressHUDWithType:TLProgressHUDTypeDefault];
    }
    [self.hud showWithText:@"发送中..."];
}

- (void)list_analyse:(LIST_PTR)pHead {
    LIST_PTR p = pHead;
    do {
        switch (p->type) {
            case 1: {
                //GEN_ANS_PTR pGenAns = &(p->data.gen_ans);
                
                break;
            }
            case 2: {
                //QRY_STS_PTR pQrySts = &(p->data.qry_sts);
                
                break;
            }
            case 3: {
                //STS_RPT_PTR pStsRpt = &(p->data.sts_rpt);
                
                break;
            }
            case 4: {
                __block NSString *text = @"----车身状态----\n";
                VRD_0X14_PTR pVrd0x14 = &(p->data.vrd_0x14);
                unsigned short body_status = pVrd0x14->body_status;
                NSArray<NSArray *> *bodyInfo = @[
                    @[@0,@"左前门"],
                    @[@1,@"右前门"],
                    @[@2,@"左后门"],
                    @[@3,@"右后门"],
                    @[@4,@"尾箱"],
                    @[@5,@"危险灯"],
                    
                    @[@8,@"左前窗"],
                    @[@9,@"右前窗"],
                    @[@10,@"左后窗"],
                    @[@11,@"右后窗"],
                    @[@12,@"天窗"],
                    @[@13,@"中控锁"],
                    @[@14,@"小灯"],
                    @[@15,@"大灯"]
                ];
                [bodyInfo enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    int value = body_status & (1 << [obj.firstObject intValue]);
                    text = [text stringByAppendingFormat:@"%@：%d\n",obj.lastObject,value];
                }];
                
                text = [text stringByAppendingString:@"----行车状态----\n"];
                unsigned short drive_status = pVrd0x14->drive_status;
                NSArray<NSArray *> *driveInfo = @[
                    @[@0,@"脚刹"],
                    @[@1,@"左转"],
                    @[@2,@"右转"],
                    @[@3,@"安全带1"],
                    @[@4,@"安全带2"],
                    @[@5,@"ACC"],
                    @[@6,@"遥控开锁"],
                    @[@7,@"遥控关锁"],
                    @[@8,@"左转灯"],
                    @[@9,@"右转灯"],
                    @[@10,@"后雾灯"],
                    @[@11,@"前雾灯"],
                    @[@12,@"发动机状态"],
                    @[@15,@"后备箱锁"]
                ];
                [driveInfo enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    int value = drive_status & (1 << [obj.firstObject intValue]);
                    text = [text stringByAppendingFormat:@"%@：%d\n",obj.lastObject,value];
                }];
                
                text = [text stringByAppendingString:@"----报警状态----\n"];
                unsigned short alarm_status = pVrd0x14->alarm_status;
                NSArray<NSArray *> *alarmInfo = @[
                    @[@0 ,@"SOS报警"  ],
                    @[@1 ,@"门未关报警"],
                    @[@2 ,@"防盗报警"  ],
                    @[@3 ,@"左前轮胎压"],
                    @[@4 ,@"右前轮胎压"],
                    @[@5 ,@"左后轮胎压"],
                    @[@6 ,@"右后轮胎压"],
                    @[@13,@"电瓶电压低"],
                    @[@14,@"未关灯报警"],
                    @[@15,@"未熄火报警"]
                ];
                [alarmInfo enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    int value = alarm_status & (1 << [obj.firstObject intValue]);
                    text = [text stringByAppendingFormat:@"%@：%d\n",obj.lastObject,value];
                }];
                
                text = [text stringByAppendingString:@"----车辆状态----\n"];
                unsigned char vehicle_status = pVrd0x14->vehicle_status;
                int vehicle_value = vehicle_status & 0x03;
                if (vehicle_value == 0x00) {
                    text = [text stringByAppendingString:@"撤防状态\n"];
                }
                else if (vehicle_value == 0x01) {
                    text = [text stringByAppendingString:@"设防状态\n"];
                }
                else if (vehicle_value == 0x10) {
                    text = [text stringByAppendingString:@"启动状态\n"];
                }
                else if (vehicle_value == 0x11) {
                    text = [text stringByAppendingString:@"远程启动状态\n"];
                }
                
                text = [text stringByAppendingString:@"----档位状态----\n"];
                unsigned char gear_status = pVrd0x14->gear_status;
                if (gear_status == 0x50) {
                    text = [text stringByAppendingString:@"P\n"];
                }
                else if (gear_status == 0x52) {
                    text = [text stringByAppendingString:@"R\n"];
                }
                else if (gear_status == 0x4E) {
                    text = [text stringByAppendingString:@"N\n"];
                }
                else if (gear_status == 0x44) {
                    text = [text stringByAppendingString:@"D\n"];
                }
                else {
                    text = [text stringByAppendingString:@"无效\n"];
                }
                
                text = [text stringByAppendingString:@"----仪表灯状态----\n"];
                unsigned short lamp_status = pVrd0x14->lamp_status;
                NSDictionary<NSNumber *,NSString *> *lampInfo = [NSMutableDictionary dictionaryWithDictionary:@{
                    @0:@"发动机",
                    @1:@"ABS",
                    @2:@"SRS",
                    @3:@"刹车"
                }];
                [lampInfo enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                    int value = lamp_status & (1 << key.intValue);
                    text = [text stringByAppendingFormat:@"%@：%d\n",obj,value];
                }];
                
                text = [text stringByAppendingString:@"----其他----\n"];
                text = [text stringByAppendingFormat:@"车内温度：%d\n",pVrd0x14->temperature == 0 ? pVrd0x14->temperature : pVrd0x14->temperature - 80];
                text = [text stringByAppendingFormat:@"累计里程：%d\n",pVrd0x14->mileage];
                text = [text stringByAppendingFormat:@"剩余油量：%d\n",pVrd0x14->gas / 10];
                text = [text stringByAppendingFormat:@"转速：%d\n",pVrd0x14->rpm];
                text = [text stringByAppendingFormat:@"平均油耗：%d\n",pVrd0x14->mpg];
                text = [text stringByAppendingFormat:@"车速：%d\n",pVrd0x14->speed];
                text = [text stringByAppendingFormat:@"再续里程：%d\n",pVrd0x14->max_range];
                
                NSString *dataString = [self dataToString:_bufferData];
                NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
                [dateformat setDateFormat:@"MM-dd HH:mm:ss"];
                dateformat.timeZone = [NSTimeZone systemTimeZone];
                _leftTextView.text = [NSString stringWithFormat:@"%@",_rightTextView.text];
                
                _rightTextView.text = [NSString stringWithFormat:@"%@\n%@\n%@",[dateformat stringFromDate:[NSDate date]],dataString,text];
                //[_leftTextView setContentOffset:CGPointMake(0, 0) animated:YES];
                //[_rightTextView setContentOffset:CGPointMake(0, 0) animated:YES];
                break;
            }
            case 5: {
                TLProgressHUD *textHUD = [TLProgressHUD progressHUDWithType:TLProgressHUDTypeText];
                VRD_0X15_PTR pVrd0x15 = &(p->data.vrd_0x15);
                CONTROL_CMD cmd = pVrd0x15->cid;
                if (cmd == CONTROL_LOCK) {
                    [textHUD showWithText:[NSString stringWithFormat:@"中控锁%@%@",pVrd0x15->param == 0x01 ? @"打开" : @"关闭",pVrd0x15->result == 0x01 ? @"成功" : @"失败"] time:2];
                }
                else if (cmd == CONTROL_START) {
                    [textHUD showWithText:[NSString stringWithFormat:@"车辆启动%@",pVrd0x15->result == 0x01 ? @"成功" : @"失败"] time:2];
                }
                else if (cmd == CONTROL_HORN) {
                    [textHUD showWithText:[NSString stringWithFormat:@"鸣笛%d次%@",pVrd0x15->param,pVrd0x15->result == 0x01 ? @"成功" : @"失败"] time:2];
                }
                else if (cmd == CONTROL_WARNINGLIGHT) {
                    [textHUD showWithText:[NSString stringWithFormat:@"打开危险灯%d次%@",pVrd0x15->param,pVrd0x15->result == 0x01 ? @"成功" : @"失败"] time:2];
                }
                else if (cmd == CONTROL_WINDOW) {
                    [textHUD showWithText:[NSString stringWithFormat:@"%@窗%@",pVrd0x15->param == 0x01 ? @"升" : @"降",pVrd0x15->result == 0x01 ? @"成功" : @"失败"] time:2];
                }
                else if (cmd == CONTROL_BOOT) {
                    [textHUD showWithText:[NSString stringWithFormat:@"打开后备箱%@",pVrd0x15->result == 0x01 ? @"成功" : @"失败"] time:2];
                }
                else if (cmd == CONTROL_LIGHTHORN) {
                    [textHUD showWithText:[NSString stringWithFormat:@"报警控制%d次%@",pVrd0x15->param,pVrd0x15->result == 0x01 ? @"成功" : @"失败"] time:2];
                }
                else if (cmd == CONTROL_STOP) {
                    [textHUD showWithText:[NSString stringWithFormat:@"车辆熄火%@",pVrd0x15->result == 0x01 ? @"成功" : @"失败"] time:2];
                }
                
                NSLog(@"0x15 cid = %d",pVrd0x15->cid);
                NSLog(@"0x15 param = %d",pVrd0x15->param);
                NSLog(@"0x15 result = %d",pVrd0x15->result);
                break;
            }
            case 6: {
                TLProgressHUD *textHUD = [TLProgressHUD progressHUDWithType:TLProgressHUDTypeText];
                VRD_0X23_PTR pVrd0x23 = &(p->data.vrd_0x23);
                SETTING_CMD cmd = pVrd0x23->func;
                NSString *resultText = [NSString stringWithFormat:@"%@%@",pVrd0x23->param == 0x01 ? @"开启" :@"关闭",pVrd0x23->result == 0x01 ? @"成功": @"失败"];
                NSString *funcTitle;
                if (cmd == SETTING_XCLS) {
                    funcTitle = @"行车落锁";
                }
                else if (cmd == SETTING_SCTS) {
                    funcTitle = @"锁车提示音";
                }
                else if (cmd == SETTING_SCSC) {
                    funcTitle = @"锁车自动升窗";
                }
                else if (cmd == SETTING_KMSS) {
                    funcTitle = @"开门双闪";
                }
                else if (cmd == SETTING_MWGTX) {
                    funcTitle = @"门未关提醒";
                }
                else if (cmd == SETTING_YBZY) {
                    funcTitle = @"迎宾座椅";
                }
                else if (cmd == SETTING_ZDHSJ) {
                    funcTitle = @"自动折叠后视镜";
                }
                else if (cmd == SETTING_SCGBTC) {
                    funcTitle = @"锁车关闭天窗";
                }
                else if (cmd == SETTING_WXHTX) {
                    funcTitle = @"未熄火提醒";
                }
                else if (cmd == SETTING_SZQDSJ) {
                    funcTitle = @"设置启动时间";
                    resultText = [NSString stringWithFormat:@"%d分钟%@",pVrd0x23->param,pVrd0x23->result == 0x01 ? @"成功": @"失败"];
                }
                else if (cmd == SETTING_YKXC) {
                    funcTitle = @"遥控寻车";
                }
                else if (cmd == SETTING_PKE) {
                    funcTitle = @"PKE系统";
                }
                if (funcTitle) {
                    [textHUD showWithText:[NSString stringWithFormat:@"%@%@",funcTitle,resultText] time:2];
                }
                NSLog(@"0x23 func = %d",pVrd0x23->func);
                NSLog(@"0x23 param = %d",pVrd0x23->param);
                NSLog(@"0x23 result = %d",pVrd0x23->result);
                break;
            }
        }
        p = p->next;
    } while (p != NULL);
}

- (void)analyseBLEData {
    if (_bufferData == nil || _dataLength == 0) return;
    if (_bufferData.length < _dataLength) return;
    
    NSData *bufferData = [_bufferData copy];
    
    Byte *byte = (Byte *)bufferData.bytes;
    if (byte[2] == 0x01 && byte[4] == 0x00 && byte[5] == 0x50) {
        //心跳数据
        //NSLog(@"heartbeat data: %@",bufferData);
    }
    else {
        NSLog(@"complete data = %@",bufferData);
        //应答
        NSData *bleData = ble_commonAnswer(byte[1], byte[2]);
        [self.peripheral writeValue:bleData forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
        
        //解码数据
        DEC d_data = decode((char *)byte);
        //list_analyse(d_data.pList);
        [self list_analyse:d_data.pList];
        
        list_clear(d_data.pList);
    }
    _bufferData = nil;
    _dataLength = 0;
}

- (NSString *)dataToString:(NSData *)data {
    if (data == nil) {
        return @"";
    }
    Byte *byte = (Byte *)[data bytes];
    NSString *str = @"";
    for (int i = 0; i < [data length]; i++) {
        NSString *tempStr = [[NSString stringWithFormat:@"%02x",(byte[i])&0xff] uppercaseString];
        str = [str stringByAppendingString:tempStr];
    }
    return str;
}

#pragma mark - Timer
- (void)startHeartbeatTimer {
    [self stopHeartbeatTimer];
    
    _heartTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(sendHeartbeat) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_heartTimer forMode:NSRunLoopCommonModes];
    [_heartTimer fire];
}

- (void)stopHeartbeatTimer {
    if (_heartTimer) {
        [_heartTimer invalidate];
        _heartTimer = nil;
    }
}

- (void)sendHeartbeat {
    if (self.peripheral.state == CBPeripheralStateConnected && self.characteristic) {
        NSData *bleData = ble_queryStatus(0);
        [self.peripheral writeValue:bleData forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        return;
    }
    UIScrollView *anotherScrollView = scrollView == _leftTextView ? _rightTextView : _leftTextView;
    [anotherScrollView setContentOffset:scrollView.contentOffset];
}

#pragma mark - TLSettingControllerDelegate
- (void)settingCommand:(int)command value:(int)value {
    unsigned char data[4];
    data[0] = 0x23;
    data[1] = 0x02;
    data[2] = command;
    data[3] = value;
    NSData *bleData = ble_getCommand(PASSTHROUGH, data, 4);
    [self.peripheral writeValue:bleData forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    if (self.hud == nil) {
        self.hud = [TLProgressHUD progressHUDWithType:TLProgressHUDTypeDefault];
    }
    [self.hud showWithText:@"发送中..."];
}

#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    /**
     CBService: isPrimary = 1, UUID = FFE0
     */
    [peripheral.services enumerateObjectsUsingBlock:^(CBService * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //NSLog(@"didDiscoverServices obj = %@",obj);
        [peripheral discoverCharacteristics:nil forService:obj];
    }];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
    if (error) {
        NSLog(@"发现服务特征失败: uuid = %@, error = %@",service.UUID.UUIDString,error.localizedDescription);
        return;
    }
    [service.characteristics enumerateObjectsUsingBlock:^(CBCharacteristic * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.UUID.UUIDString isEqual:@"FFE1"]) {
            self.characteristic = obj;
        }
        else if ([obj.UUID.UUIDString isEqual:@"FFE2"]) {
            
        }
        if ((obj.properties & CBCharacteristicPropertyNotify) == CBCharacteristicPropertyNotify) {
            [peripheral setNotifyValue:YES forCharacteristic:obj];
        }
        //NSLog(@"Service(%@) --- CBCharacteristic: uuid = %@, properties = %lu, isNotifying = %d, value = %@",service.UUID.UUIDString,obj.UUID.UUIDString,obj.properties,obj.isNotifying,obj.value);
    }];
    if (self.characteristic) {
        [self startHeartbeatTimer];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (error) {
        NSLog(@"write value failure characteristic = %@, error = %@",characteristic,error);
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.hud hide];
    });
//    NSLog(@"characteristic.value = %@",characteristic.value);
//    TLProgressHUD *textHUD = [TLProgressHUD progressHUDWithType:TLProgressHUDTypeText];
//    [textHUD showWithText:@"指令发送成功" time:2];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (characteristic.value == nil || characteristic.value.length == 0) {
        return;
    }
    Byte *byte = (Byte *)[characteristic.value bytes];
    NSUInteger length = characteristic.value.length;
    if (byte[0] == 0xF0) {
        //没有数据长度位
        if (length < 4) return;
        
        _bufferData = [NSData dataWithBytes:byte length:characteristic.value.length];
        _dataLength = byte[3] + 6;
        [self analyseBLEData];
    }
    else {
        if (_bufferData.length < _dataLength) {
            NSUInteger length = _bufferData.length + characteristic.value.length;
            Byte newByte[length];
            memcpy(newByte, _bufferData.bytes, _bufferData.length);
            memcpy(newByte + _bufferData.length, byte, characteristic.value.length);

            _bufferData = [NSData dataWithBytes:newByte length:length];
        }
        [self analyseBLEData];
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSLog(@"didUpdateNotificationState: characteristic uuid = %@, isNotifying = %d, value = %@",characteristic.UUID.UUIDString,characteristic.isNotifying,characteristic.value);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TLDeviceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TLDeviceCell" forIndexPath:indexPath];
    [cell setText:self.items[indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //@[@"喇叭",@"危险灯",@"车窗",@"后备箱",@"报警控制",@"熄火",@"开大灯"];
    NSString *text = self.items[indexPath.item];
    TLDeviceCell *cell = (TLDeviceCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([text isEqualToString:@"喇叭"]) {
        [self dc_controlWithCommand:CONTROL_HORN param:(int)cell.count];
    }
    else if ([text isEqualToString:@"危险灯"]) {
        [self dc_controlWithCommand:CONTROL_WARNINGLIGHT param:(int)cell.count];
    }
    else if ([text isEqualToString:@"车窗升"]) {
        //01升 00降
        [self dc_controlWithCommand:CONTROL_WINDOW param:0x01];
    }
    else if ([text isEqualToString:@"车窗降"]) {
        //01升 00降
        [self dc_controlWithCommand:CONTROL_WINDOW param:0x00];
    }
    else if ([text isEqualToString:@"后备箱"]) {
        [self dc_controlWithCommand:CONTROL_BOOT param:0x01];
    }
    else if ([text isEqualToString:@"报警控制"]) {
        [self dc_controlWithCommand:CONTROL_LIGHTHORN param:(int)cell.count];
    }
    else if ([text isEqualToString:@"熄火"]) {
        [self dc_controlWithCommand:CONTROL_STOP param:0x00];
    }
}

#pragma mark - Getters
- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumLineSpacing = 20.0;
        layout.minimumInteritemSpacing = 15.0;
        layout.sectionInset = UIEdgeInsetsMake(10, 20, 10, 20);
        NSInteger itemWidth = (SCREEN_WIDTH - layout.sectionInset.left - layout.sectionInset.right - layout.minimumInteritemSpacing * 2) / 3;
        layout.itemSize = CGSizeMake(itemWidth, itemWidth);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = UIColor.clearColor;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        [_collectionView registerClass:[TLDeviceCell class] forCellWithReuseIdentifier:@"TLDeviceCell"];
    }
    return _collectionView;
}

- (NSArray<NSString *> *)items {
    if (_items == nil) {
        _items = @[@"喇叭",@"危险灯",@"报警控制",@"车窗升",@"车窗降",@"后备箱",@"熄火"];
    }
    return _items;
}

@end
