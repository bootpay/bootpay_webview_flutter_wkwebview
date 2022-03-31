// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:bootpay_webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

/// Handles all cookie operations for the current platform.
class WKWebViewCookieManager extends WebViewCookieManagerPlatform {
  @override
  Future<bool> clearCookies() => MethodChannelWebViewPlatform.clearCookies();

  @override
  Future<void> setCookie(WebViewCookie cookie) {
    if (!_isValidPath(cookie.path)) {
      throw ArgumentError(
          'The path property for the provided cookie was not given a legal value.');
    }
    return MethodChannelWebViewPlatform.setCookie(cookie);
  }

  bool _isValidPath(String path) {
    // Permitted ranges based on RFC6265bis: https://datatracker.ietf.org/doc/html/draft-ietf-httpbis-rfc6265bis-02#section-4.1.1
    for (final int char in path.codeUnits) {
      if ((char < 0x20 || char > 0x3A) && (char < 0x3C || char > 0x7E)) {
        return false;
      }
    }
    return true;
  }
}
