// Copyright 2024 Bootpay
// WebView WarmUp API for pre-initializing WKWebView process

import 'dart:io';
import 'package:flutter/services.dart';

/// WebView WarmUp Manager for iOS/macOS
///
/// Pre-warms the WKWebView by creating an invisible instance in the background.
/// This initializes WebKit's internal processes (GPU, Networking, WebContent)
/// before the actual WebView is displayed, significantly reducing first load time.
///
/// ## Benefits
/// - GPU process initialization: 1-2 seconds saved
/// - Networking process initialization: 1-2 seconds saved
/// - WebContent process initialization: 1-3 seconds saved
/// - **Total: 3-7 seconds faster first payment screen loading**
///
/// ## Usage
///
/// Call `warmUp()` as early as possible in your app lifecycle:
///
/// ```dart
/// void main() {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   // Pre-warm WebView on iOS
///   BootpayWarmUp.warmUp();
///
///   runApp(MyApp());
/// }
/// ```
///
/// Or in your app's `initState`:
///
/// ```dart
/// @override
/// void initState() {
///   super.initState();
///   BootpayWarmUp.warmUp();
/// }
/// ```
///
/// ## Memory Management
///
/// Call `releaseWarmUp()` when receiving memory warnings:
///
/// ```dart
/// @override
/// void didReceiveMemoryWarning() {
///   BootpayWarmUp.releaseWarmUp();
/// }
/// ```
///
/// ## Platform Support
///
/// - **iOS**: Fully supported
/// - **macOS**: Fully supported
/// - **Android**: No-op (Android WebView doesn't benefit from this approach)
/// - **Web**: No-op
class BootpayWarmUp {
  BootpayWarmUp._();

  static const MethodChannel _channel =
      MethodChannel('kr.co.bootpay/webview_warmup');

  static bool _isWarmedUp = false;

  /// Whether the WebView has been warmed up
  static bool get isWarmedUp => _isWarmedUp;

  /// Pre-warms the WebView by creating an invisible instance
  ///
  /// This method:
  /// 1. Creates a WKWebView with 1x1 frame
  /// 2. Loads HTML with Canvas rendering + fetch to trigger all processes
  /// 3. Keeps the WebView in memory for process reuse
  ///
  /// The shared ProcessPool ensures all subsequent WebView instances
  /// benefit from the pre-warmed processes.
  ///
  /// [delay] - Delay before starting warm-up (seconds). Default 0.1.
  ///           Increase to 0.5~1.0 if UI becomes sluggish.
  ///
  /// **Note**: This is a no-op on platforms other than iOS/macOS.
  ///
  /// Returns `true` if warm-up was initiated successfully.
  ///
  /// ```dart
  /// BootpayWarmUp.warmUp();           // Default 0.1 second delay
  /// BootpayWarmUp.warmUp(delay: 0.5); // Custom delay for slow devices
  /// ```
  static Future<bool> warmUp({double delay = 0.1}) async {
    // Only supported on iOS and macOS
    if (!Platform.isIOS && !Platform.isMacOS) {
      return false;
    }

    try {
      final result = await _channel.invokeMethod<bool>('warmUp', {'delay': delay});
      _isWarmedUp = result ?? false;
      return _isWarmedUp;
    } on PlatformException catch (e) {
      // Silently fail - warmUp is optional optimization
      print('[Bootpay] WarmUp failed: ${e.message}');
      return false;
    } on MissingPluginException {
      // Plugin not registered - might be in test environment
      return false;
    }
  }

  /// Releases the pre-warmed WebView to free memory
  ///
  /// Call this method when:
  /// - Receiving memory warnings
  /// - WebView is no longer needed in the app
  /// - App is going to background for extended period
  ///
  /// **Note**: This is a no-op on platforms other than iOS/macOS.
  ///
  /// Returns `true` if release was successful.
  static Future<bool> releaseWarmUp() async {
    // Only supported on iOS and macOS
    if (!Platform.isIOS && !Platform.isMacOS) {
      return false;
    }

    try {
      final result = await _channel.invokeMethod<bool>('releaseWarmUp');
      _isWarmedUp = false;
      return result ?? false;
    } on PlatformException catch (e) {
      print('[Bootpay] ReleaseWarmUp failed: ${e.message}');
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Checks if the WebView is currently warmed up (native state)
  ///
  /// Returns `true` if a pre-warmed WebView exists in native memory.
  static Future<bool> checkIsWarmedUp() async {
    // Only supported on iOS and macOS
    if (!Platform.isIOS && !Platform.isMacOS) {
      return false;
    }

    try {
      final result = await _channel.invokeMethod<bool>('isWarmedUp');
      _isWarmedUp = result ?? false;
      return _isWarmedUp;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
