//
//  TLDeviceCell.h
//  TLBluetoothOC
//
//  Created by Will on 2021/3/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TLDeviceCell : UICollectionViewCell

///
@property (nonatomic, strong) UILabel *textLabel;

///
@property (nonatomic, strong) NSString *text;

///
@property (nonatomic, assign, readonly) NSInteger count;

@end

NS_ASSUME_NONNULL_END
