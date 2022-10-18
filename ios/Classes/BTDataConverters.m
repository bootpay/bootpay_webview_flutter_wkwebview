// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "BTDataConverters.h"

#import <Flutter/Flutter.h>

NSURLRequest *_Nullable BTNSURLRequestFromRequestData(BTNSUrlRequestData *data) {
  NSURL *url = [NSURL URLWithString:data.url];
  if (!url) {
    return nil;
  }

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  if (!request) {
    return nil;
  }

  if (data.httpMethod) {
    [request setHTTPMethod:data.httpMethod];
  }
  if (data.httpBody) {
    [request setHTTPBody:data.httpBody.data];
  }
  [request setAllHTTPHeaderFields:data.allHttpHeaderFields];

  return request;
}

extern NSHTTPCookie *_Nullable BTNSHTTPCookieFromCookieData(BTNSHttpCookieData *data) {
  NSMutableDictionary<NSHTTPCookiePropertyKey, id> *properties = [NSMutableDictionary dictionary];
  for (int i = 0; i < data.propertyKeys.count; i++) {
    NSHTTPCookiePropertyKey cookieKey =
        BTNSHTTPCookiePropertyKeyFromEnumData(data.propertyKeys[i]);
    if (!cookieKey) {
      // Some keys aren't supported on all versions, so this ignores keys
      // that require a higher version or are unsupported.
      continue;
    }
    [properties setObject:data.propertyValues[i] forKey:cookieKey];
  }
  return [NSHTTPCookie cookieWithProperties:properties];
}

NSKeyValueObservingOptions BTNSKeyValueObservingOptionsFromEnumData(
    BTNSKeyValueObservingOptionsEnumData *data) {
  switch (data.value) {
    case BTNSKeyValueObservingOptionsEnumNewValue:
      return NSKeyValueObservingOptionNew;
    case BTNSKeyValueObservingOptionsEnumOldValue:
      return NSKeyValueObservingOptionOld;
    case BTNSKeyValueObservingOptionsEnumInitialValue:
      return NSKeyValueObservingOptionInitial;
    case BTNSKeyValueObservingOptionsEnumPriorNotification:
      return NSKeyValueObservingOptionPrior;
  }

  return -1;
}

NSHTTPCookiePropertyKey _Nullable BTNSHTTPCookiePropertyKeyFromEnumData(
    BTNSHttpCookiePropertyKeyEnumData *data) {
  switch (data.value) {
    case BTNSHttpCookiePropertyKeyEnumComment:
      return NSHTTPCookieComment;
    case BTNSHttpCookiePropertyKeyEnumCommentUrl:
      return NSHTTPCookieCommentURL;
    case BTNSHttpCookiePropertyKeyEnumDiscard:
      return NSHTTPCookieDiscard;
    case BTNSHttpCookiePropertyKeyEnumDomain:
      return NSHTTPCookieDomain;
    case BTNSHttpCookiePropertyKeyEnumExpires:
      return NSHTTPCookieExpires;
    case BTNSHttpCookiePropertyKeyEnumMaximumAge:
      return NSHTTPCookieMaximumAge;
    case BTNSHttpCookiePropertyKeyEnumName:
      return NSHTTPCookieName;
    case BTNSHttpCookiePropertyKeyEnumOriginUrl:
      return NSHTTPCookieOriginURL;
    case BTNSHttpCookiePropertyKeyEnumPath:
      return NSHTTPCookiePath;
    case BTNSHttpCookiePropertyKeyEnumPort:
      return NSHTTPCookiePort;
    case BTNSHttpCookiePropertyKeyEnumSameSitePolicy:
      if (@available(iOS 13.0, *)) {
        return NSHTTPCookieSameSitePolicy;
      } else {
        return nil;
      }
    case BTNSHttpCookiePropertyKeyEnumSecure:
      return NSHTTPCookieSecure;
    case BTNSHttpCookiePropertyKeyEnumValue:
      return NSHTTPCookieValue;
    case BTNSHttpCookiePropertyKeyEnumVersion:
      return NSHTTPCookieVersion;
  }

  return nil;
}

extern WKUserScript *BTWKUserScriptFromScriptData(BTWKUserScriptData *data) {
  return [[WKUserScript alloc]
        initWithSource:data.source
         injectionTime:BTWKUserScriptInjectionTimeFromEnumData(data.injectionTime)
      forMainFrameOnly:data.isMainFrameOnly.boolValue];
}

WKUserScriptInjectionTime BTWKUserScriptInjectionTimeFromEnumData(
    BTWKUserScriptInjectionTimeEnumData *data) {
  switch (data.value) {
    case BTWKUserScriptInjectionTimeEnumAtDocumentStart:
      return WKUserScriptInjectionTimeAtDocumentStart;
    case BTWKUserScriptInjectionTimeEnumAtDocumentEnd:
      return WKUserScriptInjectionTimeAtDocumentEnd;
  }

  return -1;
}

API_AVAILABLE(ios(10.0))
WKAudiovisualMediaTypes BTWKAudiovisualMediaTypeFromEnumData(
    BTWKAudiovisualMediaTypeEnumData *data) {
  switch (data.value) {
    case BTWKAudiovisualMediaTypeEnumNone:
      return WKAudiovisualMediaTypeNone;
    case BTWKAudiovisualMediaTypeEnumAudio:
      return WKAudiovisualMediaTypeAudio;
    case BTWKAudiovisualMediaTypeEnumVideo:
      return WKAudiovisualMediaTypeVideo;
    case BTWKAudiovisualMediaTypeEnumAll:
      return WKAudiovisualMediaTypeAll;
  }

  return -1;
}

NSString *_Nullable BTWKWebsiteDataTypeFromEnumData(BTWKWebsiteDataTypeEnumData *data) {
  switch (data.value) {
    case BTWKWebsiteDataTypeEnumCookies:
      return WKWebsiteDataTypeCookies;
    case BTWKWebsiteDataTypeEnumMemoryCache:
      return WKWebsiteDataTypeMemoryCache;
    case BTWKWebsiteDataTypeEnumDiskCache:
      return WKWebsiteDataTypeDiskCache;
    case BTWKWebsiteDataTypeEnumOfflineWebApplicationCache:
      return WKWebsiteDataTypeOfflineWebApplicationCache;
    case BTWKWebsiteDataTypeEnumLocalStorage:
      return WKWebsiteDataTypeLocalStorage;
    case BTWKWebsiteDataTypeEnumSessionStorage:
      return WKWebsiteDataTypeSessionStorage;
    case BTWKWebsiteDataTypeEnumWebSQLDatabases:
      return WKWebsiteDataTypeWebSQLDatabases;
    case BTWKWebsiteDataTypeEnumIndexedDBDatabases:
      return WKWebsiteDataTypeIndexedDBDatabases;
  }

  return nil;
}

BTWKNavigationActionData *BTWKNavigationActionDataFromNavigationAction(
    WKNavigationAction *action) {
  return [BTWKNavigationActionData
      makeWithRequest:BTNSUrlRequestDataFromNSURLRequest(action.request)
          targetFrame:BTWKFrameInfoDataFromWKFrameInfo(action.targetFrame)];
}

BTNSUrlRequestData *BTNSUrlRequestDataFromNSURLRequest(NSURLRequest *request) {
  return [BTNSUrlRequestData
              makeWithUrl:request.URL.absoluteString
               httpMethod:request.HTTPMethod
                 httpBody:request.HTTPBody
                              ? [FlutterStandardTypedData typedDataWithBytes:request.HTTPBody]
                              : nil
      allHttpHeaderFields:request.allHTTPHeaderFields ? request.allHTTPHeaderFields : @{}];
}

BTWKFrameInfoData *BTWKFrameInfoDataFromWKFrameInfo(WKFrameInfo *info) {
  return [BTWKFrameInfoData makeWithIsMainFrame:@(info.isMainFrame)];
}

WKNavigationActionPolicy BTWKNavigationActionPolicyFromEnumData(
    BTWKNavigationActionPolicyEnumData *data) {
  switch (data.value) {
    case BTWKNavigationActionPolicyEnumAllow:
      return WKNavigationActionPolicyAllow;
    case BTWKNavigationActionPolicyEnumCancel:
      return WKNavigationActionPolicyCancel;
  }

  return -1;
}

BTNSErrorData *BTNSErrorDataFromNSError(NSError *error) {
  return [BTNSErrorData makeWithCode:@(error.code)
                               domain:error.domain
                 localizedDescription:error.localizedDescription];
}

BTNSKeyValueChangeKeyEnumData *BTNSKeyValueChangeKeyEnumDataFromNSKeyValueChangeKey(
    NSKeyValueChangeKey key) {
  if ([key isEqualToString:NSKeyValueChangeIndexesKey]) {
    return [BTNSKeyValueChangeKeyEnumData makeWithValue:BTNSKeyValueChangeKeyEnumIndexes];
  } else if ([key isEqualToString:NSKeyValueChangeKindKey]) {
    return [BTNSKeyValueChangeKeyEnumData makeWithValue:BTNSKeyValueChangeKeyEnumKind];
  } else if ([key isEqualToString:NSKeyValueChangeNewKey]) {
    return [BTNSKeyValueChangeKeyEnumData makeWithValue:BTNSKeyValueChangeKeyEnumNewValue];
  } else if ([key isEqualToString:NSKeyValueChangeNotificationIsPriorKey]) {
    return [BTNSKeyValueChangeKeyEnumData
        makeWithValue:BTNSKeyValueChangeKeyEnumNotificationIsPrior];
  } else if ([key isEqualToString:NSKeyValueChangeOldKey]) {
    return [BTNSKeyValueChangeKeyEnumData makeWithValue:BTNSKeyValueChangeKeyEnumOldValue];
  }

  return nil;
}

BTWKScriptMessageData *BTWKScriptMessageDataFromWKScriptMessage(WKScriptMessage *message) {
  return [BTWKScriptMessageData makeWithName:message.name body:message.body];
}
