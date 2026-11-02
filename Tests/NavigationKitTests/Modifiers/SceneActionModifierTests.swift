// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

#if os(macOS)
import AppKit
import SwiftUI
import XCTest

@testable import NavigationKit

@MainActor
class SceneActionModifierTests: XCTestCase {

    private final class Recorder {
        var received = [Int]()
    }

    private struct Host: View {

        let recorder: Recorder

        var body: some View {
            Color.clear
                .frame(width: 10, height: 10)
                .sceneAction(for: Int.self) {
                    recorder.received.append($0)
                }
        }
    }

    private func makeWindow(
        sceneAction: SceneAction,
        recorder: Recorder
    ) -> NSWindow {
        _ = NSApplication.shared
        let hosting = NSHostingView(
            rootView: Host(recorder: recorder).environment(\.sceneAction, sceneAction)
        )

        let window = NSWindow(
            contentRect: .init(x: 0, y: 0, width: 100, height: 100),
            styleMask: [.titled],
            backing: .buffered,
            defer: false
        )

        window.isReleasedWhenClosed = false
        window.contentView = hosting
        window.orderBack(nil)
        hosting.layoutSubtreeIfNeeded()
        return window
    }

    private func waitUntil(_ condition: () -> Bool) async {
        for _ in 0..<500 where !condition() {
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
    }

    func testModifier_whenActionPerformedRightAfterBuilding_shouldBePerformed() async throws {
        // Given
        let sceneAction = SceneAction()
        let recorder = Recorder()

        // When
        let window = makeWindow(sceneAction: sceneAction, recorder: recorder)
        sceneAction(1)
        sceneAction(2)

        await waitUntil { recorder.received.count == 2 }

        // Then
        XCTAssertEqual(recorder.received, [1, 2])
        window.close()
    }

    func testModifier_whenActionPerformedLater_shouldBePerformed() async throws {
        // Given
        let sceneAction = SceneAction()
        let recorder = Recorder()
        let window = makeWindow(sceneAction: sceneAction, recorder: recorder)

        // When
        try await Task.sleep(nanoseconds: 200_000_000)
        sceneAction(3)

        await waitUntil { recorder.received.count == 1 }

        // Then
        XCTAssertEqual(recorder.received, [3])
        window.close()
    }
}
#endif
