// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import Testing

@testable import NavigationKit

@MainActor
@Suite struct SceneActionTransformerTests {

    let sceneAction = SceneAction()

    @Test func transformer_whenString_shouldBeString() async throws {
        // Given
        let input = "Hello World"
        let sut = SceneActionTransformer()

        // When
        var iterator = sceneAction.values(for: String.self).makeAsyncIterator()

        sut(input)
        sut.perform(sceneAction)

        // Then
        let output = await iterator.next()
        #expect(output == input)
    }
}
