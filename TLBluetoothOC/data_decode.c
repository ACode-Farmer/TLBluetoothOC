//
//  data_decode.c
//  TLBluetoothOC
//
//  Created by Will on 2021/3/19.
//

#include "data_decode.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

const unsigned char FS = 0xF0;
const unsigned char FE = 0x0F;

#pragma mark - Decode
void print_frame_head(const FRAME_HEAD_PTR pFrameHead) {
    printf("frame: start   = 0x%02X (%d)\n", pFrameHead->start, pFrameHead->start);
    printf("frame: serial  = 0x%02X (%d)\n", pFrameHead->serial, pFrameHead->serial);
    printf("frame: command = 0x%02X (%d)\n", pFrameHead->command, pFrameHead->command);
    printf("frame: dlen    = 0x%02X (%d)\n", pFrameHead->dlen, pFrameHead->dlen);
}

void print_frame_tail(const FRAME_TAIL_PTR pFrameTail) {
    printf("frame: chksum  = 0x%02X (%d)\n", pFrameTail->chksum, pFrameTail->chksum);
    printf("frame: end     = 0x%02X (%d)\n", pFrameTail->end, pFrameTail->end);
}

void print_vrd_0x14(const VRD_0X14_PTR p0x14) {
    printf("body_status    = %d\n", p0x14->body_status);
    printf("drive_status   = %d\n", p0x14->drive_status);
    printf("vehicle_status = %d\n", p0x14->vehicle_status);
    printf("gear_status    = %d\n", p0x14->gear_status);
    printf("lamp_status    = %d\n", p0x14->lamp_status);
    printf("temperature    = %d\n", p0x14->temperature);
    printf("mileage        = %d\n", p0x14->mileage);
    printf("gas            = %d\n", p0x14->gas);
    printf("rpm            = %d\n", p0x14->rpm);
    printf("alarm_status   = %d\n", p0x14->alarm_status);
    printf("mpg            = %d\n", p0x14->mpg);
    printf("speed          = %d\n", p0x14->speed);
    printf("max_range      = %d\n", p0x14->max_range);
}

void print_vrd_0x15(const VRD_0X15_PTR p0x15) {
    printf("cid    = %d\n", p0x15->cid);
    printf("param  = %d\n", p0x15->param);
    printf("result = %d\n", p0x15->result);
}

void print_vrd_0x23(const VRD_0X23_PTR p0x23) {
    printf("func   = %d\n", p0x23->func);
    printf("param  = %d\n", p0x23->param);
    printf("result = %d\n", p0x23->result);
}

void print_gen_ans(const GEN_ANS_PTR pGenAns) {
    printf("answer_serial  = 0x%02X (%d)\n", pGenAns->answer_serial, pGenAns->answer_serial);
    printf("answer_command = 0x%02X (%d)\n", pGenAns->answer_command, pGenAns->answer_command);
}

void print_qry_sts(const QRY_STS_PTR pQrySts) {
    printf("query_type = %d\n", pQrySts->query_type);
}

void print_sts_rpt(const STS_RPT_PTR pStsRpt) {
    switch (pStsRpt->status_type) {
        case 0x00: {
            printf("ck_type = 0x%02X (%d)\n", pStsRpt->status.ck_type, pStsRpt->status.ck_type);
            break;
        }
        case 0x01: {
            printf("gps.alarm     = %d\n", BSWAP_32(pStsRpt->status.data.gps.alarm));
            printf("gps.status    = %d\n", BSWAP_32(pStsRpt->status.data.gps.status));
            printf("gps.latitude  = %.6f\n", BSWAP_32(pStsRpt->status.data.gps.latitude)/1000000.0);
            printf("gps.longitude = %.6f\n", BSWAP_32(pStsRpt->status.data.gps.longitude)/1000000.0);
            printf("gps.height    = %d\n", BSWAP_16(pStsRpt->status.data.gps.height));
            printf("gps.speed     = %.2f\n", BSWAP_16(pStsRpt->status.data.gps.speed)/10.0);
            printf("gps.direction = %d\n", BSWAP_16(pStsRpt->status.data.gps.direction));
            char dt[32];
            sprintf(dt, "%02X-%02X-%02X %02X:%02X:%02X",
                pStsRpt->status.data.gps.datetime[0],
                pStsRpt->status.data.gps.datetime[1],
                pStsRpt->status.data.gps.datetime[2],
                pStsRpt->status.data.gps.datetime[3],
                pStsRpt->status.data.gps.datetime[4],
                pStsRpt->status.data.gps.datetime[5]
            );
            printf("gps.datetime  = %s\n", dt);
            printf("mileage       = %d\n", BSWAP_32(pStsRpt->status.data.mileage));
            printf("signal        = %d\n", pStsRpt->status.data.signal);
            printf("satellite     = %d\n", pStsRpt->status.data.satellite);
            printf("voltage       = %.2f\n", BSWAP_16(pStsRpt->status.data.voltage)/100.0);
            break;
        }
        default:
            break;
    }
}

LIST_PTR list_create_node(int type, void* data) {
    LIST_PTR p = NULL;
    p = (LIST_PTR)calloc(1, sizeof(LIST));
    p->type = type;
    switch (type) {
        case 1:
            memcpy(&p->data, data, sizeof(GEN_ANS));
            break;
        case 2:
            memcpy(&p->data, data, sizeof(QRY_STS));
            break;
        case 3:
            memcpy(&p->data, data, sizeof(STS_RPT));
            break;
        case 4:
            memcpy(&p->data, data, sizeof(VRD_0X14));
            break;
        case 5:
            memcpy(&p->data, data, sizeof(VRD_0X15));
            break;
        case 6:
            memcpy(&p->data, data, sizeof(VRD_0X23));
            break;
    }
    p->next = NULL;
    return p;
}

void list_append(LIST_PTR pHead, LIST_PTR pNew) {
    LIST_PTR p = pHead;
    while (p->next != NULL) {
        p = p->next;
    }
    p->next = pNew;
}

void list_print(LIST_PTR pHead) {
    LIST_PTR p = pHead;
    do {
        switch (p->type) {
            case 1: {
                GEN_ANS_PTR pGenAns = &(p->data.gen_ans);
                print_gen_ans(pGenAns);
                break;
            }
            case 2: {
                QRY_STS_PTR pQrySts = &(p->data.qry_sts);
                print_qry_sts(pQrySts);
                break;
            }
            case 3: {
                STS_RPT_PTR pStsRpt = &(p->data.sts_rpt);
                print_sts_rpt(pStsRpt);
                break;
            }
            case 4: {
                VRD_0X14_PTR pVrd0x14 = &(p->data.vrd_0x14);
                print_vrd_0x14(pVrd0x14);
                break;
            }
            case 5: {
                VRD_0X15_PTR pVrd0x15 = &(p->data.vrd_0x15);
                print_vrd_0x15(pVrd0x15);
                break;
            }
            case 6: {
                VRD_0X23_PTR pVrd0x23 = &(p->data.vrd_0x23);
                print_vrd_0x23(pVrd0x23);
                break;
            }
        }
        p = p->next;
    } while (p != NULL);
}

void list_clear(LIST_PTR pHead) {
    while (pHead->next != NULL) {
        LIST_PTR p = pHead->next;
        pHead->next = p->next;
        free(p);
    }
    if (pHead->next == NULL) {
        free(pHead);
        return;
    }
}

unsigned char chksum(const unsigned char *data, int len) {
    unsigned char ret = 0;
    for (int i=0; i<len; i++) {
        ret ^= data[i];
    }
    return ret;
}

//unsigned char *get_buf_from_hex(const char *hex) {
//    size_t len = strlen(hex) / 2;
//    unsigned char *buf = calloc(len, 1);
//    for (int i=0; i<len; i++) {
//        sscanf(hex+i*2, "%2X", buf+i);
//    }
//    return buf;
//}

DEC decode(char *hex) {
    unsigned char *buf = (unsigned char *)hex;//get_buf_from_hex(hex);
    DEC dec;
    if (buf[0] == FS) { // 帧起始校验
        FRAME_HEAD_PTR pFrameHead = (FRAME_HEAD_PTR)buf;
        print_frame_head(pFrameHead);

        if (buf[sizeof(FRAME_HEAD)+pFrameHead->dlen+sizeof(FRAME_TAIL)-1] == FE) { // 帧结束校验
            FRAME_TAIL_PTR pFrameTail = (FRAME_TAIL_PTR)(buf+sizeof(FRAME_HEAD)+pFrameHead->dlen);
            print_frame_tail(pFrameTail);

            if (chksum(buf+1, sizeof(FRAME_HEAD)+pFrameHead->dlen-1) == pFrameTail->chksum) { // 帧校验和校验
                FRAME_BODY FrameBody;
                FrameBody.data = calloc(pFrameHead->dlen, 1);
                memcpy(FrameBody.data, buf+sizeof(FRAME_HEAD), pFrameHead->dlen);
                printf("%c %c\n", FrameBody.data[0], FrameBody.data[1]);

                dec.serial = pFrameHead->serial;
                dec.command = pFrameHead->command;
                dec.pList = NULL;

                if (pFrameHead->command == 0x80 || pFrameHead->command == 0x00) {
                    unsigned char *ptr = FrameBody.data;
                    GEN_ANS_PTR pGenAns = (GEN_ANS_PTR)(ptr);
                    dec.pList = list_create_node(1, pGenAns);
                }
                else if (pFrameHead->command == 0x81) {
                    unsigned char *ptr = FrameBody.data;
                    QRY_STS_PTR pQrySts = (QRY_STS_PTR)(ptr);
                    dec.pList = list_create_node(2, pQrySts);
                }
                else if (pFrameHead->command == 0x01) {
                    unsigned char *ptr = FrameBody.data;
                    STS_RPT_PTR pStsRpt = (STS_RPT_PTR)(ptr);
                    dec.pList = list_create_node(3, pStsRpt);
                }
                else if (pFrameHead->command == 0x09 || pFrameHead->command == 0x89) { // 透传指令
                    unsigned char *ptr = FrameBody.data;
                    while (ptr < FrameBody.data+pFrameHead->dlen) {
                        VRD_HEAD_PTR pVrdHead = (VRD_HEAD_PTR)(ptr);
                        switch (pVrdHead->command) {
                            case 0x14: {
                                VRD_0X14_PTR p0x14 = (VRD_0X14_PTR)(ptr+sizeof(VRD_HEAD));
                                if (dec.pList == NULL) {
                                    dec.pList = list_create_node(4, p0x14);
                                } else {
                                    list_append(dec.pList, list_create_node(4, p0x14));
                                }
                                break;
                            }
                            case 0x15: {
                                VRD_0X15_PTR p0x15 = (VRD_0X15_PTR)(ptr+sizeof(VRD_HEAD));
                                if (dec.pList == NULL) {
                                    dec.pList = list_create_node(5, p0x15);
                                } else {
                                    list_append(dec.pList, list_create_node(5, p0x15));
                                }
                                break;
                            }
                            case 0x23: {
                                VRD_0X23_PTR p0x23 = (VRD_0X23_PTR)(ptr+sizeof(VRD_HEAD));
                                if (dec.pList == NULL) {
                                    dec.pList = list_create_node(6, p0x23);
                                } else {
                                    list_append(dec.pList, list_create_node(6, p0x23));
                                }
                                break;
                            }
                            default:
                                break;
                        }
                        ptr += sizeof(VRD_HEAD)+pVrdHead->dlen;
                    }
                }
                free(FrameBody.data);
            }
        }
    }
    //free(buf);

    return dec;
}

//int main(int argc, char **argv) {
//    while (*++argv != NULL) {
//        printf("%s\n", *argv);
//        decode(*argv);
//        printf("\n");
//    }
//}
