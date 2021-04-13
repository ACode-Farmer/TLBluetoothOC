//
//  TLSettingController.h
//  TLBluetoothOC
//
//  Created by Will on 2021/3/29.
//

#import "TLViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TLSettingControllerDelegate <NSObject>

- (void)settingCommand:(int)command value:(int)value;

@end

@interface TLSettingController : TLViewController

///
@property (nonatomic, weak  ) id<TLSettingControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
