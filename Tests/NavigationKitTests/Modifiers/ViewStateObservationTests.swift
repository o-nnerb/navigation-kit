// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

#if canImport(AppKit) || (canImport(UIKit) && !os(watchOS))
import Observation
import SwiftUI
import XCTest

@testable import NavigationKit

@available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, *)
@MainActor
class ViewStateObservationTests: XCTestCase {

    @Observable
    @MainActor
    final class Model {
        var viewState: ViewState = .inactive
    }

    @MainActor
    private final class Recorder {
        var rendered = [ViewState]()
    }

    private struct Host: View {

        let model: Model
        let recorder: Recorder

        var body: some View {
            // Observation tracks the property read in this body.
            let _ = recorder.rendered.append(model.viewState)
            Color.clear
                .frame(width: 10, height: 10)
                .viewState(model, keyPath: \.viewState)
        }
    }

    func testViewState_whenModelIsObservable_shouldBecomeActiveAndRenderAgain() async throws {
        // Given
        let model = Model()
        let recorder = Recorder()

        // When
        let window = hostInWindow(Host(model: model, recorder: recorder))
        await waitUntil { model.viewState == .active }
        await waitUntil { recorder.rendered.last == .active }

        // Then
        XCTAssertEqual(model.viewState, .active)
        XCTAssertEqual(recorder.rendered.last, .active)
        XCTAssertNotNil(window)
    }
}
#endif
