// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface BTNavigationDelegateHostApiTests : XCTestCase
@end

@implementation BTNavigationDelegateHostApiTests
/**
 * Creates a partially mocked BTNavigationDelegate and adds it to instanceManager.
 *
 * @param instanceManager Instance manager to add the delegate to.
 * @param identifier Identifier for the delegate added to the instanceManager.
 *
 * @return A mock BTNavigationDelegate.
 */
- (id)mockNavigationDelegateWithManager:(BTInstanceManager *)instanceManager
                             identifier:(long)identifier {
  BTNavigationDelegate *navigationDelegate = [[BTNavigationDelegate alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];

  [instanceManager addDartCreatedInstance:navigationDelegate withIdentifier:0];
  return OCMPartialMock(navigationDelegate);
}

/**
 * Creates a  mock BTNavigationDelegateFlutterApiImpl with instanceManager.
 *
 * @param instanceManager Instance manager passed to the Flutter API.
 *
 * @return A mock BTNavigationDelegateFlutterApiImpl.
 */
- (id)mockFlutterApiWithManager:(BTInstanceManager *)instanceManager {
  BTNavigationDelegateFlutterApiImpl *flutterAPI = [[BTNavigationDelegateFlutterApiImpl alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];
  return OCMPartialMock(flutterAPI);
}

- (void)testCreateWithIdentifier {
  BTInstanceManager *instanceManager = [[BTInstanceManager alloc] init];
  BTNavigationDelegateHostApiImpl *hostAPI = [[BTNavigationDelegateHostApiImpl alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];

  FlutterError *error;
  [hostAPI createWithIdentifier:@0 error:&error];
  BTNavigationDelegate *navigationDelegate =
      (BTNavigationDelegate *)[instanceManager instanceForIdentifier:0];

  XCTAssertTrue([navigationDelegate conformsToProtocol:@protocol(WKNavigationDelegate)]);
  XCTAssertNil(error);
}

- (void)testDidFinishNavigation {
  BTInstanceManager *instanceManager = [[BTInstanceManager alloc] init];

  BTNavigationDelegate *mockDelegate = [self mockNavigationDelegateWithManager:instanceManager
                                                                     identifier:0];
  BTNavigationDelegateFlutterApiImpl *mockFlutterAPI =
      [self mockFlutterApiWithManager:instanceManager];

  OCMStub([mockDelegate navigationDelegateAPI]).andReturn(mockFlutterAPI);

  WKWebView *mockWebView = OCMClassMock([WKWebView class]);
  OCMStub([mockWebView URL]).andReturn([NSURL URLWithString:@"https://flutter.dev/"]);
  [instanceManager addDartCreatedInstance:mockWebView withIdentifier:1];

  [mockDelegate webView:mockWebView didFinishNavigation:OCMClassMock([WKNavigation class])];
  OCMVerify([mockFlutterAPI didFinishNavigationForDelegateWithIdentifier:@0
                                                       webViewIdentifier:@1
                                                                     URL:@"https://flutter.dev/"
                                                              completion:OCMOCK_ANY]);
}

- (void)testDidStartProvisionalNavigation {
  BTInstanceManager *instanceManager = [[BTInstanceManager alloc] init];

  BTNavigationDelegate *mockDelegate = [self mockNavigationDelegateWithManager:instanceManager
                                                                     identifier:0];
  BTNavigationDelegateFlutterApiImpl *mockFlutterAPI =
      [self mockFlutterApiWithManager:instanceManager];

  OCMStub([mockDelegate navigationDelegateAPI]).andReturn(mockFlutterAPI);

  WKWebView *mockWebView = OCMClassMock([WKWebView class]);
  OCMStub([mockWebView URL]).andReturn([NSURL URLWithString:@"https://flutter.dev/"]);
  [instanceManager addDartCreatedInstance:mockWebView withIdentifier:1];

  [mockDelegate webView:mockWebView
      didStartProvisionalNavigation:OCMClassMock([WKNavigation class])];
  OCMVerify([mockFlutterAPI
      didStartProvisionalNavigationForDelegateWithIdentifier:@0
                                           webViewIdentifier:@1
                                                         URL:@"https://flutter.dev/"
                                                  completion:OCMOCK_ANY]);
}

- (void)testDecidePolicyForNavigationAction {
  BTInstanceManager *instanceManager = [[BTInstanceManager alloc] init];

  BTNavigationDelegate *mockDelegate = [self mockNavigationDelegateWithManager:instanceManager
                                                                     identifier:0];
  BTNavigationDelegateFlutterApiImpl *mockFlutterAPI =
      [self mockFlutterApiWithManager:instanceManager];

  OCMStub([mockDelegate navigationDelegateAPI]).andReturn(mockFlutterAPI);

  WKWebView *mockWebView = OCMClassMock([WKWebView class]);
  [instanceManager addDartCreatedInstance:mockWebView withIdentifier:1];

  WKNavigationAction *mockNavigationAction = OCMClassMock([WKNavigationAction class]);
  OCMStub([mockNavigationAction request])
      .andReturn([NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.flutter.dev"]]);

  WKFrameInfo *mockFrameInfo = OCMClassMock([WKFrameInfo class]);
  OCMStub([mockFrameInfo isMainFrame]).andReturn(YES);
  OCMStub([mockNavigationAction targetFrame]).andReturn(mockFrameInfo);

  OCMStub([mockFlutterAPI
      decidePolicyForNavigationActionForDelegateWithIdentifier:@0
                                             webViewIdentifier:@1
                                              navigationAction:
                                                  [OCMArg isKindOfClass:[BTWKNavigationActionData
                                                                            class]]
                                                    completion:
                                                        ([OCMArg
                                                            invokeBlockWithArgs:
                                                                [BTWKNavigationActionPolicyEnumData
                                                                    makeWithValue:
                                                                        BTWKNavigationActionPolicyEnumCancel],
                                                                [NSNull null], nil])]);

  WKNavigationActionPolicy __block callbackPolicy = -1;
  [mockDelegate webView:mockWebView
      decidePolicyForNavigationAction:mockNavigationAction
                      decisionHandler:^(WKNavigationActionPolicy policy) {
                        callbackPolicy = policy;
                      }];
  XCTAssertEqual(callbackPolicy, WKNavigationActionPolicyCancel);
}

- (void)testDidFailNavigation {
  BTInstanceManager *instanceManager = [[BTInstanceManager alloc] init];

  BTNavigationDelegate *mockDelegate = [self mockNavigationDelegateWithManager:instanceManager
                                                                     identifier:0];
  BTNavigationDelegateFlutterApiImpl *mockFlutterAPI =
      [self mockFlutterApiWithManager:instanceManager];

  OCMStub([mockDelegate navigationDelegateAPI]).andReturn(mockFlutterAPI);

  WKWebView *mockWebView = OCMClassMock([WKWebView class]);
  [instanceManager addDartCreatedInstance:mockWebView withIdentifier:1];

  [mockDelegate webView:mockWebView
      didFailNavigation:OCMClassMock([WKNavigation class])
              withError:[NSError errorWithDomain:@"domain" code:0 userInfo:nil]];
  OCMVerify([mockFlutterAPI
      didFailNavigationForDelegateWithIdentifier:@0
                               webViewIdentifier:@1
                                           error:[OCMArg isKindOfClass:[BTNSErrorData class]]
                                      completion:OCMOCK_ANY]);
}

- (void)testDidFailProvisionalNavigation {
  BTInstanceManager *instanceManager = [[BTInstanceManager alloc] init];

  BTNavigationDelegate *mockDelegate = [self mockNavigationDelegateWithManager:instanceManager
                                                                     identifier:0];
  BTNavigationDelegateFlutterApiImpl *mockFlutterAPI =
      [self mockFlutterApiWithManager:instanceManager];

  OCMStub([mockDelegate navigationDelegateAPI]).andReturn(mockFlutterAPI);

  WKWebView *mockWebView = OCMClassMock([WKWebView class]);
  [instanceManager addDartCreatedInstance:mockWebView withIdentifier:1];

  [mockDelegate webView:mockWebView
      didFailProvisionalNavigation:OCMClassMock([WKNavigation class])
                         withError:[NSError errorWithDomain:@"domain" code:0 userInfo:nil]];
  OCMVerify([mockFlutterAPI
      didFailProvisionalNavigationForDelegateWithIdentifier:@0
                                          webViewIdentifier:@1
                                                      error:[OCMArg isKindOfClass:[BTNSErrorData
                                                                                      class]]
                                                 completion:OCMOCK_ANY]);
}

- (void)testWebViewWebContentProcessDidTerminate {
  BTInstanceManager *instanceManager = [[BTInstanceManager alloc] init];

  BTNavigationDelegate *mockDelegate = [self mockNavigationDelegateWithManager:instanceManager
                                                                     identifier:0];
  BTNavigationDelegateFlutterApiImpl *mockFlutterAPI =
      [self mockFlutterApiWithManager:instanceManager];

  OCMStub([mockDelegate navigationDelegateAPI]).andReturn(mockFlutterAPI);

  WKWebView *mockWebView = OCMClassMock([WKWebView class]);
  [instanceManager addDartCreatedInstance:mockWebView withIdentifier:1];

  [mockDelegate webViewWebContentProcessDidTerminate:mockWebView];
  OCMVerify([mockFlutterAPI
      webViewWebContentProcessDidTerminateForDelegateWithIdentifier:@0
                                                  webViewIdentifier:@1
                                                         completion:OCMOCK_ANY]);
}
@end
