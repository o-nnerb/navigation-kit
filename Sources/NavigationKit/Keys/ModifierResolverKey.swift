/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI

typealias ModifierResolver = Resolver<ObjectIdentifier, (AnyView) -> AnyView>

struct ModifierResolverKey: EnvironmentKey {
    static var defaultValue: ModifierResolver?
}

extension EnvironmentValues {

    var modifierResolver: ModifierResolver? {
        get { self[ModifierResolverKey.self] }
        set { self[ModifierResolverKey.self] = newValue }
    }
}
