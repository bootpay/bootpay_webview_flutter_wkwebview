// Copyright 2024 Bootpay
// Auto WarmUp loader - triggers WebView pre-warming when module loads

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

// Forward declaration for Swift class
@class BootpayWarmUpManager;

// Shared process pool - will be used by both ObjC and Swift
static WKProcessPool *_bootpaySharedProcessPool = nil;
static WKWebView *_prewarmedWebView = nil;
static BOOL _isWarmedUp = NO;

// WarmUp HTML for triggering all processes
static NSString *const kWarmUpHTML = @"<!DOCTYPE html><html><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width,initial-scale=1\"></head><body><canvas id=\"c\" width=\"1\" height=\"1\"></canvas><script>var c=document.getElementById('c').getContext('2d');c.fillRect(0,0,1,1);fetch('https://webview.bootpay.co.kr/health',{mode:'no-cors'}).catch(function(){});</script></body></html>";

@interface BootpayAutoWarmUp : NSObject
+ (WKProcessPool *)sharedProcessPool;
+ (void)releaseWarmUp;
+ (BOOL)isWarmedUp;
@end

@implementation BootpayAutoWarmUp

// This method is called automatically when the class is loaded into memory
// This happens very early in the app lifecycle, before didFinishLaunchingWithOptions
+ (void)load {
    NSLog(@"[Bootpay] BootpayAutoWarmUp +load called");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performWarmUp];
    });
}

+ (void)performWarmUp {
    if (_prewarmedWebView != nil) {
        NSLog(@"[Bootpay] WarmUp already performed, skipping");
        return;
    }

    NSLog(@"[Bootpay] performWarmUp starting...");

    // Create shared process pool
    if (_bootpaySharedProcessPool == nil) {
        _bootpaySharedProcessPool = [[WKProcessPool alloc] init];
        NSLog(@"[Bootpay] Created shared WKProcessPool: %@", _bootpaySharedProcessPool);
    }

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.processPool = _bootpaySharedProcessPool;

    // Create 1x1 WebView to trigger process initialization
    _prewarmedWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 1, 1) configuration:config];

    // Load HTML to trigger GPU, WebContent, and Networking processes
    [_prewarmedWebView loadHTMLString:kWarmUpHTML baseURL:[NSURL URLWithString:@"https://webview.bootpay.co.kr"]];

    _isWarmedUp = YES;

    NSLog(@"[Bootpay] Auto warmUp started - WebView processes initializing...");
}

+ (WKProcessPool *)sharedProcessPool {
    if (_bootpaySharedProcessPool == nil) {
        _bootpaySharedProcessPool = [[WKProcessPool alloc] init];
        NSLog(@"[Bootpay] Created shared WKProcessPool (lazy): %@", _bootpaySharedProcessPool);
    }
    return _bootpaySharedProcessPool;
}

+ (void)releaseWarmUp {
    dispatch_async(dispatch_get_main_queue(), ^{
        _prewarmedWebView = nil;
        _isWarmedUp = NO;
        NSLog(@"[Bootpay] WarmUp released");
    });
}

+ (BOOL)isWarmedUp {
    return _isWarmedUp && _prewarmedWebView != nil;
}

@end
