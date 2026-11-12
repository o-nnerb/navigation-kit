// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import Foundation

#if canImport(UIKit)
import UIKit
#endif

/// Polls `condition` for up to three seconds.
@MainActor
func waitUntil(_ condition: () -> Bool) async {
    for _ in 0..<300 where !condition() {
        try? await Task.sleep(nanoseconds: 10_000_000)
    }
}

/// Polls `condition` for up to thirty seconds, keeping `window` the key window meanwhile.
///
/// The tests run in parallel and every window they host becomes the key window. On visionOS a sheet
/// or a popover only finishes appearing while the window that presents it is the key one, so a
/// presentation started while another test takes the key window stays on screen without its content
/// ever appearing. Taking the key window back lets it finish.
///
/// It is long because the first presentation on a simulator that has just booted can take several
/// seconds. It returns as soon as the condition holds, so the limit only matters when a test fails.
@MainActor
func waitUntil(keeping window: AnyObject, _ condition: () -> Bool) async {
    for _ in 0..<3000 where !condition() {
        #if canImport(UIKit) && !os(watchOS)
        if let window = window as? UIWindow, !window.isKeyWindow {
            window.makeKey()
        }
        #endif

        try? await Task.sleep(nanoseconds: 10_000_000)
    }
}
