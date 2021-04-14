//
//  TLSettingController.m
//  TLBluetoothOC
//
//  Created by Will on 2021/3/29.
//

#import "TLSettingController.h"
#import "TLDataModel.h"
#import "UIView+TLImagePicker.h"

#define kSettingKey @"device_setting"

#define kSettingTimeKey @"device_setting_time"

@interface TLSettingController ()<UITableViewDataSource,UITableViewDelegate>

///
@property (nonatomic, strong) UITableView *tableView;

///
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *data;

@end

@implementation TLSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"车辆设置"];
    
    [self.view addSubview:self.tableView];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *data = [userDefaults objectForKey:kSettingKey];
    /**
     SETTING_XCLS = 0x01, //行车落锁
     SETTING_SCTS = 0x02, //锁车提示音
     SETTING_SCSC = 0x03, //锁车升窗
     SETTING_SCGBTC = 0x04, //锁车关闭天窗
     SETTING_KMSS = 0x06, //开门双闪
     SETTING_SZQDSJ = 0x07, //设置启动时间
     SETTING_MWGTX = 0x09, //门未关提醒
     SETTING_WXHTX = 0xA, //未熄火提醒
     SETTING_YBZY = 0x0B, //迎宾座椅
     SETTING_ZDHSJ = 0x0C, //自动后视镜
     */
    //SETTING_YKXC
    if (data == nil) {
        data = @[
            [NSMutableDictionary dictionaryWithObjectsAndKeys:@"行车落锁",@"title",@0, @"state",nil],
            [NSMutableDictionary dictionaryWithObjectsAndKeys:@"锁车提示音",@"title",@1, @"state",nil],
            [NSMutableDictionary dictionaryWithObjectsAndKeys:@"锁车自动升窗",@"title",@1,@"state", nil],
            [NSMutableDictionary dictionaryWithObjectsAndKeys:@"锁车关闭天窗",@"title",@1,@"state", nil],
            [NSMutableDictionary dictionaryWithObjectsAndKeys:@"遥控寻车",@"title",@1,@"state", nil],
            [NSMutableDictionary dictionaryWithObjectsAndKeys:@"开门双闪",@"title",@1,@"state", nil],
            [NSMutableDictionary dictionaryWithObjectsAndKeys:@"门未关提醒",@"title",@1, @"state",nil],
            [NSMutableDictionary dictionaryWithObjectsAndKeys:@"未熄火提醒",@"title",@0, @"state",nil],
            [NSMutableDictionary dictionaryWithObjectsAndKeys:@"迎宾座椅",@"title",@0, @"state",nil],
            [NSMutableDictionary dictionaryWithObjectsAndKeys:@"自动折叠后视镜",@"title",@1,@"state", nil],
            [NSMutableDictionary dictionaryWithObjectsAndKeys:@"PKE系统开关",@"title",@1,@"state", nil]
        ];
    }
    self.data = [NSMutableArray arrayWithCapacity:data.count];
    [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.data addObject:[obj mutableCopy]];
    }];
    
    NSArray<NSNumber *> *times = @[@5,@10,@20,@30,@40];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.tl_width, 80)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 20)];
    titleLabel.text = @"远程启动时间(分钟)";
    titleLabel.textColor = UIColor.blackColor;
    [footerView addSubview:titleLabel];
    
    NSNumber *setTime = [userDefaults objectForKey:kSettingTimeKey];
    if (setTime == nil) {
        setTime = @30;
        [userDefaults setObject:setTime forKey:kSettingTimeKey];
        [userDefaults synchronize];
    }
    
    __block CGFloat leftX = titleLabel.tl_left;
    [times enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *item = [UIButton buttonWithType:UIButtonTypeCustom];
        [item setTitle:[NSString stringWithFormat:@"%@",obj] forState:0];
        [item setTitleColor:UIColor.blackColor forState:0];
        [item setTitleColor:UIColor.orangeColor forState:UIControlStateSelected];
        [item addTarget:self action:@selector(timeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        item.tag = obj.integerValue + 1000;
        item.frame = CGRectMake(leftX, titleLabel.tl_bottom + 15, 40, 40);
        item.selected = (obj.integerValue == setTime.integerValue);
        leftX = item.tl_right + 20;
        [footerView addSubview:item];
    }];
    self.tableView.tableFooterView = footerView;
    
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.data forKey:kSettingKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Events
- (void)switchStatusChange:(UISwitch *)sender {
    NSNumber *state = sender.isOn ? @1 : @0;
    NSMutableDictionary *item = self.data[sender.tag - 1000];
    NSString *title = [item objectForKey:@"title"];
    [item setObject:state forKey:@"state"];
    
    int command = 0x00,value = sender.isOn ? 0x01 : 0x00;
    if ([title isEqual:@"行车落锁"]) {
        command = SETTING_XCLS;
    }
    else if ([title isEqual:@"锁车提示音"]) {
        command = SETTING_SCTS;
    }
    else if ([title isEqual:@"锁车自动升窗"]) {
        command = SETTING_SCSC;
    }
    else if ([title isEqual:@"锁车关闭天窗"]) {
        command = SETTING_SCGBTC;
    }
    else if ([title isEqual:@"开门双闪"]) {
        command = SETTING_KMSS;
    }
    else if ([title isEqual:@"门未关提醒"]) {
        command = SETTING_MWGTX;
    }
    else if ([title isEqual:@"未熄火提醒"]) {
        command = SETTING_WXHTX;
    }
    else if ([title isEqual:@"迎宾座椅"]) {
        command = SETTING_YBZY;
    }
    else if ([title isEqual:@"自动折叠后视镜"]) {
        command = SETTING_ZDHSJ;
    }
    else if ([title isEqual:@"遥控寻车"]) {
        command = SETTING_YKXC;
    }
    else if ([title isEqual:@"PKE系统开关"]) {
        command = SETTING_PKE;
    }
    if (command == 0x00 && value == 0x00) return;
    
    if ([_delegate respondsToSelector:@selector(settingCommand:value:)]) {
        [_delegate settingCommand:command value:value];
    }
}

- (void)timeButtonAction:(UIButton *)sender {
    if (sender.isSelected) {
        return;
    }
    [self.tableView.tableFooterView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIButton class]]) {
            [(UIButton *)obj setSelected:NO];
        }
    }];
    sender.selected = YES;
    
    if ([_delegate respondsToSelector:@selector(settingCommand:value:)]) {
        [_delegate settingCommand:SETTING_SZQDSJ value:(int)(sender.tag - 1000)];
    }
    
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults objectForKey:kSettingTimeKey];
    [[NSUserDefaults standardUserDefaults] setObject:@(sender.tag - 1000) forKey:kSettingTimeKey];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = @"sc_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = 0;
        CGFloat cellHeight = 50.0;
        CGRect frame = CGRectMake(self.view.frame.size.width - 70, (cellHeight - 31) * 0.5, 51, 31);
        UISwitch *switchBtn = [[UISwitch alloc] initWithFrame:frame];
        [switchBtn addTarget:self action:@selector(switchStatusChange:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchBtn;
    }
    NSMutableDictionary *item = self.data[indexPath.row];
    cell.textLabel.text = [item objectForKey:@"title"];
    UISwitch *switchBtn = (UISwitch *)cell.accessoryView;
    switchBtn.tag = 1000 + indexPath.row;
    switchBtn.on = [[item objectForKey:@"state"] isEqual:@1];
    return cell;
}

#pragma mark - Getters
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 50.0;
    }
    return _tableView;
}


@end
