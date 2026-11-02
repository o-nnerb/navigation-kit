// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

#if os(iOS) || os(tvOS) || os(macOS)
import SwiftUI

/// The views the fallback navigation shows for each type of item.
///
/// `navigationDestination(for:)` does not exist before iOS 16, so `nkNavigationDestination` registers
/// the destinations here, and the fallback stack reads them from the view hierarchy.
struct FallbackDestinations {

    typealias Builder = (AnyHashable) -> AnyView?

    private var builders = [ObjectIdentifier: Builder]()

    init() {}

    init<Item: Hashable>(_ itemType: Item.Type, build: @escaping (Item) -> AnyView) {
        builders[ObjectIdentifier(itemType)] = { value in
            (value.base as? Item).map(build)
        }
    }

    func view(for value: AnyHashable) -> AnyView? {
        builders[ObjectIdentifier(type(of: value.base))]?(value)
    }

    /// The destinations of `other` take precedence over the ones of `self`.
    func merging(_ other: Self) -> Self {
        var merged = self
        merged.builders.merge(other.builders) { _, new in new }
        return merged
    }
}

struct FallbackDestinationsKey: PreferenceKey {

    static var defaultValue: FallbackDestinations {
        .init()
    }

    static func reduce(value: inout FallbackDestinations, nextValue: () -> FallbackDestinations) {
        value = value.merging(nextValue())
    }
}
#endif
