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

    func testSceneTransaction_whenTwoFired_shouldTransactionToTwoElements() async throws {
        // Given
        let sut = SceneTransaction<Int>()

        // When
        let iterator = sut.values.makeAsyncIterator()

        sut(1)
        sut(2)

        // Then
        let values = [await iterator.next(), await iterator.next()]
        XCTAssertEqual(values, [1, 2])
    }

    func testSceneTransaction_whenTwoSubscribers_shouldDeliverToBoth() async throws {
        // Given
        let sut = SceneTransaction<Int>()

        // When
        let first = sut.values.makeAsyncIterator()
        let second = sut.values.makeAsyncIterator()

        sut(1)

        // Then
        let values = [await first.next(), await second.next()]
        XCTAssertEqual(values, [1, 1])
    }

    func testSceneTransaction_whenFiredBeforeSubscription_shouldNotReplay() async throws {
        // Given
        let sut = SceneTransaction<Int>()
        sut(1)

        // When
        let iterator = sut.values.makeAsyncIterator()
        sut(2)

        // Then
        let value = await iterator.next()
        XCTAssertEqual(value, 2)
    }

    func testSceneTransaction_whenCopied_shouldShareSubscribers() async throws {
        // Given
        let sut = SceneTransaction<Int>()
        let copy = sut

        // When
        let iterator = sut.values.makeAsyncIterator()
        copy(5)

        // Then
        let value = await iterator.next()
        XCTAssertEqual(sut, copy)
        XCTAssertEqual(value, 5)
    }

    func testSceneTransaction_whenIteratingTaskIsCancelled_shouldFinishSequence() async throws {
        // Given
        let sut = SceneTransaction<Int>()
        let values = sut.values

        // When
        let task = Task { () -> [Int] in
            var received = [Int]()
            for await value in values {
                received.append(value)
            }
            return received
        }

        task.cancel()

        // Then
        let received = await task.value
        XCTAssertTrue(received.isEmpty)
    }

    // MARK: - Deprecated

    @available(*, deprecated, message: "Covers the deprecated Combine `publisher` until it is removed.")
    func testSceneTransaction_whenUsingDeprecatedPublisher_shouldStillEmit() throws {
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

    @available(*, deprecated, message: "Covers the deprecated Combine `publisher` until it is removed.")
    func testSceneTransaction_whenFired_shouldReachPublisherAndValues() async throws {
        // Given
        let sut = SceneTransaction<Int>()
        var published = [Int]()

        // When
        sut.publisher.sink { published.append($0) }.store(in: &cancellations)
        let iterator = sut.values.makeAsyncIterator()

        sut(9)

        // Then
        let value = await iterator.next()
        XCTAssertEqual(value, 9)
        XCTAssertEqual(published, [9])
    }
}
