/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI

extension NavigationAction {

    public struct CodableRepresentation: Codable {

        let navigationPath: NavigationPath.CodableRepresentation
        let hashes: [Int]
    }
}
