//
//  File.swift
//  
//
//  Created by Brenno on 23/02/23.
//

import Foundation

final class RegisterID: Hashable {

    static func == (_ lhs: RegisterID, _ rhs: RegisterID) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

struct Resolver<Key: Hashable, Value> {

    private var table: [Key: Factory<Value>] = [:]

    init() {}

    func callAsFunction(_ key: Key) -> Value {
        guard let factory = table[key] else {
            fatalError()
        }

        return factory.value
    }

    mutating func register(_ value: Value, forKey key: Key, with id: RegisterID) {
        if let item = table[key] {
            guard let itemID = item.id, itemID == id else {
                print("[NavigationKit]", "Resolver will use the first object already registered")
                return
            }
        }

        table[key] = Factory(value, with: id)
    }
}
