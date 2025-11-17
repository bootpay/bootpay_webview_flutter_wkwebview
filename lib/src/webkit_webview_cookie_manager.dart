// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:bootpay_webview_flutter_platform_interface/bootpay_webview_flutter_platform_interface.dart';

import 'common/web_kit.g.dart';
import 'webkit_proxy.dart';

/// Object specifying creation parameters for a [BootpayWebKitWebViewCookieManager].
class BootpayWebKitWebViewCookieManagerCreationParams
    extends PlatformWebViewCookieManagerCreationParams {
  /// Constructs a [BootpayWebKitWebViewCookieManagerCreationParams].
  BootpayWebKitWebViewCookieManagerCreationParams({WebKitProxy? webKitProxy})
    : webKitProxy = webKitProxy ?? const WebKitProxy();

  /// Constructs a [BootpayWebKitWebViewCookieManagerCreationParams] using a
  /// [PlatformWebViewCookieManagerCreationParams].
  BootpayWebKitWebViewCookieManagerCreationParams.fromPlatformWebViewCookieManagerCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebViewCookieManagerCreationParams params, {
    @visibleForTesting WebKitProxy? webKitProxy,
  }) : this(webKitProxy: webKitProxy);

  /// Handles constructing objects and calling static methods for the WebKit
  /// native library.
  @visibleForTesting
  final WebKitProxy webKitProxy;

  /// Manages stored data for [WKWebView]s.
  late final WKWebsiteDataStore _websiteDataStore = webKitProxy
      .defaultDataStoreWKWebsiteDataStore();
}

/// An implementation of [PlatformWebViewCookieManager] with the WebKit api.
class BootpayWebKitWebViewCookieManager extends PlatformWebViewCookieManager {
  /// Constructs a [BootpayWebKitWebViewCookieManager].
  BootpayWebKitWebViewCookieManager(PlatformWebViewCookieManagerCreationParams params)
    : super.implementation(
        params is BootpayWebKitWebViewCookieManagerCreationParams
            ? params
            : BootpayWebKitWebViewCookieManagerCreationParams.fromPlatformWebViewCookieManagerCreationParams(
                params,
              ),
      );

  BootpayWebKitWebViewCookieManagerCreationParams get _webkitParams =>
      params as BootpayWebKitWebViewCookieManagerCreationParams;

  @override
  Future<bool> clearCookies() {
    return _webkitParams._websiteDataStore.removeDataOfTypes(<WebsiteDataType>[
      WebsiteDataType.cookies,
    ], 0.0);
  }

  @override
  Future<void> setCookie(WebViewCookie cookie) {
    if (!_isValidPath(cookie.path)) {
      throw ArgumentError(
        'The path property for the provided cookie was not given a legal value.',
      );
    }

    return _webkitParams._websiteDataStore.httpCookieStore.setCookie(
      _webkitParams.webKitProxy.newHTTPCookie(
        properties: <HttpCookiePropertyKey, Object>{
          HttpCookiePropertyKey.name: cookie.name,
          HttpCookiePropertyKey.value: cookie.value,
          HttpCookiePropertyKey.domain: cookie.domain,
          HttpCookiePropertyKey.path: cookie.path,
        },
      ),
    );
  }

  bool _isValidPath(String path) {
    // Permitted ranges based on RFC6265bis: https://datatracker.ietf.org/doc/html/draft-ietf-httpbis-rfc6265bis-02#section-4.1.1
    return !path.codeUnits.any((int char) {
      return (char < 0x20 || char > 0x3A) && (char < 0x3C || char > 0x7E);
    });
  }
}

// Type aliases for backward compatibility with tests
typedef WebKitWebViewCookieManagerCreationParams = BootpayWebKitWebViewCookieManagerCreationParams;
typedef WebKitWebViewCookieManager = BootpayWebKitWebViewCookieManager;
