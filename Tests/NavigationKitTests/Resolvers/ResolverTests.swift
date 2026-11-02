// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import Testing

@testable import NavigationKit

@MainActor
@Suite struct ResolverTests {

    struct HashKey: Hashable {}

    @Test func resolver_whenRegister_shouldResolveHashKey() async throws {
        // Given
        var resolver = Resolver<HashKey, Int>()
        let seed = Seed()
        let key = HashKey()
        let value = 1

        // When
        resolver.register(value, forKey: key, with: seed)

        // Then
        #expect(resolver(key) == value)
    }

    @Test func resolver_whenAlreadyRegister_shouldResolveFirstValue() async throws {
        // Given
        var resolver = Resolver<HashKey, Int>()
        let seed = Seed()
        let key = HashKey()
        let value1 = 1
        let value2 = 1

        // When
        resolver.register(value1, forKey: key, with: seed)
        resolver.register(value2, forKey: key, with: seed)

        // Then
        #expect(resolver(key) == value1)
    }

    @Test func resolver_whenAlreadyRegisterButSeedChange_shouldResolveSecondValue() async throws {
        // Given
        var resolver = Resolver<HashKey, Int>()
        var seed = Seed()
        let key = HashKey()
        let value1 = 1
        let value2 = 1

        // When
        resolver.register(value1, forKey: key, with: seed)
        seed = Seed()
        resolver.register(value2, forKey: key, with: seed)

        // Then
        #expect(resolver(key) == value2)
    }
}
