//
//  TLProgressHUD.h
//  GPUImageDemo
//
//  Created by 汪杰 on 2020/7/6.
//  Copyright © 2020 汪杰. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TLProgressHUDType) {
    TLProgressHUDTypeDefault,  //indicator + text
    TLProgressHUDTypeText,     //text
    TLProgressHUDTypeIndicator,//indicator
};

@interface TLProgressHUD : UIButton

///
@property (nonatomic, assign, readonly) TLProgressHUDType type;

///
@property (nonatomic, copy  ) NSString *text;

+ (instancetype)progressHUDWithType:(TLProgressHUDType)type;

- (instancetype)initWithType:(TLProgressHUDType)type;

- (void)show;

- (void)showWithText:(NSString *)text;

- (void)showWithText:(NSString *)text time:(CGFloat)time;

- (void)showInView:(UIView * __nullable )view text:(NSString *)text;

- (void)showInView:(UIView * __nullable )view text:(NSString *)text time:(CGFloat)time;

- (void)hide;

@end

NS_ASSUME_NONNULL_END
