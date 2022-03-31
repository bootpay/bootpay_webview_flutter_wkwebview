// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bootpay_webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:bootpay_webview_ios/src/wkwebview_cookie_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel cookieChannel =
      MethodChannel('bootpay.co.kr/cookie_manager');
  final List<MethodCall> log = <MethodCall>[];

  cookieChannel.setMockMethodCallHandler((MethodCall methodCall) async {
    log.add(methodCall);

    if (methodCall.method == 'clearCookies') {
      return true;
    }

    // Return null explicitly instead of relying on the implicit null
    // returned by the method channel if no return statement is specified.
    return null;
  });

  tearDown(() {
    log.clear();
  });

  test('clearCookies should call `clearCookies` on the method channel',
      () async {
    await WKWebViewCookieManager().clearCookies();
    expect(
      log,
      <Matcher>[
        isMethodCall(
          'clearCookies',
          arguments: null,
        ),
      ],
    );
  });

  test('setCookie should call `setCookie` on the method channel', () async {
    await WKWebViewCookieManager().setCookie(
      const WebViewCookie(name: 'foo', value: 'bar', domain: 'flutter.dev'),
    );
    expect(
      log,
      <Matcher>[
        isMethodCall(
          'setCookie',
          arguments: <String, String>{
            'name': 'foo',
            'value': 'bar',
            'domain': 'flutter.dev',
            'path': '/',
          },
        ),
      ],
    );
  });
}
