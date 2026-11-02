// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import Combine
import XCTest

@testable import NavigationKit

@MainActor
class SceneTransactionTests: XCTestCase {

    var cancellations = [AnyCancellable]()

    override func tearDown() async throws {
        try await super.tearDown()
        cancellations = []
    }

    func testSceneTransaction_whenTwoFired_shouldTransactionToTwoElements() throws {
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
        waitForExpectations(timeout: 15)
        XCTAssertEqual(values, [1, 2])
    }
}
