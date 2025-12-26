// Copyright 2024 Bootpay
// WebView WarmUp Manager for pre-initializing WKWebView process

import WebKit

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

/// Shared WKProcessPool for session/cookie persistence
/// This is used by WebViewConfigurationProxyAPIDelegate as well
let bootpaySharedProcessPool = WKProcessPool()

/// Manager class for WebView pre-warming functionality
/// Pre-warming helps reduce the initial loading time of WebView by:
/// 1. Pre-creating the WKWebView's internal processes (GPU, Networking, WebContent)
/// 2. Sharing ProcessPool across all WebView instances for session persistence
@objc(BootpayWarmUpManager)
public class BootpayWarmUpManager: NSObject {

    /// Singleton instance
    @objc public static let shared = BootpayWarmUpManager()

    /// Pre-warmed WebView instance (kept in memory for process reuse)
    private var prewarmedWebView: WKWebView?

    /// Whether warm-up has been performed
    @objc public private(set) var isWarmedUp: Bool = false

    private override init() {
        super.init()
    }

    /// Shared configuration using the shared process pool
    private var sharedConfiguration: WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        config.processPool = bootpaySharedProcessPool
        return config
    }

    /// Pre-warms the WebView by creating an invisible instance
    /// This initializes WKWebView's internal processes in the background
    ///
    /// Benefits:
    /// - GPU process initialization (1-2 seconds saved)
    /// - Networking process initialization (1-2 seconds saved)
    /// - WebContent process initialization (1-3 seconds saved)
    /// - Total: 3-7 seconds faster first payment screen loading
    ///
    /// Call this in AppDelegate.didFinishLaunchingWithOptions or as early as possible
    @objc public func warmUp() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if self.prewarmedWebView == nil {
                // Create WebView with zero frame (invisible)
                self.prewarmedWebView = WKWebView(frame: .zero, configuration: self.sharedConfiguration)

                // Load empty HTML to trigger process initialization
                self.prewarmedWebView?.loadHTMLString("", baseURL: nil)

                self.isWarmedUp = true

                #if DEBUG
                print("[Bootpay] WebView warm-up completed")
                #endif
            }
        }
    }

    /// Releases the pre-warmed WebView to free memory
    /// Call this when receiving memory warnings or when WebView is no longer needed
    @objc public func releaseWarmUp() {
        DispatchQueue.main.async { [weak self] in
            self?.prewarmedWebView = nil
            self?.isWarmedUp = false

            #if DEBUG
            print("[Bootpay] WebView warm-up released")
            #endif
        }
    }

    /// Gets the shared process pool for use by other WebView instances
    @objc public var sharedProcessPool: WKProcessPool {
        return bootpaySharedProcessPool
    }
}

/// Flutter Method Channel handler for WarmUp functionality
public class BootpayWarmUpMethodChannel: NSObject {

    private static let channelName = "kr.co.bootpay/webview_warmup"
    private var channel: FlutterMethodChannel?

    public func register(with messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: BootpayWarmUpMethodChannel.channelName, binaryMessenger: messenger)

        channel?.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            self?.handleMethodCall(call, result: result)
        }
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "warmUp":
            BootpayWarmUpManager.shared.warmUp()
            result(true)

        case "releaseWarmUp":
            BootpayWarmUpManager.shared.releaseWarmUp()
            result(true)

        case "isWarmedUp":
            result(BootpayWarmUpManager.shared.isWarmedUp)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func dispose() {
        channel?.setMethodCallHandler(nil)
        channel = nil
    }
}
