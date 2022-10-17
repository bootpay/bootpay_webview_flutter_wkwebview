// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>

#import "BTGeneratedWebKitApis.h"
#import "BTInstanceManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Flutter api implementation for NSObject.
 *
 * Handles making callbacks to Dart for an NSObject.
 */
@interface BTObjectFlutterApiImpl : BTNSObjectFlutterApi
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager;

- (void)observeValueForObject:(NSObject *)instance
                      keyPath:(NSString *)keyPath
                       object:(NSObject *)object
                       change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                   completion:(void (^)(NSError *_Nullable))completion;
@end

/**
 * Implementation of NSObject for BTObjectHostApiImpl.
 */
@interface BTObject : NSObject
@property(readonly, nonnull, nonatomic) BTObjectFlutterApiImpl *objectApi;

- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager;
@end

/**
 * Host api implementation for NSObject.
 *
 * Handles creating NSObject that intercommunicate with a paired Dart object.
 */
@interface BTObjectHostApiImpl : NSObject <BTNSObjectHostApi>
- (instancetype)initWithInstanceManager:(BTInstanceManager *)instanceManager;
@end

NS_ASSUME_NONNULL_END
