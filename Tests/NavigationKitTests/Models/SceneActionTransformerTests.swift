// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import XCTest

@testable import NavigationKit

@MainActor
class SceneActionTransformerTests: XCTestCase {

    var sceneAction: SceneAction!

    override func setUp() async throws {
        try await super.setUp()
        sceneAction = .init()
    }

    override func tearDown() async throws {
        try await super.tearDown()
        sceneAction = nil
    }

    func testTransformer_whenString_shouldBeString() async throws {
        // Given
        let input = "Hello World"
        let sut = SceneActionTransformer()

        // When
        var iterator = sceneAction.values(for: String.self).makeAsyncIterator()

        sut(input)
        sut.perform(sceneAction)

        // Then
        let output = await iterator.next()
        XCTAssertEqual(output, input)
    }
}
