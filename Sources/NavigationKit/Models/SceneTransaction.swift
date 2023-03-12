//
//  File.swift
//  
//
//  Created by Brenno on 12/03/23.
//

import Foundation
import Combine

public struct SceneTransaction<Destination: Hashable> {

    private let id: UUID
    private let subject = PassthroughSubject<Destination, Never>()

    public init() {
        self.id = UUID()
    }
}

extension SceneTransaction: Hashable {

    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension SceneTransaction {

    public var publisher: AnyPublisher<Destination, Never> {
        subject.eraseToAnyPublisher()
    }

    public func send(_ destination: Destination) {
        subject.send(destination)
    }
}
