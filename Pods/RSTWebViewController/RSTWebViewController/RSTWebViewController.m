//
//  RSTWebViewController.m
//
//  Created by Riley Testut on 7/15/13.
//  Copyright (c) 2013 Riley Testut. All rights reserved.
//

#import "RSTWebViewController.h"
#import "NJKWebViewProgress.h"
#import "RSTSafariActivity.h"

#import <objc/runtime.h>

//////////////////

// Category on NSObject so we can associate an NSProgress with a particular download task
// It's a category on NSObject because internally, downloads are done via the __NSCFLocalDownloadTask class, which apparently isn't a subclass of NSURLSessionTask
@interface NSObject (Progress)

// don't name it 'progress', conflicts with private API and (albeit rarely) crashes
@property (strong, nonatomic) NSProgress *downloadProgress;

@end

@implementation NSObject (Progress)
@dynamic downloadProgress;

- (void)setDownloadProgress:(NSProgress *)downloadProgress
{
    objc_setAssociatedObject(self, @selector(downloadProgress), downloadProgress, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSProgress *)downloadProgress
{
    return objc_getAssociatedObject(self, @selector(downloadProgress));
}

@end

//////////////////

@interface RSTWebViewController () <UIWebViewDelegate, NJKWebViewProgressDelegate, NSURLSessionDownloadDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIWebView *webView;

@property (strong, nonatomic) NSURLRequest *currentRequest;
@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) NJKWebViewProgress *webViewProgress;

@property (strong, nonatomic) UIView *snapshotView;
@property (strong, nonatomic) UIScreenEdgePanGestureRecognizer *screenEdgePanGestureRecognizer;

@property (assign, nonatomic) BOOL showsPageLoadingProgress;

@property (strong, nonatomic) UIBarButtonItem *doneButton;
@property (strong, nonatomic) UIBarButtonItem *goBackButton;
@property (strong, nonatomic) UIBarButtonItem *goForwardButton;
@property (strong, nonatomic) UIBarButtonItem *shareButton;
@property (strong, nonatomic) UIBarButtonItem *flexibleSpaceButton;
@property (strong, nonatomic) UIBarButtonItem *fixedSpaceButton;

@property (strong, nonatomic) UIPopoverController *sharingPopoverController;

// Refreshing
@property (assign, nonatomic) UIBarButtonItem *refreshButton; // Assigned to either reloadButton or stopLoadButton
@property (strong, nonatomic) UIBarButtonItem *reloadButton;
@property (strong, nonatomic) UIBarButtonItem *stopLoadButton;

@end

@implementation RSTWebViewController
{
    BOOL _performedInitialRequest;
}

#pragma mark - Initialization

- (instancetype)initWithAddress:(NSString *)address
{
    return [self initWithURL:[NSURL URLWithString:address]];
}

- (instancetype)initWithURL:(NSURL *)url
{
    return [self initWithRequest:[NSURLRequest requestWithURL:url]];
}

- (instancetype)initWithRequest:(NSURLRequest *)request
{
    self = [super init];
    
    if (self)
    {
        _currentRequest = request;
        
        _webViewProgress = [[NJKWebViewProgress alloc] init];
        _webViewProgress.webViewProxyDelegate = self;
        _webViewProgress.progressDelegate = self;
        
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        _progressView.trackTintColor = [UIColor clearColor];
        _progressView.alpha = 0.0;
        _progressView.progress = 0.0;
        
        _showsPageLoadingProgress = YES;
    }
    
    return self;
}

#pragma mark - Configure View

- (void)loadView
{
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self.webViewProgress;
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.scrollView.backgroundColor = [UIColor whiteColor];
    self.webView.scalesPageToFit = YES;
    self.view = self.webView;
    
    // iOS 7 bug: bar of black appears at bottom of web view until first page is loaded. To compensate, we load a white page, then load the request
    [self.webView loadHTMLString:@"<html><body bgcolor='#FFFFFF'></body></html>" baseURL:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.progressView.frame = CGRectMake(0,
                                         CGRectGetHeight(self.navigationController.navigationBar.bounds) - CGRectGetHeight(self.progressView.bounds),
                                         CGRectGetWidth(self.navigationController.navigationBar.bounds),
                                         CGRectGetHeight(self.progressView.bounds));
    
    self.goBackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_button"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    self.goForwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forward_button"] style:UIBarButtonItemStylePlain target:self action:@selector(goForward:)];
    self.reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload:)];
    self.stopLoadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopLoading:)];
    self.shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareLink:)];
    self.flexibleSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.fixedSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    self.screenEdgePanGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanFromScreenEdge:)];
    self.screenEdgePanGestureRecognizer.edges = UIRectEdgeLeft;
    //[self.webView addGestureRecognizer:self.screenEdgePanGestureRecognizer];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.fixedSpaceButton.width = 20.0f;
    }
    
    self.refreshButton = self.reloadButton;
    
    if (self.showsDoneButton)
    {
        self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissWebViewController:)];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            [self.navigationItem setRightBarButtonItem:self.doneButton];
        }
    }
    
    [self refreshToolbarItems];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if ([[self.navigationController viewControllers] firstObject] != self)
        {
            [self.navigationController setToolbarHidden:NO animated:NO];
        }
        else
        {
            [UIView performWithoutAnimation:^{
                [self.navigationController setToolbarHidden:NO animated:NO];
            }];
        }
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar addSubview:self.progressView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([[self.navigationController viewControllers] firstObject] != self)
    {
        [self.navigationController setToolbarHidden:YES animated:NO];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self hideProgressViewWithCompletion:^{
        [self.progressView removeFromSuperview];
    }];
}

- (void)refreshToolbarItems
{
    self.goBackButton.enabled = [self.webView canGoBack];
    self.goForwardButton.enabled = [self.webView canGoForward];
    
    self.refreshButton = [[UIApplication sharedApplication] isNetworkActivityIndicatorVisible] ? self.stopLoadButton : self.reloadButton;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        self.toolbarItems = @[self.fixedSpaceButton, self.goBackButton, self.flexibleSpaceButton, self.goForwardButton, self.flexibleSpaceButton, self.refreshButton, self.flexibleSpaceButton, self.shareButton, self.fixedSpaceButton];
    }
    else
    {
        NSMutableArray *buttons = [@[self.shareButton, self.fixedSpaceButton, self.refreshButton, self.fixedSpaceButton, self.goForwardButton, self.fixedSpaceButton, self.goBackButton] mutableCopy];
        
        if (self.showsDoneButton)
        {
            [buttons insertObject:self.doneButton atIndex:0];
            [buttons insertObject:self.fixedSpaceButton atIndex:1];
        }
        
        self.navigationItem.rightBarButtonItems = buttons;
    }
    
}

#pragma mark - Navigation

- (void)goBack:(UIBarButtonItem *)sender
{
    [self.webView goBack];
}

- (void)goForward:(UIBarButtonItem *)sender
{
    [self.webView goForward];
}

- (void)didPanFromScreenEdge:(UIScreenEdgePanGestureRecognizer *)screenEdgePanGestureRecognizer
{
    if (self.snapshotView == nil)
    {
        self.showsPageLoadingProgress = NO;
        
        self.snapshotView = [self.webView snapshotViewAfterScreenUpdates:YES];
        [self.view addSubview:self.snapshotView];
        
        [self goBack:self.goBackButton];
    }
    
    self.snapshotView.frame = ({
        CGRect frame = self.snapshotView.frame;
        frame.origin.x = [screenEdgePanGestureRecognizer locationInView:self.webView].x;
        frame;
    });
}

#pragma mark - Refreshing

- (void)reload:(UIBarButtonItem *)sender
{
    [self.webView reload];
}

- (void)stopLoading:(UIBarButtonItem *)sender
{
    [self.webView stopLoading];
}

#pragma mark - Sharing

- (void)shareLink:(UIBarButtonItem *)barButtonItem
{
    if (self.sharingPopoverController)
    {
        [self.sharingPopoverController dismissPopoverAnimated:YES];
        self.sharingPopoverController = nil;
        
        return;
    }
    
    NSString *currentAddress = [self.webView stringByEvaluatingJavaScriptFromString:@"window.location.href"];
    NSURL *url = [NSURL URLWithString:currentAddress];
    
    NSArray *applicationActivities = @[[RSTSafariActivity new], [RSTChromeActivity new]];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:applicationActivities];
    activityViewController.excludedActivityTypes = [self excludedActivityTypes];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self presentViewController:activityViewController animated:YES completion:NULL];
    }
    else
    {
        if ([UIPresentationController class])
        {
            activityViewController.modalPresentationStyle = UIModalPresentationPopover;
            activityViewController.popoverPresentationController.barButtonItem = barButtonItem;
            activityViewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            
            [self presentViewController:activityViewController animated:YES completion:NULL];
        }
        else
        {
            self.sharingPopoverController = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
            self.sharingPopoverController.delegate = self;
            [self.sharingPopoverController presentPopoverFromBarButtonItem:barButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.sharingPopoverController = nil;
}

#pragma mark - Progress View

- (void)showProgressView
{
    if (!self.showsPageLoadingProgress)
    {
        return;
    }
    
    [UIView animateWithDuration:0.4 animations:^{
        self.progressView.alpha = 1.0;
    }];
}

- (void)hideProgressViewWithCompletion:(void (^)(void))completion
{
    [UIView animateWithDuration:0.4 animations:^{
        self.progressView.alpha = 0.0;
    } completion:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = 0.0;
        });
        
        if (completion) {
            completion();
        }
    }];
}

- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    if (!_performedInitialRequest)
    {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // Prevent the progress view from ever resetting back to a smaller progress value.
        // It's also common for the progress to be 1.0, and then start showing the actual progress. So this is the *only* exception to the don't-display-less-progress rule.
        if ((progress > self.progressView.progress) || self.progressView.progress >= 1.0f)
        {
            if (self.progressView.alpha == 0.0)
            {
                [self didStartLoading];
            }
            
            [self.progressView setProgress:progress animated:YES];
        }
        
        if (progress >= 1.0)
        {
            [self didFinishLoading];
        }
    });
}

#pragma mark - UIWebViewController delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (!_performedInitialRequest)
    {
        return;
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self refreshToolbarItems];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (!_performedInitialRequest)
    {
        _performedInitialRequest = YES;
        [self.webView loadRequest:self.currentRequest];
    }
    
    self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.currentRequest = self.webView.request;
    
    // Don't hide progress view here, as the webpage isn't necessarily visible yet
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [self refreshToolbarItems];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self refreshToolbarItems];
    
    [self didFinishLoading];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([self.downloadDelegate webViewController:self shouldInterceptDownloadRequest:request])
    {
        [self startDownloadWithRequest:request];
    }
    
    return YES;
}

#pragma mark - Private

- (void)didStartLoading
{
    [self showProgressView];
    [self refreshToolbarItems];
}

- (void)didFinishLoading
{
    [self hideProgressViewWithCompletion:NULL];
    
    [self refreshToolbarItems];
    
    if ([self.delegate respondsToSelector:@selector(webViewControllerDidFinishLoad:)])
    {
        [self.delegate webViewControllerDidFinishLoad:self];
    }
}

#pragma mark - Downloading

- (void)startDownloadWithRequest:(NSURLRequest *)request
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.allowsCellularAccess = YES;
    configuration.discretionary = NO;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];
    
    [self.downloadDelegate webViewController:self shouldStartDownloadTask:downloadTask startDownloadBlock:^(BOOL shouldContinue, NSProgress *progress)
     {
         if (shouldContinue)
         {
             [downloadTask setDownloadProgress:progress];
             [downloadTask resume];
         }
         else
         {
             [downloadTask cancel];
         }
     }];
}

#pragma mark - NSURLSession delegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSProgress *progress = downloadTask.downloadProgress;
    
    progress.totalUnitCount = totalBytesExpectedToWrite;
    progress.completedUnitCount = totalBytesWritten;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    [self.downloadDelegate webViewController:self didCompleteDownloadTask:downloadTask destinationURL:location error:nil];
    
    NSProgress *progress = downloadTask.downloadProgress;
    progress.completedUnitCount = progress.totalUnitCount;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error)
    {
        [self.downloadDelegate webViewController:self didCompleteDownloadTask:(NSURLSessionDownloadTask *)task destinationURL:nil error:error];
    }
    
    NSProgress *progress = task.downloadProgress;
    progress.completedUnitCount = progress.totalUnitCount;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    // TODO: Support download resuming
}

#pragma mark - Dismissal

- (void)dismissWebViewController:(UIBarButtonItem *)barButtonItem
{
    [self.sharingPopoverController dismissPopoverAnimated:YES];
    self.sharingPopoverController = nil;
    
    if ([self.delegate respondsToSelector:@selector(webViewControllerWillDismiss:)])
    {
        [self.delegate webViewControllerWillDismiss:self];
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Interface Orientation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self.webView stopLoading];
 	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.webView.delegate = nil;
}

@end
