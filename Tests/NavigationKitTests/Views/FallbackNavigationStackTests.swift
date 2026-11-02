// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

#if os(iOS) || os(tvOS) || os(macOS)
import SwiftUI
import Testing

@testable import NavigationKit

extension NavigationStackSuites {
    /// Exercises the fallback navigation (the one used before iOS 16, tvOS 16 and macOS 13) by forcing it
    /// on the OS version the tests run on.
    @MainActor
    @Suite(.forcedFallback) struct FallbackNavigationStackTests {

        @MainActor
        private final class Recorder {

            var action: NavigationAction?
            var appeared = [Int]()
            var disappeared = [Int]()
            var strings = [String]()
            var environmentWasAvailable = [Bool]()
            var sidebarAppeared = false
        }

        private struct Root: View {

            @Environment(\.navigationAction) var navigationAction
            let recorder: Recorder

            var body: some View {
                Color.clear
                    .frame(width: 50, height: 50)
                    .onAppear {
                        recorder.action = navigationAction
                    }
                    .nkNavigationDestination(for: Int.self) {
                        Detail(value: $0, recorder: recorder)
                    }
                    .nkNavigationDestination(for: String.self) { value in
                        Color.clear
                            .frame(width: 50, height: 50)
                            .onAppear { recorder.strings.append(value) }
                    }
            }
        }

        private struct Detail: View {

            @Environment(\.navigationAction) var navigationAction
            let value: Int
            let recorder: Recorder

            var body: some View {
                Color.clear
                    .frame(width: 50, height: 50)
                    .onAppear {
                        recorder.appeared.append(value)
                        // The destination gets the same environment as the content it was declared on.
                        recorder.environmentWasAvailable.append(navigationAction.count >= 0)
                    }
                    .onDisappear {
                        recorder.disappeared.append(value)
                    }
            }
        }

        private struct Stack: View {

            let recorder: Recorder
            let representation: NavigationAction.CodableRepresentation?

            var body: some View {
                if let representation {
                    NKNavigationStack(representation) {
                        Root(recorder: recorder)
                    }
                } else {
                    NKNavigationStack {
                        Root(recorder: recorder)
                    }
                }
            }
        }

        private func host(
            _ recorder: Recorder,
            representation: NavigationAction.CodableRepresentation? = nil
        ) async -> AnyObject {
            let window = hostInWindow(Stack(recorder: recorder, representation: representation))
            await waitUntil { recorder.action != nil }
            return window
        }

        @Test func stack_whenItemIsAppended_shouldShowItsDestination() async throws {
            // Given
            let recorder = Recorder()
            let window = await host(recorder)

            // When
            recorder.action?.append(1)
            await waitUntil { recorder.appeared.contains(1) }

            // Then
            #expect(Set(recorder.appeared) == [1])
            #expect(recorder.action?.count == 1)
            #expect(recorder.environmentWasAvailable.allSatisfy { $0 })
            withExtendedLifetime(window) {}
        }

        /// The second item is appended while the push of the first one is still animating.
        @Test func stack_whenItemsOfDifferentTypesAreAppended_shouldShowEachDestination() async throws {
            // Given
            let recorder = Recorder()
            let window = await host(recorder)

            // When
            recorder.action?.append(1)
            await waitUntil { recorder.appeared.contains(1) }

            recorder.action?.append("text")
            await waitUntil { recorder.strings == ["text"] }
            try await Task.sleep(nanoseconds: 1_000_000_000)

            // Then
            #expect(Set(recorder.appeared) == [1])
            #expect(recorder.strings == ["text"])
            #expect(recorder.action?.count == 2)
            withExtendedLifetime(window) {}
        }

        @Test func stack_whenLastItemIsRemoved_shouldDismissItsDestination() async throws {
            // Given
            let recorder = Recorder()
            let window = await host(recorder)

            recorder.action?.append(1)
            await waitUntil { recorder.appeared.contains(1) }

            recorder.action?.append(2)
            await waitUntil { recorder.appeared.contains(2) }

            // When
            recorder.action?.removeLast()
            await waitUntil { recorder.disappeared.contains(2) }

            // Then
            #expect(recorder.disappeared.contains(2))
            #expect(recorder.action?.count == 1)
            withExtendedLifetime(window) {}
        }

        /// The system navigation drops (and reports as dismissed) the items pushed while another push is in
        /// progress, so the stack has to still have all of them once the pushes are done.
        @Test func stack_whenSeveralItemsAreSet_shouldKeepAllOfThem() async throws {
            // Given
            let recorder = Recorder()
            let window = await host(recorder)

            // When
            recorder.action?.setItems([1, 2, 3])
            await waitUntil { recorder.appeared.contains(3) }
            try await Task.sleep(nanoseconds: 1_000_000_000)

            // Then
            #expect(Set(recorder.appeared) == [1, 2, 3])
            #expect(recorder.action?.count == 3)
            withExtendedLifetime(window) {}
        }

        @Test func stack_whenAllItemsAreRemoved_shouldDismissEveryDestination() async throws {
            // Given
            let recorder = Recorder()
            let window = await host(recorder)

            recorder.action?.setItems([1, 2, 3])
            await waitUntil { recorder.appeared.contains(3) }

            // When
            recorder.action?.removeAll()
            await waitUntil { Set(recorder.disappeared) == [1, 2, 3] }

            // Then
            #expect(Set(recorder.disappeared) == [1, 2, 3])
            #expect(recorder.action?.count == 0)
            withExtendedLifetime(window) {}
        }

        @Test func stack_whenCreatedWithARepresentation_shouldShowTheItems() async throws {
            // Given
            let recorder = Recorder()
            let representation = NavigationAction.CodableRepresentation(
                navigationPath: ["Swift.Int", "2", "Swift.Int", "1"],
                hashes: [1.hashValue, 2.hashValue]
            )

            // When
            let window = await host(recorder, representation: representation)
            await waitUntil { recorder.appeared.contains(2) }

            try await Task.sleep(nanoseconds: 1_000_000_000)

            // Then
            #expect(Set(recorder.appeared) == [1, 2])
            #expect(recorder.action?.count == 2)
            withExtendedLifetime(window) {}
        }

        @Test func stack_whenItemsAreCodable_shouldProduceARepresentationThatRestoresThem() async throws {
            // Given
            let recorder = Recorder()
            let window = await host(recorder)

            recorder.action?.setItems([1, 2])
            await waitUntil { recorder.appeared.contains(2) }

            // When
            let representation = try #require(recorder.action?.codable)

            // Then
            #expect(representation.navigationPath == ["Swift.Int", "2", "Swift.Int", "1"])
            withExtendedLifetime(window) {}
        }

        // MARK: - Split view

        private struct Sidebar: View {

            @Environment(\.navigationAction) var navigationAction
            let recorder: Recorder

            var body: some View {
                Color.clear
                    .frame(width: 50, height: 50)
                    .onAppear {
                        recorder.action = navigationAction
                        recorder.sidebarAppeared = true
                    }
            }
        }

        private struct SplitView: View {

            let recorder: Recorder

            var body: some View {
                NKNavigationSplitView {
                    Sidebar(recorder: recorder)
                } detail: {
                    Root(recorder: recorder)
                }
            }
        }

        @Test func splitView_whenCreated_shouldProvideTheNavigationAction() async throws {
            // Given
            let recorder = Recorder()

            // When
            let window = hostInWindow(SplitView(recorder: recorder))
            await waitUntil { recorder.sidebarAppeared }

            // Then
            #expect(recorder.sidebarAppeared)
            #expect(recorder.action?.count == 0)
            withExtendedLifetime(window) {}
        }

        #if os(macOS)
        @Test func splitView_whenItemIsAppended_shouldShowItsDestinationInTheDetail() async throws {
            // Given
            let recorder = Recorder()
            let window = hostInWindow(SplitView(recorder: recorder))
            await waitUntil { recorder.sidebarAppeared }

            // When
            recorder.action?.append(1)
            await waitUntil { recorder.appeared.contains(1) }

            // Then
            #expect(recorder.appeared.contains(1))
            #expect(recorder.action?.count == 1)
            withExtendedLifetime(window) {}
        }
        #endif
    }
}
#endif
