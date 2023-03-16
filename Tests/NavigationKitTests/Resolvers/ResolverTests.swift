/*
 See LICENSE for this package's licensing information.
*/

import XCTest
@testable import NavigationKit

class ResolverTests: XCTestCase {

    struct HashKey: Hashable {}

    func testResolver_whenRegister_shouldResolveHashKey() async throws {
        // Given
        var resolver = Resolver<HashKey, Int>()
        let seed = Seed()
        let key = HashKey()
        let value = 1

        // When
        resolver.register(value, forKey: key, with: seed)

        // Then
        XCTAssertEqual(resolver(key), value)
    }

    func testResolver_whenAlreadyRegister_shouldResolveFirstValue() async throws {
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
        XCTAssertEqual(resolver(key), value1)
    }

    func testResolver_whenAlreadyRegisterButSeedChange_shouldResolveSecondValue() async throws {
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
        XCTAssertEqual(resolver(key), value2)
    }
}
