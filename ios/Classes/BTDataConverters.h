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
extern NSURLRequest *_Nullable BTNSURLRequestFromRequestData(BTNSUrlRequestData *data);

/**
 * Converts an BTNSHttpCookieData to an NSHTTPCookie.
 *
 * @param data The data object containing information to create an NSHTTPCookie.
 *
 * @return An NSHTTPCookie or nil if data could not be converted.
 */
extern NSHTTPCookie *_Nullable BTNSHTTPCookieFromCookieData(BTNSHttpCookieData *data);

/**
 * Converts an BTNSKeyValueObservingOptionsEnumData to an NSKeyValueObservingOptions.
 *
 * @param data The data object containing information to create an NSKeyValueObservingOptions.
 *
 * @return An NSKeyValueObservingOptions or -1 if data could not be converted.
 */
extern NSKeyValueObservingOptions BTNSKeyValueObservingOptionsFromEnumData(
    BTNSKeyValueObservingOptionsEnumData *data);

/**
 * Converts an BTNSHTTPCookiePropertyKeyEnumData to an NSHTTPCookiePropertyKey.
 *
 * @param data The data object containing information to create an NSHTTPCookiePropertyKey.
 *
 * @return An NSHttpCookiePropertyKey or nil if data could not be converted.
 */
extern NSHTTPCookiePropertyKey _Nullable BTNSHTTPCookiePropertyKeyFromEnumData(
    BTNSHttpCookiePropertyKeyEnumData *data);

/**
 * Converts a WKUserScriptData to a WKUserScript.
 *
 * @param data The data object containing information to create a WKUserScript.
 *
 * @return A WKUserScript or nil if data could not be converted.
 */
extern WKUserScript *BTWKUserScriptFromScriptData(BTWKUserScriptData *data);

/**
 * Converts an BTWKUserScriptInjectionTimeEnumData to a WKUserScriptInjectionTime.
 *
 * @param data The data object containing information to create a WKUserScriptInjectionTime.
 *
 * @return A WKUserScriptInjectionTime or -1 if data could not be converted.
 */
extern WKUserScriptInjectionTime BTWKUserScriptInjectionTimeFromEnumData(
    BTWKUserScriptInjectionTimeEnumData *data);

/**
 * Converts an BTWKAudiovisualMediaTypeEnumData to a WKAudiovisualMediaTypes.
 *
 * @param data The data object containing information to create a WKAudiovisualMediaTypes.
 *
 * @return A WKAudiovisualMediaType or -1 if data could not be converted.
 */
API_AVAILABLE(ios(10.0))
extern WKAudiovisualMediaTypes BTWKAudiovisualMediaTypeFromEnumData(
    BTWKAudiovisualMediaTypeEnumData *data);

/**
 * Converts an BTWKWebsiteDataTypeEnumData to a WKWebsiteDataType.
 *
 * @param data The data object containing information to create a WKWebsiteDataType.
 *
 * @return A WKWebsiteDataType or nil if data could not be converted.
 */
extern NSString *_Nullable BTWKWebsiteDataTypeFromEnumData(BTWKWebsiteDataTypeEnumData *data);

/**
 * Converts a WKNavigationAction to an BTWKNavigationActionData.
 *
 * @param action The object containing information to create a WKNavigationActionData.
 *
 * @return A BTWKNavigationActionData.
 */
extern BTWKNavigationActionData *BTWKNavigationActionDataFromNavigationAction(
    WKNavigationAction *action);

/**
 * Converts a NSURLRequest to an BTNSUrlRequestData.
 *
 * @param request The object containing information to create a WKNavigationActionData.
 *
 * @return A BTNSUrlRequestData.
 */
extern BTNSUrlRequestData *BTNSUrlRequestDataFromNSURLRequest(NSURLRequest *request);

/**
 * Converts a WKFrameInfo to an BTWKFrameInfoData.
 *
 * @param info The object containing information to create a BTWKFrameInfoData.
 *
 * @return A BTWKFrameInfoData.
 */
extern BTWKFrameInfoData *BTWKFrameInfoDataFromWKFrameInfo(WKFrameInfo *info);

/**
 * Converts an BTWKNavigationActionPolicyEnumData to a WKNavigationActionPolicy.
 *
 * @param data The data object containing information to create a WKNavigationActionPolicy.
 *
 * @return A WKNavigationActionPolicy or -1 if data could not be converted.
 */
extern WKNavigationActionPolicy BTWKNavigationActionPolicyFromEnumData(
    BTWKNavigationActionPolicyEnumData *data);

/**
 * Converts a NSError to an BTNSErrorData.
 *
 * @param error The object containing information to create a BTNSErrorData.
 *
 * @return A BTNSErrorData.
 */
extern BTNSErrorData *BTNSErrorDataFromNSError(NSError *error);

/**
 * Converts an NSKeyValueChangeKey to a BTNSKeyValueChangeKeyEnumData.
 *
 * @param key The data object containing information to create a BTNSKeyValueChangeKeyEnumData.
 *
 * @return A BTNSKeyValueChangeKeyEnumData or nil if data could not be converted.
 */
extern BTNSKeyValueChangeKeyEnumData *BTNSKeyValueChangeKeyEnumDataFromNSKeyValueChangeKey(
    NSKeyValueChangeKey key);

/**
 * Converts a WKScriptMessage to an BTWKScriptMessageData.
 *
 * @param message The object containing information to create a BTWKScriptMessageData.
 *
 * @return A BTWKScriptMessageData.
 */
extern BTWKScriptMessageData *BTWKScriptMessageDataFromWKScriptMessage(WKScriptMessage *message);
/**
 * Converts a WKNavigationType to an FWFWKNavigationType.
 *
 * @param type The object containing information to create a FWFWKNavigationType
 *
 * @return A FWFWKNavigationType.
 */

extern BTWKNavigationType BTWKNavigationTypeFromWKNavigationType(WKNavigationType type);

NS_ASSUME_NONNULL_END
