// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>

#import "BTGeneratedWebKitApis.h"
#import "BTInstanceManager.h"
#import "BTObjectHostApi.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Flutter api implementation for WKWebViewConfiguration.
 *
 * Handles making callbacks to Dart for a WKWebViewConfiguration.
 */
@interface BTWebViewConfigurationFlutterApiImpl : BTWKWebViewConfigurationFlutterApi
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager;

- (void)createWithConfiguration:(WKWebViewConfiguration *)configuration
                     completion:(void (^)(FlutterError *_Nullable))completion;
@end

/**
 * Implementation of WKWebViewConfiguration for BTWebViewConfigurationHostApiImpl.
 */
@interface BTWebViewConfiguration : WKWebViewConfiguration
@property(readonly, nonnull, nonatomic) BTObjectFlutterApiImpl *objectApi;

- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager;
@end

/**
 * Host api implementation for WKWebViewConfiguration.
 *
 * Handles creating WKWebViewConfiguration that intercommunicate with a paired Dart object.
 */
@interface BTWebViewConfigurationHostApiImpl : NSObject <BTWKWebViewConfigurationHostApi>
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager;
@end

NS_ASSUME_NONNULL_END
