// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "BTUIDelegateHostApi.h"
#import "BTDataConverters.h"

@interface BTUIDelegateFlutterApiImpl ()
// BinaryMessenger must be weak to prevent a circular reference with the host API it
// references.
@property(nonatomic, weak) id<FlutterBinaryMessenger> binaryMessenger;
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) BTInstanceManager *instanceManager;
@end

@implementation BTUIDelegateFlutterApiImpl
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager {
  self = [self initWithBinaryMessenger:binaryMessenger];
  if (self) {
    _binaryMessenger = binaryMessenger;
    _instanceManager = instanceManager;
    _webViewConfigurationFlutterApi =
        [[BTWebViewConfigurationFlutterApiImpl alloc] initWithBinaryMessenger:binaryMessenger
                                                               instanceManager:instanceManager];
  }
  return self;
}

- (long)identifierForDelegate:(BTUIDelegate *)instance {
  return [self.instanceManager identifierWithStrongReferenceForInstance:instance];
}

- (void)onCreateWebViewForDelegate:(BTUIDelegate *)instance
                           webView:(WKWebView *)webView
                     configuration:(WKWebViewConfiguration *)configuration
                  navigationAction:(WKNavigationAction *)navigationAction
                        completion:(void (^)(NSError *_Nullable))completion {
  if (![self.instanceManager containsInstance:configuration]) {
    [self.webViewConfigurationFlutterApi createWithConfiguration:configuration
                                                      completion:^(NSError *error) {
                                                        NSAssert(!error, @"%@", error);
                                                      }];
  }

  NSNumber *configurationIdentifier =
      @([self.instanceManager identifierWithStrongReferenceForInstance:configuration]);
  BTWKNavigationActionData *navigationActionData =
      BTWKNavigationActionDataFromNavigationAction(navigationAction);

  [self onCreateWebViewForDelegateWithIdentifier:@([self identifierForDelegate:instance])
                               webViewIdentifier:
                                   @([self.instanceManager
                                       identifierWithStrongReferenceForInstance:webView])
                         configurationIdentifier:configurationIdentifier
                                navigationAction:navigationActionData
                                      completion:completion];
}
@end

@implementation BTUIDelegate
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager {
  self = [super initWithBinaryMessenger:binaryMessenger instanceManager:instanceManager];
  if (self) {
    _UIDelegateAPI = [[BTUIDelegateFlutterApiImpl alloc] initWithBinaryMessenger:binaryMessenger
                                                                  instanceManager:instanceManager];
  }
  return self;
}

- (WKWebView *)webView:(WKWebView *)webView
    createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
               forNavigationAction:(WKNavigationAction *)navigationAction
                    windowFeatures:(WKWindowFeatures *)windowFeatures {
  [self.UIDelegateAPI onCreateWebViewForDelegate:self
                                         webView:webView
                                   configuration:configuration
                                navigationAction:navigationAction
                                      completion:^(NSError *error) {
                                        NSAssert(!error, @"%@", error);
                                      }];
  return nil;
}
@end

@interface BTUIDelegateHostApiImpl ()
// BinaryMessenger must be weak to prevent a circular reference with the host API it
// references.
@property(nonatomic, weak) id<FlutterBinaryMessenger> binaryMessenger;
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) BTInstanceManager *instanceManager;
@end

@implementation BTUIDelegateHostApiImpl
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _binaryMessenger = binaryMessenger;
    _instanceManager = instanceManager;
  }
  return self;
}

- (BTUIDelegate *)delegateForIdentifier:(NSNumber *)identifier {
  return (BTUIDelegate *)[self.instanceManager instanceForIdentifier:identifier.longValue];
}

- (void)createWithIdentifier:(nonnull NSNumber *)identifier
                       error:(FlutterError *_Nullable *_Nonnull)error {
  BTUIDelegate *uIDelegate = [[BTUIDelegate alloc] initWithBinaryMessenger:self.binaryMessenger
                                                             instanceManager:self.instanceManager];
  [self.instanceManager addDartCreatedInstance:uIDelegate withIdentifier:identifier.longValue];
}
@end
