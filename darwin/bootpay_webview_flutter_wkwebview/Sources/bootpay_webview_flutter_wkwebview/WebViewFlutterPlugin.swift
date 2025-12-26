// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

public class BTWebViewFlutterPlugin: NSObject, FlutterPlugin {
  var proxyApiRegistrar: ProxyAPIRegistrar?
  var warmUpMethodChannel: BootpayWarmUpMethodChannel?

  init(binaryMessenger: FlutterBinaryMessenger) {
    proxyApiRegistrar = ProxyAPIRegistrar(
      binaryMessenger: binaryMessenger)
    proxyApiRegistrar?.setUp()

    // Register WarmUp Method Channel
    warmUpMethodChannel = BootpayWarmUpMethodChannel()
    warmUpMethodChannel?.register(with: binaryMessenger)
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    #if os(iOS)
      let binaryMessenger = registrar.messenger()
    #else
      let binaryMessenger = registrar.messenger
    #endif
    let plugin = BTWebViewFlutterPlugin(binaryMessenger: binaryMessenger)

    let viewFactory = FlutterViewFactory(instanceManager: plugin.proxyApiRegistrar!.instanceManager)
    registrar.register(viewFactory, withId: "kr.co.bootpay/webview")
    registrar.publish(plugin)
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    proxyApiRegistrar!.ignoreCallsToDart = true
    proxyApiRegistrar!.tearDown()
    proxyApiRegistrar = nil

    // Dispose WarmUp Method Channel
    warmUpMethodChannel?.dispose()
    warmUpMethodChannel = nil
  }
}
