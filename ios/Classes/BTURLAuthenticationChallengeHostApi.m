// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "BTURLAuthenticationChallengeHostApi.h"
#import "BTURLProtectionSpaceHostApi.h"

@interface BTURLAuthenticationChallengeFlutterApiImpl ()
// BinaryMessenger must be weak to prevent a circular reference with the host API it
// references.
@property(nonatomic, weak) id<FlutterBinaryMessenger> binaryMessenger;
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) BTInstanceManager *instanceManager;
@end

@implementation BTURLAuthenticationChallengeFlutterApiImpl
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _binaryMessenger = binaryMessenger;
    _instanceManager = instanceManager;
    _api =
        [[BTNSUrlAuthenticationChallengeFlutterApi alloc] initWithBinaryMessenger:binaryMessenger];
  }
  return self;
}

- (void)createWithInstance:(NSURLAuthenticationChallenge *)instance
           protectionSpace:(NSURLProtectionSpace *)protectionSpace
                completion:(void (^)(FlutterError *_Nullable))completion {
  if ([self.instanceManager containsInstance:instance]) {
    return;
  }

  BTURLProtectionSpaceFlutterApiImpl *protectionSpaceApi =
      [[BTURLProtectionSpaceFlutterApiImpl alloc] initWithBinaryMessenger:self.binaryMessenger
                                                           instanceManager:self.instanceManager];
  [protectionSpaceApi createWithInstance:protectionSpace
                                    host:protectionSpace.host
                                   realm:protectionSpace.realm
                    authenticationMethod:protectionSpace.authenticationMethod
                              completion:^(FlutterError *error) {
                                NSAssert(!error, @"%@", error);
                              }];

  [self.api createWithIdentifier:[self.instanceManager addHostCreatedInstance:instance]
       protectionSpaceIdentifier:[self.instanceManager
                                     identifierWithStrongReferenceForInstance:protectionSpace]
                      completion:completion];
}
@end
