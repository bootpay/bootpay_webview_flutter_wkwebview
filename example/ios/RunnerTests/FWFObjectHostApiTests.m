// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface BTObjectHostApiTests : XCTestCase
@end

@implementation BTObjectHostApiTests
/**
 * Creates a partially mocked BTObject and adds it to instanceManager.
 *
 * @param instanceManager Instance manager to add the delegate to.
 * @param identifier Identifier for the delegate added to the instanceManager.
 *
 * @return A mock BTObject.
 */
- (id)mockObjectWithManager:(BTInstanceManager *)instanceManager identifier:(long)identifier {
  BTObject *object =
      [[BTObject alloc] initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
                                 instanceManager:instanceManager];

  [instanceManager addDartCreatedInstance:object withIdentifier:0];
  return OCMPartialMock(object);
}

/**
 * Creates a  mock BTObjectFlutterApiImpl with instanceManager.
 *
 * @param instanceManager Instance manager passed to the Flutter API.
 *
 * @return A mock BTObjectFlutterApiImpl.
 */
- (id)mockFlutterApiWithManager:(BTInstanceManager *)instanceManager {
  BTObjectFlutterApiImpl *flutterAPI = [[BTObjectFlutterApiImpl alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];
  return OCMPartialMock(flutterAPI);
}

- (void)testAddObserver {
  NSObject *mockObject = OCMClassMock([NSObject class]);

  BTInstanceManager *instanceManager = [[BTInstanceManager alloc] init];
  [instanceManager addDartCreatedInstance:mockObject withIdentifier:0];

  BTObjectHostApiImpl *hostAPI =
      [[BTObjectHostApiImpl alloc] initWithInstanceManager:instanceManager];

  NSObject *observerObject = [[NSObject alloc] init];
  [instanceManager addDartCreatedInstance:observerObject withIdentifier:1];

  FlutterError *error;
  [hostAPI
      addObserverForObjectWithIdentifier:@0
                      observerIdentifier:@1
                                 keyPath:@"myKey"
                                 options:@[
                                   [BTNSKeyValueObservingOptionsEnumData
                                       makeWithValue:BTNSKeyValueObservingOptionsEnumOldValue],
                                   [BTNSKeyValueObservingOptionsEnumData
                                       makeWithValue:BTNSKeyValueObservingOptionsEnumNewValue]
                                 ]
                                   error:&error];

  OCMVerify([mockObject addObserver:observerObject
                         forKeyPath:@"myKey"
                            options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                            context:nil]);
  XCTAssertNil(error);
}

- (void)testRemoveObserver {
  NSObject *mockObject = OCMClassMock([NSObject class]);

  BTInstanceManager *instanceManager = [[BTInstanceManager alloc] init];
  [instanceManager addDartCreatedInstance:mockObject withIdentifier:0];

  BTObjectHostApiImpl *hostAPI =
      [[BTObjectHostApiImpl alloc] initWithInstanceManager:instanceManager];

  NSObject *observerObject = [[NSObject alloc] init];
  [instanceManager addDartCreatedInstance:observerObject withIdentifier:1];

  FlutterError *error;
  [hostAPI removeObserverForObjectWithIdentifier:@0
                              observerIdentifier:@1
                                         keyPath:@"myKey"
                                           error:&error];
  OCMVerify([mockObject removeObserver:observerObject forKeyPath:@"myKey"]);
  XCTAssertNil(error);
}

- (void)testDispose {
  NSObject *object = [[NSObject alloc] init];

  BTInstanceManager *instanceManager = [[BTInstanceManager alloc] init];
  [instanceManager addDartCreatedInstance:object withIdentifier:0];

  BTObjectHostApiImpl *hostAPI =
      [[BTObjectHostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostAPI disposeObjectWithIdentifier:@0 error:&error];
  // Only the strong reference is removed, so the weak reference will remain until object is set to
  // nil.
  object = nil;
  XCTAssertFalse([instanceManager containsInstance:object]);
  XCTAssertNil(error);
}

- (void)testObserveValueForKeyPath {
  BTInstanceManager *instanceManager = [[BTInstanceManager alloc] init];

  BTObject *mockObject = [self mockObjectWithManager:instanceManager identifier:0];
  BTObjectFlutterApiImpl *mockFlutterAPI = [self mockFlutterApiWithManager:instanceManager];

  OCMStub([mockObject objectApi]).andReturn(mockFlutterAPI);

  NSObject *object = [[NSObject alloc] init];
  [instanceManager addDartCreatedInstance:object withIdentifier:1];

  [mockObject observeValueForKeyPath:@"keyPath"
                            ofObject:object
                              change:@{NSKeyValueChangeOldKey : @"key"}
                             context:nil];
  OCMVerify([mockFlutterAPI
      observeValueForObjectWithIdentifier:@0
                                  keyPath:@"keyPath"
                         objectIdentifier:@1
                               changeKeys:[OCMArg checkWithBlock:^BOOL(
                                                      NSArray<BTNSKeyValueChangeKeyEnumData *>
                                                          *value) {
                                 return value[0].value == BTNSKeyValueChangeKeyEnumOldValue;
                               }]
                             changeValues:[OCMArg checkWithBlock:^BOOL(id value) {
                               return [@"key" isEqual:value[0]];
                             }]
                               completion:OCMOCK_ANY]);
}
@end
