/*
 See LICENSE for this package's licensing information.
*/

import XCTest
import Combine
@testable import NavigationKit

class SceneTransactionTests: XCTestCase {

    var cancellations = [AnyCancellable]()
    
    override func tearDown() async throws {
        try await super.tearDown()
        cancellations = []
    }
    
    func testSceneTransaction_whenTwoFired_shouldTransactionToTwoElements() async throws {
        // Given
        let expectation = expectation(description: "scene.transaction")
        var values = [Int]()
        
        expectation.expectedFulfillmentCount = 2
        
        // When
        let sut = SceneTransaction<Int>()
        sut.publisher.sink {
            values.append($0)
            expectation.fulfill()
        }.store(in: &cancellations)
        
        sut(1)
        sut(2)
        
        // Then
        await waitForExpectations(timeout: 15)
        XCTAssertEqual(values, [1, 2])
    }
}
