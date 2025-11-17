# Async Pattern Analysis - registrar.dispatchOnMainThread

이 문서는 bootpay_webview_flutter_wkwebview에서 사용하는 모든 `registrar.dispatchOnMainThread` 패턴을 분석하고, 네이티브 이벤트를 방해할 수 있는 패턴을 식별합니다.

## 요약

**총 22개의 `registrar.dispatchOnMainThread` 인스턴스를 분석한 결과:**

- ✅ **21개는 정상** - 의도적으로 비동기 Dart 콜백을 사용하며, v2 구현과 일치
- ❌ **1개는 문제** - 팝업 생성을 방해 (이미 수정됨)

## 분석 결과

### 카테고리 1: 정보성 콜백 (SAFE - 비동기 OK)

이벤트를 Dart에 통지만 하며, 네이티브 응답이 필요 없는 패턴:

| 파일 | 메서드 | 라인 | 설명 | 상태 |
|------|--------|------|------|------|
| NavigationDelegateProxyAPIDelegate.swift | `didFinishNavigation` | 18 | 페이지 로딩 완료 통지 | ✅ 정상 |
| NavigationDelegateProxyAPIDelegate.swift | `didStartProvisionalNavigation` | 31 | 페이지 로딩 시작 통지 | ✅ 정상 |
| NavigationDelegateProxyAPIDelegate.swift | `didFailNavigation` | 45 | 네비게이션 실패 통지 | ✅ 정상 |
| NavigationDelegateProxyAPIDelegate.swift | `didFailProvisionalNavigation` | 59 | 임시 네비게이션 실패 통지 | ✅ 정상 |
| NavigationDelegateProxyAPIDelegate.swift | `webViewWebContentProcessDidTerminate` | 71 | 웹 프로세스 종료 통지 | ✅ 정상 |
| ScrollViewDelegateProxyAPIDelegate.swift | `scrollViewDidScroll` | 21 | 스크롤 위치 변경 통지 | ✅ 정상 |
| NSObjectProxyAPIDelegate.swift | `observeValue` | 49 | KVO 프로퍼티 변경 통지 | ✅ 정상 |
| ScriptMessageHandlerProxyAPIDelegate.swift | `didReceiveScriptMessage` | 20 | JavaScript 메시지 수신 | ✅ 정상 |

**결론**: 이들은 단순 통지이므로 비동기 처리가 적절함.

---

### 카테고리 2: 결정 핸들러 (SAFE - v2와 동일한 패턴)

네이티브 응답이 필요하지만, 비동기 Dart 콜백 내에서 핸들러를 호출하는 패턴:

#### 2.1 Navigation Policy Decisions

**파일**: `NavigationDelegateProxyAPIDelegate.swift`

##### `decidePolicyForNavigationAction` (라인 82-185, 2개 인스턴스)

```swift
// ✅ 정상: App-to-App URL은 동기 처리
if isItunesURL(url) {
    startAppToApp(URL(string: url)!)
    decisionHandler(.cancel)  // ← 즉시 호출
    return
} else if !url.hasPrefix("http") {
    startAppToApp(URL(string: url)!)
    decisionHandler(.cancel)  // ← 즉시 호출
    return
}

// ✅ 정상: HTTP URL은 비동기 Dart 콜백 사용 (v2와 동일)
registrar.dispatchOnMainThread { onFailure in
    self.api.decidePolicyForNavigationAction(...) { result in
        DispatchQueue.main.async {
            switch result {
            case .success(let policy):
                decisionHandler(policy)  // ← 비동기 콜백 내부에서 호출
            case .failure:
                decisionHandler(.cancel)
            }
        }
    }
}
```

**v2 비교 (BTNavigationDelegateHostApi.m:197-228)**:
```objc
// v2도 동일한 패턴 사용
if([self isItunesURL:url]) {
    [self startAppToApp:[NSURL URLWithString:url]];
    decisionHandler(WKNavigationActionPolicyCancel);  // 동기
} else if(![url hasPrefix:@"http"]) {
    [self startAppToApp:[NSURL URLWithString:url]];
    decisionHandler(WKNavigationActionPolicyCancel);  // 동기
} else {
    dispatch_async(dispatch_get_main_queue(), ^{  // 비동기
        [self.navigationDelegateAPI decidePolicyForNavigationActionForDelegate:...
            completion:^(...) {
                decisionHandler(...);  // 비동기 콜백 내부
            }];
    });
}
```

**결론**: ✅ **정상** - v2와 동일한 패턴, 의도적 설계

| 인스턴스 | 라인 | Compiler | 상태 |
|----------|------|----------|------|
| 1 | 103 | `#if compiler(>=6.0)` | ✅ 정상 |
| 2 | 153 | `#else` | ✅ 정상 |

##### `decidePolicyForNavigationResponse` (라인 187-261, 2개 인스턴스)

```swift
// ✅ 정상: 비동기 Dart 콜백 사용 (v2와 동일)
registrar.dispatchOnMainThread { onFailure in
    self.api.decidePolicyForNavigationResponse(...) { result in
        DispatchQueue.main.async {
            switch result {
            case .success(let policy):
                decisionHandler(policy)
            case .failure:
                decisionHandler(.cancel)
            }
        }
    }
}
```

**결론**: ✅ **정상** - v2와 동일한 패턴

| 인스턴스 | 라인 | Compiler | 상태 |
|----------|------|----------|------|
| 1 | 192 | `#if compiler(>=6.0)` | ✅ 정상 |
| 2 | 229 | `#else` | ✅ 정상 |

#### 2.2 Authentication Challenge

**파일**: `NavigationDelegateProxyAPIDelegate.swift`

##### `didReceiveAuthenticationChallenge` (라인 263-308, 2개 인스턴스)

```swift
// ✅ 정상: 비동기 Dart 콜백 사용
registrar.dispatchOnMainThread { onFailure in
    self.api.didReceiveAuthenticationChallenge(...) { result in
        DispatchQueue.main.async {
            switch result {
            case .success(let response):
                completionHandler(response.disposition, response.credential)
            case .failure:
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        }
    }
}
```

**결론**: ✅ **정상** - Dart가 인증 결정을 내릴 수 있도록 의도적 설계

| 인스턴스 | 라인 | Compiler | 상태 |
|----------|------|----------|------|
| 1 | 270 | `#if compiler(>=6.0)` | ✅ 정상 |
| 2 | 292 | `#else` | ✅ 정상 |

---

### 카테고리 3: 권한 및 UI 핸들러 (SAFE - v2와 동일한 패턴)

**파일**: `UIDelegateProxyAPIDelegate.swift`

#### 3.1 Media Capture Permission

##### `requestMediaCapturePermission` (라인 42-128, 2개 인스턴스)

```swift
// ✅ 정상: 비동기 Dart 콜백 사용
registrar.dispatchOnMainThread { onFailure in
    self.api.requestMediaCapturePermission(...) { result in
        DispatchQueue.main.async {
            switch result {
            case .success(let decision):
                decisionHandler(decision)  // .deny, .grant, .prompt
            case .failure:
                decisionHandler(.deny)
            }
        }
    }
}
```

**결론**: ✅ **정상** - Dart가 카메라/마이크 권한을 제어할 수 있도록 설계

| 인스턴스 | 라인 | Compiler | 상태 |
|----------|------|----------|------|
| 1 | 61 | `#if compiler(>=6.0)` | ✅ 정상 |
| 2 | 104 | `#else` | ✅ 정상 |

#### 3.2 JavaScript Alert Panel

##### `runJavaScriptAlertPanel` (라인 135-171, 2개 인스턴스)

```swift
// ✅ 정상: 비동기 Dart 콜백 사용
registrar.dispatchOnMainThread { onFailure in
    self.api.runJavaScriptAlertPanel(...) { result in
        DispatchQueue.main.async {
            if case .failure(let error) = result {
                onFailure("WKUIDelegate.runJavaScriptAlertPanel", error)
            }
            completionHandler()  // alert 표시 후 호출
        }
    }
}
```

**결론**: ✅ **정상** - Dart가 커스텀 alert UI를 제공할 수 있도록 설계

| 인스턴스 | 라인 | Compiler | 상태 |
|----------|------|----------|------|
| 1 | 140 | `#if compiler(>=6.0)` | ✅ 정상 |
| 2 | 158 | `#else` | ✅ 정상 |

#### 3.3 JavaScript Confirm Panel

##### `runJavaScriptConfirmPanel` (라인 173-215, 2개 인스턴스)

```swift
// ✅ 정상: 비동기 Dart 콜백 사용
registrar.dispatchOnMainThread { onFailure in
    self.api.runJavaScriptConfirmPanel(...) { result in
        DispatchQueue.main.async {
            switch result {
            case .success(let confirmed):
                completionHandler(confirmed)  // true/false
            case .failure:
                completionHandler(false)
            }
        }
    }
}
```

**결론**: ✅ **정상** - Dart가 커스텀 confirm UI를 제공할 수 있도록 설계

| 인스턴스 | 라인 | Compiler | 상태 |
|----------|------|----------|------|
| 1 | 178 | `#if compiler(>=6.0)` | ✅ 정상 |
| 2 | 199 | `#else` | ✅ 정상 |

#### 3.4 JavaScript Text Input Panel

##### `runJavaScriptTextInputPanel` (라인 217-259, 2개 인스턴스)

```swift
// ✅ 정상: 비동기 Dart 콜백 사용
registrar.dispatchOnMainThread { onFailure in
    self.api.runJavaScriptTextInputPanel(...) { result in
        DispatchQueue.main.async {
            switch result {
            case .success(let response):
                completionHandler(response)  // String?
            case .failure:
                completionHandler(nil)
            }
        }
    }
}
```

**결론**: ✅ **정상** - Dart가 커스텀 prompt UI를 제공할 수 있도록 설계

| 인스턴스 | 라인 | Compiler | 상태 |
|----------|------|----------|------|
| 1 | 223 | `#if compiler(>=6.0)` | ✅ 정상 |
| 2 | 246 | `#else` | ✅ 정상 |

---

### 카테고리 4: 문제 패턴 (FIXED)

**파일**: `UIDelegateProxyAPIDelegate.swift`

#### `webView(_:createWebViewWith:...)` - 팝업 생성

**이전 코드 (문제):**
```swift
// ❌ 문제: 비동기 Dart 콜백이 팝업 생성을 방해
registrar.dispatchOnMainThread { onFailure in
    self.api.onCreateWebView(
        pigeonInstance: self, webView: webView, configuration: configuration,
        navigationAction: navigationAction
    ) { result in
        if case .failure(let error) = result {
            onFailure("WKUIDelegate.onCreateWebView", error)
        }
    }
}

return nil  // ← 팝업이 생성되지 않음!
```

**수정된 코드:**
```swift
// ✅ 수정: 팝업을 즉시 반환, Dart 콜백 제거
// Lines 35-39
// Note: Removed Dart callback to prevent popup creation issues
// Handle popup entirely in native code for better stability
// This matches bootpay_flutter_webview 2 implementation
return popupView
```

**v2 비교 (BTUIDelegateHostApi.m:181-196)**:
```objc
// v2도 즉시 반환
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
           forNavigationAction:(WKNavigationAction *)navigationAction
                windowFeatures:(WKWindowFeatures *)windowFeatures {
    // ... 팝업 생성 ...
    return popupView;  // ← 즉시 반환, 비동기 콜백 없음
}
```

**결론**: ✅ **수정 완료** - v2 패턴과 일치하도록 변경

---

## 핵심 인사이트

### 1. 정상적인 비동기 패턴의 특징

다음과 같은 경우 비동기 Dart 콜백이 **의도적이며 정상**입니다:

1. **정보성 이벤트**: 네이티브 응답이 필요 없는 통지
   - 예: `didFinishNavigation`, `scrollViewDidScroll`

2. **결정 위임**: Dart에서 결정을 내려야 하는 경우
   - 예: `decidePolicyForNavigationAction` (HTTP URL), `requestMediaCapturePermission`
   - 핸들러가 비동기 콜백 **내부**에서 호출됨

3. **UI 커스터마이징**: Dart에서 커스텀 UI를 제공하는 경우
   - 예: `runJavaScriptAlertPanel`, `runJavaScriptConfirmPanel`

### 2. 문제가 되는 패턴의 특징

다음과 같은 경우 비동기 Dart 콜백이 **문제**가 됩니다:

1. **즉시 반환이 필요한 경우**: 메서드의 반환 값이 네이티브 객체인 경우
   - 예: `createWebViewWith` - `WKWebView` 인스턴스를 즉시 반환해야 함
   - ❌ 잘못: 비동기 콜백 내부에서 생성 → `nil` 반환
   - ✅ 올바름: 동기적으로 생성하고 즉시 반환

2. **동기 응답이 필수인 경우**: WebKit이 즉시 응답을 요구하는 경우
   - App-to-App URL 처리는 동기적으로 처리됨 (현재 구현 ✅)

### 3. V2와의 비교 결과

| 패턴 | 현재 구현 | V2 구현 | 일치 여부 |
|------|-----------|---------|-----------|
| App-to-App URL 처리 | 동기 | 동기 | ✅ 일치 |
| HTTP URL 네비게이션 결정 | 비동기 Dart 콜백 | 비동기 Dart 콜백 | ✅ 일치 |
| 팝업 생성 | 즉시 반환 (수정 후) | 즉시 반환 | ✅ 일치 |
| JavaScript alert/confirm/prompt | 비동기 Dart 콜백 | (v2에서 확인 필요) | - |
| 정보성 이벤트 | 비동기 Dart 콜백 | 비동기 Dart 콜백 | ✅ 일치 |

---

## 권장 사항

### 새로운 코드 작성 시 가이드라인

1. **즉시 반환이 필요한 메서드**:
   ```swift
   // ✅ 올바름: 동기 처리
   func methodThatReturnsObject() -> SomeObject {
       let obj = createObject()
       return obj  // 즉시 반환
   }
   ```

   ```swift
   // ❌ 잘못: 비동기 콜백 사용
   func methodThatReturnsObject() -> SomeObject? {
       registrar.dispatchOnMainThread { ... }
       return nil  // 항상 nil 반환!
   }
   ```

2. **핸들러/completionHandler가 있는 메서드**:
   ```swift
   // ✅ 올바름: 비동기 콜백 내부에서 핸들러 호출
   func methodWithHandler(handler: @escaping (Result) -> Void) {
       registrar.dispatchOnMainThread { onFailure in
           self.api.someMethod(...) { result in
               DispatchQueue.main.async {
                   handler(result)  // 콜백 내부에서 호출
               }
           }
       }
   }
   ```

3. **동기 응답이 필수인 경우**:
   ```swift
   // ✅ 올바름: 특정 조건은 동기 처리
   if needsImmediateResponse {
       handler(.cancel)
       return
   }

   // 나머지는 비동기 처리
   registrar.dispatchOnMainThread { ... }
   ```

---

## 체크리스트

새로운 delegate 메서드를 추가할 때:

- [ ] 메서드가 객체를 **즉시 반환**해야 하는가?
  - ✅ 예 → 동기 처리, Dart 콜백 제거
  - ❌ 아니오 → 다음 단계로

- [ ] 메서드가 **핸들러/completionHandler**를 받는가?
  - ✅ 예 → 비동기 Dart 콜백 사용, 콜백 내부에서 핸들러 호출
  - ❌ 아니오 → 정보성 이벤트, 비동기 Dart 콜백 사용

- [ ] **동기 응답이 필수**인 특수한 경우가 있는가?
  - ✅ 예 → 해당 케이스는 동기 처리 (예: App-to-App URL)
  - ❌ 아니오 → 비동기 처리

- [ ] **V2 구현**과 비교했는가?
  - ✅ 예 → 동일한 패턴 사용
  - ❌ 아니오 → V2 코드 확인 필요

---

## 참고 파일

- **현재 구현**: `/Users/taesupyoon/bootpay/client/flutter/bootpay/bootpay_flutter_webview/bootpay_webview_flutter_wkwebview/darwin/`
- **V2 참조**: `/Users/taesupyoon/bootpay/client/flutter/bootpay/bootpay_flutter_webview 2/bootpay_webview_flutter_wkwebview/ios/Classes/`

---

**마지막 업데이트**: 2025-01-17
**분석 범위**: 22개 `registrar.dispatchOnMainThread` 인스턴스 전체
