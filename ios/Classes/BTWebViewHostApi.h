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
 * A set of Flutter and Dart assets used by a `FlutterEngine` to initialize execution.
 *
 * Default implementation delegates methods to FlutterDartProject.
 */
@interface BTAssetManager : NSObject
- (NSString *)lookupKeyForAsset:(NSString *)asset;
@end

/**
 * Implementation of WKWebView that can be used as a FlutterPlatformView.
 */
@interface BTWebView : WKWebView <FlutterPlatformView>
@property(readonly, nonnull, nonatomic) BTObjectFlutterApiImpl *objectApi;


- (instancetype)initWithFrame:(CGRect)frame
                configuration:(nonnull WKWebViewConfiguration *)configuration
              binaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
              instanceManager:(BTInstanceManager *)instanceManager;
@end

/**
 * Host api implementation for WKWebView.
 *
 * Handles creating WKWebViews that intercommunicate with a paired Dart object.
 */
@interface BTWebViewHostApiImpl : NSObject <BTWKWebViewHostApi>
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager;

- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager
                                 bundle:(NSBundle *)bundle
                           assetManager:(BTAssetManager *)assetManager;
@end

NS_ASSUME_NONNULL_END
