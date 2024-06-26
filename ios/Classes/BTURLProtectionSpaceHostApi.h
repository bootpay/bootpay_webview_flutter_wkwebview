// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import "BTGeneratedWebKitApis.h"
#import "BTInstanceManager.h"

NS_ASSUME_NONNULL_BEGIN

/// Flutter API implementation for `NSURLProtectionSpace`.
///
/// This class may handle instantiating and adding Dart instances that are attached to a native
/// instance or sending callback methods from an overridden native class.
@interface BTURLProtectionSpaceFlutterApiImpl : NSObject
/// The Flutter API used to send messages back to Dart.
@property BTNSUrlProtectionSpaceFlutterApi *api;
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager;
/// Sends a message to Dart to create a new Dart instance and add it to the `InstanceManager`.
- (void)createWithInstance:(NSURLProtectionSpace *)instance
                      host:(nullable NSString *)host
                     realm:(nullable NSString *)realm
      authenticationMethod:(nullable NSString *)authenticationMethod
                completion:(void (^)(FlutterError *_Nullable))completion;
@end

NS_ASSUME_NONNULL_END
