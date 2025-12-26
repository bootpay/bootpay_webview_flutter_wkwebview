// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit

/// Helper function to get shared ProcessPool from Objective-C BootpayAutoWarmUp class
private func getSharedProcessPool() -> WKProcessPool {
    // Try to get ProcessPool from Objective-C BootpayAutoWarmUp class
    if let autoWarmUpClass = NSClassFromString("BootpayAutoWarmUp") as? NSObject.Type {
        let selector = NSSelectorFromString("sharedProcessPool")
        if autoWarmUpClass.responds(to: selector) {
            if let pool = autoWarmUpClass.perform(selector)?.takeUnretainedValue() as? WKProcessPool {
                print("[Bootpay] Using ProcessPool from BootpayAutoWarmUp: \(pool)")
                return pool
            }
        }
    }
    // Fallback to Swift global ProcessPool
    print("[Bootpay] Fallback to Swift bootpaySharedProcessPool")
    return bootpaySharedProcessPool
}

/// ProxyApi implementation for `WKWebViewConfiguration`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
///
/// Note: Shared WKProcessPool is managed by BootpayAutoWarmUp (Objective-C) for early initialization
/// This ensures session/cookie persistence across all WKWebView instances and enables warm-up functionality.
class WebViewConfigurationProxyAPIDelegate: PigeonApiDelegateWKWebViewConfiguration {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiWKWebViewConfiguration) throws
    -> WKWebViewConfiguration
  {
    let config = WKWebViewConfiguration()
    // Use shared processPool from BootpayAutoWarmUp to maintain session/cookies
    // and benefit from pre-warmed WebView process
    let sharedPool = getSharedProcessPool()
    config.processPool = sharedPool
    print("[Bootpay] WKWebViewConfiguration created with shared ProcessPool: \(sharedPool)")
    return config
  }

  func setUserContentController(
    pigeonApi: PigeonApiWKWebViewConfiguration, pigeonInstance: WKWebViewConfiguration,
    controller: WKUserContentController
  ) throws {
    pigeonInstance.userContentController = controller
  }

  func getUserContentController(
    pigeonApi: PigeonApiWKWebViewConfiguration, pigeonInstance: WKWebViewConfiguration
  ) throws -> WKUserContentController {
    return pigeonInstance.userContentController
  }

  func setWebsiteDataStore(
    pigeonApi: PigeonApiWKWebViewConfiguration, pigeonInstance: WKWebViewConfiguration,
    dataStore: WKWebsiteDataStore
  ) throws {
    pigeonInstance.websiteDataStore = dataStore
  }

  func getWebsiteDataStore(
    pigeonApi: PigeonApiWKWebViewConfiguration, pigeonInstance: WKWebViewConfiguration
  ) throws -> WKWebsiteDataStore {
    return pigeonInstance.websiteDataStore
  }

  func setPreferences(
    pigeonApi: PigeonApiWKWebViewConfiguration, pigeonInstance: WKWebViewConfiguration,
    preferences: WKPreferences
  ) throws {
    pigeonInstance.preferences = preferences
  }

  func getPreferences(
    pigeonApi: PigeonApiWKWebViewConfiguration, pigeonInstance: WKWebViewConfiguration
  ) throws -> WKPreferences {
    return pigeonInstance.preferences
  }

  func setAllowsInlineMediaPlayback(
    pigeonApi: PigeonApiWKWebViewConfiguration, pigeonInstance: WKWebViewConfiguration, allow: Bool
  ) throws {
    #if !os(macOS)
      pigeonInstance.allowsInlineMediaPlayback = allow
    #endif
    // No-op, rather than error out, on macOS, since it's not a meaningful option on macOS and it's
    // easier for clients if it's just ignored.
  }

  func setLimitsNavigationsToAppBoundDomains(
    pigeonApi: PigeonApiWKWebViewConfiguration, pigeonInstance: WKWebViewConfiguration, limit: Bool
  ) throws {
    if #available(iOS 14.0, macOS 11.0, *) {
      pigeonInstance.limitsNavigationsToAppBoundDomains = limit
    } else {
      throw (pigeonApi.pigeonRegistrar as! ProxyAPIRegistrar)
        .createUnsupportedVersionError(
          method: "WKWebViewConfiguration.limitsNavigationsToAppBoundDomains",
          versionRequirements: "iOS 14.0, macOS 11.0")
    }
  }

  func setMediaTypesRequiringUserActionForPlayback(
    pigeonApi: PigeonApiWKWebViewConfiguration, pigeonInstance: WKWebViewConfiguration,
    type: AudiovisualMediaType
  ) throws {
    switch type {
    case .none:
      pigeonInstance.mediaTypesRequiringUserActionForPlayback = []
    case .audio:
      pigeonInstance.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypes.audio
    case .video:
      pigeonInstance.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypes.video
    case .all:
      pigeonInstance.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypes.all
    }
  }

  func getDefaultWebpagePreferences(
    pigeonApi: PigeonApiWKWebViewConfiguration, pigeonInstance: WKWebViewConfiguration
  ) throws -> WKWebpagePreferences {
    return pigeonInstance.defaultWebpagePreferences
  }
}
