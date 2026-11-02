// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import Combine
import XCTest

@testable import NavigationKit

@MainActor
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

    func testTransformer_whenString_shouldBeString() throws {
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
        waitForExpectations(timeout: 15)
        XCTAssertEqual(output, input)
    }
}
