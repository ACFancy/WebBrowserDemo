//
//  XKWebViewController.h
//  Dmeo4
//
//  Created by User on 11/6/17.
//  Copyright © 2017 User. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XKWebViewController : UIViewController


@property (nonatomic) BOOL isPushed;

/**
 *  origin url
 */
@property (nonatomic)NSURL* url;

/**
 *  embed webView
 */
@property (nonatomic)UIWebView* webView;

/**
 *  tint color of progress view
 */
@property (nonatomic)UIColor* progressViewColor;


//分享参数
@property (nonatomic, strong) NSString *shareTitle;
@property (nonatomic, strong) NSString *shareUrl;
@property (nonatomic, strong) NSString *shareDesc;
@property (nonatomic, strong) NSString *shareImageUrl;

/**
 *  get instance with url
 *
 *  @param url url
 *
 *  @return instance
 */
-(instancetype)initWithUrl:(NSURL*)url;


@end
