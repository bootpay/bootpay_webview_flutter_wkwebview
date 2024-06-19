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
                        completion:(void (^)(FlutterError *_Nullable))completion {

    NSLog(@"onCreateWebViewForDelegate");

    if (![self.instanceManager containsInstance:configuration]) {
        [self.webViewConfigurationFlutterApi createWithConfiguration:configuration
                                                          completion:^(FlutterError *error) {
                                                              NSAssert(!error, @"%@", error);
                                                          }];
    }


    NSInteger configurationIdentifier =
            [self.instanceManager identifierWithStrongReferenceForInstance:configuration];
    BTWKNavigationActionData *navigationActionData =
            BTWKNavigationActionDataFromNativeWKNavigationAction(navigationAction);

    [self
            onCreateWebViewForDelegateWithIdentifier:[self identifierForDelegate:instance]
                                   webViewIdentifier:[self.instanceManager
                                           identifierWithStrongReferenceForInstance:webView]
                             configurationIdentifier:configurationIdentifier
                                    navigationAction:navigationActionData
                                          completion:completion];
}

- (void)requestMediaCapturePermissionForDelegateWithIdentifier:(BTUIDelegate *)instance
                                                       webView:(WKWebView *)webView
                                                        origin:(WKSecurityOrigin *)origin
                                                         frame:(WKFrameInfo *)frame
                                                          type:(WKMediaCaptureType)type
                                                    completion:
                                                            (void (^)(WKPermissionDecision))completion
API_AVAILABLE(ios(15.0)) {
    [self
            requestMediaCapturePermissionForDelegateWithIdentifier:[self identifierForDelegate:instance]
                                                 webViewIdentifier:
                                                         [self.instanceManager
                                                                 identifierWithStrongReferenceForInstance:webView]
                                                            origin:
                                                                    BTWKSecurityOriginDataFromNativeWKSecurityOrigin(
                                                                            origin)
                                                             frame:
                                                                     BTWKFrameInfoDataFromNativeWKFrameInfo(
                                                                             frame)
                                                              type:
                                                                      BTWKMediaCaptureTypeDataFromNativeWKMediaCaptureType(
                                                                              type)
                                                        completion:^(
                                                                BTWKPermissionDecisionData *decision,
                                                                FlutterError *error) {
                                                            NSAssert(!error, @"%@", error);
                                                            completion(
                                                                    BTNativeWKPermissionDecisionFromData(
                                                                            decision));
                                                        }];
}

- (void)runJavaScriptAlertPanelForDelegateWithIdentifier:(BTUIDelegate *)instance
                                                 message:(NSString *)message
                                                   frame:(WKFrameInfo *)frame
                                       completionHandler:(void (^)(void))completionHandler {
    [self runJavaScriptAlertPanelForDelegateWithIdentifier:[self identifierForDelegate:instance]
                                                   message:message
                                                     frame:BTWKFrameInfoDataFromNativeWKFrameInfo(
                                                             frame)
                                                completion:^(FlutterError *error) {
                                                    NSAssert(!error, @"%@", error);
                                                    completionHandler();
                                                }];
}

- (void)runJavaScriptConfirmPanelForDelegateWithIdentifier:(BTUIDelegate *)instance
                                                   message:(NSString *)message
                                                     frame:(WKFrameInfo *)frame
                                         completionHandler:(void (^)(BOOL))completionHandler {
    [self runJavaScriptConfirmPanelForDelegateWithIdentifier:[self identifierForDelegate:instance]
                                                     message:message
                                                       frame:BTWKFrameInfoDataFromNativeWKFrameInfo(
                                                               frame)
                                                  completion:^(NSNumber *isConfirmed,
                                                               FlutterError *error) {
                                                      NSAssert(!error, @"%@", error);
                                                      if (error) {
                                                          completionHandler(NO);
                                                      } else {
                                                          completionHandler(isConfirmed.boolValue);
                                                      }
                                                  }];
}

- (void)runJavaScriptTextInputPanelForDelegateWithIdentifier:(BTUIDelegate *)instance
                                                      prompt:(NSString *)prompt
                                                 defaultText:(NSString *)defaultText
                                                       frame:(WKFrameInfo *)frame
                                           completionHandler:
                                                   (void (^)(NSString *_Nullable))completionHandler {
    [self
            runJavaScriptTextInputPanelForDelegateWithIdentifier:[self identifierForDelegate:instance]
                                                          prompt:prompt
                                                     defaultText:defaultText
                                                           frame:BTWKFrameInfoDataFromNativeWKFrameInfo(
                                                                   frame)
                                                      completion:^(NSString *inputText,
                                                                   FlutterError *error) {
                                                          NSAssert(!error, @"%@", error);
                                                          if (error) {
                                                              completionHandler(nil);
                                                          } else {
                                                              completionHandler(inputText);
                                                          }
                                                      }];
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

/*
- (WKWebView *)webView:(WKWebView *)webView
createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
        forNavigationAction:(WKNavigationAction *)navigationAction
        windowFeatures:(WKWindowFeatures *)windowFeatures {

    [self.UIDelegateAPI onCreateWebViewForDelegate:self
                                           webView:webView
                                     configuration:configuration
                                  navigationAction:navigationAction
                                        completion:^(FlutterError *error) {
                                            NSAssert(!error, @"%@", error);
                                        }];
    return nil;
}
*/

- (WKWebView *)webView:(WKWebView *)webView
createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
        forNavigationAction:(WKNavigationAction *)navigationAction
        windowFeatures:(WKWindowFeatures *)windowFeatures {
    WKWebView *popupView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, webView.bounds.size.width, webView.bounds.size.height) configuration:configuration];


    [popupView autoresizingMask];
    popupView.navigationDelegate = self;
    popupView.UIDelegate = self;

    [webView.superview addSubview:popupView];

    return popupView;
}

- (void)webViewDidClose:(WKWebView *)webView {
    [webView removeFromSuperview];
}

- (void)webView:(WKWebView *)webView
requestMediaCapturePermissionForOrigin:(WKSecurityOrigin *)origin
        initiatedByFrame:(WKFrameInfo *)frame
        type:(WKMediaCaptureType)type
        decisionHandler:(void (^)(WKPermissionDecision))decisionHandler
API_AVAILABLE(ios(15.0)) {
    [self.UIDelegateAPI
            requestMediaCapturePermissionForDelegateWithIdentifier:self
                                                           webView:webView
                                                            origin:origin
                                                             frame:frame
                                                              type:type
                                                        completion:^(WKPermissionDecision decision) {
                                                            decisionHandler(decision);
                                                        }];
}


- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {

    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *cred = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, cred);
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}


- (void)webView:(WKWebView *)webView
runJavaScriptAlertPanelWithMessage:(NSString *)message
        initiatedByFrame:(WKFrameInfo *)frame
        completionHandler:(void (^)(void))completionHandler {
    [self.UIDelegateAPI runJavaScriptAlertPanelForDelegateWithIdentifier:self
                                                                 message:message
                                                                   frame:frame
                                                       completionHandler:completionHandler];
}

- (void)webView:(WKWebView *)webView
runJavaScriptConfirmPanelWithMessage:(NSString *)message
        initiatedByFrame:(WKFrameInfo *)frame
        completionHandler:(void (^)(BOOL))completionHandler {
    [self.UIDelegateAPI runJavaScriptConfirmPanelForDelegateWithIdentifier:self
                                                                   message:message
                                                                     frame:frame
                                                         completionHandler:completionHandler];
}

- (void)webView:(WKWebView *)webView
runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
        defaultText:(NSString *)defaultText
        initiatedByFrame:(WKFrameInfo *)frame
        completionHandler:(void (^)(NSString *_Nullable))completionHandler {
    [self.UIDelegateAPI runJavaScriptTextInputPanelForDelegateWithIdentifier:self
                                                                      prompt:prompt
                                                                 defaultText:defaultText
                                                                       frame:frame
                                                           completionHandler:completionHandler];
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

- (void)createWithIdentifier:(NSInteger)identifier error:(FlutterError *_Nullable *_Nonnull)error {
    BTUIDelegate *uIDelegate = [[BTUIDelegate alloc] initWithBinaryMessenger:self.binaryMessenger
                                                               instanceManager:self.instanceManager];
    [self.instanceManager addDartCreatedInstance:uIDelegate withIdentifier:identifier];
}

@end
