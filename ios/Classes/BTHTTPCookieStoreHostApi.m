// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "BTHTTPCookieStoreHostApi.h"
#import "BTDataConverters.h"
#import "BTWebsiteDataStoreHostApi.h"

@interface BTHTTPCookieStoreHostApiImpl ()
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) BTInstanceManager *instanceManager;
@end

@implementation BTHTTPCookieStoreHostApiImpl
- (instancetype)initWithInstanceManager:(BTInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (WKHTTPCookieStore *)HTTPCookieStoreForIdentifier:(NSNumber *)identifier {
  return (WKHTTPCookieStore *)[self.instanceManager instanceForIdentifier:identifier.longValue];
}

- (void)createFromWebsiteDataStoreWithIdentifier:(nonnull NSNumber *)identifier
                             dataStoreIdentifier:(nonnull NSNumber *)websiteDataStoreIdentifier
                                           error:(FlutterError *_Nullable __autoreleasing *_Nonnull)
                                                     error {
  WKWebsiteDataStore *dataStore = (WKWebsiteDataStore *)[self.instanceManager
      instanceForIdentifier:websiteDataStoreIdentifier.longValue];
  [self.instanceManager addDartCreatedInstance:dataStore.httpCookieStore
                                withIdentifier:identifier.longValue];
}

- (void)setCookieForStoreWithIdentifier:(nonnull NSNumber *)identifier
                                 cookie:(nonnull BTNSHttpCookieData *)cookie
                             completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  NSHTTPCookie *nsCookie = BTNativeNSHTTPCookieFromCookieData(cookie);

  [[self HTTPCookieStoreForIdentifier:identifier] setCookie:nsCookie
                                          completionHandler:^{
                                            completion(nil);
                                          }];
}
@end
