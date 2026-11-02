// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

#if canImport(AppKit) || (canImport(UIKit) && !os(watchOS))
import SwiftUI

#if canImport(AppKit)
import AppKit
#else
import UIKit
#endif

/// Hosts `view` in a window and lays it out, so its `body` is evaluated and its lifecycle
/// callbacks run. The returned window must be kept alive while the view is being tested.
@MainActor
func hostInWindow<Content: View>(_ view: Content) -> AnyObject {
    #if canImport(AppKit)
    _ = NSApplication.shared
    let hosting = NSHostingView(rootView: view)
    let window = NSWindow(
        contentRect: .init(x: 0, y: 0, width: 100, height: 100),
        styleMask: [.titled],
        backing: .buffered,
        defer: false
    )

    window.isReleasedWhenClosed = false
    window.contentView = hosting
    window.orderBack(nil)
    hosting.layoutSubtreeIfNeeded()
    return window
    #else
    let controller = UIHostingController(rootView: view)
    let window = UIWindow(frame: .init(x: 0, y: 0, width: 100, height: 100))
    window.rootViewController = controller
    window.makeKeyAndVisible()
    controller.view.layoutIfNeeded()
    return window
    #endif
}

/// Polls `condition` for up to three seconds.
@MainActor
func waitUntil(_ condition: () -> Bool) async {
    for _ in 0..<300 where !condition() {
        try? await Task.sleep(nanoseconds: 10_000_000)
    }
}
#endif
