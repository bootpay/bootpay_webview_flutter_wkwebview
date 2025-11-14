// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

#if os(iOS)
  import Flutter
  import UIKit
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

/// Implementation of `FlutterPlatformViewFactory` that retrieves the view from the `WebKitLibraryPigeonInstanceManager`.
class FlutterViewFactory: NSObject, FlutterPlatformViewFactory {
  unowned let instanceManager: WebKitLibraryPigeonInstanceManager

  #if os(iOS)
    class PlatformViewImpl: NSObject, FlutterPlatformView {
      let uiView: UIView

      init(uiView: UIView) {
        self.uiView = uiView
      }

      func view() -> UIView {
        return uiView
      }
    }
  #endif

  init(instanceManager: WebKitLibraryPigeonInstanceManager) {
    self.instanceManager = instanceManager
  }

  #if os(iOS)
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?)
      -> FlutterPlatformView
    {
      let identifier: Int64 = args is Int64 ? args as! Int64 : Int64(args as! Int32)
      let instance: AnyObject? = instanceManager.instance(forIdentifier: identifier)

      if let instance = instance as? FlutterPlatformView {
        instance.view().frame = frame
        return instance
      } else if let view = instance as? UIView {
        view.frame = frame
        return PlatformViewImpl(uiView: view)
      } else {
        // If instance is nil or not a UIView/FlutterPlatformView, create a default empty view
        let defaultView = UIView(frame: frame)
        defaultView.backgroundColor = .clear
        return PlatformViewImpl(uiView: defaultView)
      }
    }
  #elseif os(macOS)
    func create(
      withViewIdentifier viewId: Int64,
      arguments args: Any?
    ) -> NSView {
      let identifier: Int64 = args is Int64 ? args as! Int64 : Int64(args as! Int32)
      let instance: AnyObject? = instanceManager.instance(forIdentifier: identifier)
      if let view = instance as? NSView {
        return view
      } else {
        // If instance is nil or not an NSView, create a default empty view
        let defaultView = NSView()
        return defaultView
      }
    }
  #endif

  #if os(iOS)
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
      return FlutterStandardMessageCodec.sharedInstance()
    }
  #elseif os(macOS)
    func createArgsCodec() -> (FlutterMessageCodec & NSObjectProtocol)? {
      return FlutterStandardMessageCodec.sharedInstance()
    }
  #endif
}
