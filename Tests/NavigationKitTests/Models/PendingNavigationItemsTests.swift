// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI
import Testing

@testable import NavigationKit

@Suite struct PendingNavigationItemsTests {

    @Test func pendingItems_whenIsEmpty_shouldBeEmpty() async throws {
        // Given
        let items = [Int]()

        // When
        let pending = PendingNavigationItems(items)

        // Then
        #expect(pending.entries.isEmpty)
        #expect(pending.hashes == [])

        if #available(iOS 16.0, tvOS 16.0, macOS 13.0, *) {
            #expect(pending.path.count == 0)
        }
    }

    @Test func pendingItems_whenContainsOneElement_shouldBeOne() async throws {
        // Given
        let items = [1]

        // When
        let pending = PendingNavigationItems(items)

        // Then
        #expect(pending.entries.map(\.value) == [AnyHashable(1)])
        #expect(pending.hashes == [1.hashValue])

        if #available(iOS 16.0, tvOS 16.0, macOS 13.0, *) {
            #expect(pending.path.count == 1)
        }
    }

    @Test func pendingItems_whenInstantiateWithCodableRepresentation_shouldBeValid() async throws {
        // Given
        let codableRepresentation = NavigationAction.CodableRepresentation(
            navigationPath: ["Swift.Int", "1"],
            hashes: [1]
        )

        // When
        let pending = PendingNavigationItems(codableRepresentation)

        // Then
        #expect(pending.entries.map(\.value) == [AnyHashable(1)])

        if #available(iOS 16.0, tvOS 16.0, macOS 13.0, *) {
            #expect(pending.path.count == 1)
            #expect(
                pending.path.codable.flatMap { NavigationPathCodec.strings(from: $0) }
                    == ["Swift.Int", "1"]
            )
        }
    }

    @Test func pendingItems_whenInstantiateWithCodableRepresentation_shouldHashTheItemsOfThisLaunch() async throws {
        // Given
        // `hashValue` is different on each launch, so the hashes saved by another launch are useless.
        let codableRepresentation = NavigationAction.CodableRepresentation(
            navigationPath: ["Swift.Int", "2", "Swift.Int", "1"],
            hashes: [1.hashValue &+ 7, 2.hashValue &+ 7]
        )

        // When
        let pending = PendingNavigationItems(codableRepresentation)

        // Then
        #expect(pending.hashes == [1.hashValue, 2.hashValue])
    }

    @Test func pendingItems_whenCodableRepresentationIsInvalid_shouldKeepTheSavedHashes() async throws {
        // Given
        let codableRepresentation = NavigationAction.CodableRepresentation(
            navigationPath: ["NavigationKit.DoesNotExist", "1"],
            hashes: [42]
        )

        // When
        let pending = PendingNavigationItems(codableRepresentation)

        // Then
        #expect(pending.entries.isEmpty)
        #expect(pending.hashes == [42])
    }
}
