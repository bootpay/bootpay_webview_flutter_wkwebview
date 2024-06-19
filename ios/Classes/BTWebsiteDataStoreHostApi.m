// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "BTWebsiteDataStoreHostApi.h"
#import "BTDataConverters.h"
#import "BTWebViewConfigurationHostApi.h"

@interface BTWebsiteDataStoreHostApiImpl ()
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) BTInstanceManager *instanceManager;
@end

@implementation BTWebsiteDataStoreHostApiImpl
- (instancetype)initWithInstanceManager:(BTInstanceManager *)instanceManager {
    self = [self init];
    if (self) {
        _instanceManager = instanceManager;
    }
    return self;
}

- (WKWebsiteDataStore *)websiteDataStoreForIdentifier:(NSInteger)identifier {
    return (WKWebsiteDataStore *)[self.instanceManager instanceForIdentifier:identifier];
}

- (void)createFromWebViewConfigurationWithIdentifier:(NSInteger)identifier
                             configurationIdentifier:(NSInteger)configurationIdentifier
                                               error:(FlutterError *_Nullable *_Nonnull)error {
    WKWebViewConfiguration *configuration = (WKWebViewConfiguration *)[self.instanceManager
            instanceForIdentifier:configurationIdentifier];
    [self.instanceManager addDartCreatedInstance:configuration.websiteDataStore
                                  withIdentifier:identifier];
}

- (void)createDefaultDataStoreWithIdentifier:(NSInteger)identifier
                                       error:(FlutterError *_Nullable __autoreleasing *_Nonnull)
error {
    [self.instanceManager addDartCreatedInstance:[WKWebsiteDataStore defaultDataStore]
                                  withIdentifier:identifier];
}

- (void)removeDataFromDataStoreWithIdentifier:(NSInteger)identifier
                                      ofTypes:(nonnull NSArray<BTWKWebsiteDataTypeEnumData *> *)
dataTypes
        modifiedSince:(double)modificationTimeInSecondsSinceEpoch
        completion:
(nonnull void (^)(NSNumber *_Nullable,
        FlutterError *_Nullable))completion {
    NSMutableSet<NSString *> *stringDataTypes = [NSMutableSet set];
    for (BTWKWebsiteDataTypeEnumData *type in dataTypes) {
        [stringDataTypes addObject:BTNativeWKWebsiteDataTypeFromEnumData(type)];
    }

    WKWebsiteDataStore *dataStore = [self websiteDataStoreForIdentifier:identifier];
    [dataStore fetchDataRecordsOfTypes:stringDataTypes
                     completionHandler:^(NSArray<WKWebsiteDataRecord *> *records) {
        [dataStore removeDataOfTypes:stringDataTypes
                       modifiedSince:[NSDate dateWithTimeIntervalSince1970:
                               modificationTimeInSecondsSinceEpoch]
                   completionHandler:^{
                       completion([NSNumber numberWithBool:(records.count > 0)], nil);
                   }];
    }];
}
@end
