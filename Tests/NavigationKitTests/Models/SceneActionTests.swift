/*
 See LICENSE for this package's licensing information.
*/

import XCTest
import Combine
@testable import NavigationKit

class SceneActionTests: XCTestCase {

    var cancellations = [AnyCancellable]()

    override func tearDown() async throws {
        try await super.tearDown()
        cancellations = []
    }

    func testSceneAction_whenIntegerRegister_shouldBeValid() async throws {
        // Given
        let expectation = expectation(description: "scene.action")
        let sceneAction = SceneAction()
        let value = 1
        var received: Int?

        // When
        sceneAction.publisher(for: Int.self).sink {
            received = $0
            expectation.fulfill()
        }.store(in: &cancellations)

        sceneAction(value)

        // Then
        await waitForExpectations(timeout: 15)
        XCTAssertEqual(received, value)
    }

    func testSceneAction_whenIntegerRegisterTwoTimes_shouldBeValid() async throws {
        // Given
        let expectation = expectation(description: "scene.action")
        let sceneAction = SceneAction()
        let value = 1
        var received = [Int]()

        expectation.expectedFulfillmentCount = 2

        // When
        sceneAction.publisher(for: Int.self).sink {
            received.append($0)
            expectation.fulfill()
        }.store(in: &cancellations)

        sceneAction.publisher(for: Int.self).sink {
            received.append($0)
            expectation.fulfill()
        }.store(in: &cancellations)

        sceneAction(value)

        // Then
        await waitForExpectations(timeout: 15)
        XCTAssertEqual(received, [value, value])
    }
}
