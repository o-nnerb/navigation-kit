// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

#if canImport(AppKit) || (canImport(UIKit) && !os(watchOS))
import SwiftUI
import Testing

@testable import NavigationKit

@MainActor
@Suite struct SceneActionPresentationTests {

    @MainActor
    private final class Recorder {
        var integers = [Int]()
        var strings = [String]()
        var sceneActions = [ObjectIdentifier]()
        var presented = [Int]()
    }

    private struct Sender<Action: Hashable>: View {

        @Environment(\.sceneAction) var sceneAction
        let action: Action

        var body: some View {
            Color.clear
                .frame(width: 50, height: 50)
                .onAppear { sceneAction(action) }
        }
    }

    private struct SceneReader: View {

        @Environment(\.sceneAction) var sceneAction
        let recorder: Recorder

        var body: some View {
            Color.clear
                .frame(width: 50, height: 50)
                .onAppear { recorder.sceneActions.append(sceneAction.id) }
        }
    }

    // MARK: - Transformer

    @Test func transformer_whenActionIsSent_shouldSendTheTransformedActionToo() async throws {
        // Given
        let recorder = Recorder()

        // When
        let window = hostInWindow(
            Sender(action: 4)
                .sceneAction(for: Int.self) { recorder.integers.append($0) }
                .sceneActionTransformer(for: Int.self) { transformer, value in
                    transformer("n\(value)")
                }
                .sceneAction(for: String.self) { recorder.strings.append($0) }
                .sceneActionEnabled()
        )
        await waitUntil { !recorder.strings.isEmpty }

        // Then
        #expect(recorder.strings == ["n4"])
        #expect(recorder.integers == [4])
        withExtendedLifetime(window) {}
    }

    @Test func transformer_whenClosureDoesNotTransform_shouldSendNothing() async throws {
        // Given
        let recorder = Recorder()

        // When
        let window = hostInWindow(
            VStack {
                Sender(action: 4)
                Sender(action: 5)
            }
            .sceneActionTransformer(for: Int.self) { transformer, value in
                if value == 5 {
                    transformer("n\(value)")
                }
            }
            .sceneAction(for: String.self) { recorder.strings.append($0) }
            .sceneActionEnabled()
        )
        await waitUntil { !recorder.strings.isEmpty }
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(recorder.strings == ["n5"])
        withExtendedLifetime(window) {}
    }

    // MARK: - Scene

    @Test func sceneActionEnabled_whenNested_shouldStartAnotherScene() async throws {
        // Given
        let recorder = Recorder()

        // When
        let window = hostInWindow(
            VStack {
                SceneReader(recorder: recorder)
                SceneReader(recorder: recorder)
                    .sceneActionEnabled()
            }
            .sceneActionEnabled()
        )
        await waitUntil { recorder.sceneActions.count == 2 }

        // Then
        #expect(recorder.sceneActions.count == 2)
        #expect(Set(recorder.sceneActions).count == 2)
        withExtendedLifetime(window) {}
    }

    // MARK: - Sheet

    @Test func sheet_whenActionIsSent_shouldPresentTheResolvedView() async throws {
        // Given
        let recorder = Recorder()

        // When
        let window = hostInWindow(
            Sender(action: "settings")
                .sceneActionSheet(for: String.self) { $0.count }
                .viewResolver(for: Int.self) { value in
                    Probe { recorder.presented.append(value) }
                }
                .sceneActionEnabled()
        )
        await waitUntil { !recorder.presented.isEmpty }

        // Then
        #expect(recorder.presented == [8])
        withExtendedLifetime(window) {}
    }

    @Test func sheet_whenActionIsTheModel_shouldResolveTheAction() async throws {
        // Given
        let recorder = Recorder()

        // When
        let window = hostInWindow(
            Sender(action: 9)
                .sceneActionSheet(for: Int.self)
                .viewResolver(for: Int.self) { value in
                    Probe { recorder.presented.append(value) }
                }
                .sceneActionEnabled()
        )
        await waitUntil { !recorder.presented.isEmpty }

        // Then
        #expect(recorder.presented == [9])
        withExtendedLifetime(window) {}
    }

    // MARK: - Popover

    #if !os(tvOS)
    @Test func popover_whenActionIsSent_shouldPresentTheResolvedView() async throws {
        // Given
        let recorder = Recorder()

        // When
        let window = hostInWindow(
            Sender(action: "popover")
                .sceneActionPopover(for: String.self) { $0.count }
                .viewResolver(for: Int.self) { value in
                    Probe { recorder.presented.append(value) }
                }
                .sceneActionEnabled()
        )
        await waitUntil { !recorder.presented.isEmpty }

        // Then
        #expect(recorder.presented == [7])
        withExtendedLifetime(window) {}
    }

    @Test func popover_whenActionIsTheModel_shouldResolveTheAction() async throws {
        // Given
        let recorder = Recorder()

        // When
        let window = hostInWindow(
            Sender(action: 6)
                .sceneActionPopover(for: Int.self, attachmentAnchor: .point(.center), arrowEdge: .bottom)
                .viewResolver(for: Int.self) { value in
                    Probe { recorder.presented.append(value) }
                }
                .sceneActionEnabled()
        )
        await waitUntil { !recorder.presented.isEmpty }

        // Then
        #expect(recorder.presented == [6])
        withExtendedLifetime(window) {}
    }
    #endif
}
#endif
