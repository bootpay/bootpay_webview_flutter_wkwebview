// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "BTDataConverters.h"

#import <Flutter/Flutter.h>

NSURLRequest *_Nullable BTNativeNSURLRequestFromRequestData(BTNSUrlRequestData *data) {
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

extern NSHTTPCookie *_Nullable BTNativeNSHTTPCookieFromCookieData(BTNSHttpCookieData *data) {
NSMutableDictionary<NSHTTPCookiePropertyKey, id> *properties = [NSMutableDictionary dictionary];
for (int i = 0; i < data.propertyKeys.count; i++) {
NSHTTPCookiePropertyKey cookieKey =
        BTNativeNSHTTPCookiePropertyKeyFromEnumData(data.propertyKeys[i]);
if (!cookieKey) {
// Some keys aren't supported on all versions, so this ignores keys
// that require a higher version or are unsupported.
continue;
}
[properties setObject:data.propertyValues[i] forKey:cookieKey];
}
return [NSHTTPCookie cookieWithProperties:properties];
}

NSKeyValueObservingOptions BTNativeNSKeyValueObservingOptionsFromEnumData(
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

NSHTTPCookiePropertyKey _Nullable BTNativeNSHTTPCookiePropertyKeyFromEnumData(
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

extern WKUserScript *BTNativeWKUserScriptFromScriptData(BTWKUserScriptData *data) {
  return [[WKUserScript alloc]
          initWithSource:data.source
           injectionTime:BTNativeWKUserScriptInjectionTimeFromEnumData(data.injectionTime)
        forMainFrameOnly:data.isMainFrameOnly];
}

WKUserScriptInjectionTime BTNativeWKUserScriptInjectionTimeFromEnumData(
        BTWKUserScriptInjectionTimeEnumData *data) {
  switch (data.value) {
    case BTWKUserScriptInjectionTimeEnumAtDocumentStart:
      return WKUserScriptInjectionTimeAtDocumentStart;
    case BTWKUserScriptInjectionTimeEnumAtDocumentEnd:
      return WKUserScriptInjectionTimeAtDocumentEnd;
  }

  return -1;
}

WKAudiovisualMediaTypes BTNativeWKAudiovisualMediaTypeFromEnumData(
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

NSString *_Nullable BTNativeWKWebsiteDataTypeFromEnumData(BTWKWebsiteDataTypeEnumData *data) {
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

BTWKNavigationActionData *BTWKNavigationActionDataFromNativeWKNavigationAction(
        WKNavigationAction *action) {
  return [BTWKNavigationActionData
          makeWithRequest:BTNSUrlRequestDataFromNativeNSURLRequest(action.request)
              targetFrame:BTWKFrameInfoDataFromNativeWKFrameInfo(action.targetFrame)
           navigationType:BTWKNavigationTypeFromNativeWKNavigationType(action.navigationType)];
}

BTNSUrlRequestData *BTNSUrlRequestDataFromNativeNSURLRequest(NSURLRequest *request) {
  return [BTNSUrlRequestData
          makeWithUrl:request.URL.absoluteString == nil ? @"" : request.URL.absoluteString
           httpMethod:request.HTTPMethod
             httpBody:request.HTTPBody
                      ? [FlutterStandardTypedData typedDataWithBytes:request.HTTPBody]
                      : nil
  allHttpHeaderFields:request.allHTTPHeaderFields ? request.allHTTPHeaderFields : @{}];
}

BTWKFrameInfoData *BTWKFrameInfoDataFromNativeWKFrameInfo(WKFrameInfo *info) {
  return [BTWKFrameInfoData
          makeWithIsMainFrame:info.isMainFrame
                      request:BTNSUrlRequestDataFromNativeNSURLRequest(info.request)];
}

BTWKNavigationResponseData *BTWKNavigationResponseDataFromNativeNavigationResponse(
        WKNavigationResponse *response) {
  return [BTWKNavigationResponseData
          makeWithResponse:BTNSHttpUrlResponseDataFromNativeNSURLResponse(response.response)
              forMainFrame:response.forMainFrame];
}

/// Cast the NSURLResponse object to NSHTTPURLResponse.
///
/// NSURLResponse doesn't contain the status code so it must be cast to NSHTTPURLResponse.
/// This cast will always succeed because the NSURLResponse object actually is an instance of
/// NSHTTPURLResponse. See:
/// https://developer.apple.com/documentation/foundation/nsurlresponse#overview
BTNSHttpUrlResponseData *BTNSHttpUrlResponseDataFromNativeNSURLResponse(NSURLResponse *response) {
  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
  return [BTNSHttpUrlResponseData makeWithStatusCode:httpResponse.statusCode];
}

WKNavigationActionPolicy BTNativeWKNavigationActionPolicyFromEnumData(
        BTWKNavigationActionPolicyEnumData *data) {
  switch (data.value) {
    case BTWKNavigationActionPolicyEnumAllow:
      return WKNavigationActionPolicyAllow;
    case BTWKNavigationActionPolicyEnumCancel:
      return WKNavigationActionPolicyCancel;
  }

  return -1;
}

BTNSErrorData *BTNSErrorDataFromNativeNSError(NSError *error) {
  NSMutableDictionary *userInfo;
  if (error.userInfo) {
    userInfo = [NSMutableDictionary dictionary];
    for (NSErrorUserInfoKey key in error.userInfo.allKeys) {
      NSObject *value = error.userInfo[key];
      if ([value isKindOfClass:[NSString class]]) {
        userInfo[key] = value;
      } else {
        userInfo[key] = [NSString stringWithFormat:@"Unsupported Type: %@", value.description];
      }
    }
  }
  return [BTNSErrorData makeWithCode:error.code domain:error.domain userInfo:userInfo];
}

WKNavigationResponsePolicy BTNativeWKNavigationResponsePolicyFromEnum(
        BTWKNavigationResponsePolicyEnum policy) {
  switch (policy) {
    case BTWKNavigationResponsePolicyEnumAllow:
      return WKNavigationResponsePolicyAllow;
    case BTWKNavigationResponsePolicyEnumCancel:
      return WKNavigationResponsePolicyCancel;
  }

  return -1;
}

BTNSKeyValueChangeKeyEnumData *BTNSKeyValueChangeKeyEnumDataFromNativeNSKeyValueChangeKey(
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
  } else {
    return [BTNSKeyValueChangeKeyEnumData makeWithValue:BTNSKeyValueChangeKeyEnumUnknown];
  }

  return nil;
}

BTWKScriptMessageData *BTWKScriptMessageDataFromNativeWKScriptMessage(WKScriptMessage *message) {
  return [BTWKScriptMessageData makeWithName:message.name body:message.body];
}

BTWKNavigationType BTWKNavigationTypeFromNativeWKNavigationType(WKNavigationType type) {
  switch (type) {
    case WKNavigationTypeLinkActivated:
      return BTWKNavigationTypeLinkActivated;
    case WKNavigationTypeFormSubmitted:
      return BTWKNavigationTypeFormResubmitted;
    case WKNavigationTypeBackForward:
      return BTWKNavigationTypeBackForward;
    case WKNavigationTypeReload:
      return BTWKNavigationTypeReload;
    case WKNavigationTypeFormResubmitted:
      return BTWKNavigationTypeFormResubmitted;
    case WKNavigationTypeOther:
      return BTWKNavigationTypeOther;
  }

  return BTWKNavigationTypeUnknown;
}

BTWKSecurityOriginData *BTWKSecurityOriginDataFromNativeWKSecurityOrigin(
        WKSecurityOrigin *origin) {
  return [BTWKSecurityOriginData makeWithHost:origin.host
                                          port:origin.port
                                      protocol:origin.protocol];
}

WKPermissionDecision BTNativeWKPermissionDecisionFromData(BTWKPermissionDecisionData *data) {
  switch (data.value) {
    case BTWKPermissionDecisionDeny:
      return WKPermissionDecisionDeny;
    case BTWKPermissionDecisionGrant:
      return WKPermissionDecisionGrant;
    case BTWKPermissionDecisionPrompt:
      return WKPermissionDecisionPrompt;
  }

  return -1;
}

BTWKMediaCaptureTypeData *BTWKMediaCaptureTypeDataFromNativeWKMediaCaptureType(
        WKMediaCaptureType type) {
  switch (type) {
    case WKMediaCaptureTypeCamera:
      return [BTWKMediaCaptureTypeData makeWithValue:BTWKMediaCaptureTypeCamera];
    case WKMediaCaptureTypeMicrophone:
      return [BTWKMediaCaptureTypeData makeWithValue:BTWKMediaCaptureTypeMicrophone];
    case WKMediaCaptureTypeCameraAndMicrophone:
      return [BTWKMediaCaptureTypeData makeWithValue:BTWKMediaCaptureTypeCameraAndMicrophone];
    default:
      return [BTWKMediaCaptureTypeData makeWithValue:BTWKMediaCaptureTypeUnknown];
  }

  return nil;
}

NSURLSessionAuthChallengeDisposition
BTNativeNSURLSessionAuthChallengeDispositionFromBTNSUrlSessionAuthChallengeDisposition(
        BTNSUrlSessionAuthChallengeDisposition value) {
  switch (value) {
    case BTNSUrlSessionAuthChallengeDispositionUseCredential:
      return NSURLSessionAuthChallengeUseCredential;
    case BTNSUrlSessionAuthChallengeDispositionPerformDefaultHandling:
      return NSURLSessionAuthChallengePerformDefaultHandling;
    case BTNSUrlSessionAuthChallengeDispositionCancelAuthenticationChallenge:
      return NSURLSessionAuthChallengeCancelAuthenticationChallenge;
    case BTNSUrlSessionAuthChallengeDispositionRejectProtectionSpace:
      return NSURLSessionAuthChallengeRejectProtectionSpace;
  }

  return -1;
}

NSURLCredentialPersistence BTNativeNSURLCredentialPersistenceFromBTNSUrlCredentialPersistence(
        BTNSUrlCredentialPersistence value) {
  switch (value) {
    case BTNSUrlCredentialPersistenceNone:
      return NSURLCredentialPersistenceNone;
    case BTNSUrlCredentialPersistenceSession:
      return NSURLCredentialPersistenceForSession;
    case BTNSUrlCredentialPersistencePermanent:
      return NSURLCredentialPersistencePermanent;
    case BTNSUrlCredentialPersistenceSynchronizable:
      return NSURLCredentialPersistenceSynchronizable;
  }

  return -1;
}
