// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface BTUIDelegateHostApiTests : XCTestCase
@end

@implementation BTUIDelegateHostApiTests
/**
 * Creates a partially mocked BTUIDelegate and adds it to instanceManager.
 *
 * @param instanceManager Instance manager to add the delegate to.
 * @param identifier Identifier for the delegate added to the instanceManager.
 *
 * @return A mock BTUIDelegate.
 */
- (id)mockDelegateWithManager:(BTInstanceManager *)instanceManager identifier:(long)identifier {
  BTUIDelegate *delegate = [[BTUIDelegate alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];

  [instanceManager addDartCreatedInstance:delegate withIdentifier:0];
  return OCMPartialMock(delegate);
}

/**
 * Creates a  mock BTUIDelegateFlutterApiImpl with instanceManager.
 *
 * @param instanceManager Instance manager passed to the Flutter API.
 *
 * @return A mock BTUIDelegateFlutterApiImpl.
 */
- (id)mockFlutterApiWithManager:(BTInstanceManager *)instanceManager {
  BTUIDelegateFlutterApiImpl *flutterAPI = [[BTUIDelegateFlutterApiImpl alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];
  return OCMPartialMock(flutterAPI);
}

- (void)testCreateWithIdentifier {
  BTInstanceManager *instanceManager = [[BTInstanceManager alloc] init];
  BTUIDelegateHostApiImpl *hostAPI = [[BTUIDelegateHostApiImpl alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];

  FlutterError *error;
  [hostAPI createWithIdentifier:@0 error:&error];
  BTUIDelegate *delegate = (BTUIDelegate *)[instanceManager instanceForIdentifier:0];

  XCTAssertTrue([delegate conformsToProtocol:@protocol(WKUIDelegate)]);
  XCTAssertNil(error);
}

- (void)testOnCreateWebViewForDelegateWithIdentifier {
  BTInstanceManager *instanceManager = [[BTInstanceManager alloc] init];

  BTUIDelegate *mockDelegate = [self mockDelegateWithManager:instanceManager identifier:0];
  BTUIDelegateFlutterApiImpl *mockFlutterAPI = [self mockFlutterApiWithManager:instanceManager];

  OCMStub([mockDelegate UIDelegateAPI]).andReturn(mockFlutterAPI);

  WKWebView *mockWebView = OCMClassMock([WKWebView class]);
  [instanceManager addDartCreatedInstance:mockWebView withIdentifier:1];

  WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
  id mockConfigurationFlutterApi = OCMPartialMock(mockFlutterAPI.webViewConfigurationFlutterApi);
  NSNumber *__block configurationIdentifier;
  OCMStub([mockConfigurationFlutterApi createWithIdentifier:[OCMArg checkWithBlock:^BOOL(id value) {
                                         configurationIdentifier = value;
                                         return YES;
                                       }]
                                                 completion:OCMOCK_ANY]);

  WKNavigationAction *mockNavigationAction = OCMClassMock([WKNavigationAction class]);
  OCMStub([mockNavigationAction request])
      .andReturn([NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.flutter.dev"]]);

  WKFrameInfo *mockFrameInfo = OCMClassMock([WKFrameInfo class]);
  OCMStub([mockFrameInfo isMainFrame]).andReturn(YES);
  OCMStub([mockNavigationAction targetFrame]).andReturn(mockFrameInfo);

  [mockDelegate webView:mockWebView
      createWebViewWithConfiguration:configuration
                 forNavigationAction:mockNavigationAction
                      windowFeatures:OCMClassMock([WKWindowFeatures class])];
  OCMVerify([mockFlutterAPI
      onCreateWebViewForDelegateWithIdentifier:@0
                             webViewIdentifier:@1
                       configurationIdentifier:configurationIdentifier
                              navigationAction:[OCMArg
                                                   isKindOfClass:[BTWKNavigationActionData class]]
                                    completion:OCMOCK_ANY]);
}
@end
