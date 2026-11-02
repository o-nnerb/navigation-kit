// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI
import Testing

@testable import NavigationKit

// swiftlint:disable type_name
@Suite struct NavigationActionCodableRepresentationTests {

    @Test func representation_whenInstantiate_shouldKeepValues() async throws {
        // Given
        let navigationPath = ["Swift.Int", "1"]
        let hashes = [1]

        // When
        let sut = NavigationAction.CodableRepresentation(
            navigationPath: navigationPath,
            hashes: hashes
        )

        // Then
        #expect(sut.navigationPath == navigationPath)
        #expect(sut.hashes == hashes)
    }

    @Test func representation_whenCoded_shouldBeValid() async throws {
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
        #expect(sut.navigationPath == navigationPath)
        #expect(sut.hashes == hashes)
    }

    @Test func representation_whenEncoded_shouldKeepTheFormatOfThePreviousVersions() async throws {
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
        #expect(
            String(decoding: data, as: UTF8.self)
                == #"{"hashes":[1],"navigationPath":["Swift.Int","1"]}"#
        )
    }
}

@Suite struct NavigationPathCodecTests {

    @available(iOS 16.0, tvOS 16.0, macOS 13.0, *)
    @Test func codec_whenPathIsCodable_shouldMatchTheSystemFormat() async throws {
        // Given
        var path = NavigationPath()
        path.append(1)
        path.append("text")

        // When
        let strings = try #require(path.codable.flatMap { NavigationPathCodec.strings(from: $0) })

        // Then
        #expect(strings == ["Swift.String", "\"text\"", "Swift.Int", "1"])
    }

    @available(iOS 16.0, tvOS 16.0, macOS 13.0, *)
    @Test func codec_whenStringsAreValid_shouldRestoreThePath() async throws {
        // Given
        var path = NavigationPath()
        path.append(1)
        path.append("text")

        let strings = try #require(path.codable.flatMap { NavigationPathCodec.strings(from: $0) })

        // When
        let restored = try #require(NavigationPathCodec.path(from: strings))

        // Then
        #expect(restored.count == 2)
        #expect(restored.codable.flatMap { NavigationPathCodec.strings(from: $0) } == strings)
    }

    @available(iOS 16.0, tvOS 16.0, macOS 13.0, *)
    @Test func codec_whenStringsHaveAnOddCount_shouldBeNil() async throws {
        #expect(NavigationPathCodec.path(from: ["Swift.Int"]) == nil)
    }
}
