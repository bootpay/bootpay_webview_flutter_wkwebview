// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

#import "BTGeneratedWebKitApis.h"
#import "BTInstanceManager.h"
#import "BTObjectHostApi.h"

NS_ASSUME_NONNULL_BEGIN

/// Flutter api implementation for WKNavigationDelegate.
///
/// Handles making callbacks to Dart for a WKNavigationDelegate.
@interface BTNavigationDelegateFlutterApiImpl : BTWKNavigationDelegateFlutterApi
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager;
@end

/// Implementation of WKNavigationDelegate for BTNavigationDelegateHostApiImpl.
@interface BTNavigationDelegate : BTObject <WKNavigationDelegate>
@property(readonly, nonnull, nonatomic) BTNavigationDelegateFlutterApiImpl *navigationDelegateAPI;

- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager;
@end

/// Host api implementation for WKNavigationDelegate.
///
/// Handles creating WKNavigationDelegate that intercommunicate with a paired Dart object.
@interface BTNavigationDelegateHostApiImpl : NSObject <BTWKNavigationDelegateHostApi>
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager;
@end

NS_ASSUME_NONNULL_END
