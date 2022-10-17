// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>

#import "BTGeneratedWebKitApis.h"
#import "BTInstanceManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Host api implementation for UIScrollView.
 *
 * Handles creating UIScrollView that intercommunicate with a paired Dart object.
 */
@interface BTScrollViewHostApiImpl : NSObject <BTUIScrollViewHostApi>
- (instancetype)initWithInstanceManager:(BTInstanceManager *)instanceManager;
@end

NS_ASSUME_NONNULL_END