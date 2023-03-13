/*
 See LICENSE for this package's licensing information.
*/

import Foundation

struct Resolver<Key: Hashable, Value> {

    private var table: [Key: Factory<Value>] = [:]

    init() {}

    func callAsFunction(_ key: Key) -> Value {
        guard let factory = table[key] else {
            fatalError()
        }

        return factory.value
    }

    mutating func register(_ value: Value, forKey key: Key, with seed: Seed) {
        if let item = table[key] {
            guard item.seed == nil || item.seed == seed else {
                print("[NavigationKit]", "Resolver will use the first object already registered")
                return
            }
        }

        table[key] = Factory(value, with: seed)
    }
}
