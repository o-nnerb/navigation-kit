/*
 See LICENSE for this package's licensing information.
*/

import XCTest
@testable import NavigationKit

class SeedTests: XCTestCase {

    func testSeed_whenSelfSeed_shouldBeEqual() async throws {
        // Given
        let seed = Seed()

        // Then
        XCTAssertEqual(seed, seed)
    }

    func testSeed_whenTwoSeeds_shouldBeNotEqual() async throws {
        // Given
        let seed1 = Seed()
        let seed2 = Seed()

        // Then
        XCTAssertNotEqual(seed1, seed2)
    }

    func testSeed_whenSelfSeed_shouldHashBeObjectIdentifier() async throws {
        // Given
        let seed = Seed()

        // When
        let hashValue = ObjectIdentifier(seed).hashValue

        // Then
        XCTAssertEqual(seed.hashValue, hashValue)
    }
}
