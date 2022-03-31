// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This header is available in the Test module. Import via "@import webview_flutter_wkwebview.Test;"

#import <bootpay_webview_flutter_wkwebview/BTFlutterWebView.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTWebViewController ()

- (NSURLRequest *)buildNSURLRequest:(NSDictionary<NSString *, id> *)arguments;

- (void)onLoadUrl:(FlutterMethodCall *)call result:(FlutterResult)result;

- (void)onLoadRequest:(FlutterMethodCall *)call result:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
