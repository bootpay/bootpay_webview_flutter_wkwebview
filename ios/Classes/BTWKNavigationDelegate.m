// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "BTWKNavigationDelegate.h"

@implementation BTWKNavigationDelegate {
  FlutterMethodChannel *_methodChannel;
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
  self = [super init];
  if (self) {
    _methodChannel = channel;
  }
  return self;
}

#pragma mark - WKNavigationDelegate conformance

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
  [_methodChannel invokeMethod:@"onPageStarted" arguments:@{@"url" : webView.URL.absoluteString}];
}

- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
  
    if (!self.hasDartNavigationDelegate) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    
    NSString *url = navigationAction.request.URL.absoluteString;
    _beforeUrl = url;
    
    
    
//    [self updateBlindViewIfNaverLogin:webView :url];
    
    if([self isItunesURL:url]) {
        [self startAppToApp:[NSURL URLWithString:url]];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else if(![url hasPrefix:@"http"]) {
        [self startAppToApp:[NSURL URLWithString:url]];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        NSDictionary *arguments = @{
          @"url" : navigationAction.request.URL.absoluteString,
          @"isForMainFrame" : @(navigationAction.targetFrame.isMainFrame)
        };
        [_methodChannel invokeMethod:@"navigationRequest"
                           arguments:arguments
                              result:^(id _Nullable result) {
                                if ([result isKindOfClass:[FlutterError class]]) {
                                  NSLog(@"navigationRequest has unexpectedly completed with an error, "
                                        @"allowing navigation.");
                                  decisionHandler(WKNavigationActionPolicyAllow);
                                  return;
                                }
                                if (result == FlutterMethodNotImplemented) {
                                  NSLog(@"navigationRequest was unexepectedly not implemented: %@, "
                                        @"allowing navigation.",
                                        result);
                                  decisionHandler(WKNavigationActionPolicyAllow);
                                  return;
                                }
                                if (![result isKindOfClass:[NSNumber class]]) {
                                  NSLog(@"navigationRequest unexpectedly returned a non boolean value: "
                                        @"%@, allowing navigation.",
                                        result);
                                  decisionHandler(WKNavigationActionPolicyAllow);
                                  return;
                                }
                                NSNumber *typedResult = result;
                                decisionHandler([typedResult boolValue] ? WKNavigationActionPolicyAllow
                                                                        : WKNavigationActionPolicyCancel);
                              }];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  if (!self.shouldEnableZoom) {
    NSString *source =
        @"var meta = document.createElement('meta');"
        @"meta.name = 'viewport';"
        @"meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0,"
        @"user-scalable=no';"
        @"var head = document.getElementsByTagName('head')[0];head.appendChild(meta);";

    [webView evaluateJavaScript:source completionHandler:nil];
  }

  [_methodChannel invokeMethod:@"onPageFinished" arguments:@{@"url" : webView.URL.absoluteString}];
}

+ (id)errorCodeToString:(NSUInteger)code {
  switch (code) {
    case WKErrorUnknown:
      return @"unknown";
    case WKErrorWebContentProcessTerminated:
      return @"webContentProcessTerminated";
    case WKErrorWebViewInvalidated:
      return @"webViewInvalidated";
    case WKErrorJavaScriptExceptionOccurred:
      return @"javaScriptExceptionOccurred";
    case WKErrorJavaScriptResultTypeIsUnsupported:
      return @"javaScriptResultTypeIsUnsupported";
  }

  return [NSNull null];
}

- (void)onWebResourceError:(NSError *)error {
  [_methodChannel invokeMethod:@"onWebResourceError"
                     arguments:@{
                       @"errorCode" : @(error.code),
                       @"domain" : error.domain,
                       @"description" : error.description,
                       @"errorType" : [BTWKNavigationDelegate errorCodeToString:error.code],
                     }];
}

- (void)webView:(WKWebView *)webView
    didFailNavigation:(WKNavigation *)navigation
            withError:(NSError *)error {
  [self onWebResourceError:error];
}

- (void)webView:(WKWebView *)webView
    didFailProvisionalNavigation:(WKNavigation *)navigation
                       withError:(NSError *)error {
  [self onWebResourceError:error];
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
  NSError *contentProcessTerminatedError =
      [[NSError alloc] initWithDomain:WKErrorDomain
                                 code:WKErrorWebContentProcessTerminated
                             userInfo:nil];
  [self onWebResourceError:contentProcessTerminatedError];
}


#pragma mark - bootpay logic
//
- (void) updateBlindViewIfNaverLogin:(WKWebView*)webView :(NSString*)url {
    if ([url hasPrefix:@"https://nid.naver.com"]) {
        if(_topBlindView == nil) { _topBlindView = [[UIView alloc] init]; }
        else { [_topBlindView removeFromSuperview]; }
        [_topBlindView setFrame:CGRectMake(0, 0, webView.frame.size.width, 50)];
        [_topBlindView setBackgroundColor:[UIColor redColor]];
        [webView.superview addSubview:_topBlindView];
          

//        if(_topBlindButton == nil) { _topBlindButton = [UIButton buttonWithType: UIButtonTypeCustom]; }
//        else { [_topBlindButton removeFromSuperview]; }
//        [_topBlindButton setFrame:CGRectMake(webView.frame.size.width - 50, 0, 50, 50)];
//        [_topBlindButton setTitle:@"X" forState: UIControlStateNormal];
//        [_topBlindButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [_topBlindButton addTarget:self action:@selector(closeView:) forControlEvents: UIControlEventTouchUpInside];
//        [webView addSubview:_topBlindButton];
    } else {
        if(_topBlindView != nil) { [_topBlindView removeFromSuperview]; }
        _topBlindView = nil;
        if(_topBlindButton != nil) { [_topBlindButton removeFromSuperview]; }
        _topBlindButton = nil;
    }
}


- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    WKWebView *popupView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, webView.bounds.size.width, webView.bounds.size.height) configuration:configuration];
     
    
    [popupView autoresizingMask];
    popupView.navigationDelegate = self;
    popupView.UIDelegate = self;
    
    [webView.superview addSubview:popupView];
    
    return popupView;
}

- (void)webViewDidClose:(WKWebView *)webView {
    [webView removeFromSuperview];
}


- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *cred = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, cred);
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}


- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
   
   UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
   
   [alertController addAction:[UIAlertAction actionWithTitle:@"??????" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
       completionHandler();
   }]];
   
   [[self  topMostController] presentViewController:alertController animated:true completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
   UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
   
   [alertController addAction:[UIAlertAction actionWithTitle:@"??????" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
       completionHandler(true);
   }]];

   [[self  topMostController] presentViewController:alertController animated:true completion:nil];
}

- (UIViewController*) topMostController
{
   UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;

   while (topController.presentedViewController) {
       topController = topController.presentedViewController;
   }

   return topController;
}

 

-(void) doJavascript:(WKWebView*)webview :(NSString*) script {
    [webview evaluateJavaScript:script completionHandler:nil];
}

- (void) loadUrl:(WKWebView*)webview :(NSString*) urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [webview loadRequest:request];
}

- (void) naverLoginBugFix:(WKWebView*)webView {
    if([_beforeUrl hasPrefix:@"naversearchthirdlogin://"]) {
        NSString* value = [self getQueryStringParameter:_beforeUrl :@"session"];
        if(value != nil && [value length] > 0) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://nid.naver.com/login/scheme.redirect?session=%@", value]];
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
            [webView loadRequest:request];
        }
    }
}

- (NSString*) getQueryStringParameter:(NSString*)url :(NSString*)param {
    NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
    NSArray *urlComponents = [url componentsSeparatedByString:@"&"];
    
    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];

        if([param isEqualToString:key]) {
            return value;
        }
    }
//    startApp
    return @"";
}

- (void) startAppToApp:(NSURL*) url {
    UIApplication *application = [UIApplication sharedApplication];
        
    if (@available(iOS 10.0, *)) {
        [application openURL:url options:@{} completionHandler: ^(BOOL success) {
            if (!success) {
                [self startItunesToInstall:url];
            }
        }];
    } else {
        [application openURL:url];
    }
}

- (void) startItunesToInstall:(NSURL*) url {
    NSString *sUrl = url.absoluteString;
    NSString *itunesUrl = @"";
    
    if([sUrl hasPrefix:@"kfc-bankpay"]) {
        itunesUrl = @"https://apps.apple.com/kr/app/%EB%B1%85%ED%81%AC%ED%8E%98%EC%9D%B4-%EA%B8%88%EC%9C%B5%EA%B8%B0%EA%B4%80-%EA%B3%B5%EB%8F%99-%EA%B3%84%EC%A2%8C%EC%9D%B4%EC%B2%B4-%EA%B2%B0%EC%A0%9C-%EC%A0%9C%EB%A1%9C%ED%8E%98%EC%9D%B4/id398456030";
    } else if([sUrl hasPrefix:@"kfc-ispmobile"]) {
        itunesUrl = @"https://apps.apple.com/kr/app/isp/id369125087";
    } else if([sUrl hasPrefix:@"hdcardappcardansimclick"] || [sUrl hasPrefix:@"smhyundaiansimclick"]) {
        itunesUrl = @"https://apps.apple.com/kr/app/%ED%98%84%EB%8C%80%EC%B9%B4%EB%93%9C/id702653088";
    } else if([sUrl hasPrefix:@"shinhan-sr-ansimclick"] || [sUrl hasPrefix:@"smshinhanansimclick"]) {
        itunesUrl = @"https://apps.apple.com/kr/app/%EC%8B%A0%ED%95%9C%ED%8E%98%EC%9D%B4%ED%8C%90/id572462317";
    } else if([sUrl hasPrefix:@"kb-acp"]) {
        itunesUrl = @"https://apps.apple.com/kr/app/kb-pay/id695436326";
    } else if([sUrl hasPrefix:@"liivbank"]) {
        itunesUrl = @"https://apps.apple.com/kr/app/%EB%A6%AC%EB%B8%8C/id1126232922";
    } else if([sUrl hasPrefix:@"mpocket.online.ansimclick"] || [sUrl hasPrefix:@"ansimclickscard"] || [sUrl hasPrefix:@"ansimclickipcollect"] || [sUrl hasPrefix:@"samsungpay"]  || [sUrl hasPrefix:@"scardcertiapp"]) {
        itunesUrl = @"https://apps.apple.com/kr/app/%EC%82%BC%EC%84%B1%EC%B9%B4%EB%93%9C/id535125356";
    } else if([sUrl hasPrefix:@"lottesmartpay"]) {
        itunesUrl = @"https://apps.apple.com/us/app/%EB%A1%AF%EB%8D%B0%EC%B9%B4%EB%93%9C-%EC%95%B1%EC%B9%B4%EB%93%9C/id688047200";
    } else if([sUrl hasPrefix:@"lotteappcard"]) {
        itunesUrl = @"https://apps.apple.com/kr/app/%EB%94%94%EC%A7%80%EB%A1%9C%EC%B9%B4-%EB%A1%AF%EB%8D%B0%EC%B9%B4%EB%93%9C/id688047200";
    } else if([sUrl hasPrefix:@"newsmartpib"]) {
        itunesUrl = @"https://apps.apple.com/kr/app/%EC%9A%B0%EB%A6%AC-won-%EB%B1%85%ED%82%B9/id1470181651";
    } else if([sUrl hasPrefix:@"com.wooricard.wcard"]) {
        itunesUrl = @"https://apps.apple.com/kr/app/%EC%9A%B0%EB%A6%ACwon%EC%B9%B4%EB%93%9C/id1499598869";
    } else if([sUrl hasPrefix:@"citispay"] || [sUrl hasPrefix:@"citicardappkr"] || [sUrl hasPrefix:@"citimobileapp"]) {
        itunesUrl = @"https://apps.apple.com/kr/app/%EC%94%A8%ED%8B%B0%EB%AA%A8%EB%B0%94%EC%9D%BC/id1179759666";
    } else if([sUrl hasPrefix:@"shinsegaeeasypayment"]) {
        itunesUrl = @"https://apps.apple.com/kr/app/ssgpay/id666237916";
    } else if([sUrl hasPrefix:@"cloudpay"]) {
        itunesUrl = @"https://apps.apple.com/kr/app/%ED%95%98%EB%82%98%EC%B9%B4%EB%93%9C-%EC%9B%90%ED%81%90%ED%8E%98%EC%9D%B4/id847268987";
    } else if([sUrl hasPrefix:@"hanawalletmembers"]) {
        itunesUrl = @"https://apps.apple.com/kr/app/n-wallet/id492190784";
    } else if([sUrl hasPrefix:@"nhappvardansimclick"]) {
        itunesUrl = @"https://apps.apple.com/kr/app/%EC%98%AC%EC%9B%90%ED%8E%98%EC%9D%B4-nh%EC%95%B1%EC%B9%B4%EB%93%9C/id1177889176";
    } else if([sUrl hasPrefix:@"nhallonepayansimclick"] || [sUrl hasPrefix:@"nhappcardansimclick"] || [sUrl hasPrefix:@"nhallonepayansimclick"] || [sUrl hasPrefix:@"nonghyupcardansimclick"]) {
        itunesUrl = @"https://apps.apple.com/kr/app/%EC%98%AC%EC%9B%90%ED%8E%98%EC%9D%B4-nh%EC%95%B1%EC%B9%B4%EB%93%9C/id1177889176";
    } else if([sUrl hasPrefix:@"payco"]) {
        itunesUrl = @"https://apps.apple.com/kr/app/payco/id924292102";
    } else if([sUrl hasPrefix:@"lpayapp"] || [sUrl hasPrefix:@"lmslpay"]) {
        itunesUrl = @"https://apps.apple.com/kr/app/l-point-with-l-pay/id473250588";
    } else if([sUrl hasPrefix:@"naversearchapp"]) {
        itunesUrl = @"https://apps.apple.com/kr/app/%EB%84%A4%EC%9D%B4%EB%B2%84-naver/id393499958";
    } else if([sUrl hasPrefix:@"tauthlink"]) {
        itunesUrl = @"https://apps.apple.com/kr/app/pass-by-skt/id1141258007";
    } else if([sUrl hasPrefix:@"uplusauth"] || [sUrl hasPrefix:@"upluscorporation"]) {
        itunesUrl = @"https://apps.apple.com/kr/app/pass-by-u/id1147394645";
    } else if([sUrl hasPrefix:@"ktauthexternalcall"]) {
        itunesUrl = @"https://apps.apple.com/kr/app/pass-by-kt/id1134371550";
    } else if([sUrl hasPrefix:@"supertoss"]) {
        itunesUrl = @"https://apps.apple.com/kr/app/%ED%86%A0%EC%8A%A4/id839333328";
    } else if([sUrl hasPrefix:@"kakaotalk"]) {
        itunesUrl = @"https://apps.apple.com/kr/app/kakaotalk/id362057947";
    } else if([sUrl hasPrefix:@"chaipayment"]) {
        itunesUrl = @"https://apps.apple.com/kr/app/%EC%B0%A8%EC%9D%B4/id1459979272";
    }
    
    if(itunesUrl.length > 0) {
        NSURL *url = [NSURL URLWithString:itunesUrl];
        [self startAppToApp:url];
    }
}

- (BOOL) isItunesURL:(NSString*) urlString {
    NSRange match = [urlString rangeOfString: @"apple.com"];
    return match.location != NSNotFound;
}

@end
