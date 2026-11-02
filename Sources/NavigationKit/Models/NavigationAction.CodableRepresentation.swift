// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

extension NavigationAction {

    public struct CodableRepresentation: Codable {

        let navigationPath: NavigationPath.CodableRepresentation
        let hashes: [Int]
    }
}
