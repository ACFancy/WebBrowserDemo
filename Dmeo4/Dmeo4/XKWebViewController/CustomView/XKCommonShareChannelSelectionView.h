//
//  XKCommonShareChannelSelectionView.h
//  DangJi
//
//  Created by Glority_Lee on 2017/7/20.
//  Copyright © 2017年 Glority. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, XKShareMenuType) {
    XKShareMenuTypeNone = 1000,
    XKShareMenuTypeWechat,
    XKShareMenuTypeCircle,
    XKShareMenuTypeQQ,
    XKShareMenuTypeSina,
};


@class UserShareConfigModel, XKCommonShareChannelSelectionView;
@protocol XKCommonShareChannelSelectionViewDelegate <NSObject>

@optional
- (void)commonShareChannelSelectionView:(XKCommonShareChannelSelectionView *)shareChannelSelectionView didChooseMenuTag:(XKShareMenuType)menuTagType;
- (void)commonShareChannelSelectionView:(XKCommonShareChannelSelectionView *)shareChannelSelectionView didCanceled:(UIButton *)sender;

@end

@interface XKCommonShareChannelSelectionView : UIView

@property (nonatomic, weak) id<XKCommonShareChannelSelectionViewDelegate> delegate;

+ (instancetype)shareChannelSelectionView;
- (void)showInView:(UIView *)superView;
- (void)updateSubviewsLayout;

@end
