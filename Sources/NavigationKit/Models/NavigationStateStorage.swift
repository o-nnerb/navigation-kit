// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

/// Owns the navigation state of a stack: a `NavigationState` where the system navigation is
/// available and a `FallbackNavigationState` everywhere else.
@MainActor
final class NavigationStateStorage: ObservableObject {

    let state: NavigationStateProtocol

    /// Not `nil` when the fallback implementation is in use.
    let fallback: FallbackNavigationState?

    private let system: AnyObject?

    init() {
        if NavigationBackend.usesFallback {
            let fallback = FallbackNavigationState()
            self.state = fallback
            self.fallback = fallback
            self.system = nil
        } else if #available(iOS 16.0, tvOS 16.0, macOS 13.0, *) {
            let system = NavigationState()
            self.state = system
            self.fallback = nil
            self.system = system
        } else {
            preconditionFailure("The fallback is always used where NavigationStack is unavailable")
        }
    }

    @available(iOS 16.0, tvOS 16.0, macOS 13.0, *)
    var systemState: NavigationState {
        guard let state = system as? NavigationState else {
            preconditionFailure("The system navigation state is not in use")
        }

        return state
    }
}
