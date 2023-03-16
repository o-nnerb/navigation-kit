/*
 See LICENSE for this package's licensing information.
*/

import XCTest
@testable import NavigationKit

class FactoryTests: XCTestCase {

    func testFactory_whenInstantiate_shouldBeEqual() {
        // Given
        let seed = Seed()
        let value = 1

        // When
        let sut = Factory(value, with: seed)

        // Then
        XCTAssertEqual(sut.value, value)
        XCTAssertEqual(sut.seed, seed)
    }

    func testFactory_whenInstantiateWithWeakSeed_shouldBeNilSeed() {
        // Given
        let value = 0

        // When
        let sut = Factory(value, with: .init())

        // Then
        XCTAssertEqual(sut.value, value)
        XCTAssertNil(sut.seed)
    }
}
