// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import Testing

@testable import NavigationKit

@Suite struct FactoryTests {

    @Test func factory_whenInstantiate_shouldBeEqual() {
        // Given
        let seed = Seed()
        let value = 1

        // When
        let sut = Factory(value, with: seed)

        // Then
        #expect(sut.value == value)
        #expect(sut.seed == seed)
    }

    @Test func factory_whenInstantiateWithWeakSeed_shouldBeNilSeed() {
        // Given
        let value = 0

        // When
        let sut = Factory(value, with: .init())

        // Then
        #expect(sut.value == value)
        #expect(sut.seed == nil)
    }
}
