//
//  XKCommonShareChannelSelectionView.m
//  DangJi
//
//  Created by Glority_Lee on 2017/7/20.
//  Copyright © 2017年 Glority. All rights reserved.
//

#import "XKCommonShareChannelSelectionView.h"

/***********************第三方库*********************/
#import <Masonry.h>

/***********************自定义视图类*********************/
//#import "YSCommonShareMenuView.h"
#import "XKShareButton.h"

#define kNormalShareTitleColor UIColorFromHEX(0x666666)
#define kNormalShareTitleFont YSFontLight(12)
#define kSpecialShareTitleColor UIColorFromHEX(0x5a5a5a)
#define kSpecialShareTitleFont YSFontRegular(12)
#define KTipColor UIColorFromHEX(0x666666)
#define kTipFont YSFontLight(13)

#define kShareChannelViewH (115.0f + HEIGHT_HOME_INDICATOR)
static CGFloat const kNormalShareBtnH = 54.0;
static CGFloat const kSpecialShareBtnH = 57.0;
static CGFloat const kNormalShareBtnImageWH = 38.0;
static CGFloat const kSpecialShareBtnImageWH = 42.0;
static CGFloat const kNormalShareTitleMarginTop = 8.0;
static CGFloat const kSpecialShareTitleMarginTop = 7.0;
static NSString *kTipText = @"分享至";

@interface XKCommonShareChannelSelectionView()

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) NSMutableArray<XKShareButton *> *shareChannelBtns;
@property (nonatomic, strong) UIButton *maskBtn;

@end

@implementation XKCommonShareChannelSelectionView

#pragma mark - init Methods
+ (instancetype)shareChannelSelectionView {
    XKCommonShareChannelSelectionView *_instance = [[self alloc] init];
    return _instance;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    self.backgroundColor = [UIColor whiteColor];
    [self addAllSubviews];
    [self layoutAllSubviews];
}

- (void)addAllSubviews {
    [self addSubview:self.tipLabel];
    [self createAndAddDefaultShareBtns];
}

- (void)layoutAllSubviews {
    //分享提示
    [self.tipLabel remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.top).offset(Frame_Ratio(5, 0));
        make.centerX.equalTo(self.centerX);
        make.width.lessThanOrEqualTo(self.width).offset(Frame_Ratio(20, 0));
    }];
    
   //分享按钮
    [self layoutShareBtns];
}

#pragma mark - Public Methods
- (void)showInView:(UIView *)superView {
    if(superView == nil  || self.superview) {
        return;
    }
    
    self.maskBtn.alpha = 0.0;
    [superView addSubview:self.maskBtn];
    [self.maskBtn makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superView);
    }];
    
    [self layoutAllSubviews];
    [superView addSubview:self];
    self.frame = (CGRect){0, HEIGHT_SCREEN, WIDTH_SCREEN, kShareChannelViewH};
    [self appearAnimation];
}

- (void)updateSubviewsLayout {
    if (self.superview == nil) {
        return;
    }
    self.frame = self.alpha <= 0.0 ? (CGRect){0, HEIGHT_SCREEN, WIDTH_SCREEN, kShareChannelViewH} : (CGRect){0, HEIGHT_SCREEN-kShareChannelViewH, WIDTH_SCREEN, kShareChannelViewH};
    [self layoutAllSubviews];
    
}

- (void)appearAnimation {
    [UIView animateWithDuration:0.25 animations:^{
      self.frame = (CGRect){0, HEIGHT_SCREEN-kShareChannelViewH, WIDTH_SCREEN, kShareChannelViewH};
        self.maskBtn.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.frame = (CGRect){0, HEIGHT_SCREEN-kShareChannelViewH, WIDTH_SCREEN, kShareChannelViewH};
        self.maskBtn.alpha = 1.0;
    }];
}

- (void)disappearAniamtion {
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = (CGRect){0, HEIGHT_SCREEN, WIDTH_SCREEN, kShareChannelViewH};
        self.maskBtn.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.frame = (CGRect){0, HEIGHT_SCREEN, WIDTH_SCREEN, kShareChannelViewH};
        self.maskBtn.alpha = 0.0;
        [self.maskBtn removeFromSuperview];
        [self removeFromSuperview];
    }];
}

- (void)dismiss {
    self.maskBtn.alpha = 0.0;
    [self.maskBtn removeFromSuperview];
    [self removeFromSuperview];
}

#pragma mark - Private Methods
- (void)layoutShareBtns {
    //分享渠道按钮
    CGFloat leftRightMarginSpace = Frame_Ratio(30, 0);
    CGFloat shareBtnWidth = (WIDTH_SCREEN- leftRightMarginSpace*2)/(self.shareChannelBtns.count);
    CGFloat shareBtnMarginTop = 20.0;
    CGFloat shareBtnSpecialMarginTop = 18;
    if(self.shareChannelBtns.count > 0) {
        [self.shareChannelBtns enumerateObjectsUsingBlock:^(XKShareButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGFloat maringToTop = (obj.tag == XKShareMenuTypeCircle) ? shareBtnSpecialMarginTop : shareBtnMarginTop;
            CGFloat shareHeight = (obj.tag == XKShareMenuTypeCircle) ? kSpecialShareBtnH : kNormalShareBtnH;
            if(idx == 0) {
                [obj remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.tipLabel.bottom).offset(maringToTop);
                    make.left.equalTo(self.left).offset(leftRightMarginSpace);
                    make.size.equalTo((CGSize){shareBtnWidth, shareHeight});
                }];
            }else {
                NSUInteger preIdx = idx - 1;
                XKShareButton *leftBtn = self.shareChannelBtns[preIdx];
                [obj remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.tipLabel.bottom).offset(maringToTop);
                    make.left.equalTo(leftBtn.right);
                    make.size.equalTo((CGSize){shareBtnWidth, shareHeight});
                }];
            }
        }];
    }
}

- (void)createAndAddDefaultShareBtns {
    NSArray *tags = @[@(XKShareMenuTypeWechat), @(XKShareMenuTypeCircle),  @(XKShareMenuTypeQQ), @(XKShareMenuTypeSina)];
    [self.shareChannelBtns makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.shareChannelBtns removeAllObjects];
    for (NSNumber *tagTmp in tags) {
        XKShareButton *shareBtn = (tagTmp.integerValue == XKShareMenuTypeCircle) ? [self createSpecialShareBtn] : [self createNormalShareBtn];
        shareBtn.tag = tagTmp.integerValue;
        [shareBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        NSString *titleStr = @"";
        NSString *imageName = @"";
        switch (tagTmp.integerValue) {
            case XKShareMenuTypeWechat:
                {
                    titleStr = @"微信好友";
                    imageName = @"common_share_wechat";
                }
                break;
            case XKShareMenuTypeCircle:
            {
                titleStr = @"朋友圈";
                imageName = @"common_share_moment";
            }
                break;
            case XKShareMenuTypeSina:
            {
                titleStr = @"微博";
                imageName = @"common_share_weibo";
            }
                break;
            case XKShareMenuTypeQQ:
            {
                titleStr = @"QQ好友";
                imageName = @"common_share_qq";
            }
                break;
                
            default:
                break;
        }
        [shareBtn setTitle:titleStr forState:UIControlStateNormal];
        [shareBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [self addSubview:shareBtn];
        [self.shareChannelBtns addObject:shareBtn];
    }
}

#pragma mark - Action Methods
- (void)shareAction:(UIButton *)sender {
    [self dismiss];
    if([self.delegate respondsToSelector:@selector(commonShareChannelSelectionView:didChooseMenuTag:)]) {
        [self.delegate commonShareChannelSelectionView:self didChooseMenuTag:sender.tag];
    }
}

- (void)closeAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(commonShareChannelSelectionView:didCanceled:)]) {
        [self.delegate commonShareChannelSelectionView:self didCanceled:sender];
    }
    [self disappearAniamtion];
}

#pragma mark - Getter Methods
- (NSMutableArray *)shareChannelBtns {
    if(_shareChannelBtns == nil) {
        _shareChannelBtns = @[].mutableCopy;
    }
    return _shareChannelBtns;
}

- (UILabel *)tipLabel {
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = kTipFont;
        _tipLabel.textColor = KTipColor;
        _tipLabel.text = kTipText;
    }
    return _tipLabel;
}

- (XKShareButton *)createNormalShareBtn {
    XKShareButton *shareBtn = [XKShareButton xkl_shareButtonWithImageWH:kNormalShareBtnImageWH titleMarginTop:kNormalShareTitleMarginTop];
    shareBtn.titleLabel.font = kNormalShareTitleFont;
    [shareBtn setTitleColor:kNormalShareTitleColor forState:UIControlStateNormal];
    return shareBtn;
}

- (XKShareButton *)createSpecialShareBtn {
    XKShareButton *shareBtn = [XKShareButton xkl_shareButtonWithImageWH:kSpecialShareBtnImageWH titleMarginTop:kSpecialShareTitleMarginTop];
    shareBtn.titleLabel.font = kSpecialShareTitleFont;
    [shareBtn setTitleColor:kSpecialShareTitleColor forState:UIControlStateNormal];
    return shareBtn;
}

- (UIButton *)maskBtn {
    if (_maskBtn == nil) {
        _maskBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_maskBtn addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        _maskBtn.backgroundColor = UIColorFromRGB(0x000000, 0.6);
    }
    return _maskBtn;
}


@end
