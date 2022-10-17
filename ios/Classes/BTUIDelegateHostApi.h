// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>

#import "BTGeneratedWebKitApis.h"
#import "BTInstanceManager.h"
#import "BTObjectHostApi.h"
#import "BTWebViewConfigurationHostApi.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Flutter api implementation for WKUIDelegate.
 *
 * Handles making callbacks to Dart for a WKUIDelegate.
 */
@interface BTUIDelegateFlutterApiImpl : BTWKUIDelegateFlutterApi
@property(readonly, nonatomic)
    BTWebViewConfigurationFlutterApiImpl *webViewConfigurationFlutterApi;

- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager;
@end

/**
 * Implementation of WKUIDelegate for BTUIDelegateHostApiImpl.
 */
@interface BTUIDelegate : BTObject <WKUIDelegate>
@property(readonly, nonnull, nonatomic) BTUIDelegateFlutterApiImpl *UIDelegateAPI;

- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager;
@end

/**
 * Host api implementation for WKUIDelegate.
 *
 * Handles creating WKUIDelegate that intercommunicate with a paired Dart object.
 */
@interface BTUIDelegateHostApiImpl : NSObject <BTWKUIDelegateHostApi>
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager;
@end

NS_ASSUME_NONNULL_END
