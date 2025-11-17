// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:bootpay_webview_flutter_platform_interface/bootpay_webview_flutter_platform_interface.dart';

import 'webkit_webview_controller.dart';
import 'webkit_webview_cookie_manager.dart';

/// Implementation of [WebViewPlatform] using the WebKit API.
class BTWebKitWebViewPlatform extends WebViewPlatform {
  /// Registers this class as the default instance of [WebViewPlatform].
  static void registerWith() {
    WebViewPlatform.instance = BTWebKitWebViewPlatform();
  }

  @override
  BootpayWebKitWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    return BootpayWebKitWebViewController(params);
  }

  @override
  BootpayWebKitNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) {
    return BootpayWebKitNavigationDelegate(params);
  }

  @override
  BootpayWebKitWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) {
    return BootpayWebKitWebViewWidget(params);
  }

  @override
  BootpayWebKitWebViewCookieManager createPlatformCookieManager(
    PlatformWebViewCookieManagerCreationParams params,
  ) {
    return BootpayWebKitWebViewCookieManager(params);
  }
}
