// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>
#import "BTObjectHostApi.h"

#import "BTGeneratedWebKitApis.h"
#import "BTInstanceManager.h"

NS_ASSUME_NONNULL_BEGIN

/// Flutter api implementation for UIScrollViewDelegate.
///
/// Handles making callbacks to Dart for a UIScrollViewDelegate.
@interface BTScrollViewDelegateFlutterApiImpl : BTUIScrollViewDelegateFlutterApi

- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager;
@end

/// Implementation of WKUIScrollViewDelegate for BTUIScrollViewDelegateHostApiImpl.
@interface BTScrollViewDelegate : BTObject <UIScrollViewDelegate>
@property(readonly, nonnull, nonatomic) BTScrollViewDelegateFlutterApiImpl *scrollViewDelegateAPI;

- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager;

@end

/// Host api implementation for UIScrollViewDelegate.
///
/// Handles creating UIScrollView that intercommunicate with a paired Dart object.
@interface BTScrollViewDelegateHostApiImpl : NSObject <BTUIScrollViewDelegateHostApi>
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager;
@end

NS_ASSUME_NONNULL_END
