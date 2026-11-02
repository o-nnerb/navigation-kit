// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import Foundation

/// A type-erased item of the fallback navigation stack.
struct NavigationEntry: Identifiable {

    let id = UUID()
    let value: AnyHashable

    /// The JSON of the value. Only items that are `Codable` have one.
    private let encodeValue: (() throws -> String)?

    var hash: Int {
        value.hashValue
    }

    init<Item: Hashable>(_ item: Item) {
        self.value = AnyHashable(item)
        self.encodeValue = nil
    }

    init<Item: Hashable & Codable>(_ item: Item) {
        self.value = AnyHashable(item)
        self.encodeValue = {
            String(decoding: try JSONEncoder().encode(item), as: UTF8.self)
        }
    }

    var isCodable: Bool {
        encodeValue != nil
    }

    func encoded() -> (typeName: String, json: String)? {
        guard let encodeValue, let json = try? encodeValue() else {
            return nil
        }

        return (_typeName(type(of: value.base), qualified: true), json)
    }
}

// MARK: - Codec

/// Reads and writes the same flat format `NavigationPath.CodableRepresentation` uses, so the
/// representation saved by the fallback restores the system navigation, and the other way around.
///
/// The format is an array of strings: the items from the last one to the first one, each one as its
/// qualified type name followed by its JSON.
enum NavigationEntryCodec {

    static func encode(_ entries: [NavigationEntry]) -> [String]? {
        var strings = [String]()

        for entry in entries.reversed() {
            guard let (typeName, json) = entry.encoded() else {
                return nil
            }

            strings.append(typeName)
            strings.append(json)
        }

        return strings
    }

    static func decode(_ strings: [String]) -> [NavigationEntry]? {
        guard strings.count.isMultiple(of: 2) else {
            return nil
        }

        var entries = [NavigationEntry]()

        for index in stride(from: 0, to: strings.count, by: 2) {
            guard
                let type = resolve(strings[index]) as? any (Hashable & Codable).Type,
                let entry = decode(type, from: Data(strings[index + 1].utf8))
            else {
                return nil
            }

            entries.append(entry)
        }

        return entries.reversed()
    }

    private static func decode<Item: Hashable & Codable>(
        _ type: Item.Type,
        from data: Data
    ) -> NavigationEntry? {
        (try? JSONDecoder().decode(type, from: data)).map { NavigationEntry($0) }
    }

    /// Finds a type from its qualified name (`Module.Type`, `Module.Outer.Inner`).
    ///
    /// The runtime only resolves mangled names, so the name is mangled again trying structure, enum
    /// and class for each nested type. Generic, private and local types are not resolved.
    static func resolve(_ qualifiedName: String) -> Any.Type? {
        if let type = _typeByName(qualifiedName) {
            return type
        }

        let components = qualifiedName.split(separator: ".").map(String.init)

        guard components.count >= 2 else {
            return nil
        }

        func mangled(_ name: String) -> String {
            "\(name.utf8.count)\(name)"
        }

        func resolve(_ index: Int, _ prefix: String) -> Any.Type? {
            for kind in ["V", "O", "C"] {
                let candidate = prefix + mangled(components[index]) + kind

                if index == components.count - 1 {
                    if let type = _typeByName(candidate) {
                        return type
                    }
                } else if let type = resolve(index + 1, candidate) {
                    return type
                }
            }

            return nil
        }

        return resolve(1, mangled(components[0]))
    }
}
