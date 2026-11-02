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

    private func settle() async throws {
        try await Task.sleep(nanoseconds: 50_000_000)
    }

    func testSubscription_whenUpdatedBeforeTheConsumerRuns_shouldReceiveActionPerformedInBetween() async throws {
        // Given
        let sut = SceneActionSubscription<Int>()
        let sceneAction = SceneAction()
        let recorder = Recorder()

        // When
        sut.update(sceneAction: sceneAction) { recorder.received.append($0) }
        sceneAction(1)
        sceneAction(2)

        await waitUntil { recorder.received.count == 2 }

        // Then
        XCTAssertEqual(recorder.received, [1, 2])
    }

    func testSubscription_whenUpdatedAgain_shouldCallTheLatestHandlerOnly() async throws {
        // Given
        let sut = SceneActionSubscription<Int>()
        let sceneAction = SceneAction()
        let first = Recorder()
        let second = Recorder()

        // When
        sut.update(sceneAction: sceneAction) { first.received.append($0) }
        try await settle()
        sut.update(sceneAction: sceneAction) { second.received.append($0) }
        sceneAction(1)

        await waitUntil { second.received.count == 1 }

        // Then
        XCTAssertEqual(first.received, [])
        XCTAssertEqual(second.received, [1])
    }

    func testSubscription_whenUpdatedAgainWithSameScene_shouldNotReplayHandledActions() async throws {
        // Given
        let sut = SceneActionSubscription<Int>()
        let sceneAction = SceneAction()
        let recorder = Recorder()

        sut.update(sceneAction: sceneAction) { recorder.received.append($0) }
        sceneAction(1)
        await waitUntil { recorder.received.count == 1 }

        // When
        sut.update(sceneAction: sceneAction) { recorder.received.append($0) }
        sceneAction(2)
        await waitUntil { recorder.received.count == 2 }
        try await settle()

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
        sut.update(sceneAction: old) { recorder.received.append($0) }
        sut.update(sceneAction: new) { recorder.received.append($0) }

        old(1)
        new(2)

        await waitUntil { recorder.received.count == 1 }
        try await settle()

        // Then
        XCTAssertEqual(recorder.received, [2])
    }

    func testSubscription_whenReleased_shouldStopConsuming() async throws {
        // Given
        var sut: SceneActionSubscription<Int>? = .init()
        weak let weakSut = sut
        let sceneAction = SceneAction()
        let recorder = Recorder()

        sut?.update(sceneAction: sceneAction) { recorder.received.append($0) }
        sceneAction(1)
        await waitUntil { recorder.received.count == 1 }

        // When
        sut = nil
        sceneAction(2)
        try await settle()

        // Then
        XCTAssertNil(weakSut)
        XCTAssertEqual(recorder.received, [1])
    }
}
