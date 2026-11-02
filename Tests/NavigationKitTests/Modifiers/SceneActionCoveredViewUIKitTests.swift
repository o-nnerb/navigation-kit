// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

#if canImport(UIKit)
import SwiftUI
import UIKit
import XCTest

@testable import NavigationKit

/// A scene action handler must keep receiving while its view is covered (for example the root of a
/// stack with a destination pushed on top), exactly like `onReceive` did.
@MainActor
class SceneActionCoveredViewUIKitTests: XCTestCase {

    private final class Recorder {
        var received = [Int]()
        var navigationAction: NavigationAction?
        var sceneAction: SceneAction?
        var rootAppeared = 0
        var rootDisappeared = 0
    }

    private struct Root: View {

        @Environment(\.navigationAction) var navigationAction
        @Environment(\.sceneAction) var sceneAction
        let recorder: Recorder
        let handlesActions: Bool

        var body: some View {
            Color.clear
                .onAppear {
                    recorder.navigationAction = navigationAction
                    recorder.sceneAction = sceneAction
                    recorder.rootAppeared += 1
                }
                .onDisappear {
                    recorder.rootDisappeared += 1
                }
                .modifier(OptionalHandler(recorder: recorder, isEnabled: handlesActions))
        }
    }

    private struct OptionalHandler: ViewModifier {

        let recorder: Recorder
        let isEnabled: Bool

        @ViewBuilder
        func body(content: Content) -> some View {
            if isEnabled {
                content.sceneAction(for: Int.self) {
                    recorder.received.append($0)
                }
            } else {
                content
            }
        }
    }

    private func waitUntil(_ condition: () -> Bool) async {
        for _ in 0..<300 where !condition() {
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
    }

    private func sleep(milliseconds: UInt64) async throws {
        try await Task.sleep(nanoseconds: milliseconds * 1_000_000)
    }

    private func makeWindow<Content: View>(_ rootView: Content) -> UIWindow {
        let window = UIWindow(frame: .init(x: 0, y: 0, width: 300, height: 600))
        window.rootViewController = UIHostingController(rootView: rootView)
        window.makeKeyAndVisible()
        return window
    }

    private func runScenario(recorder: Recorder) async throws {
        await waitUntil { recorder.rootAppeared > 0 }
        try await sleep(milliseconds: 300)

        // 1. Visible.
        recorder.sceneAction?(1)
        await waitUntil { recorder.received.count == 1 }

        // 2. Covered by a destination pushed on top.
        recorder.navigationAction?.append("pushed")
        await waitUntil { recorder.rootDisappeared > 0 }
        try await sleep(milliseconds: 800)

        recorder.sceneAction?(2)
        await waitUntil { recorder.received.count == 2 }

        // 3. Visible again after popping.
        recorder.navigationAction?.removeLast()
        try await sleep(milliseconds: 1000)

        recorder.sceneAction?(3)
        await waitUntil { recorder.received.count == 3 }
    }

    func testHandlerOnRoot_whenAnotherViewIsPushedOnTop_shouldStillReceive() async throws {
        // Given
        let recorder = Recorder()
        let window = makeWindow(
            NKNavigationStack {
                Root(recorder: recorder, handlesActions: true)
                    .navigationDestination(for: String.self) { _ in Color.red }
            }
            .sceneActionEnabled()
        )

        // When
        try await runScenario(recorder: recorder)

        // Then
        XCTAssertGreaterThan(recorder.rootDisappeared, 0)
        XCTAssertEqual(recorder.received, [1, 2, 3])
        window.isHidden = true
    }

    func testHandlerOnStack_whenAnotherViewIsPushedOnTop_shouldStillReceive() async throws {
        // Given
        let recorder = Recorder()
        let window = makeWindow(
            NKNavigationStack {
                Root(recorder: recorder, handlesActions: false)
                    .navigationDestination(for: String.self) { _ in Color.red }
            }
            .sceneAction(for: Int.self) { recorder.received.append($0) }
            .sceneActionEnabled()
        )

        // When
        try await runScenario(recorder: recorder)

        // Then
        XCTAssertGreaterThan(recorder.rootDisappeared, 0)
        XCTAssertEqual(recorder.received, [1, 2, 3])
        window.isHidden = true
    }

    func testHandler_whenViewIsRemovedFromTheHierarchy_shouldStopReceiving() async throws {
        // Given
        let recorder = Recorder()
        let window = makeWindow(
            NKNavigationStack {
                Root(recorder: recorder, handlesActions: true)
            }
            .sceneActionEnabled()
        )

        await waitUntil { recorder.rootAppeared > 0 }
        try await sleep(milliseconds: 300)

        recorder.sceneAction?(1)
        await waitUntil { recorder.received.count == 1 }

        // When
        let sceneAction = recorder.sceneAction
        window.rootViewController = nil
        try await sleep(milliseconds: 300)

        sceneAction?(2)
        try await sleep(milliseconds: 300)

        // Then
        XCTAssertEqual(recorder.received, [1])
        window.isHidden = true
    }
}
#endif
