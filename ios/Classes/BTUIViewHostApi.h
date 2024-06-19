// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>

#import "BTGeneratedWebKitApis.h"
#import "BTInstanceManager.h"

NS_ASSUME_NONNULL_BEGIN

/// Host api implementation for UIView.
///
/// Handles creating UIView that intercommunicate with a paired Dart object.
@interface BTUIViewHostApiImpl : NSObject <BTUIViewHostApi>
- (instancetype)initWithInstanceManager:(BTInstanceManager *)instanceManager;
@end

NS_ASSUME_NONNULL_END
