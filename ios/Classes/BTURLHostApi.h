// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import "BTGeneratedWebKitApis.h"
#import "BTInstanceManager.h"

NS_ASSUME_NONNULL_BEGIN

/// Host API implementation for `NSURL`.
///
/// This class may handle instantiating and adding native object instances that are attached to a
/// Dart instance or method calls on the associated native class or an instance of the class.
@interface BTURLHostApiImpl : NSObject <BTNSUrlHostApi>
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager;
@end

/// Flutter API implementation for `NSURL`.
///
/// This class may handle instantiating and adding Dart instances that are attached to a native
/// instance or sending callback methods from an overridden native class.
@interface BTURLFlutterApiImpl : NSObject
/// The Flutter API used to send messages back to Dart.
@property BTNSUrlFlutterApi *api;
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager;

/// Sends a message to Dart to create a new Dart instance and add it to the `InstanceManager`.
- (void)create:(NSURL *)instance completion:(void (^)(FlutterError *_Nullable))completion;
@end

NS_ASSUME_NONNULL_END
