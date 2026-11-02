// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import XCTest

@testable import NavigationKit

@MainActor
class SceneActionSubscriptionTests: XCTestCase {

    private final class Recorder {
        var received = [Int]()
    }

    private func waitUntil(_ condition: () -> Bool) async {
        for _ in 0..<500 where !condition() {
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
    }

    private func consume(
        _ subscription: SceneActionSubscription<Int>,
        _ sceneAction: SceneAction,
        into recorder: Recorder
    ) -> Task<Void, Never> {
        Task { @MainActor in
            await subscription.consume(sceneAction) {
                recorder.received.append($0)
            }
        }
    }

    func testSubscription_whenPreparedBeforeConsuming_shouldReceiveActionPerformedInBetween() async throws {
        // Given
        let sut = SceneActionSubscription<Int>()
        let sceneAction = SceneAction()
        let recorder = Recorder()

        // When
        sut.prepare(for: sceneAction)
        sceneAction(1)

        let task = consume(sut, sceneAction, into: recorder)
        await waitUntil { recorder.received.count == 1 }
        task.cancel()
        await task.value

        // Then
        XCTAssertEqual(recorder.received, [1])
    }

    func testSubscription_whenNotPrepared_shouldOnlyReceiveActionsAfterConsuming() async throws {
        // Given
        let sut = SceneActionSubscription<Int>()
        let sceneAction = SceneAction()
        let recorder = Recorder()

        // When
        sceneAction(1)

        let task = consume(sut, sceneAction, into: recorder)
        try await Task.sleep(nanoseconds: 50_000_000)
        sceneAction(2)

        await waitUntil { recorder.received.count == 1 }
        task.cancel()
        await task.value

        // Then
        XCTAssertEqual(recorder.received, [2])
    }

    func testSubscription_whenPreparedWhileConsuming_shouldNotReplayHandledActions() async throws {
        // Given
        let sut = SceneActionSubscription<Int>()
        let sceneAction = SceneAction()
        let recorder = Recorder()

        sut.prepare(for: sceneAction)
        let first = consume(sut, sceneAction, into: recorder)
        try await Task.sleep(nanoseconds: 50_000_000)

        // When
        sut.prepare(for: sceneAction)
        sceneAction(1)

        await waitUntil { recorder.received.count == 1 }
        first.cancel()
        await first.value

        let second = consume(sut, sceneAction, into: recorder)
        try await Task.sleep(nanoseconds: 50_000_000)
        sceneAction(2)

        await waitUntil { recorder.received.count == 2 }
        second.cancel()
        await second.value

        // Then
        XCTAssertEqual(recorder.received, [1, 2])
    }

    func testSubscription_whenSceneActionChanges_shouldListenToTheNewOne() async throws {
        // Given
        let sut = SceneActionSubscription<Int>()
        let old = SceneAction()
        let new = SceneAction()
        let recorder = Recorder()

        // When
        sut.prepare(for: old)
        sut.prepare(for: new)

        let task = consume(sut, new, into: recorder)
        try await Task.sleep(nanoseconds: 50_000_000)
        old(1)
        new(2)

        await waitUntil { recorder.received.count == 1 }
        task.cancel()
        await task.value

        // Then
        XCTAssertEqual(recorder.received, [2])
    }
}
