//
//  data_decode.h
//  TLBluetoothOC
//
//  Created by Will on 2021/3/19.
//

#ifndef data_decode_h
#define data_decode_h

#include <stdio.h>
#include <MacTypes.h>

typedef unsigned int uint_32 ;
typedef unsigned short uint_16 ;
 
#define BSWAP_16(x) \
    (uint_16)((((uint_16)(x) & 0x00ff) << 8) | \
              (((uint_16)(x) & 0xff00) >> 8) \
             )
             
#define BSWAP_32(x) \
    (uint_32)((((uint_32)(x) & 0xff000000) >> 24) | \
              (((uint_32)(x) & 0x00ff0000) >> 8) | \
              (((uint_32)(x) & 0x0000ff00) << 8) | \
              (((uint_32)(x) & 0x000000ff) << 24) \
             )

typedef struct {
    unsigned char start;
    unsigned char serial;
    unsigned char command;
    unsigned char dlen;
} FRAME_HEAD, *FRAME_HEAD_PTR;

typedef struct {
    unsigned char *data;
} FRAME_BODY, *FRAME_BODY_PTR;

typedef struct {
    unsigned char chksum;
    unsigned char end;
} FRAME_TAIL, *FRAME_TAIL_PTR;

typedef struct {
    FRAME_HEAD head;
    FRAME_BODY body;
    FRAME_TAIL tail;
} FRAME, *FRAME_PTR;

typedef struct {
    unsigned char answer_serial;
    unsigned char answer_command;
} GEN_ANS, *GEN_ANS_PTR;

#pragma pack(1)
typedef struct {
    unsigned char query_type;
} QRY_STS, *QRY_STS_PTR;

typedef struct {
    unsigned char status_type;
    union {
        unsigned char ck_type;
        struct {
            struct {
                unsigned int alarm;
                unsigned int status;
                unsigned int latitude;
                unsigned int longitude;
                unsigned short height;
                unsigned short speed;
                unsigned short direction;
                unsigned char datetime[6];
            } gps;
            unsigned int mileage;
            unsigned char signal;
            unsigned char satellite;
            unsigned short voltage;
        } data;
    } status;
} STS_RPT, *STS_RPT_PTR;

typedef struct {
    unsigned char command;
    unsigned char dlen;
} VRD_HEAD, *VRD_HEAD_PTR;
#pragma pack()

typedef struct {
    unsigned short body_status;//车身状态
    unsigned short drive_status;//行车状态
    unsigned char vehicle_status;//车辆状态
    unsigned char gear_status;//档位状态
    unsigned char lamp_status;//仪表灯状态
    unsigned char temperature;//车内温度
    unsigned int mileage;   //累计里程
    unsigned int gas;       //剩余油量
    unsigned short rpm;//转速
    unsigned short alarm_status;//报警状态
    unsigned char mpg;//平均油耗
    unsigned char speed;//车速
    unsigned short max_range;//续航历程
} VRD_0X14, *VRD_0X14_PTR;

typedef struct {
    unsigned char cid;
    unsigned char param;
    unsigned char result;
} VRD_0X15, *VRD_0X15_PTR;

typedef struct {
    unsigned char func;
    unsigned char param;
    unsigned char result;
} VRD_0X23, *VRD_0X23_PTR;

typedef union {
    GEN_ANS gen_ans;
    QRY_STS qry_sts;
    STS_RPT sts_rpt;
    VRD_0X14 vrd_0x14;
    VRD_0X15 vrd_0x15;
    VRD_0X23 vrd_0x23;
} DATA, *DATA_PTR;

/*
 type:
 GEN_ANS gen_ans;
 QRY_STS qry_sts;
 STS_RPT sts_rpt;
 VRD_0X14 vrd_0x14;
 VRD_0X15 vrd_0x15;
 VRD_0X23 vrd_0x23;
 */
typedef struct slist {
    int type;
    DATA data;
    struct slist *next;
} LIST, *LIST_PTR;

typedef struct {
    unsigned char serial;
    unsigned char command;
    LIST_PTR pList;
} DEC, *DEC_PTR;

DEC decode(char *hex);

void list_clear(LIST_PTR pHead);

#endif /* data_decode_h */
