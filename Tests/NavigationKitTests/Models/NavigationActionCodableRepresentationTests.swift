// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI
import XCTest

@testable import NavigationKit

// swiftlint:disable type_name
class NavigationActionCodableRepresentationTests: XCTestCase {

    func testRepresentation_whenInstantiateWithEmpty_shouldBeEmpty() async throws {
        // Given
        let path = NavigationPath([1])
        let hashes = [1]

        // When
        let sut = path.codable.map {
            NavigationAction.CodableRepresentation(
                navigationPath: $0,
                hashes: hashes
            )
        }

        // Then
        XCTAssertEqual(sut?.navigationPath, path.codable)
        XCTAssertEqual(sut?.hashes, hashes)
    }

    func testRepresentation_whenCoded_shouldBeValid() async throws {
        // Given
        let path = NavigationPath([1])
        let hashes = [1]

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        // When
        let codableRepresentation = path.codable.map {
            NavigationAction.CodableRepresentation(
                navigationPath: $0,
                hashes: hashes
            )
        }

        let data = try codableRepresentation.map {
            try encoder.encode($0)
        }

        let sut = try data.map {
            try decoder.decode(NavigationAction.CodableRepresentation.self, from: $0)
        }

        // Then
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut?.hashes, hashes)

        XCTAssertEqual(
            sut?.navigationPath,
            try {
                try path.codable
                    .map { try encoder.encode($0) }
                    .map { try decoder.decode(NavigationPath.CodableRepresentation.self, from: $0) }
            }()
        )
    }
}
