//
//  TLRootController.m
//  TLBluetoothOC
//
//  Created by Will on 2021/3/17.
//

#import "TLRootController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#import "UIView+TLImagePicker.h"
#import "TLProgressHUD.h"
#import "TLDeviceController.h"

#import "GCDAsyncSocket.h"

@interface TLRootController ()<UITableViewDataSource,UITableViewDelegate,CBCentralManagerDelegate,GCDAsyncSocketDelegate>

///
@property (nonatomic, strong) TLProgressHUD *hud;
///
@property (nonatomic, strong) UILabel *stateLabel;
///
@property (nonatomic, strong) UITableView *tableView;
///
@property (nonatomic, strong) NSMutableArray<CBPeripheral *> *data;

//中心设备管理
@property (nonatomic, strong) CBCentralManager *centralManager;

//Socket
@property (nonatomic, strong) GCDAsyncSocket *clientSocket;

@end

@implementation TLRootController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self.navigationItem setTitle:@"周边蓝牙设备"];
    [self.view addSubview:self.tableView];
    
    NSDictionary *options = @{
        CBCentralManagerOptionShowPowerAlertKey:@YES
    };
    
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:options];
    
    //[self setupSocket];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat tableViewY = STATUSBAR_HEIGHT + NAVBAR_HEIGHT;
    self.tableView.frame = CGRectMake(0, tableViewY, self.view.tl_width, self.view.tl_height - tableViewY);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)showHUDWithText:(NSString *)text {
    if (![text isKindOfClass:[NSString class]] || text.length == 0) {
        return;
    }
    if (_hud == nil) {
        _hud = [TLProgressHUD progressHUDWithType:TLProgressHUDTypeDefault];
    }
    [_hud showWithText:text];
}

- (void)setupSocket {
    self.clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    [self.clientSocket connectToHost:@"10.88.18.73" onPort:12345 error:&error];
    if (error) NSLog(@"error == %@",error);
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"连接成功，服务器IP: %@-------端口: %d",host,port);
    
    NSString *msg = @"APP: 你好\r\n";
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    // withTimeout -1 : 无穷大,一直等
    // tag : 消息标记
    [self.clientSocket writeData:data withTimeout:-1 tag:1];
    
    [sock readDataWithTimeout:-1 tag:2];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"发送数据 tag = %zi",tag);
    //[sock readDataWithTimeout:-1 tag:tag];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"读取数据：data = %@ tag = %zi",str,tag);
    [sock readDataWithTimeout:- 1 tag:tag];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"socketDidDisconnect：err = %@",err);
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBManagerStatePoweredOn) {
        NSDictionary *options = @{
            CBCentralManagerScanOptionAllowDuplicatesKey:@NO
        };
        [_centralManager scanForPeripheralsWithServices:nil options:options];
        self.stateLabel.text = @"扫描中...";
        return;
    }
    self.stateLabel.text = @"蓝牙不可用";
}

//发现外设
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if (peripheral.name == nil || peripheral.name.length == 0 ||
        [self.data containsObject:peripheral]) {
        return;
    }
    if ([peripheral.name hasPrefix:@"XC"]) {
        [self.data insertObject:peripheral atIndex:0];
    }
    else {
        [self.data addObject:peripheral];
    }
    [self.tableView reloadData];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [self.hud hide];
    
    TLProgressHUD *textHUD = [TLProgressHUD progressHUDWithType:TLProgressHUDTypeText];
    [textHUD showWithText:@"连接成功" time:1.5];
    
    TLDeviceController *deviceController = [[TLDeviceController alloc] init];
    deviceController.peripheral = peripheral;
    deviceController.centralManager = self.centralManager;
    [self.navigationController pushViewController:deviceController animated:YES];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    NSLog(@"连接失败: identifier = %@, error = %@",peripheral.identifier.UUIDString,error.localizedDescription);
    TLProgressHUD *textHUD = [TLProgressHUD progressHUDWithType:TLProgressHUDTypeText];
    [textHUD showWithText:@"连接失败" time:3];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    NSLog(@"断开连接: identifier = %@, error = %@",peripheral.identifier.UUIDString,error.localizedDescription);
    if (peripheral.name.length > 0) {
        TLProgressHUD *textHUD = [TLProgressHUD progressHUDWithType:TLProgressHUDTypeText];
        [textHUD showWithText:[NSString stringWithFormat:@"%@断开连接",peripheral.name] time:1.5];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"rcCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = self.data[indexPath.row].name;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CBPeripheral *peripheral = self.data[indexPath.row];
    if (peripheral.state == CBPeripheralStateConnected) {
        TLDeviceController *deviceController = [[TLDeviceController alloc] init];
        deviceController.peripheral = peripheral;
        [self.navigationController pushViewController:deviceController animated:YES];
        return;
    }
    
    [self showHUDWithText:@"连接中..."];
    [self.centralManager connectPeripheral:peripheral options:nil];
}

#pragma mark - Getters
- (UILabel *)stateLabel {
    if (_stateLabel == nil) {
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, self.view.frame.size.width, 20)];
        _stateLabel.font = [UIFont systemFontOfSize:18];
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.text = @"状态";
    }
    return _stateLabel;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [UIView new];
        
        _tableView.tableHeaderView = ({
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.tl_width, 60)];
            self.stateLabel.frame = CGRectMake(0, 20, headerView.tl_width, 20);
            [headerView addSubview:self.stateLabel];
            headerView;
        });
    }
    return _tableView;
}

- (NSMutableArray<CBPeripheral *> *)data {
    if (_data == nil) {
        _data = [NSMutableArray arrayWithCapacity:1];
    }
    return _data;
}

@end
