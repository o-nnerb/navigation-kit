// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI
import XCTest

@testable import NavigationKit

// swiftlint:disable type_name
class NavigationActionCodableRepresentationTests: XCTestCase {

    func testRepresentation_whenInstantiate_shouldKeepValues() async throws {
        // Given
        let navigationPath = ["Swift.Int", "1"]
        let hashes = [1]

        // When
        let sut = NavigationAction.CodableRepresentation(
            navigationPath: navigationPath,
            hashes: hashes
        )

        // Then
        XCTAssertEqual(sut.navigationPath, navigationPath)
        XCTAssertEqual(sut.hashes, hashes)
    }

    func testRepresentation_whenCoded_shouldBeValid() async throws {
        // Given
        let navigationPath = ["Swift.Int", "1"]
        let hashes = [1]

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        // When
        let data = try encoder.encode(
            NavigationAction.CodableRepresentation(
                navigationPath: navigationPath,
                hashes: hashes
            )
        )

        let sut = try decoder.decode(NavigationAction.CodableRepresentation.self, from: data)

        // Then
        XCTAssertEqual(sut.navigationPath, navigationPath)
        XCTAssertEqual(sut.hashes, hashes)
    }

    func testRepresentation_whenEncoded_shouldKeepTheFormatOfThePreviousVersions() async throws {
        // Given
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys

        // When
        let data = try encoder.encode(
            NavigationAction.CodableRepresentation(
                navigationPath: ["Swift.Int", "1"],
                hashes: [1]
            )
        )

        // Then
        XCTAssertEqual(
            String(decoding: data, as: UTF8.self),
            #"{"hashes":[1],"navigationPath":["Swift.Int","1"]}"#
        )
    }
}

@available(iOS 16.0, tvOS 16.0, macOS 13.0, *)
class NavigationPathCodecTests: XCTestCase {

    func testCodec_whenPathIsCodable_shouldMatchTheSystemFormat() async throws {
        // Given
        var path = NavigationPath()
        path.append(1)
        path.append("text")

        // When
        let strings = try XCTUnwrap(path.codable.flatMap { NavigationPathCodec.strings(from: $0) })

        // Then
        XCTAssertEqual(strings, ["Swift.String", "\"text\"", "Swift.Int", "1"])
    }

    func testCodec_whenStringsAreValid_shouldRestoreThePath() async throws {
        // Given
        var path = NavigationPath()
        path.append(1)
        path.append("text")

        let strings = try XCTUnwrap(path.codable.flatMap { NavigationPathCodec.strings(from: $0) })

        // When
        let restored = try XCTUnwrap(NavigationPathCodec.path(from: strings))

        // Then
        XCTAssertEqual(restored.count, 2)
        XCTAssertEqual(restored.codable.flatMap { NavigationPathCodec.strings(from: $0) }, strings)
    }

    func testCodec_whenStringsHaveAnOddCount_shouldBeNil() async throws {
        XCTAssertNil(NavigationPathCodec.path(from: ["Swift.Int"]))
    }
}
