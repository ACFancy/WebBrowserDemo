//
//  XKShareButton.m
//  Dmeo4
//
//  Created by User on 11/7/17.
//  Copyright © 2017 User. All rights reserved.
//

#import "XKShareButton.h"

#define kShareBtnImageWH 40
#define kShareBtnHeight  60

//自定义分享按钮
@interface XKShareButton ()

@property (nonatomic, assign) CGFloat imageWH;
@property (nonatomic, assign) CGFloat titleMarginTop;
@property (nonatomic, assign) CGFloat totalHeight;

@end

@implementation XKShareButton

#pragma mark - init Methods

/**
 类初始化
 
 @return 返回tabBarItem
 */
+ (instancetype)xkl_shareButton {
    XKShareButton *shareBtn = [self buttonWithType:UIButtonTypeCustom];
    shareBtn.imageWH = kShareBtnImageWH;
    shareBtn.titleMarginTop = 6;
    shareBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    return shareBtn;
}

+ (instancetype)xkl_shareButtonWithImageWH:(CGFloat)imageWH
                            titleMarginTop:(CGFloat)titleMarginTop {
    XKShareButton *shareBtn = [self buttonWithType:UIButtonTypeCustom];
    shareBtn.imageWH = imageWH;
    shareBtn.titleMarginTop = titleMarginTop;
    shareBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    return shareBtn;
}

#pragma mark - Override Methods
- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return (CGRect){0.5 * (CGRectGetWidth(self.frame)- self.imageWH),0,self.imageWH,self.imageWH};
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return (CGRect){0,self.imageWH + self.titleMarginTop ,CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - (self.imageWH + self.titleMarginTop)};
}

@end
