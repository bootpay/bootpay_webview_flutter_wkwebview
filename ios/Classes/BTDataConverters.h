// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "BTGeneratedWebKitApis.h"

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Converts an BTNSUrlRequestData to an NSURLRequest.
 *
 * @param data The data object containing information to create an NSURLRequest.
 *
 * @return An NSURLRequest or nil if data could not be converted.
 */
extern NSURLRequest *_Nullable BTNativeNSURLRequestFromRequestData(BTNSUrlRequestData *data);

/**
 * Converts an BTNSHttpCookieData to an NSHTTPCookie.
 *
 * @param data The data object containing information to create an NSHTTPCookie.
 *
 * @return An NSHTTPCookie or nil if data could not be converted.
 */
extern NSHTTPCookie *_Nullable BTNativeNSHTTPCookieFromCookieData(BTNSHttpCookieData *data);

/**
 * Converts an BTNSKeyValueObservingOptionsEnumData to an NSKeyValueObservingOptions.
 *
 * @param data The data object containing information to create an NSKeyValueObservingOptions.
 *
 * @return An NSKeyValueObservingOptions or -1 if data could not be converted.
 */
extern NSKeyValueObservingOptions BTNativeNSKeyValueObservingOptionsFromEnumData(
    BTNSKeyValueObservingOptionsEnumData *data);

/**
 * Converts an BTNSHTTPCookiePropertyKeyEnumData to an NSHTTPCookiePropertyKey.
 *
 * @param data The data object containing information to create an NSHTTPCookiePropertyKey.
 *
 * @return An NSHttpCookiePropertyKey or nil if data could not be converted.
 */
extern NSHTTPCookiePropertyKey _Nullable BTNativeNSHTTPCookiePropertyKeyFromEnumData(
    BTNSHttpCookiePropertyKeyEnumData *data);

/**
 * Converts a WKUserScriptData to a WKUserScript.
 *
 * @param data The data object containing information to create a WKUserScript.
 *
 * @return A WKUserScript or nil if data could not be converted.
 */
extern WKUserScript *BTNativeWKUserScriptFromScriptData(BTWKUserScriptData *data);

/**
 * Converts an BTWKUserScriptInjectionTimeEnumData to a WKUserScriptInjectionTime.
 *
 * @param data The data object containing information to create a WKUserScriptInjectionTime.
 *
 * @return A WKUserScriptInjectionTime or -1 if data could not be converted.
 */
extern WKUserScriptInjectionTime BTNativeWKUserScriptInjectionTimeFromEnumData(
    BTWKUserScriptInjectionTimeEnumData *data);

/**
 * Converts an BTWKAudiovisualMediaTypeEnumData to a WKAudiovisualMediaTypes.
 *
 * @param data The data object containing information to create a WKAudiovisualMediaTypes.
 *
 * @return A WKAudiovisualMediaType or -1 if data could not be converted.
 */
extern WKAudiovisualMediaTypes BTNativeWKAudiovisualMediaTypeFromEnumData(
    BTWKAudiovisualMediaTypeEnumData *data);

/**
 * Converts an BTWKWebsiteDataTypeEnumData to a WKWebsiteDataType.
 *
 * @param data The data object containing information to create a WKWebsiteDataType.
 *
 * @return A WKWebsiteDataType or nil if data could not be converted.
 */
extern NSString *_Nullable BTNativeWKWebsiteDataTypeFromEnumData(
    BTWKWebsiteDataTypeEnumData *data);

/**
 * Converts a WKNavigationAction to an BTWKNavigationActionData.
 *
 * @param action The object containing information to create a WKNavigationActionData.
 *
 * @return A BTWKNavigationActionData.
 */
extern BTWKNavigationActionData *BTWKNavigationActionDataFromNativeWKNavigationAction(
    WKNavigationAction *action);

/**
 * Converts a NSURLRequest to an BTNSUrlRequestData.
 *
 * @param request The object containing information to create a WKNavigationActionData.
 *
 * @return A BTNSUrlRequestData.
 */
extern BTNSUrlRequestData *BTNSUrlRequestDataFromNativeNSURLRequest(NSURLRequest *request);

/**
 * Converts a WKFrameInfo to an BTWKFrameInfoData.
 *
 * @param info The object containing information to create a BTWKFrameInfoData.
 *
 * @return A BTWKFrameInfoData.
 */
extern BTWKFrameInfoData *BTWKFrameInfoDataFromNativeWKFrameInfo(WKFrameInfo *info);

/**
 * Converts an BTWKNavigationActionPolicyEnumData to a WKNavigationActionPolicy.
 *
 * @param data The data object containing information to create a WKNavigationActionPolicy.
 *
 * @return A WKNavigationActionPolicy or -1 if data could not be converted.
 */
extern WKNavigationActionPolicy BTNativeWKNavigationActionPolicyFromEnumData(
    BTWKNavigationActionPolicyEnumData *data);

/**
 * Converts a NSError to an BTNSErrorData.
 *
 * @param error The object containing information to create a BTNSErrorData.
 *
 * @return A BTNSErrorData.
 */
extern BTNSErrorData *BTNSErrorDataFromNativeNSError(NSError *error);

/**
 * Converts an NSKeyValueChangeKey to a BTNSKeyValueChangeKeyEnumData.
 *
 * @param key The data object containing information to create a BTNSKeyValueChangeKeyEnumData.
 *
 * @return A BTNSKeyValueChangeKeyEnumData or nil if data could not be converted.
 */
extern BTNSKeyValueChangeKeyEnumData *BTNSKeyValueChangeKeyEnumDataFromNativeNSKeyValueChangeKey(
    NSKeyValueChangeKey key);

/**
 * Converts a WKScriptMessage to an BTWKScriptMessageData.
 *
 * @param message The object containing information to create a BTWKScriptMessageData.
 *
 * @return A BTWKScriptMessageData.
 */
extern BTWKScriptMessageData *BTWKScriptMessageDataFromNativeWKScriptMessage(
    WKScriptMessage *message);

/**
 * Converts a WKNavigationType to an BTWKNavigationType.
 *
 * @param type The object containing information to create a BTWKNavigationType
 *
 * @return A BTWKNavigationType.
 */
extern BTWKNavigationType BTWKNavigationTypeFromNativeWKNavigationType(WKNavigationType type);

/**
 * Converts a WKSecurityOrigin to an BTWKSecurityOriginData.
 *
 * @param origin The object containing information to create an BTWKSecurityOriginData.
 *
 * @return An BTWKSecurityOriginData.
 */
extern BTWKSecurityOriginData *BTWKSecurityOriginDataFromNativeWKSecurityOrigin(
    WKSecurityOrigin *origin);

/**
 * Converts an BTWKPermissionDecisionData to a WKPermissionDecision.
 *
 * @param data The data object containing information to create a WKPermissionDecision.
 *
 * @return A WKPermissionDecision or -1 if data could not be converted.
 */
API_AVAILABLE(ios(15.0))
extern WKPermissionDecision BTNativeWKPermissionDecisionFromData(
    BTWKPermissionDecisionData *data);

/**
 * Converts an WKMediaCaptureType to a BTWKMediaCaptureTypeData.
 *
 * @param type The data object containing information to create a BTWKMediaCaptureTypeData.
 *
 * @return A BTWKMediaCaptureTypeData or nil if data could not be converted.
 */
API_AVAILABLE(ios(15.0))
extern BTWKMediaCaptureTypeData *BTWKMediaCaptureTypeDataFromNativeWKMediaCaptureType(
    WKMediaCaptureType type);

NS_ASSUME_NONNULL_END
