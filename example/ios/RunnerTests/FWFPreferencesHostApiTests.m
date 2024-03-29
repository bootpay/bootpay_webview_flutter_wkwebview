// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface BTPreferencesHostApiTests : XCTestCase
@end

@implementation BTPreferencesHostApiTests
- (void)testCreateFromWebViewConfigurationWithIdentifier {
  BTInstanceManager *instanceManager = [[BTInstanceManager alloc] init];
  BTPreferencesHostApiImpl *hostAPI =
      [[BTPreferencesHostApiImpl alloc] initWithInstanceManager:instanceManager];

  [instanceManager addDartCreatedInstance:[[WKWebViewConfiguration alloc] init] withIdentifier:0];

  FlutterError *error;
  [hostAPI createFromWebViewConfigurationWithIdentifier:@1 configurationIdentifier:@0 error:&error];
  WKPreferences *preferences = (WKPreferences *)[instanceManager instanceForIdentifier:1];
  XCTAssertTrue([preferences isKindOfClass:[WKPreferences class]]);
  XCTAssertNil(error);
}

- (void)testSetJavaScriptEnabled {
  WKPreferences *mockPreferences = OCMClassMock([WKPreferences class]);

  BTInstanceManager *instanceManager = [[BTInstanceManager alloc] init];
  [instanceManager addDartCreatedInstance:mockPreferences withIdentifier:0];

  BTPreferencesHostApiImpl *hostAPI =
      [[BTPreferencesHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostAPI setJavaScriptEnabledForPreferencesWithIdentifier:@0 isEnabled:@YES error:&error];
  OCMVerify([mockPreferences setJavaScriptEnabled:YES]);
  XCTAssertNil(error);
}
@end
