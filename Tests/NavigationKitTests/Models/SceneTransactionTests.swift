// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import Testing

@testable import NavigationKit

@MainActor
@Suite struct SceneTransactionTests {

    @Test func sceneTransaction_whenTwoFired_shouldTransactionToTwoElements() async throws {
        // Given
        let sut = SceneTransaction<Int>()

        // When
        let iterator = sut.values.makeAsyncIterator()

        sut(1)
        sut(2)

        // Then
        let values = [await iterator.next(), await iterator.next()]
        #expect(values == [1, 2])
    }

    @Test func sceneTransaction_whenTwoSubscribers_shouldDeliverToBoth() async throws {
        // Given
        let sut = SceneTransaction<Int>()

        // When
        let first = sut.values.makeAsyncIterator()
        let second = sut.values.makeAsyncIterator()

        sut(1)

        // Then
        let values = [await first.next(), await second.next()]
        #expect(values == [1, 1])
    }

    @Test func sceneTransaction_whenFiredBeforeSubscription_shouldNotReplay() async throws {
        // Given
        let sut = SceneTransaction<Int>()
        sut(1)

        // When
        let iterator = sut.values.makeAsyncIterator()
        sut(2)

        // Then
        let value = await iterator.next()
        #expect(value == 2)
    }

    @Test func sceneTransaction_whenCopied_shouldShareSubscribers() async throws {
        // Given
        let sut = SceneTransaction<Int>()
        let copy = sut

        // When
        let iterator = sut.values.makeAsyncIterator()
        copy(5)

        // Then
        let value = await iterator.next()
        #expect(sut == copy)
        #expect(value == 5)
    }

    @Test func sceneTransaction_whenIteratingTaskIsCancelled_shouldFinishSequence() async throws {
        // Given
        let sut = SceneTransaction<Int>()
        let values = sut.values

        // When
        let task = Task { () -> [Int] in
            var received = [Int]()
            for await value in values {
                received.append(value)
            }
            return received
        }

        task.cancel()

        // Then
        let received = await task.value
        #expect(received.isEmpty)
    }

    @Test func sceneTransaction_whenFiredFromAnotherTask_shouldBeObservedByAnotherTask() async throws {
        // Given
        let sut = SceneTransaction<Int>()
        let iterator = sut.values.makeAsyncIterator()

        // When
        let task = Task { () -> [Int?] in
            [await iterator.next(), await iterator.next()]
        }

        await Task.detached {
            sut(1)
            sut(2)
        }.value

        // Then
        let received = await task.value
        #expect(received == [1, 2])
    }
}
