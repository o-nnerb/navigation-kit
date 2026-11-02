// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

extension NavigationAction {

    /// A value that describes the contents of a navigation stack in a serializable format.
    ///
    /// The representation saved on one OS version can be restored on any other supported one.
    public struct CodableRepresentation: Codable {

        let navigationPath: [String]
        let hashes: [Int]
    }
}
