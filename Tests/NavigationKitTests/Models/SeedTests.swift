// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import Testing

@testable import NavigationKit

@Suite struct SeedTests {

    @Test func seed_whenSelfSeed_shouldBeEqual() async throws {
        // Given
        let seed = Seed()

        // Then
        #expect(seed == seed)
    }

    @Test func seed_whenTwoSeeds_shouldBeNotEqual() async throws {
        // Given
        let seed1 = Seed()
        let seed2 = Seed()

        // Then
        #expect(seed1 != seed2)
    }

    @Test func seed_whenSelfSeed_shouldHashBeObjectIdentifier() async throws {
        // Given
        let seed = Seed()

        // When
        let hashValue = ObjectIdentifier(seed).hashValue

        // Then
        #expect(seed.hashValue == hashValue)
    }
}
