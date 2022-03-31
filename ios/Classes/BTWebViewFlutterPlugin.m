// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "BTWebViewFlutterPlugin.h"
#import "BTCookieManager.h"
#import "BTFlutterWebView.h"

@implementation BTWebViewFlutterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [BTCookieManager registerWithRegistrar:registrar];
  BTWebViewFactory *webviewFactory =
      [[BTWebViewFactory alloc] initWithMessenger:registrar.messenger
                                     cookieManager:[BTCookieManager instance]];
  [registrar registerViewFactory:webviewFactory withId:@"bootpay.co.kr/webview"];
}

@end
