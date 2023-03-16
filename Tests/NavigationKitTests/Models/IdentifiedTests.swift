/*
 See LICENSE for this package's licensing information.
*/

import XCTest
@testable import NavigationKit

class IdentifiedTests: XCTestCase {

    func testIdentified_whenInstantiate_shouldBeItemEqualToID() {
        // Given
        let item = "Hello World"

        // When
        let sut = Identified(item: item)

        // Then
        XCTAssertEqual(sut.item, item)
        XCTAssertEqual(sut.id, item.hashValue)
    }
}
