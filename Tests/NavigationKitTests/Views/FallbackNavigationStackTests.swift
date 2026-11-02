// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

#if os(iOS) || os(tvOS) || os(macOS)
import SwiftUI
import XCTest

@testable import NavigationKit

/// Exercises the fallback navigation (the one used before iOS 16, tvOS 16 and macOS 13) by forcing it
/// on the OS version the tests run on.
@MainActor
class FallbackNavigationStackTests: XCTestCase {

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

    override func setUp() async throws {
        NavigationBackend.forcesFallback = true
    }

    override func tearDown() async throws {
        NavigationBackend.forcesFallback = false
    }

    private func host(
        _ recorder: Recorder,
        representation: NavigationAction.CodableRepresentation? = nil
    ) async -> AnyObject {
        let window = hostInWindow(Stack(recorder: recorder, representation: representation))
        await waitUntil { recorder.action != nil }
        return window
    }

    func testStack_whenItemIsAppended_shouldShowItsDestination() async throws {
        // Given
        let recorder = Recorder()
        let window = await host(recorder)

        // When
        recorder.action?.append(1)
        await waitUntil { recorder.appeared.contains(1) }

        // Then
        XCTAssertEqual(Set(recorder.appeared), [1])
        XCTAssertEqual(recorder.action?.count, 1)
        XCTAssertTrue(recorder.environmentWasAvailable.allSatisfy { $0 })
        XCTAssertNotNil(window)
    }

    /// The second item is appended while the push of the first one is still animating.
    func testStack_whenItemsOfDifferentTypesAreAppended_shouldShowEachDestination() async throws {
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
        XCTAssertEqual(Set(recorder.appeared), [1])
        XCTAssertEqual(recorder.strings, ["text"])
        XCTAssertEqual(recorder.action?.count, 2)
        XCTAssertNotNil(window)
    }

    func testStack_whenLastItemIsRemoved_shouldDismissItsDestination() async throws {
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
        XCTAssertTrue(recorder.disappeared.contains(2))
        XCTAssertEqual(recorder.action?.count, 1)
        XCTAssertNotNil(window)
    }

    /// The system navigation drops (and reports as dismissed) the items pushed while another push is in
    /// progress, so the stack has to still have all of them once the pushes are done.
    func testStack_whenSeveralItemsAreSet_shouldKeepAllOfThem() async throws {
        // Given
        let recorder = Recorder()
        let window = await host(recorder)

        // When
        recorder.action?.setItems([1, 2, 3])
        await waitUntil { recorder.appeared.contains(3) }
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Then
        XCTAssertEqual(Set(recorder.appeared), [1, 2, 3])
        XCTAssertEqual(recorder.action?.count, 3)
        XCTAssertNotNil(window)
    }

    func testStack_whenAllItemsAreRemoved_shouldDismissEveryDestination() async throws {
        // Given
        let recorder = Recorder()
        let window = await host(recorder)

        recorder.action?.setItems([1, 2, 3])
        await waitUntil { recorder.appeared.contains(3) }

        // When
        recorder.action?.removeAll()
        await waitUntil { Set(recorder.disappeared) == [1, 2, 3] }

        // Then
        XCTAssertEqual(Set(recorder.disappeared), [1, 2, 3])
        XCTAssertEqual(recorder.action?.count, 0)
        XCTAssertNotNil(window)
    }

    func testStack_whenCreatedWithARepresentation_shouldShowTheItems() async throws {
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
        XCTAssertEqual(Set(recorder.appeared), [1, 2])
        XCTAssertEqual(recorder.action?.count, 2)
        XCTAssertNotNil(window)
    }

    func testStack_whenItemsAreCodable_shouldProduceARepresentationThatRestoresThem() async throws {
        // Given
        let recorder = Recorder()
        let window = await host(recorder)

        recorder.action?.setItems([1, 2])
        await waitUntil { recorder.appeared.contains(2) }

        // When
        let representation = try XCTUnwrap(recorder.action?.codable)

        // Then
        XCTAssertEqual(representation.navigationPath, ["Swift.Int", "2", "Swift.Int", "1"])
        XCTAssertNotNil(window)
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

    func testSplitView_whenCreated_shouldProvideTheNavigationAction() async throws {
        // Given
        let recorder = Recorder()

        // When
        let window = hostInWindow(SplitView(recorder: recorder))
        await waitUntil { recorder.sidebarAppeared }

        // Then
        XCTAssertTrue(recorder.sidebarAppeared)
        XCTAssertEqual(recorder.action?.count, 0)
        XCTAssertNotNil(window)
    }

    #if os(macOS)
    func testSplitView_whenItemIsAppended_shouldShowItsDestinationInTheDetail() async throws {
        // Given
        let recorder = Recorder()
        let window = hostInWindow(SplitView(recorder: recorder))
        await waitUntil { recorder.sidebarAppeared }

        // When
        recorder.action?.append(1)
        await waitUntil { recorder.appeared.contains(1) }

        // Then
        XCTAssertTrue(recorder.appeared.contains(1))
        XCTAssertEqual(recorder.action?.count, 1)
        XCTAssertNotNil(window)
    }
    #endif
}
#endif
