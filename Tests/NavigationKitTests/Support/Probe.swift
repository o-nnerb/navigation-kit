// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

#if canImport(AppKit) || (canImport(UIKit) && !os(watchOS))
import SwiftUI

/// A small view that reports when it appears, so a test can tell what was built on screen.
struct Probe: View {

    let onAppear: @MainActor () -> Void

    init(_ onAppear: @escaping @MainActor () -> Void) {
        self.onAppear = onAppear
    }

    var body: some View {
        Color.clear
            .frame(width: 50, height: 50)
            .onAppear(perform: onAppear)
    }
}
#endif
