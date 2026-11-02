// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

#if canImport(UIKit) && !os(watchOS)
import SwiftUI
import UIKit
import Testing

@testable import NavigationKit

@MainActor
@Suite struct SceneActionModifierUIKitTests {

    private final class Recorder {
        var received = [Int]()
    }

    private struct Child: View {

        @Environment(\.sceneAction) var sceneAction
        let value: Int

        var body: some View {
            Color.clear
                .frame(width: 10, height: 10)
                .onAppear {
                    sceneAction(value)
                }
        }
    }

    private struct Parent: View {

        let recorder: Recorder
        let value: Int

        var body: some View {
            Child(value: value)
                .sceneAction(for: Int.self) {
                    recorder.received.append($0)
                }
        }
    }

    private func makeWindow(
        sceneAction: SceneAction,
        recorder: Recorder,
        value: Int
    ) -> UIWindow {
        let controller = UIHostingController(
            rootView: Parent(recorder: recorder, value: value).environment(\.sceneAction, sceneAction)
        )

        let window = UIWindow(frame: .init(x: 0, y: 0, width: 200, height: 200))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        controller.view.layoutIfNeeded()
        return window
    }

    private func waitUntil(_ condition: () -> Bool) async {
        for _ in 0..<500 where !condition() {
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
    }

    @Test func modifier_whenActionIsFiredFromChildOnAppear_shouldBePerformed() async throws {
        // Given
        let sceneAction = SceneAction()
        let recorder = Recorder()

        // When
        let window = makeWindow(sceneAction: sceneAction, recorder: recorder, value: 7)
        await waitUntil { !recorder.received.isEmpty }

        // Then
        #expect(recorder.received == [7])
        window.isHidden = true
    }

    @Test func modifier_whenActionIsFiredRightAfterHosting_shouldBePerformed() async throws {
        // Given
        let sceneAction = SceneAction()
        let recorder = Recorder()

        // When
        let window = makeWindow(sceneAction: sceneAction, recorder: recorder, value: 1)
        sceneAction(2)
        await waitUntil { recorder.received.count == 2 }

        // Then
        #expect(recorder.received.sorted() == [1, 2])
        window.isHidden = true
    }
}
#endif
