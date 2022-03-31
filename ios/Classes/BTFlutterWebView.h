// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>

#import "BTCookieManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The WkWebView used for the plugin.
 *
 * This class overrides some methods in `WKWebView` to serve the needs for the plugin.
 */
@interface BTWKWebView : WKWebView
@end

@interface BTWebViewController : NSObject <FlutterPlatformView, WKUIDelegate>

@property(nonatomic) BTWKWebView *webView;

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger;

- (UIView *)view;

- (void)onMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result;

@end

@interface BTWebViewFactory : NSObject <FlutterPlatformViewFactory>
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
                    cookieManager:(BTCookieManager *)cookieManager;
@end

NS_ASSUME_NONNULL_END
