// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "BTScriptMessageHandlerHostApi.h"
#import "BTDataConverters.h"

@interface BTScriptMessageHandlerFlutterApiImpl ()
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) BTInstanceManager *instanceManager;
@end

@implementation BTScriptMessageHandlerFlutterApiImpl
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager {
  self = [self initWithBinaryMessenger:binaryMessenger];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (long)identifierForHandler:(BTScriptMessageHandler *)instance {
  return [self.instanceManager identifierWithStrongReferenceForInstance:instance];
}

- (void)didReceiveScriptMessageForHandler:(BTScriptMessageHandler *)instance
                    userContentController:(WKUserContentController *)userContentController
                                  message:(WKScriptMessage *)message
                               completion:(void (^)(FlutterError *_Nullable))completion {
  NSInteger userContentControllerIdentifier =
          [self.instanceManager identifierWithStrongReferenceForInstance:userContentController];
  BTWKScriptMessageData *messageData = BTWKScriptMessageDataFromNativeWKScriptMessage(message);
  [self didReceiveScriptMessageForHandlerWithIdentifier:[self identifierForHandler:instance]
                        userContentControllerIdentifier:userContentControllerIdentifier
                                                message:messageData
                                             completion:completion];
}
@end

@implementation BTScriptMessageHandler
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager {
  self = [super initWithBinaryMessenger:binaryMessenger instanceManager:instanceManager];
  if (self) {
    _scriptMessageHandlerAPI =
            [[BTScriptMessageHandlerFlutterApiImpl alloc] initWithBinaryMessenger:binaryMessenger
                                                                   instanceManager:instanceManager];
  }
  return self;
}

- (void)userContentController:(nonnull WKUserContentController *)userContentController
        didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
  [self.scriptMessageHandlerAPI didReceiveScriptMessageForHandler:self
                                            userContentController:userContentController
                                                          message:message
                                                       completion:^(FlutterError *error) {
                                                           NSAssert(!error, @"%@", error);
                                                       }];
}
@end

@interface BTScriptMessageHandlerHostApiImpl ()
// BinaryMessenger must be weak to prevent a circular reference with the host API it
// references.
@property(nonatomic, weak) id<FlutterBinaryMessenger> binaryMessenger;
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) BTInstanceManager *instanceManager;
@end

@implementation BTScriptMessageHandlerHostApiImpl
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _binaryMessenger = binaryMessenger;
    _instanceManager = instanceManager;
  }
  return self;
}

- (BTScriptMessageHandler *)scriptMessageHandlerForIdentifier:(NSNumber *)identifier {
  return (BTScriptMessageHandler *)[self.instanceManager
          instanceForIdentifier:identifier.longValue];
}

- (void)createWithIdentifier:(NSInteger)identifier error:(FlutterError *_Nullable *_Nonnull)error {
  BTScriptMessageHandler *scriptMessageHandler =
          [[BTScriptMessageHandler alloc] initWithBinaryMessenger:self.binaryMessenger
                                                   instanceManager:self.instanceManager];
  [self.instanceManager addDartCreatedInstance:scriptMessageHandler withIdentifier:identifier];
}
@end
