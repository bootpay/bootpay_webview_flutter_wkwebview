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
        
//        NSLog(@"popup naver biz");
//        webView.contain


        if(_topBlindButton == nil) { _topBlindButton = [UIButton buttonWithType: UIButtonTypeCustom]; }
        else { [_topBlindButton removeFromSuperview]; }
        [_topBlindButton setFrame:CGRectMake(webView.frame.size.width - 50, 0, 50, 50)];
        [_topBlindButton setTitle:@"X" forState: UIControlStateNormal];
        [_topBlindButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_topBlindButton addTarget:self action:@selector(closeView:) forControlEvents: UIControlEventTouchUpInside];
        [webView addSubview:_topBlindButton];
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
   
   [alertController addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
       completionHandler();
   }]];
   
   [[self  topMostController] presentViewController:alertController animated:true completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
   UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
   
   [alertController addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
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
    
    return @"";
}

- (void) startAppToApp:(NSURL*) url {
    UIApplication *application = [UIApplication sharedApplication];
    
    if (@available(iOS 10.0, *)) {
        [application openURL:url options:@{} completionHandler:nil];
    } else {
        [application openURL:url];
    }
}

- (BOOL) isItunesURL:(NSString*) urlString {
    NSRange match = [urlString rangeOfString: @"itunes.apple.com"];
    return match.location != NSNotFound;
}

@end
