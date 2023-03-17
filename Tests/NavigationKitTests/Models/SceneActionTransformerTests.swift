/*
 See LICENSE for this package's licensing information.
*/

import XCTest
import Combine
@testable import NavigationKit

class SceneActionTransformerTests: XCTestCase {

    var sceneAction: SceneAction!
    var cancellations = [AnyCancellable]()

    override func setUp() async throws {
        try await super.setUp()
        sceneAction = .init()
    }

    override func tearDown() async throws {
        try await super.tearDown()
        sceneAction = nil
        cancellations = []
    }

    func testTransformer_whenString_shouldBeString() async throws {
        // Given
        let expectation = expectation(description: "scene.action.transformer")
        let input = "Hello World"
        let sut = SceneActionTransformer()
        var output: String?

        // When
        sceneAction.publisher(for: String.self).sink {
            output = $0
            expectation.fulfill()
        }.store(in: &cancellations)

        sut(input)
        sut.perform(sceneAction)

        // Then
        await waitForExpectations(timeout: 15)
        XCTAssertEqual(output, input)
    }
}
