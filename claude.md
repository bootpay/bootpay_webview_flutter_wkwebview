# webview_flutter_wkwebview → bootpay_webview_flutter_wkwebview 포크 작업 가이드

이 문서는 Flutter 공식 `webview_flutter` 패키지를 Bootpay용으로 포크할 때 필요한 작업 목록입니다.

## 1. 패키지 이름 변경

### 1.1 pubspec.yaml 수정
```yaml
# 변경 전
name: webview_flutter_wkwebview
description: A Flutter plugin...

# 변경 후
name: bootpay_webview_flutter_wkwebview
description: webview_flutter_wkwebview 를 국내 결제환경에 맞게 fork 떠서 관리하는 프로젝트 입니다.
repository: https://github.com/bootpay/bootpay_webview_flutter_wkwebview
issue_tracker: https://github.com/bootpay/bootpay_webview_flutter_wkwebview/issues

flutter:
  plugin:
    implements: bootpay_webview_flutter_platform_interface  # 중요: platform interface 패키지를 구현
    platforms:
      ios:
        pluginClass: BTWebViewFlutterPlugin  # BT 접두사 사용
        dartPluginClass: BTWebKitWebViewPlatform
        sharedDarwinSource: true
      macos:
        pluginClass: BTWebViewFlutterPlugin
        dartPluginClass: BTWebKitWebViewPlatform
        sharedDarwinSource: true

dependencies:
  bootpay_webview_flutter_platform_interface:
    path: ../bootpay_webview_flutter_platform_interface
```

### 1.2 의존성 변경
- `webview_flutter_platform_interface` → `bootpay_webview_flutter_platform_interface`
- 로컬 경로 의존성 사용: `path: ../bootpay_webview_flutter_platform_interface`

## 2. Dart 파일 수정

### 2.1 메인 라이브러리 파일 이름 변경
```bash
mv lib/webview_flutter_wkwebview.dart lib/bootpay_webview_flutter_wkwebview.dart
```

### 2.2 모든 Dart 파일의 import 문 수정
`lib/src/` 디렉토리의 모든 파일에서:

```dart
// 변경 전
import 'package:bootpay_webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

// 변경 후
import 'package:bootpay_webview_flutter_platform_interface/bootpay_webview_flutter_platform_interface.dart';
```

수정할 파일들:
- `lib/src/common/instance_manager.dart`
- `lib/src/common/platform_webview_controller_creation_params.dart`
- `lib/src/common/web_kit.g.dart`
- `lib/src/common/weak_reference_utils.dart`
- `lib/src/foundation/foundation.dart`
- `lib/src/ui_kit/ui_kit.dart`
- `lib/src/webkit_proxy.dart`
- `lib/src/webkit_ssl_auth_error.dart`
- `lib/src/webkit_webview_controller.dart`
- `lib/src/webkit_webview_cookie_manager.dart`
- `lib/src/webkit_webview_platform.dart`

### 2.3 클래스 이름 변경 (필요시)
주요 클래스들:
- `WebKitWebViewPlatform` → `BTWebKitWebViewPlatform` (Dart 플러그인 클래스)

## 3. iOS/macOS 네이티브 코드 수정

### 3.1 podspec 파일 수정
```bash
# 파일 이름 변경
mv darwin/webview_flutter_wkwebview.podspec darwin/bootpay_webview_flutter_wkwebview.podspec
```

```ruby
# podspec 내용 수정
Pod::Spec.new do |s|
  s.name             = 'bootpay_webview_flutter_wkwebview'
  s.version          = '0.0.1'
  s.summary          = 'A WebView Plugin for Flutter (Bootpay Fork).'
  s.homepage         = 'https://github.com/bootpay/bootpay_webview_flutter_wkwebview'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Bootpay' => 'bootpay.co.kr' }

  s.source_files = 'bootpay_webview_flutter_wkwebview/Sources/bootpay_webview_flutter_wkwebview/**/*.swift'
  s.resource_bundles = {
    'bootpay_webview_flutter_wkwebview_privacy' => [
      'bootpay_webview_flutter_wkwebview/Sources/bootpay_webview_flutter_wkwebview/Resources/PrivacyInfo.xcprivacy'
    ]
  }
  s.public_header_files = 'bootpay_webview_flutter_wkwebview/Sources/bootpay_webview_flutter_wkwebview/**/*.h'
  s.module_map = 'bootpay_webview_flutter_wkwebview/Sources/bootpay_webview_flutter_wkwebview/include/bootpay_webview_flutter_wkwebview.modulemap'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
```

### 3.2 darwin 디렉토리 구조 변경
```bash
# 디렉토리 이름 변경
cd darwin
mv webview_flutter_wkwebview bootpay_webview_flutter_wkwebview

# Sources 내부도 확인
cd bootpay_webview_flutter_wkwebview/Sources
mv webview_flutter_wkwebview bootpay_webview_flutter_wkwebview
```

### 3.3 Swift 파일 수정

**WebViewFlutterPlugin.swift 핵심 수정:**
```swift
// 파일: darwin/bootpay_webview_flutter_wkwebview/Sources/bootpay_webview_flutter_wkwebview/WebViewFlutterPlugin.swift

// 클래스 이름을 BTWebViewFlutterPlugin으로 변경
public class BTWebViewFlutterPlugin: NSObject, FlutterPlugin {
  var proxyApiRegistrar: ProxyAPIRegistrar?

  init(binaryMessenger: FlutterBinaryMessenger) {
    proxyApiRegistrar = ProxyAPIRegistrar(
      binaryMessenger: binaryMessenger)
    proxyApiRegistrar?.setUp()
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    #if os(iOS)
      let binaryMessenger = registrar.messenger()
    #else
      let binaryMessenger = registrar.messenger
    #endif
    let plugin = BTWebViewFlutterPlugin(binaryMessenger: binaryMessenger)

    let viewFactory = FlutterViewFactory(instanceManager: plugin.proxyApiRegistrar!.instanceManager)
    // ⚠️ 충돌 방지: webview_flutter와 동시 사용을 위해 Bootpay 전용 네임스페이스 사용
    registrar.register(viewFactory, withId: "kr.co.bootpay/webview")
    registrar.publish(plugin)
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    proxyApiRegistrar!.ignoreCallsToDart = true
    proxyApiRegistrar!.tearDown()
    proxyApiRegistrar = nil
  }
}
```

**WebViewFlutterWKWebViewExternalAPI.swift 수정:**
```swift
// 파일: darwin/bootpay_webview_flutter_wkwebview/Sources/bootpay_webview_flutter_wkwebview/WebViewFlutterWKWebViewExternalAPI.swift

@objc(BTWebViewFlutterWKWebViewExternalAPI)
public class BTWebViewFlutterWKWebViewExternalAPI: NSObject {
  @objc(webViewForIdentifier:withPluginRegistry:)
  public static func webView(
    forIdentifier identifier: Int64, withPluginRegistry registry: FlutterPluginRegistry
  ) -> WKWebView? {
    // 플러그인 이름을 BTWebViewFlutterPlugin으로 수정
    let plugin = registry.valuePublished(byPlugin: "BTWebViewFlutterPlugin") as! BTWebViewFlutterPlugin

    let webView: WKWebView? = plugin.proxyApiRegistrar?.instanceManager.instance(
      forIdentifier: identifier)
    return webView
  }
}
```

### 3.4 Package.swift 수정
```swift
// darwin/bootpay_webview_flutter_wkwebview/Package.swift

let package = Package(
  name: "bootpay_webview_flutter_wkwebview",
  platforms: [
    .iOS("13.0"),
    .macOS("10.15")
  ],
  products: [
    .library(name: "bootpay-webview-flutter-wkwebview", targets: ["bootpay_webview_flutter_wkwebview"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "bootpay_webview_flutter_wkwebview",
      dependencies: [],
      exclude: ["include"],
      resources: [
        .process("Resources")
      ],
      cSettings: [
        .headerSearchPath("include/bootpay_webview_flutter_wkwebview")
      ]
    )
  ]
)
```

## 4. Example 앱 수정

### 4.1 example/pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  bootpay_webview_flutter_platform_interface:
    path: ../../bootpay_webview_flutter_platform_interface
  bootpay_webview_flutter_wkwebview:
    path: ../
```

### 4.2 example/lib/main.dart
```dart
// import 문 수정
import 'package:bootpay_webview_flutter_platform_interface/bootpay_webview_flutter_platform_interface.dart';
import 'package:bootpay_webview_flutter_wkwebview/bootpay_webview_flutter_wkwebview.dart';
```

## 5. 빌드 및 테스트

### 5.1 의존성 설치
```bash
# 루트에서
flutter pub get

# example에서
cd example
flutter pub get
```

### 5.2 iOS CocoaPods 설치
```bash
cd example/ios
pod install
cd ../..
```

### 5.3 빌드 테스트
```bash
# iOS 디바이스에서 테스트
flutter run -d <device-id>

# 또는 Xcode에서 직접 빌드
open example/ios/Runner.xcworkspace
```

## 6. 체크리스트

- [ ] `pubspec.yaml` 패키지명, implements, pluginClass 수정
- [ ] 메인 라이브러리 파일 이름 변경 (`lib/bootpay_webview_flutter_wkwebview.dart`)
- [ ] 모든 Dart 파일의 import 문 수정 (platform_interface 경로)
- [ ] podspec 파일 이름 및 내용 수정
- [ ] darwin 디렉토리 구조 변경
- [ ] `WebViewFlutterPlugin.swift`에서 클래스명을 `BTWebViewFlutterPlugin`으로 변경
- [ ] `WebViewFlutterWKWebViewExternalAPI.swift`에서 플러그인 참조 수정
- [ ] `Package.swift` 수정
- [ ] example/pubspec.yaml 의존성 수정
- [ ] example/lib/main.dart import 문 수정
- [ ] `flutter pub get` 실행
- [ ] `pod install` 실행
- [ ] 빌드 테스트 (iOS 디바이스)

## 7. 충돌 방지 처리 (필수!)

> ⚠️ **매우 중요**: 이 섹션의 처리를 하지 않으면 `webview_flutter`와 `bootpay_flutter_webview`를 동시에 사용할 때 충돌이 발생합니다!

### 7.1 플랫폼 뷰 타입 이름 변경

**문제**: 공식 `webview_flutter`와 플랫폼 뷰 타입 이름이 동일하면 Flutter 엔진에서 충돌 발생

**해결**: Bootpay 전용 네임스페이스 사용

#### Swift 네이티브 코드
**파일**: `darwin/bootpay_webview_flutter_wkwebview/Sources/bootpay_webview_flutter_wkwebview/WebViewFlutterPlugin.swift`

```swift
// ❌ 잘못된 예 (webview_flutter와 충돌)
registrar.register(viewFactory, withId: "plugins.flutter.io/webview")

// ✅ 올바른 예 (충돌 없음)
registrar.register(viewFactory, withId: "kr.co.bootpay/webview")
```

#### Dart 코드
**파일**: `lib/src/webkit_webview_controller.dart` (2군데)

```dart
// ❌ 잘못된 예
viewType: 'plugins.flutter.io/webview',

// ✅ 올바른 예
viewType: 'kr.co.bootpay/webview',
```

**파일**: `lib/src/legacy/webview_cupertino.dart` (1군데)

```dart
// ❌ 잘못된 예
viewType: 'plugins.flutter.io/webview',

// ✅ 올바른 예
viewType: 'kr.co.bootpay/webview',
```

### 7.2 변경 확인 방법

```bash
# 올바르게 변경되었는지 확인
grep -r "kr.co.bootpay/webview" .
# 결과: Swift 파일 1개, Dart 파일 3개에서 발견되어야 함

# 잘못된 값이 남아있는지 확인
grep -r "plugins.flutter.io/webview" .
# 결과: 아무것도 나오지 않아야 함 (주석, 문서 제외)
```

### 7.3 충돌 방지 테스트

실제로 두 패키지를 함께 사용하는 테스트 앱을 만들어 검증:

```yaml
# test_app/pubspec.yaml
dependencies:
  webview_flutter: ^4.0.0  # 공식 패키지
  bootpay_webview_flutter: ^3.0.0  # Bootpay 패키지
```

```dart
// 두 WebView를 동시에 사용
Column(
  children: [
    Expanded(
      child: webview_flutter.WebViewWidget(...),  // 공식
    ),
    Expanded(
      child: bootpay_webview_flutter.WebViewWidget(...),  // Bootpay
    ),
  ],
)
```

**성공 조건**:
- ✅ 두 WebView가 모두 정상 표시
- ✅ 에러나 충돌 없음
- ✅ 각각 독립적으로 작동

**실패 시 에러 예시**:
```
Error: The platform view type 'plugins.flutter.io/webview' is already registered.
```

## 8. 주의사항

### 8.1 네이밍 규칙
- **패키지명**: `bootpay_` 접두사 사용
- **iOS 네이티브 클래스**: `BT` 접두사 사용 (예: `BTWebViewFlutterPlugin`)
- **Dart 클래스**: `BT` 접두사 사용 (예: `BTWebKitWebViewPlatform`)

### 8.2 implements 필드 (매우 중요!)
- `implements` 필드는 **메인 패키지**를 지정해야 함
- 예: `implements: bootpay_webview_flutter` (bootpay_webview_flutter의 패키지명)
- ❌ 잘못된 예 1: `implements: bootpay_webview_flutter_wkwebview` (자기 자신을 implements하면 안됨)
- ❌ 잘못된 예 2: `implements: bootpay_webview_flutter_platform_interface` (인터페이스 패키지가 아닌 메인 패키지를 지정)

**이유**: Flutter의 플러그인 시스템은 3-tier 구조입니다:
1. 메인 패키지 (`bootpay_webview_flutter`) - 사용자가 import하는 패키지
2. 플랫폼 구현 (`bootpay_webview_flutter_wkwebview`) - iOS/macOS 구현
3. 플랫폼 인터페이스 (`bootpay_webview_flutter_platform_interface`) - 공통 인터페이스

메인 패키지가 `default_package`로 플랫폼 구현을 자동 선택하므로, 구현 패키지는 메인 패키지를 `implements`해야 합니다.

### 8.3 플랫폼 인터페이스
- 반드시 `bootpay_webview_flutter_platform_interface` 사용
- 로컬 경로 의존성으로 설정: `path: ../bootpay_webview_flutter_platform_interface`

### 8.4 iOS 네이티브 클래스명
- `GeneratedPluginRegistrant.m`이 자동으로 `BTWebViewFlutterPlugin`을 찾음
- pubspec.yaml의 `pluginClass`와 Swift 클래스명이 **정확히 일치**해야 함
- `WebViewFlutterWKWebViewExternalAPI.swift`의 플러그인 조회 시에도 동일한 이름 사용

### 8.5 iOS 26 UIScene Lifecycle 필수 적용
- **경고**: `UIScene lifecycle will soon be required. Failure to adopt will result in an assert in the future.`
- iOS 13부터 도입된 UIScene lifecycle이 iOS 26에서 필수가 될 예정
- **해결 방법**:

#### 1. Info.plist에 UIApplicationSceneManifest 추가
```xml
<key>UIApplicationSceneManifest</key>
<dict>
    <key>UIApplicationSupportsMultipleScenes</key>
    <false/>
    <key>UISceneConfigurations</key>
    <dict>
        <key>UIWindowSceneSessionRoleApplication</key>
        <array>
            <dict>
                <key>UISceneConfigurationName</key>
                <string>Default Configuration</string>
                <key>UISceneDelegateClassName</key>
                <string>SceneDelegate</string>
                <key>UISceneStoryboardFile</key>
                <string>Main</string>
            </dict>
        </array>
    </dict>
</dict>
```

#### 2. AppDelegate.m에 UISceneSession lifecycle 메서드 추가
```objc
#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application
    configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession
                                   options:(UISceneConnectionOptions *)options {
  return [[UISceneConfiguration alloc] initWithName:@"Default Configuration"
                                         sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application
    didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
  // Release resources specific to discarded scenes
}
```

#### 3. SceneDelegate.h 생성
```objc
#import <UIKit/UIKit.h>

@interface SceneDelegate : UIResponder <UIWindowSceneDelegate>
@property (strong, nonatomic) UIWindow *window;
@end
```

#### 4. SceneDelegate.m 생성
```objc
#import "SceneDelegate.h"

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // Scene setup
}

- (void)sceneDidDisconnect:(UIScene *)scene { }
- (void)sceneDidBecomeActive:(UIScene *)scene { }
- (void)sceneWillResignActive:(UIScene *)scene { }
- (void)sceneWillEnterForeground:(UIScene *)scene { }
- (void)sceneDidEnterBackground:(UIScene *)scene { }

@end
```

### 8.6 알려진 이슈
- **Asset Catalog 에러**: "Failed to launch AssetCatalogSimulatorAgent via CoreSimulator spawn"
  - 이는 macOS/Xcode 시스템 이슈로 코드 문제가 아님
  - 해결 방법:
    1. Xcode에서 직접 빌드
    2. CoreSimulator 재시작: `killall -9 com.apple.CoreSimulator.CoreSimulatorService`
    3. USB 유선 연결 사용 (무선 대신)

## 9. 참고 링크

- [Flutter Plugin 개발 가이드](https://docs.flutter.dev/packages-and-plugins/developing-packages)
- [CocoaPods Podspec 문법](https://guides.cocoapods.org/syntax/podspec.html)
- [Swift Package Manager](https://swift.org/package-manager/)
- [전체 프로젝트 Fork 업데이트 가이드](../FORK_UPDATE_GUIDE.md) - 새 버전 업데이트 시 참고
