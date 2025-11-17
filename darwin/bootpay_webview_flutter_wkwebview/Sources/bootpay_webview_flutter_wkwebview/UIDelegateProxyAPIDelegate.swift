// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit

/// Implementation of `WKUIDelegate` that calls to Dart in callback methods.
/// Also implements WKNavigationDelegate to handle popup webview navigation (e.g., payment flows)
class UIDelegateImpl: NSObject, WKUIDelegate, WKNavigationDelegate {
  let api: PigeonApiProtocolWKUIDelegate
  unowned let registrar: ProxyAPIRegistrar

  init(api: PigeonApiProtocolWKUIDelegate, registrar: ProxyAPIRegistrar) {
    self.api = api
    self.registrar = registrar
  }

  func webView(
    _ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
    for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures
  ) -> WKWebView? {
    // Create popup webview for payment windows
    let popupView = WKWebView(
      frame: CGRect(x: 0, y: 0, width: webView.bounds.size.width, height: webView.bounds.size.height),
      configuration: configuration
    )

    popupView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    // Use self as navigationDelegate to handle App-to-App payment in popup
    popupView.navigationDelegate = self
    popupView.uiDelegate = self

    webView.superview?.addSubview(popupView)

    // Note: Removed Dart callback to prevent popup creation issues
    // Handle popup entirely in native code for better stability
    // This matches bootpay_flutter_webview 2 implementation

    return popupView
  }

  #if compiler(>=6.0)
    @available(iOS 15.0, macOS 12.0, *)
    func webView(
      _ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin,
      initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType,
      decisionHandler: @escaping @MainActor (WKPermissionDecision) -> Void
    ) {
      let wrapperCaptureType: MediaCaptureType
      switch type {
      case .camera:
        wrapperCaptureType = .camera
      case .microphone:
        wrapperCaptureType = .microphone
      case .cameraAndMicrophone:
        wrapperCaptureType = .cameraAndMicrophone
      @unknown default:
        wrapperCaptureType = .unknown
      }

      registrar.dispatchOnMainThread { onFailure in
        self.api.requestMediaCapturePermission(
          pigeonInstance: self, webView: webView, origin: origin, frame: frame,
          type: wrapperCaptureType
        ) { result in
          DispatchQueue.main.async {
            switch result {
            case .success(let decision):
              switch decision {
              case .deny:
                decisionHandler(.deny)
              case .grant:
                decisionHandler(.grant)
              case .prompt:
                decisionHandler(.prompt)
              }
            case .failure(let error):
              decisionHandler(.deny)
              onFailure("WKUIDelegate.requestMediaCapturePermission", error)
            }
          }
        }
      }
    }
  #else
    @available(iOS 15.0, macOS 12.0, *)
    func webView(
      _ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin,
      initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType,
      decisionHandler: @escaping (WKPermissionDecision) -> Void
    ) {
      let wrapperCaptureType: MediaCaptureType
      switch type {
      case .camera:
        wrapperCaptureType = .camera
      case .microphone:
        wrapperCaptureType = .microphone
      case .cameraAndMicrophone:
        wrapperCaptureType = .cameraAndMicrophone
      @unknown default:
        wrapperCaptureType = .unknown
      }

      registrar.dispatchOnMainThread { onFailure in
        self.api.requestMediaCapturePermission(
          pigeonInstance: self, webView: webView, origin: origin, frame: frame,
          type: wrapperCaptureType
        ) { result in
          DispatchQueue.main.async {
            switch result {
            case .success(let decision):
              switch decision {
              case .deny:
                decisionHandler(.deny)
              case .grant:
                decisionHandler(.grant)
              case .prompt:
                decisionHandler(.prompt)
              }
            case .failure(let error):
              decisionHandler(.deny)
              onFailure("WKUIDelegate.requestMediaCapturePermission", error)
            }
          }
        }
      }
    }
  #endif

  func webViewDidClose(_ webView: WKWebView) {
    // Remove popup webview when closed
    webView.removeFromSuperview()
  }

  #if compiler(>=6.0)
    func webView(
      _ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
      initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping @MainActor () -> Void
    ) {
      registrar.dispatchOnMainThread { onFailure in
        self.api.runJavaScriptAlertPanel(
          pigeonInstance: self, webView: webView, message: message, frame: frame
        ) { result in
          DispatchQueue.main.async {
            if case .failure(let error) = result {
              onFailure("WKUIDelegate.runJavaScriptAlertPanel", error)
            }
            completionHandler()
          }
        }
      }
    }
  #else
    func webView(
      _ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
      initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void
    ) {
      registrar.dispatchOnMainThread { onFailure in
        self.api.runJavaScriptAlertPanel(
          pigeonInstance: self, webView: webView, message: message, frame: frame
        ) { result in
          DispatchQueue.main.async {
            if case .failure(let error) = result {
              onFailure("WKUIDelegate.runJavaScriptAlertPanel", error)
            }
            completionHandler()
          }
        }
      }
    }
  #endif

  #if compiler(>=6.0)
    func webView(
      _ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String,
      initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping @MainActor (Bool) -> Void
    ) {
      registrar.dispatchOnMainThread { onFailure in
        self.api.runJavaScriptConfirmPanel(
          pigeonInstance: self, webView: webView, message: message, frame: frame
        ) { result in
          DispatchQueue.main.async {
            switch result {
            case .success(let confirmed):
              completionHandler(confirmed)
            case .failure(let error):
              completionHandler(false)
              onFailure("WKUIDelegate.runJavaScriptConfirmPanel", error)
            }
          }
        }
      }
    }
  #else
    func webView(
      _ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String,
      initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void
    ) {
      registrar.dispatchOnMainThread { onFailure in
        self.api.runJavaScriptConfirmPanel(
          pigeonInstance: self, webView: webView, message: message, frame: frame
        ) { result in
          DispatchQueue.main.async {
            switch result {
            case .success(let confirmed):
              completionHandler(confirmed)
            case .failure(let error):
              completionHandler(false)
              onFailure("WKUIDelegate.runJavaScriptConfirmPanel", error)
            }
          }
        }
      }
    }
  #endif

  #if compiler(>=6.0)
    func webView(
      _ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String,
      defaultText: String?, initiatedByFrame frame: WKFrameInfo,
      completionHandler: @escaping @MainActor (String?) -> Void
    ) {
      registrar.dispatchOnMainThread { onFailure in
        self.api.runJavaScriptTextInputPanel(
          pigeonInstance: self, webView: webView, prompt: prompt, defaultText: defaultText,
          frame: frame
        ) { result in
          DispatchQueue.main.async {
            switch result {
            case .success(let response):
              completionHandler(response)
            case .failure(let error):
              completionHandler(nil)
              onFailure("WKUIDelegate.runJavaScriptTextInputPanel", error)
            }
          }
        }
      }
    }
  #else
    func webView(
      _ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String,
      defaultText: String?, initiatedByFrame frame: WKFrameInfo,
      completionHandler: @escaping (String?) -> Void
    ) {
      registrar.dispatchOnMainThread { onFailure in
        self.api.runJavaScriptTextInputPanel(
          pigeonInstance: self, webView: webView, prompt: prompt, defaultText: defaultText,
          frame: frame
        ) { result in
          DispatchQueue.main.async {
            switch result {
            case .success(let response):
              completionHandler(response)
            case .failure(let error):
              completionHandler(nil)
              onFailure("WKUIDelegate.runJavaScriptTextInputPanel", error)
            }
          }
        }
      }
    }
  #endif

  // MARK: - WKNavigationDelegate methods for popup webviews

  public func webView(
    _ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
  ) {
    // Handle App-to-App payment URLs in popup
    let url = navigationAction.request.url?.absoluteString ?? ""

    if isItunesURL(url) {
      startAppToApp(URL(string: url)!)
      decisionHandler(.cancel)
      return
    } else if !url.hasPrefix("http") && !url.isEmpty && url != "about:blank" {
      startAppToApp(URL(string: url)!)
      decisionHandler(.cancel)
      return
    }

    decisionHandler(.allow)
  }

  public func webView(
    _ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge,
    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
  ) {
    // Handle SSL certificate for payment pages
    if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
      if let serverTrust = challenge.protectionSpace.serverTrust {
        let credential = URLCredential(trust: serverTrust)
        completionHandler(.useCredential, credential)
        return
      }
    }
    completionHandler(.performDefaultHandling, nil)
  }

  // MARK: - Bootpay URL Helper Methods

  private func startAppToApp(_ url: URL) {
    if #available(iOS 10.0, *) {
      UIApplication.shared.open(url, options: [:]) { success in
        if !success {
          self.startItunesToInstall(url)
        }
      }
    } else {
      UIApplication.shared.openURL(url)
    }
  }

  private func startItunesToInstall(_ url: URL) {
    let urlString = url.absoluteString
    var itunesUrl = ""

    if urlString.hasPrefix("kfc-bankpay") {
      itunesUrl =
        "https://apps.apple.com/kr/app/%EB%B1%85%ED%81%AC%ED%8E%98%EC%9D%B4-%EA%B8%88%EC%9C%B5%EA%B8%B0%EA%B4%80-%EA%B3%B5%EB%8F%99-%EA%B3%84%EC%A2%8C%EC%9D%B4%EC%B2%B4-%EA%B2%B0%EC%A0%9C-%EC%A0%9C%EB%A1%9C%ED%8E%98%EC%9D%B4/id398456030"
    } else if urlString.hasPrefix("kfc-ispmobile") {
      itunesUrl = "https://apps.apple.com/kr/app/isp/id369125087"
    } else if urlString.hasPrefix("hdcardappcardansimclick")
      || urlString.hasPrefix("smhyundaiansimclick")
    {
      itunesUrl = "https://apps.apple.com/kr/app/%ED%98%84%EB%8C%80%EC%B9%B4%EB%93%9C/id702653088"
    } else if urlString.hasPrefix("shinhan-sr-ansimclick")
      || urlString.hasPrefix("smshinhanansimclick")
    {
      itunesUrl =
        "https://apps.apple.com/kr/app/%EC%8B%A0%ED%95%9C%ED%8E%98%EC%9D%B4%ED%8C%90/id572462317"
    } else if urlString.hasPrefix("kb-acp") {
      itunesUrl = "https://apps.apple.com/kr/app/kb-pay/id695436326"
    } else if urlString.hasPrefix("liivbank") {
      itunesUrl = "https://apps.apple.com/kr/app/%EB%A6%AC%EB%B8%8C/id1126232922"
    } else if urlString.hasPrefix("mpocket.online.ansimclick")
      || urlString.hasPrefix("ansimclickscard") || urlString.hasPrefix("ansimclickipcollect")
      || urlString.hasPrefix("samsungpay") || urlString.hasPrefix("scardcertiapp")
    {
      itunesUrl =
        "https://apps.apple.com/kr/app/%EC%82%BC%EC%84%B1%EC%B9%B4%EB%93%9C/id535125356"
    } else if urlString.hasPrefix("lottesmartpay") {
      itunesUrl =
        "https://apps.apple.com/us/app/%EB%A1%AF%EB%8D%B0%EC%B9%B4%EB%93%9C-%EC%95%B1%EC%B9%B4%EB%93%9C/id688047200"
    } else if urlString.hasPrefix("lotteappcard") {
      itunesUrl =
        "https://apps.apple.com/kr/app/%EB%94%94%EC%A7%80%EB%A1%9C%EC%B9%B4-%EB%A1%AF%EB%8D%B0%EC%B9%B4%EB%93%9C/id688047200"
    } else if urlString.hasPrefix("newsmartpib") {
      itunesUrl =
        "https://apps.apple.com/kr/app/%EC%9A%B0%EB%A6%AC-won-%EB%B1%85%ED%82%B9/id1470181651"
    } else if urlString.hasPrefix("com.wooricard.wcard") {
      itunesUrl =
        "https://apps.apple.com/kr/app/%EC%9A%B0%EB%A6%ACwon%EC%B9%B4%EB%93%9C/id1499598869"
    } else if urlString.hasPrefix("citispay") || urlString.hasPrefix("citicardappkr")
      || urlString.hasPrefix("citimobileapp")
    {
      itunesUrl =
        "https://apps.apple.com/kr/app/%EC%94%A8%ED%8B%B0%EB%AA%A8%EB%B0%94%EC%9D%BC/id1179759666"
    } else if urlString.hasPrefix("shinsegaeeasypayment") {
      itunesUrl = "https://apps.apple.com/kr/app/ssgpay/id666237916"
    } else if urlString.hasPrefix("cloudpay") {
      itunesUrl =
        "https://apps.apple.com/kr/app/%ED%95%98%EB%82%98%EC%B9%B4%EB%93%9C-%EC%9B%90%ED%81%90%ED%8E%98%EC%9D%B4/id847268987"
    } else if urlString.hasPrefix("hanawalletmembers") {
      itunesUrl = "https://apps.apple.com/kr/app/n-wallet/id492190784"
    } else if urlString.hasPrefix("nhappvardansimclick") {
      itunesUrl =
        "https://apps.apple.com/kr/app/%EC%98%AC%EC%9B%90%ED%8E%98%EC%9D%B4-nh%EC%95%B1%EC%B9%B4%EB%93%9C/id1177889176"
    } else if urlString.hasPrefix("nhallonepayansimclick")
      || urlString.hasPrefix("nhappcardansimclick") || urlString.hasPrefix("nonghyupcardansimclick")
    {
      itunesUrl =
        "https://apps.apple.com/kr/app/%EC%98%AC%EC%9B%90%ED%8E%98%EC%9D%B4-nh%EC%95%B1%EC%B9%B4%EB%93%9C/id1177889176"
    } else if urlString.hasPrefix("payco") {
      itunesUrl = "https://apps.apple.com/kr/app/payco/id924292102"
    } else if urlString.hasPrefix("lpayapp") || urlString.hasPrefix("lmslpay") {
      itunesUrl = "https://apps.apple.com/kr/app/l-point-with-l-pay/id473250588"
    } else if urlString.hasPrefix("naversearchapp") {
      itunesUrl =
        "https://apps.apple.com/kr/app/%EB%84%A4%EC%9D%B4%EB%B2%84-naver/id393499958"
    } else if urlString.hasPrefix("tauthlink") {
      itunesUrl = "https://apps.apple.com/kr/app/pass-by-skt/id1141258007"
    } else if urlString.hasPrefix("uplusauth") || urlString.hasPrefix("upluscorporation") {
      itunesUrl = "https://apps.apple.com/kr/app/pass-by-u/id1147394645"
    } else if urlString.hasPrefix("ktauthexternalcall") {
      itunesUrl = "https://apps.apple.com/kr/app/pass-by-kt/id1134371550"
    } else if urlString.hasPrefix("supertoss") {
      itunesUrl = "https://apps.apple.com/kr/app/%ED%86%A0%EC%8A%A4/id839333328"
    } else if urlString.hasPrefix("kakaotalk") {
      itunesUrl = "https://apps.apple.com/kr/app/kakaotalk/id362057947"
    } else if urlString.hasPrefix("chaipayment") {
      itunesUrl = "https://apps.apple.com/kr/app/%EC%B0%A8%EC%9D%B4/id1459979272"
    }

    if !itunesUrl.isEmpty {
      if let url = URL(string: itunesUrl) {
        startAppToApp(url)
      }
    }
  }

  private func isItunesURL(_ urlString: String) -> Bool {
    return urlString.contains("apple.com")
  }
}

/// ProxyApi implementation for `WKUIDelegate`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class UIDelegateProxyAPIDelegate: PigeonApiDelegateWKUIDelegate {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiWKUIDelegate) throws -> WKUIDelegate {
    return UIDelegateImpl(
      api: pigeonApi, registrar: pigeonApi.pigeonRegistrar as! ProxyAPIRegistrar)
  }
}
