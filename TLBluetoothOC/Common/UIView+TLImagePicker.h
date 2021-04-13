//
//  UIView+TLImagePicker.h
//  GPUImageDemo
//
//  Created by 汪杰 on 2020/6/23.
//  Copyright © 2020 汪杰. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kRGB(r, g, b)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#pragma mark - 系统版本
#define     SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define     SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define     SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define     SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define     SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO_8_0 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")

#pragma mark - 设计稿尺寸
#define     DESIGN_SCREEN_WIDTH         375.0f

#pragma mark - 屏幕尺寸
#define     SCREEN_SIZE                 [UIScreen mainScreen].bounds.size
#define     SCREEN_WIDTH                SCREEN_SIZE.width
#define     SCREEN_HEIGHT               SCREEN_SIZE.height
#define     SCREEN_BOUNDS               [UIScreen mainScreen].bounds

#pragma mark - 设备(屏幕)类型

#define     IS_IPHONE4              ([UIScreen mainScreen].bounds.size.width == 320.0f && [UIScreen mainScreen].bounds.size.height == 480.0f)           // 320 * 480
#define     IS_IPHONE5              ([UIScreen mainScreen].bounds.size.width == 320.0f && [UIScreen mainScreen].bounds.size.height == 568.0f)           // 320 * 568
#define     IS_IPHONE6              ([UIScreen mainScreen].bounds.size.width == 375.0f && [UIScreen mainScreen].bounds.size.height == 667.0f)           // 375 * 667
#define     IS_IPHONE6P             ([UIScreen mainScreen].bounds.size.width == 414.0f && [UIScreen mainScreen].bounds.size.height == 736.0f)           // 414 * 736
#define     IS_IPHONEX              ([UIScreen mainScreen].bounds.size.width == 375.0f && [UIScreen mainScreen].bounds.size.height == 812.0f)
#define     IS_IPHONEXS             ([UIScreen mainScreen].bounds.size.width == 375.0f && [UIScreen mainScreen].bounds.size.height == 812.0f)
#define     IS_IPHONEXR             ([UIScreen mainScreen].bounds.size.width == 414.0f && [UIScreen mainScreen].bounds.size.height == 896.0f)
#define     IS_IPHONEXMAX           ([UIScreen mainScreen].bounds.size.width == 414.0f && [UIScreen mainScreen].bounds.size.height == 896.0f)

#define     IS_IPHONEX_ALL (IS_IPHONEX == YES || IS_IPHONEXS == YES || IS_IPHONEXR == YES || IS_IPHONEXMAX == YES)

#define     IS_IPAD [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? YES : NO


#pragma mark - 常用控件高度
//iPhoneX相对其他设备的上下间隙高度
#define     X_TOPSPACE    (IS_IPHONEX_ALL ? 24.0f : 0.0)
#define     X_BOTTOMSPACE (IS_IPHONEX_ALL ? 34.0f : 0.0)

#define     STATUSBAR_HEIGHT            (IS_IPHONEX_ALL ? 20.0f + X_TOPSPACE : 20.0f)
#define     TABBAR_HEIGHT               (IS_IPHONEX_ALL ? 49.0f + X_BOTTOMSPACE : 49.0f)
#define     NAVBAR_HEIGHT               44.0f
#define     SEARCHBAR_HEIGHT            (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0") ? 56.0f : 44.0f)
#define     BORDER_WIDTH_1PX            ([[UIScreen mainScreen] scale] > 0.0 ? 1.0 / [[UIScreen mainScreen] scale] : 1.0)

#define     TABBAR_HEIGHT_CUSTOM        (TABBAR_HEIGHT + 26.0)

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TLOscillatoryAnimationType) {
    TLOscillatoryAnimationToBigger,
    TLOscillatoryAnimationToSmaller,
};

@interface UIView (TLImagePicker)

@property (nonatomic) CGFloat tl_left;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat tl_top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat tl_right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat tl_bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat tl_width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat tl_height;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGFloat tl_centerX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat tl_centerY;     ///< Shortcut for center.y
@property (nonatomic) CGPoint tl_origin;      ///< Shortcut for frame.origin.
@property (nonatomic) CGSize  tl_size;        ///< Shortcut for frame.size.

- (void)tl_removeAllSubViews;

- (void)tl_addSubviews:(NSArray *)subviews;

+ (void)showOscillatoryAnimationWithLayer:(CALayer *)layer type:(TLOscillatoryAnimationType)type;

/**
 旋转

 @param value 旋转角度，顺时针正，逆时针负
 @param animated 是否动画
 */
- (void)tl_rotation:(CGFloat)value animated:(BOOL)animated;

/**
 添加圆角

 @param radius 圆角半径
 @param corners 圆角位置
 */
- (void)tl_setCornerRadius:(CGFloat)radius corners:(UIRectCorner)corners;

@end

NS_ASSUME_NONNULL_END
