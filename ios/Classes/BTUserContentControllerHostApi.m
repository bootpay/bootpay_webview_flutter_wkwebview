// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "BTUserContentControllerHostApi.h"
#import "BTDataConverters.h"
#import "BTWebViewConfigurationHostApi.h"

@interface BTUserContentControllerHostApiImpl ()
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) BTInstanceManager *instanceManager;
@end

@implementation BTUserContentControllerHostApiImpl
- (instancetype)initWithInstanceManager:(BTInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (WKUserContentController *)userContentControllerForIdentifier:(NSNumber *)identifier {
  return (WKUserContentController *)[self.instanceManager
      instanceForIdentifier:identifier.longValue];
}

- (void)createFromWebViewConfigurationWithIdentifier:(nonnull NSNumber *)identifier
                             configurationIdentifier:(nonnull NSNumber *)configurationIdentifier
                                               error:(FlutterError *_Nullable *_Nonnull)error {
  WKWebViewConfiguration *configuration = (WKWebViewConfiguration *)[self.instanceManager
      instanceForIdentifier:configurationIdentifier.longValue];
  [self.instanceManager addDartCreatedInstance:configuration.userContentController
                                withIdentifier:identifier.longValue];
}

- (void)addScriptMessageHandlerForControllerWithIdentifier:(nonnull NSNumber *)identifier
                                         handlerIdentifier:(nonnull NSNumber *)handler
                                                    ofName:(nonnull NSString *)name
                                                     error:
                                                         (FlutterError *_Nullable *_Nonnull)error {
  [[self userContentControllerForIdentifier:identifier]
      addScriptMessageHandler:(id<WKScriptMessageHandler>)[self.instanceManager
                                  instanceForIdentifier:handler.longValue]
                         name:name];
}

- (void)removeScriptMessageHandlerForControllerWithIdentifier:(nonnull NSNumber *)identifier
                                                         name:(nonnull NSString *)name
                                                        error:(FlutterError *_Nullable *_Nonnull)
                                                                  error {
  [[self userContentControllerForIdentifier:identifier] removeScriptMessageHandlerForName:name];
}

- (void)removeAllScriptMessageHandlersForControllerWithIdentifier:(nonnull NSNumber *)identifier
                                                            error:
                                                                (FlutterError *_Nullable *_Nonnull)
                                                                    error {
  if (@available(iOS 14.0, *)) {
    [[self userContentControllerForIdentifier:identifier] removeAllScriptMessageHandlers];
  } else {
    *error = [FlutterError
        errorWithCode:@"BTUnsupportedVersionError"
              message:@"removeAllScriptMessageHandlers is only supported on versions 14+."
              details:nil];
  }
}

- (void)addUserScriptForControllerWithIdentifier:(nonnull NSNumber *)identifier
                                      userScript:(nonnull BTWKUserScriptData *)userScript
                                           error:(FlutterError *_Nullable *_Nonnull)error {
  [[self userContentControllerForIdentifier:identifier]
      addUserScript:BTNativeWKUserScriptFromScriptData(userScript)];
}

- (void)removeAllUserScriptsForControllerWithIdentifier:(nonnull NSNumber *)identifier
                                                  error:(FlutterError *_Nullable *_Nonnull)error {
  [[self userContentControllerForIdentifier:identifier] removeAllUserScripts];
}

@end
