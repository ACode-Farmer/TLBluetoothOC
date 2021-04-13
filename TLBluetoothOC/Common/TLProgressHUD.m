//
//  TLProgressHUD.m
//  GPUImageDemo
//
//  Created by 汪杰 on 2020/7/6.
//  Copyright © 2020 汪杰. All rights reserved.
//

#import "TLProgressHUD.h"

#import "UIView+TLImagePicker.h"

@interface TLProgressHUD()

///
@property (nonatomic, strong) UIView *containerView;

///
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

///
@property (nonatomic, strong) UILabel *textLabel;

///
@property (nonatomic, assign, getter=isShow) BOOL show;

@end


@implementation TLProgressHUD

+ (instancetype)progressHUDWithType:(TLProgressHUDType)type {
    return [[self alloc] initWithType:type];
}

- (instancetype)initWithType:(TLProgressHUDType)type {
    self = [self initWithFrame:CGRectZero];
    _type = type;
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _type = TLProgressHUDTypeDefault;
        
        _containerView = [UIView new];
        _containerView.layer.cornerRadius = 3.0;
        _containerView.clipsToBounds = YES;
        _containerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        _textLabel = [UILabel new];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.font = [UIFont systemFontOfSize:16];
        _textLabel.textColor = UIColor.whiteColor;
        
        [_containerView addSubview:_indicatorView];
        [_containerView addSubview:_textLabel];
        
        [self addSubview:_containerView];
    }
    return self;
}

#pragma mark - Super Methods
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *originView = [super hitTest:point withEvent:event];
    if (self.type == TLProgressHUDTypeText &&
        originView != self.containerView) {
        return nil;
    }
    return originView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat indicatorWidth = 40.0;
    if (self.type == TLProgressHUDTypeDefault) {
        CGFloat containerHeight = 120.0;
        CGFloat containerWidth = 120.0;
        CGSize textSize = [_textLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, 20)];
        if (textSize.width > (containerWidth - 20)) {
            containerWidth = MAX(150, (textSize.width + 20));
        }
        _containerView.frame = CGRectMake((self.tl_width - containerWidth) * 0.5, (self.tl_height - containerHeight) * 0.5, containerWidth, containerHeight);
        
        _indicatorView.frame = CGRectMake((containerWidth - indicatorWidth) * 0.5, 25, indicatorWidth, indicatorWidth);
        
        _textLabel.frame = CGRectMake(0, containerHeight - 15 - 17, containerWidth, 15);
    }
    else if (self.type == TLProgressHUDTypeText) {
        CGSize textSize = [_textLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, 20)];
        textSize.height = 20.0;
        textSize.width = textSize.width < 100 ? 100 : textSize.width;
        
        CGFloat containerHeight = textSize.height + 20;
        CGFloat containerWidth = textSize.width + 40;
        _containerView.frame = CGRectMake((self.tl_width - containerWidth) * 0.5, (self.tl_height - containerHeight) * 0.5, containerWidth, containerHeight);
        _indicatorView.hidden = YES;
        
        _textLabel.frame = _containerView.bounds;
    }
    else {
        CGFloat containerWidth = 120.0;
        _containerView.frame = CGRectMake((self.tl_width - containerWidth) * 0.5, (self.tl_height - containerWidth) * 0.5, containerWidth, containerWidth);
        
        _indicatorView.frame = CGRectMake((containerWidth - 30) * 0.5, (containerWidth - 30) * 0.5, 30, 30);
        
        _textLabel.hidden = YES;
    }
}

- (void)dealloc {
    
}

- (void)show {
    [self showWithText:@""];
}

- (void)showWithText:(NSString *)text {
    [self showWithText:text time:0];
}

- (void)showWithText:(NSString *)text time:(CGFloat)time {
    [self showInView:nil text:text time:time];
}

- (void)showInView:(UIView * __nullable )view text:(NSString *)text {
    [self showInView:view text:text time:0];
}

- (void)showInView:(UIView * __nullable )view text:(NSString *)text time:(CGFloat)time {
    self.show = YES;
    if (view == nil) {
        //在主线程中处理,否则在viewDidLoad方法中直接调用,会先加本视图,
        //后加控制器的视图到UIWindow上,导致本视图无法显示出来,这样处理后便会优先加控制器的视图到UIWindow上
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
            for (UIWindow *window in frontToBackWindows) {
                BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
                BOOL windowIsVisible = !window.hidden && window.alpha > 0;
                BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;

                if (windowOnMainScreen && windowIsVisible && windowLevelNormal) {
                    [window addSubview:self];
                    self.frame = window.bounds;
                    break;
                }
            }
        }];
    }
    else {
        [view addSubview:self];
        self.frame = view.bounds;
    }
    
    self.textLabel.text = text;
    
    [self setNeedsLayout];
    
    self.containerView.alpha = 0;
    [self.indicatorView startAnimating];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.containerView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
    if (time <= 0) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.isShow) {
            [self hide];
        }
    });
}

- (void)hide {
    self.show = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.containerView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.indicatorView stopAnimating];
        [self removeFromSuperview];
    }];
}

#pragma mark - Setters
- (void)setText:(NSString *)text {
    _text = text;
    if (![text isKindOfClass:[NSString class]] || text.length == 0) {
        return;
    }
    self.textLabel.text = text;
}

@end
