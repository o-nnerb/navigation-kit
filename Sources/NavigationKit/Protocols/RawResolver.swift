//
//  File.swift
//  
//
//  Created by Brenno on 23/02/23.
//

import Foundation

protocol RawResolver {

    associatedtype _Input
    associatedtype _Key
    associatedtype _Output

    mutating func register(
        seed: Seed,
        forKey key: _Key,
        closure: @escaping (_Input) -> _Output
    )

    static func makeKey<Input>(_ input: Input.Type) -> _Key
}
