//
//  BTWebViewFlutterWKWebViewExternalAPI.m
//  bootpay_webview_flutter_wkwebview
//
//  Created by Taesup Yoon on 2023/04/26.
//

#import "BTWebViewFlutterWKWebViewExternalAPI.h"
#import "BTInstanceManager.h"

@implementation BTWebViewFlutterWKWebViewExternalAPI

+ (nullable WKWebView *)webViewForIdentifier:(long)identifier
                          withPluginRegistry:(id<FlutterPluginRegistry>)registry {
  BTInstanceManager *instanceManager =
      (BTInstanceManager *)[registry valuePublishedByPlugin:@"BTWebViewFlutterPlugin"];

  id instance = [instanceManager instanceForIdentifier:identifier];
  if ([instance isKindOfClass:[WKWebView class]]) {
    return instance;
  }

  return nil;
}

@end
