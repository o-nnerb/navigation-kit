// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

#if canImport(AppKit) || (canImport(UIKit) && !os(watchOS))
import Observation
import SwiftUI
import Testing

@testable import NavigationKit

@MainActor
@Suite struct ViewStateObservationTests {

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, *)
    @Observable
    @MainActor
    final class Model {
        var viewState: ViewState = .inactive
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, *)
    @MainActor
    private final class Recorder {
        var rendered = [ViewState]()
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, *)
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

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, *)
    @Test func viewState_whenModelIsObservable_shouldBecomeActiveAndRenderAgain() async throws {
        // Given
        let model = Model()
        let recorder = Recorder()

        // When
        let window = hostInWindow(Host(model: model, recorder: recorder))
        await waitUntil { model.viewState == .active }
        await waitUntil { recorder.rendered.last == .active }

        // Then
        #expect(model.viewState == .active)
        #expect(recorder.rendered.last == .active)
        withExtendedLifetime(window) {}
    }
}
#endif
