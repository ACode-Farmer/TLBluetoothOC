//
//  TLDeviceCell.m
//  TLBluetoothOC
//
//  Created by Will on 2021/3/29.
//

#import "TLDeviceCell.h"
#import "UIView+TLImagePicker.h"

@interface TLDeviceCell ()

///
@property (nonatomic, strong) UIView *topView;

///
@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation TLDeviceCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.systemOrangeColor;
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _textLabel.textColor = UIColor.whiteColor;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.numberOfLines = 0;
        [self addSubview:_textLabel];
        
        
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 30)];
        [self addSubview:_topView];
        
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, _topView.frame.size.width - 80, _topView.tl_height)];
        _countLabel.textColor = UIColor.whiteColor;
        _countLabel.text = @"3";
        _countLabel.textAlignment = NSTextAlignmentCenter;
        [_topView addSubview:_countLabel];
        
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.tag = 1000;
        [leftBtn setTitle:@"-" forState:0];
        [leftBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        leftBtn.frame = CGRectMake(0, 0, 40, _topView.tl_height);
        [_topView addSubview:leftBtn];
        
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.tag = 1001;
        [rightBtn setTitle:@"+" forState:0];
        [rightBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        rightBtn.frame = CGRectMake(_topView.frame.size.width - 40, 0, 40, _topView.tl_height);
        [_topView addSubview:rightBtn];
    }
    return self;
}

#pragma mark - Public Methods
- (void)setText:(NSString *)text {
    _text = text;
    if ([text isEqual:@"喇叭"] || [text isEqual:@"危险灯"] || [text isEqual:@"报警控制"]) {
        _topView.hidden = NO;
        _textLabel.frame = CGRectMake(0, CGRectGetMaxY(_topView.frame), self.frame.size.width, self.frame.size.height - CGRectGetMaxY(_topView.frame));
    }
    else {
        _topView.hidden = YES;
        _textLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
    _textLabel.text = text;
}

#pragma mark - Events
- (void)buttonAction:(UIButton *)sender {
    BOOL isAdd = sender.tag == 1001;
    NSInteger count = _countLabel.text.integerValue;
    if (!isAdd && count == 1) {
        return;
    }
    count = isAdd ? count + 1 : count - 1;
    _countLabel.text = [NSString stringWithFormat:@"%ld",count];
}

#pragma mark - Getters
- (NSInteger)count {
    return self.countLabel.text.integerValue;
}

@end
