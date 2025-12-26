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

    /// HTML for warm-up (triggers GPU/WebContent/Networking process initialization)
    private static let warmUpHTML = """
    <!DOCTYPE html>
    <html>
    <head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
    <body><canvas id="c" width="1" height="1"></canvas>
    <script>
    var c=document.getElementById('c').getContext('2d');
    c.fillRect(0,0,1,1);
    fetch('https://webview.bootpay.co.kr/health',{mode:'no-cors'}).catch(function(){});
    </script>
    </body>
    </html>
    """

    private override init() {
        super.init()
    }

    /// Shared configuration using the shared process pool
    private var sharedConfiguration: WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        config.processPool = bootpaySharedProcessPool
        return config
    }

    /// Pre-warms the WebView with default delay (0.1 seconds)
    @objc public func warmUp() {
        warmUp(delay: 0.1)
    }

    /// Pre-warms the WebView by creating an invisible instance
    /// This initializes WKWebView's internal processes in the background
    ///
    /// - Parameter delay: Delay before starting warm-up (seconds). Default 0.1.
    ///                    Increase to 0.5~1.0 if UI becomes sluggish.
    ///
    /// Benefits:
    /// - GPU process initialization (1-2 seconds saved)
    /// - Networking process initialization (1-2 seconds saved)
    /// - WebContent process initialization (1-3 seconds saved)
    /// - Total: 3-7 seconds faster first payment screen loading
    ///
    /// Call this in AppDelegate.didFinishLaunchingWithOptions or as early as possible
    @objc public func warmUp(delay: Double) {
        print("[Bootpay] warmUp() called with delay: \(delay)")
        guard prewarmedWebView == nil else {
            print("[Bootpay] warmUp skipped - already warmed up")
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self, self.prewarmedWebView == nil else {
                print("[Bootpay] warmUp async skipped - already warmed up")
                return
            }

            print("[Bootpay] warmUp creating WKWebView with shared ProcessPool...")

            // Create WebView with 1x1 frame
            self.prewarmedWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), configuration: self.sharedConfiguration)

            // Load HTML with Canvas rendering + fetch to trigger all processes
            self.prewarmedWebView?.loadHTMLString(Self.warmUpHTML, baseURL: URL(string: "https://webview.bootpay.co.kr"))

            self.isWarmedUp = true

            print("[Bootpay] warmUp started - WebView processes initializing...")
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
            // Support optional delay parameter
            if let args = call.arguments as? [String: Any],
               let delay = args["delay"] as? Double {
                BootpayWarmUpManager.shared.warmUp(delay: delay)
            } else {
                BootpayWarmUpManager.shared.warmUp()
            }
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
