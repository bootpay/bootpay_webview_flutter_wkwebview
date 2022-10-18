// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "BTWebViewFlutterPlugin.h"
#import "BTGeneratedWebKitApis.h"
#import "BTHTTPCookieStoreHostApi.h"
#import "BTInstanceManager.h"
#import "BTNavigationDelegateHostApi.h"
#import "BTObjectHostApi.h"
#import "BTPreferencesHostApi.h"
#import "BTScriptMessageHandlerHostApi.h"
#import "BTScrollViewHostApi.h"
#import "BTUIDelegateHostApi.h"
#import "BTUIViewHostApi.h"
#import "BTUserContentControllerHostApi.h"
#import "BTWebViewConfigurationHostApi.h"
#import "BTWebViewHostApi.h"
#import "BTWebsiteDataStoreHostApi.h"

@interface BTWebViewFactory : NSObject <FlutterPlatformViewFactory>
@property(nonatomic, weak) BTInstanceManager *instanceManager;

- (instancetype)initWithManager:(BTInstanceManager *)manager;
@end

@implementation BTWebViewFactory
- (instancetype)initWithManager:(BTInstanceManager *)manager {
  self = [self init];
  if (self) {
    _instanceManager = manager;
  }
  return self;
}

- (NSObject<FlutterMessageCodec> *)createArgsCodec {
  return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame
                                    viewIdentifier:(int64_t)viewId
                                         arguments:(id _Nullable)args {
  NSNumber *identifier = (NSNumber *)args;
  BTWebView *webView =
      (BTWebView *)[self.instanceManager instanceForIdentifier:identifier.longValue];
  webView.frame = frame;
  return webView;
}

@end

@implementation BTWebViewFlutterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  BTInstanceManager *instanceManager =
      [[BTInstanceManager alloc] initWithDeallocCallback:^(long identifier) {
        BTObjectFlutterApiImpl *objectApi = [[BTObjectFlutterApiImpl alloc]
            initWithBinaryMessenger:registrar.messenger
                    instanceManager:[[BTInstanceManager alloc] init]];

        dispatch_async(dispatch_get_main_queue(), ^{
          [objectApi disposeObjectWithIdentifier:@(identifier)
                                      completion:^(NSError *error) {
                                        NSAssert(!error, @"%@", error);
                                      }];
        });
      }];
  BTWKHttpCookieStoreHostApiSetup(
      registrar.messenger,
      [[BTHTTPCookieStoreHostApiImpl alloc] initWithInstanceManager:instanceManager]);
  BTWKNavigationDelegateHostApiSetup(
      registrar.messenger,
      [[BTNavigationDelegateHostApiImpl alloc] initWithBinaryMessenger:registrar.messenger
                                                        instanceManager:instanceManager]);
  BTNSObjectHostApiSetup(registrar.messenger,
                          [[BTObjectHostApiImpl alloc] initWithInstanceManager:instanceManager]);
  BTWKPreferencesHostApiSetup(registrar.messenger, [[BTPreferencesHostApiImpl alloc]
                                                        initWithInstanceManager:instanceManager]);
  BTWKScriptMessageHandlerHostApiSetup(
      registrar.messenger,
      [[BTScriptMessageHandlerHostApiImpl alloc] initWithBinaryMessenger:registrar.messenger
                                                          instanceManager:instanceManager]);
  BTUIScrollViewHostApiSetup(registrar.messenger, [[BTScrollViewHostApiImpl alloc]
                                                       initWithInstanceManager:instanceManager]);
  BTWKUIDelegateHostApiSetup(registrar.messenger, [[BTUIDelegateHostApiImpl alloc]
                                                       initWithBinaryMessenger:registrar.messenger
                                                               instanceManager:instanceManager]);
  BTUIViewHostApiSetup(registrar.messenger,
                        [[BTUIViewHostApiImpl alloc] initWithInstanceManager:instanceManager]);
  BTWKUserContentControllerHostApiSetup(
      registrar.messenger,
      [[BTUserContentControllerHostApiImpl alloc] initWithInstanceManager:instanceManager]);
  BTWKWebsiteDataStoreHostApiSetup(
      registrar.messenger,
      [[BTWebsiteDataStoreHostApiImpl alloc] initWithInstanceManager:instanceManager]);
  BTWKWebViewConfigurationHostApiSetup(
      registrar.messenger,
      [[BTWebViewConfigurationHostApiImpl alloc] initWithBinaryMessenger:registrar.messenger
                                                          instanceManager:instanceManager]);
  BTWKWebViewHostApiSetup(registrar.messenger, [[BTWebViewHostApiImpl alloc]
                                                    initWithBinaryMessenger:registrar.messenger
                                                            instanceManager:instanceManager]);

  BTWebViewFactory *webviewFactory = [[BTWebViewFactory alloc] initWithManager:instanceManager];
  [registrar registerViewFactory:webviewFactory withId:@"kr.co.bootpay/webview"];

  // InstanceManager is published so that a strong reference is maintained.
  [registrar publish:instanceManager];
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [registrar publish:[NSNull null]];
}
@end
