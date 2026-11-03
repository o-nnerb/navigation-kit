// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

#if canImport(AppKit) || (canImport(UIKit) && !os(watchOS))
import SwiftUI
import Testing

@testable import NavigationKit

@MainActor
@Suite struct ViewResolverTests {

    @MainActor
    private final class Recorder {
        var integers = [Int]()
        var strings = [String]()
    }

    private struct Reader<Item: Hashable>: View {

        @Environment(\.viewResolver) var viewResolver
        let item: Item

        var body: some View {
            viewResolver(item)
        }
    }

    @Test func viewResolver_whenTypeIsRegistered_shouldBuildItsView() async throws {
        // Given
        let recorder = Recorder()

        // When
        let window = hostInWindow(
            Reader(item: 5)
                .viewResolver(for: Int.self) { value in
                    Probe { recorder.integers.append(value) }
                }
        )
        await waitUntil { !recorder.integers.isEmpty }

        // Then
        #expect(recorder.integers == [5])
        withExtendedLifetime(window) {}
    }

    @Test func viewResolver_whenSeveralTypesAreRegistered_shouldBuildTheViewOfEachType() async throws {
        // Given
        let recorder = Recorder()

        // When
        let window = hostInWindow(
            VStack {
                Reader(item: 1)
                Reader(item: "text")
            }
            .viewResolver(for: Int.self) { value in
                Probe { recorder.integers.append(value) }
            }
            .viewResolver(for: String.self) { value in
                Probe { recorder.strings.append(value) }
            }
        )
        await waitUntil { !recorder.integers.isEmpty && !recorder.strings.isEmpty }

        // Then
        #expect(recorder.integers == [1])
        #expect(recorder.strings == ["text"])
        withExtendedLifetime(window) {}
    }

    @Test func viewResolver_whenRegisteredAgainBelow_shouldKeepTheFirstOneRegistered() async throws {
        // Given
        let recorder = Recorder()

        // When
        let window = hostInWindow(
            Reader(item: 3)
                .viewResolver(for: Int.self) { value in
                    Probe { recorder.integers.append(value * 100) }
                }
                .viewResolver(for: Int.self) { value in
                    Probe { recorder.integers.append(value) }
                }
        )
        await waitUntil { !recorder.integers.isEmpty }

        // Then
        #expect(recorder.integers.count == 1)
        withExtendedLifetime(window) {}
    }

    @Test func viewResolver_whenThereIsNoResolverAbove_shouldNotExposeOne() {
        // Given
        let values = EnvironmentValues()

        // Then
        #expect(values._viewResolver == nil)
    }
}
#endif
