/*
 See LICENSE for this package's licensing information.
*/

import XCTest
import SwiftUI
@testable import NavigationKit

class PendingNavigationItemsTests: XCTestCase {
    
    func testPendingItems_whenIsEmpty_shouldBeEmpty() async throws {
        // Given
        let path = NavigationPath()
        let hashes = [Int]()
        
        // When
        let pending = PendingNavigationItems(
            path: path, 
            hashes: hashes
        )
        
        // Then
        XCTAssertEqual(pending.path, path)
        XCTAssertEqual(pending.hashes, hashes)
    }
    
    func testPendingItems_whenContainsOneElement_shouldBeOne() async throws {
        // Given
        let path = NavigationPath([1])
        let hashes = [1]
        
        // When        
        let pending = PendingNavigationItems(
            path: path, 
            hashes: hashes
        )
        
        // Then
        XCTAssertEqual(pending.path, path)
        XCTAssertEqual(pending.hashes, hashes)
    }
    
    func testPendingItems_whenInstantiateWithCodableRepresentation_shouldBeValid() async throws {
        // Given
        let path = NavigationPath([1])
        let hashes = [1]
        
        let codableRepresentation = path.codable.map {
            NavigationAction.CodableRepresentation(
                navigationPath: $0,
                hashes: hashes
            )
        }
        
        // When        
        let pending = codableRepresentation.map {
            PendingNavigationItems($0)
        }
        
        // Then
        XCTAssertNotNil(pending)
        XCTAssertEqual(pending?.path, path.codable.map { .init($0) })
        XCTAssertEqual(pending?.hashes, hashes)
    }
}
