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
 * Flutter api implementation for WKScriptMessageHandler.
 *
 * Handles making callbacks to Dart for a WKScriptMessageHandler.
 */
@interface BTScriptMessageHandlerFlutterApiImpl : BTWKScriptMessageHandlerFlutterApi
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager;
@end

/**
 * Implementation of WKScriptMessageHandler for BTScriptMessageHandlerHostApiImpl.
 */
@interface BTScriptMessageHandler : BTObject <WKScriptMessageHandler>
@property(readonly, nonnull, nonatomic)
    BTScriptMessageHandlerFlutterApiImpl *scriptMessageHandlerAPI;

- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager;
@end

/**
 * Host api implementation for WKScriptMessageHandler.
 *
 * Handles creating WKScriptMessageHandler that intercommunicate with a paired Dart object.
 */
@interface BTScriptMessageHandlerHostApiImpl : NSObject <BTWKScriptMessageHandlerHostApi>
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager;
@end

NS_ASSUME_NONNULL_END
