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
#import "BTScrollViewDelegateHostApi.h"
#import "BTScrollViewHostApi.h"
#import "BTUIDelegateHostApi.h"
#import "BTUIViewHostApi.h"
#import "BTURLCredentialHostApi.h"
#import "BTURLHostApi.h"
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
                  [objectApi disposeObjectWithIdentifier:identifier
                                              completion:^(FlutterError *error) {
                                                  NSAssert(!error, @"%@", error);
                                              }];
              });
          }];
  SetUpBTWKHttpCookieStoreHostApi(
          registrar.messenger,
          [[BTHTTPCookieStoreHostApiImpl alloc] initWithInstanceManager:instanceManager]);
  SetUpBTWKNavigationDelegateHostApi(
          registrar.messenger,
          [[BTNavigationDelegateHostApiImpl alloc] initWithBinaryMessenger:registrar.messenger
                                                            instanceManager:instanceManager]);
  SetUpBTNSObjectHostApi(registrar.messenger,
                          [[BTObjectHostApiImpl alloc] initWithInstanceManager:instanceManager]);
  SetUpBTWKPreferencesHostApi(registrar.messenger, [[BTPreferencesHostApiImpl alloc]
          initWithInstanceManager:instanceManager]);
  SetUpBTWKScriptMessageHandlerHostApi(
          registrar.messenger,
          [[BTScriptMessageHandlerHostApiImpl alloc] initWithBinaryMessenger:registrar.messenger
                                                              instanceManager:instanceManager]);
  SetUpBTUIScrollViewHostApi(registrar.messenger, [[BTScrollViewHostApiImpl alloc]
          initWithInstanceManager:instanceManager]);
  SetUpBTWKUIDelegateHostApi(registrar.messenger, [[BTUIDelegateHostApiImpl alloc]
          initWithBinaryMessenger:registrar.messenger
                  instanceManager:instanceManager]);
  SetUpBTUIViewHostApi(registrar.messenger,
                        [[BTUIViewHostApiImpl alloc] initWithInstanceManager:instanceManager]);
  SetUpBTWKUserContentControllerHostApi(
          registrar.messenger,
          [[BTUserContentControllerHostApiImpl alloc] initWithInstanceManager:instanceManager]);
  SetUpBTWKWebsiteDataStoreHostApi(
          registrar.messenger,
          [[BTWebsiteDataStoreHostApiImpl alloc] initWithInstanceManager:instanceManager]);
  SetUpBTWKWebViewConfigurationHostApi(
          registrar.messenger,
          [[BTWebViewConfigurationHostApiImpl alloc] initWithBinaryMessenger:registrar.messenger
                                                              instanceManager:instanceManager]);
  SetUpBTWKWebViewHostApi(registrar.messenger, [[BTWebViewHostApiImpl alloc]
          initWithBinaryMessenger:registrar.messenger
                  instanceManager:instanceManager]);
  SetUpBTNSUrlHostApi(registrar.messenger,
                       [[BTURLHostApiImpl alloc] initWithBinaryMessenger:registrar.messenger
                                                          instanceManager:instanceManager]);
  SetUpBTUIScrollViewDelegateHostApi(
          registrar.messenger,
          [[BTScrollViewDelegateHostApiImpl alloc] initWithBinaryMessenger:registrar.messenger
                                                            instanceManager:instanceManager]);
  SetUpBTNSUrlCredentialHostApi(
          registrar.messenger,
          [[BTURLCredentialHostApiImpl alloc] initWithBinaryMessenger:registrar.messenger
                                                       instanceManager:instanceManager]);

  BTWebViewFactory *webviewFactory = [[BTWebViewFactory alloc] initWithManager:instanceManager];
  [registrar registerViewFactory:webviewFactory withId:@"plugins.flutter.io/webview"];

  // InstanceManager is published so that a strong reference is maintained.
  [registrar publish:instanceManager];
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [registrar publish:[NSNull null]];
}
@end
