// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit

/// Implementation of `WKNavigationDelegate` that calls to Dart in callback methods.
public class NavigationDelegateImpl: NSObject, WKNavigationDelegate {
  let api: PigeonApiProtocolWKNavigationDelegate
  unowned let registrar: ProxyAPIRegistrar

  init(api: PigeonApiProtocolWKNavigationDelegate, registrar: ProxyAPIRegistrar) {
    self.api = api
    self.registrar = registrar
  }

  public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    registrar.dispatchOnMainThread { onFailure in
      self.api.didFinishNavigation(
        pigeonInstance: self, webView: webView, url: webView.url?.absoluteString
      ) { result in
        if case .failure(let error) = result {
          onFailure("WKNavigationDelegate.didFinishNavigation", error)
        }
      }
    }
  }

  public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
  {
    registrar.dispatchOnMainThread { onFailure in
      self.api.didStartProvisionalNavigation(
        pigeonInstance: self, webView: webView, url: webView.url?.absoluteString
      ) { result in
        if case .failure(let error) = result {
          onFailure("WKNavigationDelegate.didStartProvisionalNavigation", error)
        }
      }
    }
  }

  public func webView(
    _ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error
  ) {
    registrar.dispatchOnMainThread { onFailure in
      self.api.didFailNavigation(pigeonInstance: self, webView: webView, error: error as NSError) {
        result in
        if case .failure(let error) = result {
          onFailure("WKNavigationDelegate.didFailNavigation", error)
        }
      }
    }
  }

  public func webView(
    _ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!,
    withError error: Error
  ) {
    registrar.dispatchOnMainThread { onFailure in
      self.api.didFailProvisionalNavigation(
        pigeonInstance: self, webView: webView, error: error as NSError
      ) { result in
        if case .failure(let error) = result {
          onFailure("WKNavigationDelegate.didFailProvisionalNavigation", error)
        }
      }
    }
  }

  public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
    registrar.dispatchOnMainThread { onFailure in
      self.api.webViewWebContentProcessDidTerminate(pigeonInstance: self, webView: webView) {
        result in
        if case .failure(let error) = result {
          onFailure("WKNavigationDelegate.webViewWebContentProcessDidTerminate", error)
        }
      }
    }
  }

  #if compiler(>=6.0)
    public func webView(
      _ webView: WKWebView, decidePolicyFor navigationAction: WebKit.WKNavigationAction,
      decisionHandler: @escaping @MainActor (WebKit.WKNavigationActionPolicy) -> Void
    ) {
      // Bootpay payment URL handling
      let url = navigationAction.request.url?.absoluteString ?? ""

      if isItunesURL(url) {
        DispatchQueue.main.async {
          decisionHandler(.cancel)
        }
        startAppToApp(URL(string: url)!)
        return
      } else if !url.hasPrefix("http") {
        DispatchQueue.main.async {
          decisionHandler(.cancel)
        }
        startAppToApp(URL(string: url)!)
        return
      }

      registrar.dispatchOnMainThread { onFailure in
        self.api.decidePolicyForNavigationAction(
          pigeonInstance: self, webView: webView, navigationAction: navigationAction
        ) { result in
          DispatchQueue.main.async {
            switch result {
            case .success(let policy):
              switch policy {
              case .allow:
                decisionHandler(.allow)
              case .cancel:
                decisionHandler(.cancel)
              case .download:
                if #available(iOS 14.5, macOS 11.3, *) {
                  decisionHandler(.download)
                } else {
                  decisionHandler(.cancel)
                  assertionFailure(
                    self.registrar.createUnsupportedVersionMessage(
                      "WKNavigationActionPolicy.download",
                      versionRequirements: "iOS 14.5, macOS 11.3"
                    ))
                }
              }
            case .failure(let error):
              decisionHandler(.cancel)
              onFailure("WKNavigationDelegate.decidePolicyForNavigationAction", error)
            }
          }
        }
      }
    }
  #else
    public func webView(
      _ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
      decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
      // Bootpay payment URL handling
      let url = navigationAction.request.url?.absoluteString ?? ""

      if isItunesURL(url) {
        startAppToApp(URL(string: url)!)
        decisionHandler(.cancel)
        return
      } else if !url.hasPrefix("http") {
        startAppToApp(URL(string: url)!)
        decisionHandler(.cancel)
        return
      }

      registrar.dispatchOnMainThread { onFailure in
        self.api.decidePolicyForNavigationAction(
          pigeonInstance: self, webView: webView, navigationAction: navigationAction
        ) { result in
          DispatchQueue.main.async {
            switch result {
            case .success(let policy):
              switch policy {
              case .allow:
                decisionHandler(.allow)
              case .cancel:
                decisionHandler(.cancel)
              case .download:
                if #available(iOS 14.5, macOS 11.3, *) {
                  decisionHandler(.download)
                } else {
                  decisionHandler(.cancel)
                  assertionFailure(
                    self.registrar.createUnsupportedVersionMessage(
                      "WKNavigationActionPolicy.download",
                      versionRequirements: "iOS 14.5, macOS 11.3"
                    ))
                }
              }
            case .failure(let error):
              decisionHandler(.cancel)
              onFailure("WKNavigationDelegate.decidePolicyForNavigationAction", error)
            }
          }
        }
      }
    }
  #endif

  #if compiler(>=6.0)
    public func webView(
      _ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
      decisionHandler: @escaping @MainActor (WKNavigationResponsePolicy) -> Void
    ) {
      registrar.dispatchOnMainThread { onFailure in
        self.api.decidePolicyForNavigationResponse(
          pigeonInstance: self, webView: webView, navigationResponse: navigationResponse
        ) { result in
          DispatchQueue.main.async {
            switch result {
            case .success(let policy):
              switch policy {
              case .allow:
                decisionHandler(.allow)
              case .cancel:
                decisionHandler(.cancel)
              case .download:
                if #available(iOS 14.5, macOS 11.3, *) {
                  decisionHandler(.download)
                } else {
                  decisionHandler(.cancel)
                  assertionFailure(
                    self.registrar.createUnsupportedVersionMessage(
                      "WKNavigationResponsePolicy.download",
                      versionRequirements: "iOS 14.5, macOS 11.3"
                    ))
                }
              }
            case .failure(let error):
              decisionHandler(.cancel)
              onFailure("WKNavigationDelegate.decidePolicyForNavigationResponse", error)
            }
          }
        }
      }
    }
  #else
    public func webView(
      _ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
      decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
    ) {
      registrar.dispatchOnMainThread { onFailure in
        self.api.decidePolicyForNavigationResponse(
          pigeonInstance: self, webView: webView, navigationResponse: navigationResponse
        ) { result in
          DispatchQueue.main.async {
            switch result {
            case .success(let policy):
              switch policy {
              case .allow:
                decisionHandler(.allow)
              case .cancel:
                decisionHandler(.cancel)
              case .download:
                if #available(iOS 14.5, macOS 11.3, *) {
                  decisionHandler(.download)
                } else {
                  decisionHandler(.cancel)
                  assertionFailure(
                    self.registrar.createUnsupportedVersionMessage(
                      "WKNavigationResponsePolicy.download",
                      versionRequirements: "iOS 14.5, macOS 11.3"
                    ))
                }
              }
            case .failure(let error):
              decisionHandler(.cancel)
              onFailure("WKNavigationDelegate.decidePolicyForNavigationResponse", error)
            }
          }
        }
      }
    }
  #endif

  #if compiler(>=6.0)
    public func webView(
      _ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge,
      completionHandler: @escaping @MainActor (URLSession.AuthChallengeDisposition, URLCredential?)
        ->
        Void
    ) {
      registrar.dispatchOnMainThread { onFailure in
        self.api.didReceiveAuthenticationChallenge(
          pigeonInstance: self, webView: webView, challenge: challenge
        ) { result in
          DispatchQueue.main.async {
            switch result {
            case .success(let response):
              completionHandler(response.disposition, response.credential)
            case .failure(let error):
              completionHandler(.cancelAuthenticationChallenge, nil)
              onFailure("WKNavigationDelegate.didReceiveAuthenticationChallenge", error)
            }
          }
        }
      }
    }
  #else
    public func webView(
      _ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge,
      completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) ->
        Void
    ) {
      registrar.dispatchOnMainThread { onFailure in
        self.api.didReceiveAuthenticationChallenge(
          pigeonInstance: self, webView: webView, challenge: challenge
        ) { result in
          DispatchQueue.main.async {
            switch result {
            case .success(let response):
              completionHandler(response.disposition, response.credential)
            case .failure(let error):
              completionHandler(.cancelAuthenticationChallenge, nil)
              onFailure("WKNavigationDelegate.didReceiveAuthenticationChallenge", error)
            }
          }
        }
      }
    }
  #endif

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
      itunesUrl = "https://apps.apple.com/kr/app/%EB%B1%85%ED%81%AC%ED%8E%98%EC%9D%B4-%EA%B8%88%EC%9C%B5%EA%B8%B0%EA%B4%80-%EA%B3%B5%EB%8F%99-%EA%B3%84%EC%A2%8C%EC%9D%B4%EC%B2%B4-%EA%B2%B0%EC%A0%9C-%EC%A0%9C%EB%A1%9C%ED%8E%98%EC%9D%B4/id398456030"
    } else if urlString.hasPrefix("kfc-ispmobile") {
      itunesUrl = "https://apps.apple.com/kr/app/isp/id369125087"
    } else if urlString.hasPrefix("hdcardappcardansimclick") || urlString.hasPrefix("smhyundaiansimclick") {
      itunesUrl = "https://apps.apple.com/kr/app/%ED%98%84%EB%8C%80%EC%B9%B4%EB%93%9C/id702653088"
    } else if urlString.hasPrefix("shinhan-sr-ansimclick") || urlString.hasPrefix("smshinhanansimclick") {
      itunesUrl = "https://apps.apple.com/kr/app/%EC%8B%A0%ED%95%9C%ED%8E%98%EC%9D%B4%ED%8C%90/id572462317"
    } else if urlString.hasPrefix("kb-acp") {
      itunesUrl = "https://apps.apple.com/kr/app/kb-pay/id695436326"
    } else if urlString.hasPrefix("liivbank") {
      itunesUrl = "https://apps.apple.com/kr/app/%EB%A6%AC%EB%B8%8C/id1126232922"
    } else if urlString.hasPrefix("mpocket.online.ansimclick") || urlString.hasPrefix("ansimclickscard") || urlString.hasPrefix("ansimclickipcollect") || urlString.hasPrefix("samsungpay") || urlString.hasPrefix("scardcertiapp") {
      itunesUrl = "https://apps.apple.com/kr/app/%EC%82%BC%EC%84%B1%EC%B9%B4%EB%93%9C/id535125356"
    } else if urlString.hasPrefix("lottesmartpay") {
      itunesUrl = "https://apps.apple.com/us/app/%EB%A1%AF%EB%8D%B0%EC%B9%B4%EB%93%9C-%EC%95%B1%EC%B9%B4%EB%93%9C/id688047200"
    } else if urlString.hasPrefix("lotteappcard") {
      itunesUrl = "https://apps.apple.com/kr/app/%EB%94%94%EC%A7%80%EB%A1%9C%EC%B9%B4-%EB%A1%AF%EB%8D%B0%EC%B9%B4%EB%93%9C/id688047200"
    } else if urlString.hasPrefix("newsmartpib") {
      itunesUrl = "https://apps.apple.com/kr/app/%EC%9A%B0%EB%A6%AC-won-%EB%B1%85%ED%82%B9/id1470181651"
    } else if urlString.hasPrefix("com.wooricard.wcard") {
      itunesUrl = "https://apps.apple.com/kr/app/%EC%9A%B0%EB%A6%ACwon%EC%B9%B4%EB%93%9C/id1499598869"
    } else if urlString.hasPrefix("citispay") || urlString.hasPrefix("citicardappkr") || urlString.hasPrefix("citimobileapp") {
      itunesUrl = "https://apps.apple.com/kr/app/%EC%94%A8%ED%8B%B0%EB%AA%A8%EB%B0%94%EC%9D%BC/id1179759666"
    } else if urlString.hasPrefix("shinsegaeeasypayment") {
      itunesUrl = "https://apps.apple.com/kr/app/ssgpay/id666237916"
    } else if urlString.hasPrefix("cloudpay") {
      itunesUrl = "https://apps.apple.com/kr/app/%ED%95%98%EB%82%98%EC%B9%B4%EB%93%9C-%EC%9B%90%ED%81%90%ED%8E%98%EC%9D%B4/id847268987"
    } else if urlString.hasPrefix("hanawalletmembers") {
      itunesUrl = "https://apps.apple.com/kr/app/n-wallet/id492190784"
    } else if urlString.hasPrefix("nhappvardansimclick") {
      itunesUrl = "https://apps.apple.com/kr/app/%EC%98%AC%EC%9B%90%ED%8E%98%EC%9D%B4-nh%EC%95%B1%EC%B9%B4%EB%93%9C/id1177889176"
    } else if urlString.hasPrefix("nhallonepayansimclick") || urlString.hasPrefix("nhappcardansimclick") || urlString.hasPrefix("nonghyupcardansimclick") {
      itunesUrl = "https://apps.apple.com/kr/app/%EC%98%AC%EC%9B%90%ED%8E%98%EC%9D%B4-nh%EC%95%B1%EC%B9%B4%EB%93%9C/id1177889176"
    } else if urlString.hasPrefix("payco") {
      itunesUrl = "https://apps.apple.com/kr/app/payco/id924292102"
    } else if urlString.hasPrefix("lpayapp") || urlString.hasPrefix("lmslpay") {
      itunesUrl = "https://apps.apple.com/kr/app/l-point-with-l-pay/id473250588"
    } else if urlString.hasPrefix("naversearchapp") {
      itunesUrl = "https://apps.apple.com/kr/app/%EB%84%A4%EC%9D%B4%EB%B2%84-naver/id393499958"
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

/// ProxyApi implementation for `WKNavigationDelegate`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class NavigationDelegateProxyAPIDelegate: PigeonApiDelegateWKNavigationDelegate {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiWKNavigationDelegate) throws
    -> WKNavigationDelegate
  {
    return NavigationDelegateImpl(
      api: pigeonApi, registrar: pigeonApi.pigeonRegistrar as! ProxyAPIRegistrar)
  }
}
