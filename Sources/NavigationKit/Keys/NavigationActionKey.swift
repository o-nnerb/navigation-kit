// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

private struct NavigationActionKey: EnvironmentKey {

    static var defaultValue: NavigationAction? {
        nil
    }
}

extension EnvironmentValues {

    var _navigationAction: NavigationAction? {
        get { self[NavigationActionKey.self] }
        set { self[NavigationActionKey.self] = newValue }
    }

    /// The action that changes the navigation stack the view belongs to.
    ///
    /// The value is set by ``NKNavigationStack`` and, for the views of its detail column, by
    /// ``NKNavigationSplitView``. Reading it from a view that is not inside one of them is a
    /// programmer error and stops the program.
    ///
    /// ```swift
    /// struct ProfileButton: View {
    ///     @Environment(\.navigationAction) private var navigationAction
    ///
    ///     var body: some View {
    ///         Button("Profile") {
    ///             navigationAction.append(ProfileScene())
    ///         }
    ///     }
    /// }
    /// ```
    public var navigationAction: NavigationAction {
        guard let navigationAction = _navigationAction else {
            fatalError()
        }

        return navigationAction
    }
}
