// Copyright 2024 Bootpay
// Classifies popup (window.open / target="_blank") URLs as ad pages, so the
// WKWebView popup shows a manual close bar only for ads — payment popups stay
// clean (no bar). Payment popups navigate to dynamic PG gateway URLs that can
// not be enumerated, so the default is "no bar"; only popups whose host matches
// a known ad network get the bar.

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

/// Holds the ad-network host list used to decide whether a popup needs a
/// manual close bar. Nothing is blocked: the popup (and the ad) is always
/// shown — this list only controls whether the close bar is displayed.
///
/// AdSense click-throughs always route through one of the default fragments
/// (`googleadservices.com` / `doubleclick.net` / `googlesyndication.com`) before
/// redirecting to the advertiser, so matching the popup's first URL host is
/// reliable for the AdSense case. The list can be extended from Dart via
/// `BootpayPopupConfigMethodChannel` (kr.co.bootpay/webview_popup -> addAdHosts).
@objc(BootpayPopupAdFilter)
public class BootpayPopupAdFilter: NSObject {

  /// Singleton instance
  @objc public static let shared = BootpayPopupAdFilter()

  /// Known ad-network host fragments (case-insensitive substring match against
  /// the URL host). Conservative on purpose: anything not matched is treated as
  /// a payment/other popup and keeps the current bar-less behavior.
  private var adHostFragments: [String] = [
    "doubleclick.net",
    "googleadservices.com",
    "googlesyndication.com",
    "adservice.google.",
    "adnxs.com",
    "amazon-adsystem.com",
    "taboola.com",
    "outbrain.com",
    "criteo.com",
    "media.net",
    "adsystem.com",
  ]

  /// Close-button visibility mode: "auto" (default — show ✕ only on ad popups),
  /// "always" (every popup) or "never" (no ✕). Set from Dart via
  /// `setCloseButtonMode`.
  private var closeButtonMode: String = "auto"

  private let lock = NSLock()

  private override init() { super.init() }

  /// Appends host fragments to the ad-host list. Empty / duplicate entries are
  /// ignored. Defaults always remain present (additive only).
  @objc public func addAdHosts(_ hosts: [String]) {
    lock.lock()
    defer { lock.unlock() }
    for host in hosts {
      let normalized = host.lowercased()
      if !normalized.isEmpty && !adHostFragments.contains(normalized) {
        adHostFragments.append(normalized)
      }
    }
  }

  /// Returns true if the URL's host matches a known ad-network fragment.
  @objc public func isAdURL(_ url: URL?) -> Bool {
    guard let host = url?.host?.lowercased(), !host.isEmpty else { return false }
    lock.lock()
    let fragments = adHostFragments
    lock.unlock()
    for fragment in fragments where host.contains(fragment) {
      return true
    }
    return false
  }

  /// Sets the close-button visibility mode ("auto" | "always" | "never").
  /// Unknown values fall back to "auto".
  @objc public func setCloseButtonMode(_ mode: String) {
    let normalized = mode.lowercased()
    lock.lock()
    defer { lock.unlock() }
    switch normalized {
    case "always", "never", "auto":
      closeButtonMode = normalized
    default:
      closeButtonMode = "auto"
    }
  }

  /// Whether the floating close (✕) button should be shown for a popup at
  /// `url`, per the current mode:
  /// - "never"  -> always false
  /// - "always" -> always true
  /// - "auto"   -> true only when the URL matches a known ad-network host.
  @objc public func shouldShowCloseButton(for url: URL?) -> Bool {
    lock.lock()
    let mode = closeButtonMode
    lock.unlock()
    switch mode {
    case "never": return false
    case "always": return true
    default: return isAdURL(url)
    }
  }
}

/// Flutter Method Channel handler that lets Dart extend the popup ad-host
/// list at runtime (kr.co.bootpay/webview_popup -> addAdHosts).
public class BootpayPopupConfigMethodChannel: NSObject {

  private static let channelName = "kr.co.bootpay/webview_popup"
  private var channel: FlutterMethodChannel?

  public func register(with messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: BootpayPopupConfigMethodChannel.channelName, binaryMessenger: messenger)

    channel?.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "addAdHosts":
        if let hosts = call.arguments as? [String] {
          BootpayPopupAdFilter.shared.addAdHosts(hosts)
        } else if let args = call.arguments as? [String: Any],
          let hosts = args["hosts"] as? [String]
        {
          BootpayPopupAdFilter.shared.addAdHosts(hosts)
        }
        result(true)

      case "setCloseButtonMode":
        if let mode = call.arguments as? String {
          BootpayPopupAdFilter.shared.setCloseButtonMode(mode)
        } else if let args = call.arguments as? [String: Any],
          let mode = args["mode"] as? String
        {
          BootpayPopupAdFilter.shared.setCloseButtonMode(mode)
        }
        result(true)

      case "closePopup":
        // Dismiss the currently displayed popup (e.g. on an ad-finished event).
        // No-op if none is open. Method-channel callbacks run on the main
        // thread, so it is safe to touch UIKit here.
        #if os(iOS)
          BootpayPopupContainerView.closeCurrent()
        #endif
        result(true)

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  public func dispose() {
    channel?.setMethodCallHandler(nil)
    channel = nil
  }
}
