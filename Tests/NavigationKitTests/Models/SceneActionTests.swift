// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftAsyncStream
import Testing

@testable import NavigationKit

@MainActor
@Suite struct SceneActionTests {

    @Test func sceneAction_whenIntegerRegister_shouldBeValid() async throws {
        // Given
        let sceneAction = SceneAction()
        let value = 1

        // When
        var iterator = sceneAction.values(for: Int.self).makeAsyncIterator()
        sceneAction(value)

        // Then
        let received = await iterator.next()
        #expect(received == value)
    }

    @Test func sceneAction_whenIntegerRegisterTwoTimes_shouldBeValid() async throws {
        // Given
        let sceneAction = SceneAction()
        let value = 1

        // When
        var first = sceneAction.values(for: Int.self).makeAsyncIterator()
        var second = sceneAction.values(for: Int.self).makeAsyncIterator()
        sceneAction(value)

        // Then
        let received = [await first.next(), await second.next()]
        #expect(received == [value, value])
    }

    @Test func sceneAction_whenPerformedBeforeSubscription_shouldNotReplay() async throws {
        // Given
        let sceneAction = SceneAction()
        sceneAction(1)

        // When
        var iterator = sceneAction.values(for: Int.self).makeAsyncIterator()
        sceneAction(2)

        // Then
        let received = await iterator.next()
        #expect(received == 2)
    }

    @Test func sceneAction_whenDifferentTypes_shouldOnlyDeliverMatchingType() async throws {
        // Given
        let sceneAction = SceneAction()

        // When
        var integers = sceneAction.values(for: Int.self).makeAsyncIterator()
        sceneAction("ignored")
        sceneAction(7)

        // Then
        let received = await integers.next()
        #expect(received == 7)
    }

    @Test func sceneAction_whenDifferentScenes_shouldBeIsolated() async throws {
        // Given
        let first = SceneAction()
        let second = SceneAction()

        // When
        var iterator = first.values(for: Int.self).makeAsyncIterator()
        second(1)
        first(2)

        // Then
        let received = await iterator.next()
        #expect(received == 2)
    }

    @Test func sceneAction_whenCopied_shouldShareIdentityAndSubscribers() async throws {
        // Given
        let sceneAction = SceneAction()
        let copy = sceneAction

        // When
        var iterator = sceneAction.values(for: Int.self).makeAsyncIterator()
        copy(3)

        // Then
        #expect(sceneAction.id == copy.id)
        let received = await iterator.next()
        #expect(received == 3)
    }

    @Test func sceneAction_whenIteratingTaskIsCancelled_shouldFinishSequence() async throws {
        // Given
        let sceneAction = SceneAction()
        let sequence = sceneAction.values(for: Int.self)

        // When
        let task = Task { () -> [Int] in
            var received = [Int]()
            for await value in sequence {
                received.append(value)
            }
            return received
        }

        task.cancel()

        // Then
        let received = await task.value
        #expect(received.isEmpty)
    }

    @Test func sceneAction_whenActionIsNotSendable_shouldStillBeDelivered() async throws {
        // Given
        final class Reference: Hashable {
            static func == (_ lhs: Reference, _ rhs: Reference) -> Bool { lhs === rhs }
            func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
        }

        let sceneAction = SceneAction()
        let action = Reference()

        // When
        var iterator = sceneAction.values(for: Reference.self).makeAsyncIterator()
        sceneAction(action)

        // Then
        let received = await iterator.next()
        #expect(received === action)
    }
}
