// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import Foundation

/// Chooses between the system navigation (`NavigationStack`, iOS 16 / tvOS 16 / macOS 13) and the
/// fallback implementation used on the earlier OS versions NavigationKit supports.
///
/// watchOS 9 and visionOS 1 already have `NavigationStack`, so they never use the fallback.
@MainActor
enum NavigationBackend {

    /// Forces the fallback implementation on every OS version that has one. Used by the tests to
    /// exercise it on OS versions where the system navigation is available.
    static var forcesFallback = false

    static var usesFallback: Bool {
        #if os(iOS) || os(tvOS) || os(macOS)
        if forcesFallback {
            return true
        }

        if #available(iOS 16.0, tvOS 16.0, macOS 13.0, *) {
            return false
        }

        return true
        #else
        return false
        #endif
    }
}
