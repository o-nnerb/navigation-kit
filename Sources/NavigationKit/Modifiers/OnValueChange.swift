// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

extension View {

    /// Performs `action` with the new value whenever `value` changes.
    ///
    /// `onChange(of:perform:)` is the only form available on the minimum supported OS versions of
    /// most platforms, but it is deprecated on visionOS, where the two-parameter closure is used.
    func onValueChange<Value: Equatable>(
        of value: Value,
        perform action: @escaping (Value) -> Void
    ) -> some View {
        #if os(visionOS)
        onChange(of: value) { _, newValue in
            action(newValue)
        }
        #else
        onChange(of: value, perform: action)
        #endif
    }
}
