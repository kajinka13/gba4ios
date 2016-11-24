//
//  RSTWebViewController.h
//
//  Created by Riley Testut on 7/15/13.
//  Copyright (c) 2013 Riley Testut. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RSTSafariActivity.h"
#import "RSTChromeActivity.h"

typedef void(^RSTWebViewControllerStartDownloadBlock)(BOOL shouldContinue, NSProgress *progress);

@class RSTWebViewController;

@protocol RSTWebViewControllerDelegate <NSObject>

@optional
/**
 *	Called when the web view is actually done loading content, unlike the UIWebViewDelegate method
 *  webViewDidFinishLoad: which is called after every frame.
 *
 *	@param	webViewController	The RSTWebViewController loading the content
 */
- (void)webViewControllerDidFinishLoad:(RSTWebViewController *)webViewController;

/**
 *  Called when RSTWebViewController is about to be dismissed
 *
 *  @param webViewController The RSTWebViewController to be dismissed
 */
- (void)webViewControllerWillDismiss:(RSTWebViewController *)webViewController;

@end

@protocol RSTWebViewControllerDownloadDelegate <NSObject>

// Return YES to indicate you want to intercept the request and possibly perform a download
- (BOOL)webViewController:(RSTWebViewController *)webViewController shouldInterceptDownloadRequest:(NSURLRequest *)request;

// Call startDownloadBlock once you or the user has decided whether to download a file. Pass in YES as the first argument to continue with the download, or NO to cancel it.
// Optionally, pass in an NSProgress object to be used to track progress of the download.
- (void)webViewController:(RSTWebViewController *)webViewController shouldStartDownloadTask:(NSURLSessionDownloadTask *)downloadTask startDownloadBlock:(RSTWebViewControllerStartDownloadBlock)startDownloadBlock;

// Called once download has completed. You must move the file from the destinationURL by the time the method returns if you want to keep onto it, since iOS will delete it soon after.
- (void)webViewController:(RSTWebViewController *)webViewController didCompleteDownloadTask:(NSURLSessionDownloadTask *)downloadTask destinationURL:(NSURL *)url error:(NSError *)error;

@end

@interface RSTWebViewController : UIViewController

/**
 *	The object that acts as the delegate of the receiving RSTWebViewController.
 */
@property (weak, nonatomic) id <RSTWebViewControllerDelegate> delegate;

/**
 *	Delegate object to be notified about the file downloading process.
 */
@property (weak, nonatomic) id <RSTWebViewControllerDownloadDelegate> downloadDelegate;

// UIWebView used to display webpages
@property (readonly, strong, nonatomic) UIWebView *webView;

// UIActivity activity types that shouldn't be displayed when sharing a link
@property (copy, nonatomic) NSArray /* NSString */ *excludedActivityTypes;

// Additional UIActivities to be displayed when sharing a link
@property (copy, nonatomic) NSArray /* UIActivity */ *additionalSharingActivities;

// Set to YES when presenting modally to show a Done button that'll dismiss itself. Must be set before presentation.
@property (assign, nonatomic) BOOL showsDoneButton;

- (instancetype)initWithAddress:(NSString *)address;
- (instancetype)initWithURL:(NSURL *)url;
- (instancetype)initWithRequest:(NSURLRequest *)request;

@end
