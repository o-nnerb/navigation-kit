//
//  File.swift
//  
//
//  Created by Brenno on 23/02/23.
//

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
