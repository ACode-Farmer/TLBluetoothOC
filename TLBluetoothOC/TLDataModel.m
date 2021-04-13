//
//  TLDataModel.m
//  TLBluetoothOC
//
//  Created by Will on 2021/3/17.
//

#import "TLDataModel.h"

@implementation TLDataModel

const unsigned char HEAD = 0xF0;
const unsigned char TAIL = 0x0F;
unsigned char ble_serial = 0;

#pragma mark - Send BLE Data
unsigned char ble_XORSum(unsigned char *data, int len) {
    unsigned char sum = data[1];
    for (int i=2; i<len; i++) {
        sum ^= data[i];
    }
    return sum;
}

NSData * ble_getCommand(CMD cmd, unsigned char *data, int dlen) {
    BT_DATA_FRAME_HEAD bdfh;
    BT_DATA_FRAME_TAIL bdft;
    unsigned char buf[sizeof(BT_DATA_FRAME_HEAD)+dlen+sizeof(BT_DATA_FRAME_TAIL)];
    
    bdfh.first = HEAD;
    bdfh.serial = ble_serial++;
    bdfh.cmd = cmd;
    bdfh.len = dlen;
    memcpy(buf, &bdfh, sizeof(BT_DATA_FRAME_HEAD));
    memcpy(buf+sizeof(BT_DATA_FRAME_HEAD), data, dlen);
    
    bdft.checksum = ble_XORSum(buf, sizeof(BT_DATA_FRAME_HEAD)+dlen);
    bdft.last = TAIL;
    memcpy(buf+sizeof(BT_DATA_FRAME_HEAD)+dlen, &bdft, sizeof(BT_DATA_FRAME_TAIL));
    // Add bluetooth writes out here
    NSData *bleData = [NSData dataWithBytes:buf length:sizeof(buf)];
    //0xf039810100b90f
    if (buf[2] == 0x81 && buf[3] == 0x01 && buf[4] == 0x00) {
        //NSLog(@"Heartbeat bleData = %@",bleData);
    }
    else {
        NSLog(@"SendCommand bleData = %@",bleData);
    }
    
    return bleData;
}

NSData * ble_commonAnswer(Byte answer_serial, Byte answer_cmd) {
    unsigned char data[2];

    data[0] = answer_serial;
    data[1] = answer_cmd;
    return ble_getCommand(COMMONANSWER, data, 2);
}

NSData * ble_queryStatus(unsigned char query_type) {
    return ble_getCommand(QUERYSTATUS, &query_type, 1);
}

//- (instancetype)init {
//    if (self = [super init]) {
//        __weak typeof(self) weakSelf = self;
//        self.TestBlock = ^{
////            id model = self;
////            NSLog(@"model = %@",model);
//            __strong typeof(weakSelf) strongSelf1 = weakSelf;
//            __strong typeof(strongSelf1) strongSelf2 = strongSelf1;
//            NSLog(@"TestBlock, self = %@",strongSelf1);
//            NSLog(@"TestBlock, self = %@",strongSelf2);
//        };
//        self.TestBlock();
//    }
//    return self;
//}
//
//- (void)dealloc {
//
//}

@end
