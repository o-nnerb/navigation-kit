// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

extension NavigationAction {

    /// A value that describes the contents of a navigation stack in a serializable format.
    ///
    /// The representation saved on one OS version can be restored on any other supported one.
    ///
    /// Get it from ``NavigationAction/codable`` and pass it to the initializer of ``NKNavigationStack``
    /// to restore the stack, for example after the app is relaunched. The items are found again by the
    /// name of their type, so a type that was renamed or moved to another module cannot be decoded.
    public struct CodableRepresentation: Codable {

        let navigationPath: [String]
        let hashes: [Int]
    }
}
