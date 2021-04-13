//
//  TLDataModel.h
//  TLBluetoothOC
//
//  Created by Will on 2021/3/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    unsigned char first;
    unsigned char serial;
    unsigned char cmd;
    unsigned char len;
} BT_DATA_FRAME_HEAD;

typedef struct {
    unsigned char checksum;
    unsigned char last;
} BT_DATA_FRAME_TAIL;

typedef enum {
    COMMONANSWER = 0x80,
    QUERYSTATUS = 0x81,
    SETPARA = 0x82,
    PASSTHROUGH = 0x89
} CMD;

typedef enum {
    CONTROL_LOCK = 0x01, //中控锁
    CONTROL_HORN = 0x02, //喇叭
    CONTROL_WARNINGLIGHT = 0x03, //危险灯
    CONTROL_WINDOW = 0x04, //车窗
    CONTROL_START = 0x05, //启动
    CONTROL_BOOT = 0x06, //后备箱
    CONTROL_LIGHTHORN = 0x07, //报警控制（同时控制灯和喇叭）
    CONTROL_STOP = 0x08, //熄火
    CONTROL_BIGLIGHT = 0x09, //开大灯
} CONTROL_CMD;

typedef enum {
    SETTING_XCLS = 0x01, //行车落锁
    SETTING_SCTS = 0x02, //锁车提示音
    SETTING_SCSC = 0x03, //锁车升窗
    SETTING_SCGBTC = 0x04, //锁车关闭天窗
    SETTING_YKXC = 0x05, //遥控寻车
    SETTING_KMSS = 0x06, //开门双闪
    SETTING_SZQDSJ = 0x07, //设置启动时间
    SETTING_MWGTX = 0x09, //门未关提醒
    SETTING_WXHTX = 0xA, //未熄火提醒
    SETTING_YBZY = 0x0B, //迎宾座椅
    SETTING_ZDHSJ = 0x0C, //自动后视镜
} SETTING_CMD;

@interface TLDataModel : NSObject

///
@property (nonatomic, copy) void (^TestBlock) (void);

NSData * ble_getCommand(CMD cmd, unsigned char *data, int dlen);

NSData * ble_commonAnswer(Byte answer_serial, Byte answer_cmd);

NSData * ble_queryStatus(unsigned char query_type);


@end

NS_ASSUME_NONNULL_END
