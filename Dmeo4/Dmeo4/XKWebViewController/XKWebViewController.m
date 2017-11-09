//
//  XKWebViewController.m
//  Dmeo4
//
//  Created by User on 11/6/17.
//  Copyright © 2017 User. All rights reserved.
//

#import "XKWebViewController.h"

#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import "XKCommonShareChannelSelectionView.h"
#import <Masonry.h>


@interface XKWebViewController ()<UIWebViewDelegate,UINavigationControllerDelegate,UINavigationBarDelegate,NJKWebViewProgressDelegate>

@property (nonatomic)UIBarButtonItem* closeButtonItem;

@property (nonatomic)NJKWebViewProgress* progressProxy;
@property (nonatomic)NJKWebViewProgressView* progressView;
@property (nonatomic, strong) UIButton *navLeftButton;
@property (nonatomic, strong) UIButton *navRightButton;
@property (nonatomic, strong) XKCommonShareChannelSelectionView *shareChannelsView;


/**
 *  array that hold snapshots
 */
@property (nonatomic)NSMutableArray* snapShotsArray;

/**
 *  current snapshotview displaying on screen when start swiping
 */
@property (nonatomic)UIView* currentSnapShotView;

/**
 *  previous view
 */
@property (nonatomic)UIView* prevSnapShotView;

/**
 *  background alpha black view
 */
@property (nonatomic)UIView* swipingBackgoundView;

/**
 *  left pan ges
 */
@property (nonatomic)UIPanGestureRecognizer* swipePanGesture;

/**
 *  if is swiping now
 */
@property (nonatomic)BOOL isSwipingBack;

@end

@implementation XKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initContentView];
}

- (instancetype)initWithUrl:(NSURL *)url{
    self = [super init];
    if (self) {
        self.url = url;
        _progressViewColor =UIColorFromHEX(0x149ded);
    }
    return self;
}

- (void)initContentView {
    self.navigationItem.title = @"";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.webView.delegate = self.progressProxy;
    self.webView.allowsInlineMediaPlayback = YES;
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    
    [self.navigationController.navigationBar addSubview:self.progressView];
    // Do any additional setup after loading the view.
    [self configNavigationBar];
}

- (void)configNavigationBar {
    
    [self createNavigationButtonWithImage:@"webview_back_btn" selectedImage:nil onLeft:YES withBlock:nil];
    [self.navLeftButton addTarget:self action:@selector(clickBackButton) forControlEvents:UIControlEventTouchUpInside];
    [self configShareButton];
}

- (void)configShareButton {
    if (!self.navRightButton) {
        [self createNavigationButtonWithImage:@"webView_share_btn" selectedImage:nil onLeft:NO withBlock:nil];
        [self.navRightButton addTarget:self action:@selector(clickShareBtnAction) forControlEvents:UIControlEventTouchUpInside];
//        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

//-  (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return UIInterfaceOrientationLandscapeLeft;
//}

-  (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

-  (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.webView.frame = CGRectMake(0, CGRectGetHeight(self.navigationController.navigationBar.frame) , [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-CGRectGetHeight(self.navigationController.navigationBar.frame)-HEIGHT_HOME_INDICATOR);
    [self.shareChannelsView updateSubviewsLayout];
    
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
}

-  (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
}


#pragma mark - logic of push and pop snap shot views
-(void)pushCurrentSnapshotViewWithRequest:(NSURLRequest*)request{
    //    NSLog(@"push with request %@",request);
    NSURLRequest* lastRequest = (NSURLRequest*)[[self.snapShotsArray lastObject] objectForKey:@"request"];
    
    //如果url是很奇怪的就不push
    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
        //        NSLog(@"about blank!! return");
        return;
    }
    //如果url一样就不进行push
    if ([lastRequest.URL.absoluteString isEqualToString:request.URL.absoluteString]) {
        return;
    }
    
    UIView* currentSnapShotView = [self.webView snapshotViewAfterScreenUpdates:YES];
    [self.snapShotsArray addObject:
     @{
       @"request":request,
       @"snapShotView":currentSnapShotView
       }
     ];
    //    NSLog(@"now array count %d",self.snapShotsArray.count);
}

-(void)startPopSnapshotView{
    if (self.isSwipingBack) {
        return;
    }
    if (!self.webView.canGoBack) {
        return;
    }
    self.isSwipingBack = YES;
    //create a center of scrren
    CGPoint center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2+NAVFRAME_BARHEIGHT/2.0);
    
    self.currentSnapShotView = [self.webView snapshotViewAfterScreenUpdates:YES];
    
    //add shadows just like UINavigationController
    self.currentSnapShotView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.currentSnapShotView.layer.shadowOffset = CGSizeMake(3, 3);
    self.currentSnapShotView.layer.shadowRadius = 5;
    self.currentSnapShotView.layer.shadowOpacity = 0.75;
    
    //move to center of screen
    self.currentSnapShotView.center = center;
    
    self.prevSnapShotView = (UIView*)[[self.snapShotsArray lastObject] objectForKey:@"snapShotView"];
    center.x -= 60;
    self.prevSnapShotView.center = center;
    self.prevSnapShotView.alpha = 1;
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.prevSnapShotView];
    [self.view addSubview:self.swipingBackgoundView];
    [self.view addSubview:self.currentSnapShotView];
}

-(void)popSnapShotViewWithPanGestureDistance:(CGFloat)distance{
    if (!self.isSwipingBack) {
        return;
    }
    
    if (distance <= 0) {
        return;
    }
    
    CGPoint currentSnapshotViewCenter = CGPointMake(WIDTH_SCREEN/2, HEIGHT_SCREEN/2);
    currentSnapshotViewCenter.x += distance;
    CGPoint prevSnapshotViewCenter = CGPointMake(WIDTH_SCREEN/2, HEIGHT_SCREEN/2);
    prevSnapshotViewCenter.x -= (WIDTH_SCREEN - distance)*60/WIDTH_SCREEN;
    //    NSLog(@"prev center x%f",prevSnapshotViewCenter.x);
    
    self.currentSnapShotView.center = currentSnapshotViewCenter;
    self.prevSnapShotView.center = prevSnapshotViewCenter;
    self.swipingBackgoundView.alpha = (WIDTH_SCREEN - distance)/WIDTH_SCREEN;
}

-(void)endPopSnapShotView{
    if (!self.isSwipingBack) {
        return;
    }
    
    //prevent the user touch for now
    self.view.userInteractionEnabled = NO;
    
    if (self.currentSnapShotView.center.x >= WIDTH_SCREEN) {
        // pop success
        [UIView animateWithDuration:0.2 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            self.currentSnapShotView.center = CGPointMake(WIDTH_SCREEN*3/2, HEIGHT_SCREEN/2);
            self.prevSnapShotView.center = CGPointMake(WIDTH_SCREEN/2, HEIGHT_SCREEN/2);
            self.swipingBackgoundView.alpha = 0;
        }completion:^(BOOL finished) {
            [self.prevSnapShotView removeFromSuperview];
            [self.swipingBackgoundView removeFromSuperview];
            [self.currentSnapShotView removeFromSuperview];
            [self.webView goBack];
            [self.snapShotsArray removeLastObject];
            self.view.userInteractionEnabled = YES;
            
            self.isSwipingBack = NO;
        }];
    }else{
        //pop fail
        [UIView animateWithDuration:0.2 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            self.currentSnapShotView.center = CGPointMake(WIDTH_SCREEN/2, HEIGHT_SCREEN/2);
            self.prevSnapShotView.center = CGPointMake(WIDTH_SCREEN/2-60, HEIGHT_SCREEN/2);
            self.prevSnapShotView.alpha = 1;
        }completion:^(BOOL finished) {
            [self.prevSnapShotView removeFromSuperview];
            [self.swipingBackgoundView removeFromSuperview];
            [self.currentSnapShotView removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            
            self.isSwipingBack = NO;
        }];
    }
}

#pragma mark - update nav items

-(void)updateNavigationItems{
    UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButtonItem.width = -13;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:self.navLeftButton];
    if (self.webView.canGoBack) {
        
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        [self.navigationItem setLeftBarButtonItems:@[spaceButtonItem, backButton,self.closeButtonItem] animated:NO];
    }else{
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        [self.navigationItem setLeftBarButtonItems:@[spaceButtonItem, backButton] animated:NO];
    }
}

- (void)createNavigationButtonWithImage:(NSString*)imageName selectedImage:(NSString*)selectedImageName onLeft:(BOOL)isLeft withBlock:(void(^)(void))block {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 44, 44);
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    if (selectedImageName.length > 0) {
        [button setImage:[UIImage imageNamed:selectedImageName] forState:UIControlStateHighlighted];
    }
    
    if (isLeft) {
        UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceButtonItem.width = -13;
        button.frame = (CGRect){-10, 0, 32, 44};
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.navLeftButton = button;
        self.navigationItem.leftBarButtonItems = @[spaceButtonItem,[[UIBarButtonItem alloc] initWithCustomView:button]];
    } else {
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.navRightButton = button;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
}

#pragma mark - events handler
-(void)swipePanGestureHandler:(UIPanGestureRecognizer*)panGesture{
    CGPoint translation = [panGesture translationInView:self.webView];
    CGPoint location = [panGesture locationInView:self.webView];
    //    NSLog(@"pan x %f,pan y %f",translation.x,translation.y);
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        if (location.x <= 50 && translation.x > 0) {  //开始动画
            [self startPopSnapshotView];
        }
    }else if (panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateEnded){
        [self endPopSnapShotView];
    }else if (panGesture.state == UIGestureRecognizerStateChanged){
        [self popSnapShotViewWithPanGestureDistance:translation.x];
    }
}

-(void)customBackItemClicked{
    [self.webView goBack];
}

-(void)closeItemClicked{
    if (_isPushed) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)clickBackButton {
    if (self.webView.canGoBack) {
//        _isHideCloseButton = NO;
        [self updateNavigationItems];
        [self.webView goBack];
    } else {
        if (self.isPushed) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)clickShareBtnAction {
    [self.shareChannelsView showInView:self.navigationController.navigationBar.superview];
}

#pragma mark - webView delegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    //    NSLog(@"navigation type %d",navigationType);
    switch (navigationType) {
        case UIWebViewNavigationTypeLinkClicked: {
            [self pushCurrentSnapshotViewWithRequest:request];
            break;
        }
        case UIWebViewNavigationTypeFormSubmitted: {
            [self pushCurrentSnapshotViewWithRequest:request];
            break;
        }
        case UIWebViewNavigationTypeBackForward: {
            break;
        }
        case UIWebViewNavigationTypeReload: {
            break;
        }
        case UIWebViewNavigationTypeFormResubmitted: {
            break;
        }
        case UIWebViewNavigationTypeOther: {
            [self pushCurrentSnapshotViewWithRequest:request];
            break;
        }
        default: {
            break;
        }
    }
    [self updateNavigationItems];
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateNavigationItems];
//    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
//    if (theTitle.length > 10) {
//        theTitle = [[theTitle substringToIndex:9] stringByAppendingString:@"…"];
//    }
//    self.title = theTitle;
    //    [self.progressView setProgress:1 animated:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - NJProgress delegate

-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [self.progressView setProgress:progress animated:NO];
}


#pragma mark - setters and getters
- (void)setUrl:(NSURL *)url{
    _url = url;
}

- (void)setProgressViewColor:(UIColor *)progressViewColor{
    _progressViewColor = progressViewColor;
    self.progressView.progressColor = progressViewColor;
}

- (UIWebView*)webView{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, NAVFRAME_BARHEIGHT, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-NAVFRAME_BARHEIGHT-HEIGHT_HOME_INDICATOR)];
//        if (@available(iOS 11.0, *)) {
//            _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//        }
        _webView.delegate = (id)self;
        _webView.scalesPageToFit = YES;
        _webView.backgroundColor = UIColorFromHEX(0xeaeaea);
        _webView.scrollView.backgroundColor = UIColorFromHEX(0xeaeaea);
        [_webView addGestureRecognizer:self.swipePanGesture];
    }
    return _webView;
}

-(UIBarButtonItem*)closeButtonItem{
    if (!_closeButtonItem) {
        
        UIView *customView = [[UIView alloc] initWithFrame:(CGRect){0, 0, 45, 44}];
        UIButton *closeBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
        [closeBtn setTitleColor:UIColorFromHEX(0x29a9f3) forState:UIControlStateNormal];
        [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(closeItemClicked) forControlEvents:UIControlEventTouchUpInside];
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = UIColorFromHEX(0xd9d9d9);
        [customView addSubview:lineView];
        [customView addSubview:closeBtn];
        
        [lineView makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(customView.centerY);
            make.height.equalTo(21);
            make.width.equalTo(1);
            make.left.equalTo(customView.left).offset(-10);
        }];
        
        [closeBtn makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.equalTo(customView);
            make.height.equalTo(customView.height);
            make.width.equalTo(customView.width);
            make.centerX.equalTo(customView.centerX);
            make.centerY.equalTo(customView.centerY);
        }];
        
        _closeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
    }
    return _closeButtonItem;
}

-(UIView*)swipingBackgoundView{
    if (!_swipingBackgoundView) {
        _swipingBackgoundView = [[UIView alloc] initWithFrame:self.view.bounds];
        _swipingBackgoundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    return _swipingBackgoundView;
}

-(NSMutableArray*)snapShotsArray{
    if (!_snapShotsArray) {
        _snapShotsArray = [NSMutableArray array];
    }
    return _snapShotsArray;
}

-(BOOL)isSwipingBack{
    if (!_isSwipingBack) {
        _isSwipingBack = NO;
    }
    return _isSwipingBack;
}

-(UIPanGestureRecognizer*)swipePanGesture{
    if (!_swipePanGesture) {
        _swipePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipePanGestureHandler:)];
    }
    return _swipePanGesture;
}

-(NJKWebViewProgress*)progressProxy{
    if (!_progressProxy) {
        _progressProxy = [[NJKWebViewProgress alloc] init];
        _progressProxy.webViewProxyDelegate = (id)self;
        _progressProxy.progressDelegate = (id)self;
    }
    return _progressProxy;
}

-(NJKWebViewProgressView*)progressView{
    if (!_progressView) {
        CGFloat progressBarHeight = 3.0f;
        CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
        CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height, navigaitonBarBounds.size.width, progressBarHeight);
        _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
        _progressView.progressColor = self.progressViewColor;
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    return _progressView;
}

- (XKCommonShareChannelSelectionView *)shareChannelsView {
    if (_shareChannelsView == nil) {
        _shareChannelsView = [XKCommonShareChannelSelectionView shareChannelSelectionView];
//        _shareChannelsView.delegate = self;
    }
    return _shareChannelsView;
}

@end
