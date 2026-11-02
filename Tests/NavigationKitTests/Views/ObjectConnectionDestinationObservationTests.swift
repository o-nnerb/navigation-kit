// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

#if canImport(AppKit) || (canImport(UIKit) && !os(watchOS))
import Observation
import SwiftUI
import XCTest

@testable import NavigationKit

/// The coordinator pattern from the README, using an `@Observable` view model: the coordinator reacts
/// to the view model's `destination` with `onChange` instead of subscribing to a `@Published` publisher.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, *)
@MainActor
class ObjectConnectionDestinationObservationTests: XCTestCase {

    enum Destination: Equatable {
        case error(String)
        case third(Int)
    }

    @Observable
    @MainActor
    final class ViewModel {
        var destination: Destination?
    }

    @MainActor
    private final class Recorder {
        var model: ViewModel?
        var destinations = [Destination?]()
    }

    private struct Coordinator: View {

        let recorder: Recorder

        var body: some View {
            ObjectConnection(
                1,
                { _ in ViewModel() },
                content: { viewModel in
                    Color.clear
                        .frame(width: 10, height: 10)
                        .onAppear { recorder.model = viewModel }
                        .onChange(of: viewModel.destination) { _, destination in
                            recorder.destinations.append(destination)
                        }
                }
            )
        }
    }

    func testCoordinator_whenObservableDestinationChanges_shouldReact() async throws {
        // Given
        let recorder = Recorder()
        let window = hostInWindow(Coordinator(recorder: recorder))
        await waitUntil { recorder.model != nil }

        // When
        recorder.model?.destination = .third(3)
        await waitUntil { recorder.destinations.count == 1 }

        recorder.model?.destination = .error("failure")
        await waitUntil { recorder.destinations.count == 2 }

        // Then
        XCTAssertEqual(recorder.destinations, [.third(3), .error("failure")])
        XCTAssertNotNil(window)
    }
}
#endif
