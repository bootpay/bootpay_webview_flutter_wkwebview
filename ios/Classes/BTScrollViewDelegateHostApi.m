// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "BTScrollViewDelegateHostApi.h"
#import "BTWebViewHostApi.h"

@interface BTScrollViewDelegateFlutterApiImpl ()
// BinaryMessenger must be weak to prevent a circular reference with the host API it
// references.
@property(nonatomic, weak) id<FlutterBinaryMessenger> binaryMessenger;
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) BTInstanceManager *instanceManager;
@end

@implementation BTScrollViewDelegateFlutterApiImpl

- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager {
  self = [self initWithBinaryMessenger:binaryMessenger];
  if (self) {
    _binaryMessenger = binaryMessenger;
    _instanceManager = instanceManager;
  }
  return self;
}
- (long)identifierForDelegate:(BTScrollViewDelegate *)instance {
  return [self.instanceManager identifierWithStrongReferenceForInstance:instance];
}

- (void)scrollViewDidScrollForDelegate:(BTScrollViewDelegate *)instance
                          uiScrollView:(UIScrollView *)scrollView
                            completion:(void (^)(FlutterError *_Nullable))completion {
  [self scrollViewDidScrollWithIdentifier:[self identifierForDelegate:instance]
                   UIScrollViewIdentifier:[self.instanceManager
                                              identifierWithStrongReferenceForInstance:scrollView]
                                        x:scrollView.contentOffset.x
                                        y:scrollView.contentOffset.y
                               completion:completion];
}
@end

@implementation BTScrollViewDelegate

- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager {
  self = [super initWithBinaryMessenger:binaryMessenger instanceManager:instanceManager];
  if (self) {
    _scrollViewDelegateAPI =
        [[BTScrollViewDelegateFlutterApiImpl alloc] initWithBinaryMessenger:binaryMessenger
                                                             instanceManager:instanceManager];
  }
  return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [self.scrollViewDelegateAPI scrollViewDidScrollForDelegate:self
                                                uiScrollView:scrollView
                                                  completion:^(FlutterError *error) {
                                                    NSAssert(!error, @"%@", error);
                                                  }];
}
@end

@interface BTScrollViewDelegateHostApiImpl ()
// BinaryMessenger must be weak to prevent a circular reference with the host API it
// references.
@property(nonatomic, weak) id<FlutterBinaryMessenger> binaryMessenger;
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) BTInstanceManager *instanceManager;
@end

@implementation BTScrollViewDelegateHostApiImpl
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(BTInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _binaryMessenger = binaryMessenger;
    _instanceManager = instanceManager;
  }
  return self;
}

- (void)createWithIdentifier:(NSInteger)identifier error:(FlutterError *_Nullable *_Nonnull)error {
  BTScrollViewDelegate *uiScrollViewDelegate =
      [[BTScrollViewDelegate alloc] initWithBinaryMessenger:self.binaryMessenger
                                             instanceManager:self.instanceManager];
  [self.instanceManager addDartCreatedInstance:uiScrollViewDelegate withIdentifier:identifier];
}
@end
