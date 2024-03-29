// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface BTWebViewConfigurationHostApiTests : XCTestCase
@end

@implementation BTWebViewConfigurationHostApiTests
- (void)testCreateWithIdentifier {
  BTInstanceManager *instanceManager = [[BTInstanceManager alloc] init];
  BTWebViewConfigurationHostApiImpl *hostAPI = [[BTWebViewConfigurationHostApiImpl alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];

  FlutterError *error;
  [hostAPI createWithIdentifier:@0 error:&error];
  WKWebViewConfiguration *configuration =
      (WKWebViewConfiguration *)[instanceManager instanceForIdentifier:0];
  XCTAssertTrue([configuration isKindOfClass:[WKWebViewConfiguration class]]);
  XCTAssertNil(error);
}

- (void)testCreateFromWebViewWithIdentifier {
  BTInstanceManager *instanceManager = [[BTInstanceManager alloc] init];
  BTWebViewConfigurationHostApiImpl *hostAPI = [[BTWebViewConfigurationHostApiImpl alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];

  WKWebView *mockWebView = OCMClassMock([WKWebView class]);
  OCMStub([mockWebView configuration]).andReturn(OCMClassMock([WKWebViewConfiguration class]));
  [instanceManager addDartCreatedInstance:mockWebView withIdentifier:0];

  FlutterError *error;
  [hostAPI createFromWebViewWithIdentifier:@1 webViewIdentifier:@0 error:&error];
  WKWebViewConfiguration *configuration =
      (WKWebViewConfiguration *)[instanceManager instanceForIdentifier:1];
  XCTAssertTrue([configuration isKindOfClass:[WKWebViewConfiguration class]]);
  XCTAssertNil(error);
}

- (void)testSetAllowsInlineMediaPlayback {
  WKWebViewConfiguration *mockWebViewConfiguration = OCMClassMock([WKWebViewConfiguration class]);

  BTInstanceManager *instanceManager = [[BTInstanceManager alloc] init];
  [instanceManager addDartCreatedInstance:mockWebViewConfiguration withIdentifier:0];

  BTWebViewConfigurationHostApiImpl *hostAPI = [[BTWebViewConfigurationHostApiImpl alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];

  FlutterError *error;
  [hostAPI setAllowsInlineMediaPlaybackForConfigurationWithIdentifier:@0
                                                            isAllowed:@NO
                                                                error:&error];
  OCMVerify([mockWebViewConfiguration setAllowsInlineMediaPlayback:NO]);
  XCTAssertNil(error);
}

- (void)testSetMediaTypesRequiringUserActionForPlayback {
  WKWebViewConfiguration *mockWebViewConfiguration = OCMClassMock([WKWebViewConfiguration class]);

  BTInstanceManager *instanceManager = [[BTInstanceManager alloc] init];
  [instanceManager addDartCreatedInstance:mockWebViewConfiguration withIdentifier:0];

  BTWebViewConfigurationHostApiImpl *hostAPI = [[BTWebViewConfigurationHostApiImpl alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];

  FlutterError *error;
  [hostAPI
      setMediaTypesRequiresUserActionForConfigurationWithIdentifier:@0
                                                           forTypes:@[
                                                             [BTWKAudiovisualMediaTypeEnumData
                                                                 makeWithValue:
                                                                     BTWKAudiovisualMediaTypeEnumAudio],
                                                             [BTWKAudiovisualMediaTypeEnumData
                                                                 makeWithValue:
                                                                     BTWKAudiovisualMediaTypeEnumVideo]
                                                           ]
                                                              error:&error];
  OCMVerify([mockWebViewConfiguration
      setMediaTypesRequiringUserActionForPlayback:(WKAudiovisualMediaTypeAudio |
                                                   WKAudiovisualMediaTypeVideo)]);
  XCTAssertNil(error);
}
@end
