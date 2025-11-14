#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'bootpay_webview_flutter_wkwebview'
  s.version          = '0.0.1'
  s.summary          = 'A WebView Plugin for Flutter (Bootpay Fork).'
  s.description      = <<-DESC
A Flutter plugin that provides a WebView widget for Bootpay.
Forked from webview_flutter_wkwebview for Korean payment environment.
                       DESC
  s.homepage         = 'https://github.com/bootpay/bootpay_webview_flutter_wkwebview'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Bootpay' => 'bootpay.co.kr' }
  s.source           = { :http => 'https://github.com/bootpay/bootpay_webview_flutter_wkwebview' }
  s.documentation_url = 'https://github.com/bootpay/bootpay_webview_flutter_wkwebview'
  s.source_files = 'bootpay_webview_flutter_wkwebview/Sources/bootpay_webview_flutter_wkwebview/**/*.swift'
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.resource_bundles = {'bootpay_webview_flutter_wkwebview_privacy' => ['bootpay_webview_flutter_wkwebview/Sources/bootpay_webview_flutter_wkwebview/Resources/PrivacyInfo.xcprivacy']}
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
    'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift',
  }
  s.swift_version = '5.0'
end
