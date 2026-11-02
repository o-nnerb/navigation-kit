// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import Testing

@testable import NavigationKit

@Suite struct IdentifiedTests {

    @Test func identified_whenInstantiate_shouldBeItemEqualToID() {
        // Given
        let item = "Hello World"

        // When
        let sut = Identified(item: item)

        // Then
        #expect(sut.item == item)
        #expect(sut.id == item.hashValue)
    }
}
