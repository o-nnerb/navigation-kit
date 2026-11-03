// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import Foundation

/// Whether a view is on screen, as tracked by ``SwiftUICore/View/viewState(_:)``.
///
/// A view model can keep a `ViewState` property to start loading data when its view appears and to
/// stop when it disappears, without depending on SwiftUI.
public enum ViewState {

    /// The view appeared.
    case active

    /// The view disappeared. It is also the value to start from, before the view appears.
    case inactive
}
