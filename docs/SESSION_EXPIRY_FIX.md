# iOS 외부 앱 복귀 시 세션 만료 문제 해결

## 문제 현상

- **환경**: iOS
- **시나리오**: 현대카드 앱카드 결제
- **증상**:
  1. Bootpay.requestPayment 호출
  2. Bootpay webview에서 PG사 페이지 로드
  3. 앱카드 결제로 현대카드 외부앱 실행
  4. 외부앱에서 결제 후 webview로 복귀
  5. **결제완료 버튼 클릭 시 반응 없음**
  6. `[A001]: 세션이 만료되어 더 이상 처리가 불가능합니다` 팝업 발생

## 원인 분석

### 핵심 원인: WKProcessPool 미공유

iOS의 WKWebView는 세션/쿠키를 `WKProcessPool` 단위로 관리합니다. 현재 코드에서는 `WKWebViewConfiguration` 생성 시 processPool을 명시적으로 설정하지 않아, 매번 새로운 processPool이 생성됩니다.

**문제 코드 위치**: `darwin/bootpay_webview_flutter_wkwebview/Sources/bootpay_webview_flutter_wkwebview/WebViewConfigurationProxyAPIDelegate.swift`

```swift
// 현재 코드 (문제)
func pigeonDefaultConstructor(pigeonApi: PigeonApiWKWebViewConfiguration) throws
  -> WKWebViewConfiguration
{
  return WKWebViewConfiguration()  // processPool 미설정
}
```

### 문제 발생 시나리오

```
1. 결제 시작 → WKWebView 생성 (processPool A, 세션 생성)
          ↓
2. 현대카드 앱으로 이동 → Flutter 앱 백그라운드 전환
          ↓
3. iOS 메모리 관리로 앱 상태 초기화 또는 종료
          ↓
4. 현대카드에서 복귀 → 앱 재시작 → 새 WKWebView 생성 (processPool B)
          ↓
5. processPool이 다름 → 기존 세션 없음 → "세션 만료" 에러
```

### 현재 설정 상태

| 설정 | 파일 | 상태 |
|------|------|------|
| HTTPCookieStorage.cookieAcceptPolicy | WebViewProxyAPIDelegate.swift:20 | `.always` 설정됨 (WKHTTPCookieStore와 별개) |
| WKWebsiteDataStore | WebsiteDataStoreProxyAPIDelegate.swift:13 | `.default()` 사용 (영구 저장소, 정상) |
| WKProcessPool | WebViewConfigurationProxyAPIDelegate.swift | **미설정 (문제)** |

## 해결 방법

### 1. WKProcessPool 공유 설정 (필수)

**파일**: `darwin/bootpay_webview_flutter_wkwebview/Sources/bootpay_webview_flutter_wkwebview/WebViewConfigurationProxyAPIDelegate.swift`

```swift
import WebKit

// 전역 싱글톤 ProcessPool - 모든 WKWebView가 공유
private let sharedProcessPool = WKProcessPool()

class WebViewConfigurationProxyAPIDelegate: PigeonApiDelegateWKWebViewConfiguration {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiWKWebViewConfiguration) throws
    -> WKWebViewConfiguration
  {
    let config = WKWebViewConfiguration()
    // 공유 processPool 설정 - 세션 유지에 필수!
    config.processPool = sharedProcessPool
    return config
  }

  // ... 나머지 메서드는 그대로 유지
}
```

### 2. 쿠키 동기화 강화 (권장)

**파일**: `darwin/bootpay_webview_flutter_wkwebview/Sources/bootpay_webview_flutter_wkwebview/WebViewProxyAPIDelegate.swift`

`WebViewImpl` 클래스의 init에 쿠키 동기화 로직 추가:

```swift
init(
  api: PigeonApiProtocolWKWebView, registrar: ProxyAPIRegistrar, frame: CGRect,
  configuration: WKWebViewConfiguration
) {
  self.api = api
  self.registrar = registrar
  super.init(frame: frame, configuration: configuration)

  // 기존 설정
  HTTPCookieStorage.shared.cookieAcceptPolicy = .always

  // 추가: WKHTTPCookieStore ↔ HTTPCookieStorage 동기화
  if #available(iOS 11.0, *) {
    configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
      for cookie in cookies {
        HTTPCookieStorage.shared.setCookie(cookie)
      }
    }
  }

  #if os(iOS)
    scrollView.contentInsetAdjustmentBehavior = .never
    scrollView.automaticallyAdjustsScrollIndicatorInsets = false
  #endif
}
```

## 수정 후 효과

1. 모든 WKWebView 인스턴스가 동일한 processPool 공유
2. 외부 앱에서 복귀해도 세션/쿠키 유지
3. 앱이 백그라운드에서 종료되었다가 재시작되어도 세션 유지 가능성 증가

## 테스트 체크리스트

- [ ] 현대카드 앱카드 결제 후 복귀 시 결제완료 버튼 정상 동작
- [ ] 삼성카드, 신한카드 등 다른 카드사 앱에서도 동일하게 테스트
- [ ] 장시간 외부 앱에 머문 후 복귀 시에도 세션 유지 확인
- [ ] 앱 강제 종료 후 외부 앱에서 복귀 시나리오 테스트

## 참고 자료

- [Apple Developer - WKProcessPool](https://developer.apple.com/documentation/webkit/wkprocesspool)
- [WKWebView Cookie Management](https://developer.apple.com/documentation/webkit/wkhttpcookiestore)

## 변경 이력

| 날짜 | 작성자 | 내용 |
|------|--------|------|
| 2024-12-24 | Claude | 최초 작성 - 문제 분석 및 해결책 정리 |
