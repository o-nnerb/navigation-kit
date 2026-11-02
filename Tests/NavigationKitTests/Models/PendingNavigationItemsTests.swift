// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI
import XCTest

@testable import NavigationKit

class PendingNavigationItemsTests: XCTestCase {

    func testPendingItems_whenIsEmpty_shouldBeEmpty() async throws {
        // Given
        let items = [Int]()

        // When
        let pending = PendingNavigationItems(items)

        // Then
        XCTAssertTrue(pending.entries.isEmpty)
        XCTAssertEqual(pending.hashes, [])

        if #available(iOS 16.0, tvOS 16.0, macOS 13.0, *) {
            XCTAssertEqual(pending.path.count, 0)
        }
    }

    func testPendingItems_whenContainsOneElement_shouldBeOne() async throws {
        // Given
        let items = [1]

        // When
        let pending = PendingNavigationItems(items)

        // Then
        XCTAssertEqual(pending.entries.map(\.value), [AnyHashable(1)])
        XCTAssertEqual(pending.hashes, [1.hashValue])

        if #available(iOS 16.0, tvOS 16.0, macOS 13.0, *) {
            XCTAssertEqual(pending.path.count, 1)
        }
    }

    func testPendingItems_whenInstantiateWithCodableRepresentation_shouldBeValid() async throws {
        // Given
        let codableRepresentation = NavigationAction.CodableRepresentation(
            navigationPath: ["Swift.Int", "1"],
            hashes: [1]
        )

        // When
        let pending = PendingNavigationItems(codableRepresentation)

        // Then
        XCTAssertEqual(pending.entries.map(\.value), [AnyHashable(1)])

        if #available(iOS 16.0, tvOS 16.0, macOS 13.0, *) {
            XCTAssertEqual(pending.path.count, 1)
            XCTAssertEqual(
                pending.path.codable.flatMap { NavigationPathCodec.strings(from: $0) },
                ["Swift.Int", "1"]
            )
        }
    }

    func testPendingItems_whenInstantiateWithCodableRepresentation_shouldHashTheItemsOfThisLaunch() async throws {
        // Given
        // `hashValue` is different on each launch, so the hashes saved by another launch are useless.
        let codableRepresentation = NavigationAction.CodableRepresentation(
            navigationPath: ["Swift.Int", "2", "Swift.Int", "1"],
            hashes: [1.hashValue &+ 7, 2.hashValue &+ 7]
        )

        // When
        let pending = PendingNavigationItems(codableRepresentation)

        // Then
        XCTAssertEqual(pending.hashes, [1.hashValue, 2.hashValue])
    }

    func testPendingItems_whenCodableRepresentationIsInvalid_shouldKeepTheSavedHashes() async throws {
        // Given
        let codableRepresentation = NavigationAction.CodableRepresentation(
            navigationPath: ["NavigationKit.DoesNotExist", "1"],
            hashes: [42]
        )

        // When
        let pending = PendingNavigationItems(codableRepresentation)

        // Then
        XCTAssertTrue(pending.entries.isEmpty)
        XCTAssertEqual(pending.hashes, [42])
    }
}
