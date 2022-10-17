// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface BTScriptMessageHandlerHostApiTests : XCTestCase
@end

@implementation BTScriptMessageHandlerHostApiTests
/**
 * Creates a partially mocked BTScriptMessageHandler and adds it to instanceManager.
 *
 * @param instanceManager Instance manager to add the delegate to.
 * @param identifier Identifier for the delegate added to the instanceManager.
 *
 * @return A mock BTScriptMessageHandler.
 */
- (id)mockHandlerWithManager:(BTInstanceManager *)instanceManager identifier:(long)identifier {
  BTScriptMessageHandler *handler = [[BTScriptMessageHandler alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];

  [instanceManager addDartCreatedInstance:handler withIdentifier:0];
  return OCMPartialMock(handler);
}

/**
 * Creates a  mock BTScriptMessageHandlerFlutterApiImpl with instanceManager.
 *
 * @param instanceManager Instance manager passed to the Flutter API.
 *
 * @return A mock BTScriptMessageHandlerFlutterApiImpl.
 */
- (id)mockFlutterApiWithManager:(BTInstanceManager *)instanceManager {
  BTScriptMessageHandlerFlutterApiImpl *flutterAPI = [[BTScriptMessageHandlerFlutterApiImpl alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];
  return OCMPartialMock(flutterAPI);
}

- (void)testCreateWithIdentifier {
  BTInstanceManager *instanceManager = [[BTInstanceManager alloc] init];
  BTScriptMessageHandlerHostApiImpl *hostAPI = [[BTScriptMessageHandlerHostApiImpl alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];

  FlutterError *error;
  [hostAPI createWithIdentifier:@0 error:&error];

  BTScriptMessageHandler *scriptMessageHandler =
      (BTScriptMessageHandler *)[instanceManager instanceForIdentifier:0];

  XCTAssertTrue([scriptMessageHandler conformsToProtocol:@protocol(WKScriptMessageHandler)]);
  XCTAssertNil(error);
}

- (void)testDidReceiveScriptMessageForHandler {
  BTInstanceManager *instanceManager = [[BTInstanceManager alloc] init];

  BTScriptMessageHandler *mockHandler = [self mockHandlerWithManager:instanceManager identifier:0];
  BTScriptMessageHandlerFlutterApiImpl *mockFlutterAPI =
      [self mockFlutterApiWithManager:instanceManager];

  OCMStub([mockHandler scriptMessageHandlerAPI]).andReturn(mockFlutterAPI);

  WKUserContentController *userContentController = [[WKUserContentController alloc] init];
  [instanceManager addDartCreatedInstance:userContentController withIdentifier:1];

  WKScriptMessage *mockScriptMessage = OCMClassMock([WKScriptMessage class]);
  OCMStub([mockScriptMessage name]).andReturn(@"name");
  OCMStub([mockScriptMessage body]).andReturn(@"message");

  [mockHandler userContentController:userContentController
             didReceiveScriptMessage:mockScriptMessage];
  OCMVerify([mockFlutterAPI
      didReceiveScriptMessageForHandlerWithIdentifier:@0
                      userContentControllerIdentifier:@1
                                              message:[OCMArg isKindOfClass:[BTWKScriptMessageData
                                                                                class]]
                                           completion:OCMOCK_ANY]);
}
@end
