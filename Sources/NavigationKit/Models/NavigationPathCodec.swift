// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

/// Converts `NavigationPath.CodableRepresentation` from and to the flat array of strings it is
/// encoded as, which is what `NavigationAction.CodableRepresentation` stores on every OS version.
@available(iOS 16.0, tvOS 16.0, macOS 13.0, *)
enum NavigationPathCodec {

    static func strings(from representation: NavigationPath.CodableRepresentation) -> [String]? {
        guard let data = try? JSONEncoder().encode(representation) else {
            return nil
        }

        return try? JSONDecoder().decode([String].self, from: data)
    }

    static func path(from strings: [String]) -> NavigationPath? {
        guard
            let data = try? JSONEncoder().encode(strings),
            let representation = try? JSONDecoder().decode(
                NavigationPath.CodableRepresentation.self,
                from: data
            )
        else {
            return nil
        }

        return NavigationPath(representation)
    }
}
