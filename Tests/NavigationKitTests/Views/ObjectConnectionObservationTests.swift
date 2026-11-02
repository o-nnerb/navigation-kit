// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

#if canImport(AppKit) || (canImport(UIKit) && !os(watchOS))
import Observation
import SwiftUI
import Testing

@testable import NavigationKit

@MainActor
@Suite struct ObjectConnectionObservationTests {

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, *)
    @Observable
    @MainActor
    final class Model {

        let input: Int
        var count = 0

        init(input: Int) {
            self.input = input
        }
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, *)
    @MainActor
    private final class Recorder {

        var created = [Int]()
        var rendered = [String]()
        var model: Model?
        var setInput: ((Int) -> Void)?

        func render(_ model: Model) {
            self.model = model
            rendered.append("\(model.input):\(model.count)")
        }
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, *)
    private struct Host: View {

        let recorder: Recorder
        @State private var input = 1

        var body: some View {
            ObjectConnection(
                input,
                { input in
                    recorder.created.append(input)
                    return Model(input: input)
                },
                content: { model in
                    // Observation tracks the properties read while this closure runs.
                    let _ = recorder.render(model)
                    Color.clear
                        .frame(width: 10, height: 10)
                        .onAppear {
                            recorder.setInput = { input = $0 }
                        }
                }
            )
        }
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, *)
    @Test func connection_whenModelIsObservable_shouldCreateModelOnce() async throws {
        // Given
        let recorder = Recorder()

        // When
        let window = hostInWindow(Host(recorder: recorder))
        await waitUntil { recorder.model != nil }

        recorder.model?.count = 1
        recorder.model?.count = 2
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then
        #expect(recorder.created == [1])
        withExtendedLifetime(window) {}
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, *)
    @Test func connection_whenObservablePropertyChanges_shouldRenderContentAgain() async throws {
        // Given
        let recorder = Recorder()

        // When
        let window = hostInWindow(Host(recorder: recorder))
        await waitUntil { recorder.model != nil }

        recorder.model?.count = 7
        await waitUntil { recorder.rendered.last == "1:7" }

        // Then
        #expect(recorder.rendered.last == "1:7")
        withExtendedLifetime(window) {}
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, *)
    @Test func connection_whenInputChanges_shouldCreateANewObservableModel() async throws {
        // Given
        let recorder = Recorder()
        let window = hostInWindow(Host(recorder: recorder))
        await waitUntil { recorder.model != nil }
        let first = recorder.model
        first?.count = 3

        // When
        recorder.setInput?(2)
        await waitUntil { recorder.created.count == 2 }
        await waitUntil { recorder.rendered.last == "2:0" }

        // Then
        #expect(recorder.created == [1, 2])
        #expect(recorder.rendered.last == "2:0")
        withExtendedLifetime(window) {}

        // And the new model is the one observed
        await waitUntil { recorder.model !== first }
        recorder.model?.count = 9
        await waitUntil { recorder.rendered.last == "2:9" }
        #expect(recorder.rendered.last == "2:9")
    }
}
#endif
