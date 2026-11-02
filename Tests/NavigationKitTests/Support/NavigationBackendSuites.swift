// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import Testing

@testable import NavigationKit

/// The suites that host a navigation stack. `NavigationBackend.forcesFallback` is process-wide, so
/// they run one at a time: a test forcing the fallback never overlaps one that expects the system
/// navigation.
@Suite(.serialized)
enum NavigationStackSuites {}

/// Runs a test, or every test of a suite, with the fallback navigation forced on.
struct ForcedFallbackTrait: TestTrait, SuiteTrait, TestScoping {

    var isRecursive: Bool { true }

    func provideScope(
        for test: Test,
        testCase: Test.Case?,
        performing function: @Sendable () async throws -> Void
    ) async throws {
        guard testCase != nil else {
            return try await function()
        }

        await MainActor.run { NavigationBackend.forcesFallback = true }

        do {
            try await function()
        } catch {
            await MainActor.run { NavigationBackend.forcesFallback = false }
            throw error
        }

        await MainActor.run { NavigationBackend.forcesFallback = false }
    }
}

extension Trait where Self == ForcedFallbackTrait {
    static var forcedFallback: Self { .init() }
}
