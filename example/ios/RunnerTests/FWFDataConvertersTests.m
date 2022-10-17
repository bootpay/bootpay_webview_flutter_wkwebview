// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface BTDataConvertersTests : XCTestCase
@end

@implementation BTDataConvertersTests
- (void)testBTNSURLRequestFromRequestData {
  NSURLRequest *request = BTNSURLRequestFromRequestData([BTNSUrlRequestData
              makeWithUrl:@"https://flutter.dev"
               httpMethod:@"post"
                 httpBody:[FlutterStandardTypedData typedDataWithBytes:[NSData data]]
      allHttpHeaderFields:@{@"a" : @"header"}]);

  XCTAssertEqualObjects(request.URL, [NSURL URLWithString:@"https://flutter.dev"]);
  XCTAssertEqualObjects(request.HTTPMethod, @"POST");
  XCTAssertEqualObjects(request.HTTPBody, [NSData data]);
  XCTAssertEqualObjects(request.allHTTPHeaderFields, @{@"a" : @"header"});
}

- (void)testBTNSURLRequestFromRequestDataDoesNotOverrideDefaultValuesWithNull {
  NSURLRequest *request =
      BTNSURLRequestFromRequestData([BTNSUrlRequestData makeWithUrl:@"https://flutter.dev"
                                                           httpMethod:nil
                                                             httpBody:nil
                                                  allHttpHeaderFields:@{}]);

  XCTAssertEqualObjects(request.HTTPMethod, @"GET");
}

- (void)testBTNSHTTPCookieFromCookieData {
  NSHTTPCookie *cookie = BTNSHTTPCookieFromCookieData([BTNSHttpCookieData
      makeWithPropertyKeys:@[ [BTNSHttpCookiePropertyKeyEnumData
                               makeWithValue:BTNSHttpCookiePropertyKeyEnumName] ]
            propertyValues:@[ @"cookieName" ]]);
  XCTAssertEqualObjects(cookie,
                        [NSHTTPCookie cookieWithProperties:@{NSHTTPCookieName : @"cookieName"}]);
}

- (void)testBTWKUserScriptFromScriptData {
  WKUserScript *userScript = BTWKUserScriptFromScriptData([BTWKUserScriptData
       makeWithSource:@"mySource"
        injectionTime:[BTWKUserScriptInjectionTimeEnumData
                          makeWithValue:BTWKUserScriptInjectionTimeEnumAtDocumentStart]
      isMainFrameOnly:@NO]);

  XCTAssertEqualObjects(userScript.source, @"mySource");
  XCTAssertEqual(userScript.injectionTime, WKUserScriptInjectionTimeAtDocumentStart);
  XCTAssertEqual(userScript.isForMainFrameOnly, NO);
}

- (void)testBTWKNavigationActionDataFromNavigationAction {
  WKNavigationAction *mockNavigationAction = OCMClassMock([WKNavigationAction class]);

  NSURLRequest *request =
      [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.flutter.dev/"]];
  OCMStub([mockNavigationAction request]).andReturn(request);

  WKFrameInfo *mockFrameInfo = OCMClassMock([WKFrameInfo class]);
  OCMStub([mockFrameInfo isMainFrame]).andReturn(YES);
  OCMStub([mockNavigationAction targetFrame]).andReturn(mockFrameInfo);

  BTWKNavigationActionData *data =
      BTWKNavigationActionDataFromNavigationAction(mockNavigationAction);
  XCTAssertNotNil(data);
}

- (void)testBTNSUrlRequestDataFromNSURLRequest {
  NSMutableURLRequest *request =
      [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.flutter.dev/"]];
  request.HTTPMethod = @"POST";
  request.HTTPBody = [@"aString" dataUsingEncoding:NSUTF8StringEncoding];
  request.allHTTPHeaderFields = @{@"a" : @"field"};

  BTNSUrlRequestData *data = BTNSUrlRequestDataFromNSURLRequest(request);
  XCTAssertEqualObjects(data.url, @"https://www.flutter.dev/");
  XCTAssertEqualObjects(data.httpMethod, @"POST");
  XCTAssertEqualObjects(data.httpBody.data, [@"aString" dataUsingEncoding:NSUTF8StringEncoding]);
  XCTAssertEqualObjects(data.allHttpHeaderFields, @{@"a" : @"field"});
}

- (void)testBTWKFrameInfoDataFromWKFrameInfo {
  WKFrameInfo *mockFrameInfo = OCMClassMock([WKFrameInfo class]);
  OCMStub([mockFrameInfo isMainFrame]).andReturn(YES);

  BTWKFrameInfoData *targetFrameData = BTWKFrameInfoDataFromWKFrameInfo(mockFrameInfo);
  XCTAssertEqualObjects(targetFrameData.isMainFrame, @YES);
}

- (void)testBTNSErrorDataFromNSError {
  NSError *error = [NSError errorWithDomain:@"domain"
                                       code:23
                                   userInfo:@{NSLocalizedDescriptionKey : @"description"}];

  BTNSErrorData *data = BTNSErrorDataFromNSError(error);
  XCTAssertEqualObjects(data.code, @23);
  XCTAssertEqualObjects(data.domain, @"domain");
  XCTAssertEqualObjects(data.localizedDescription, @"description");
}

- (void)testBTWKScriptMessageDataFromWKScriptMessage {
  WKScriptMessage *mockScriptMessage = OCMClassMock([WKScriptMessage class]);
  OCMStub([mockScriptMessage name]).andReturn(@"name");
  OCMStub([mockScriptMessage body]).andReturn(@"message");

  BTWKScriptMessageData *data = BTWKScriptMessageDataFromWKScriptMessage(mockScriptMessage);
  XCTAssertEqualObjects(data.name, @"name");
  XCTAssertEqualObjects(data.body, @"message");
}
@end
