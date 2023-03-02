//
//  File.swift
//  
//
//  Created by Brenno on 23/02/23.
//

import Foundation

struct NavigationItem {

    let key: ObjectIdentifier
    let input: AnyHashable

    private init<Input: Hashable>(_ input: Input) {
        self.key = ObjectIdentifier(Input.self)
        self.input = input
    }

    static func item<Item: Hashable>(_ item: Item) -> Self {
        .init(item)
    }
}

extension NavigationItem: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
        hasher.combine(input)
    }
}
