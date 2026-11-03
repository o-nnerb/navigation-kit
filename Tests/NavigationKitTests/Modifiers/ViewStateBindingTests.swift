// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

#if canImport(AppKit) || (canImport(UIKit) && !os(watchOS))
import SwiftUI
import Testing

@testable import NavigationKit

@MainActor
@Suite struct ViewStateBindingTests {

    @MainActor
    private final class Model {
        var viewState = ViewState.inactive
        var changes = [ViewState]()
    }

    private struct BindingHost: View {

        let model: Model
        @State private var isShown = true
        @State private var viewState = ViewState.inactive

        var body: some View {
            Group {
                if isShown {
                    Color.clear
                        .frame(width: 10, height: 10)
                        .viewState($viewState)
                }
            }
            .onValueChange(of: viewState) { model.changes.append($0) }
            .onAppear { model.viewState = .inactive }
        }
    }

    private struct ObjectHost: View {

        let model: Model

        var body: some View {
            Color.clear
                .frame(width: 10, height: 10)
                .viewState(model, keyPath: \.viewState)
        }
    }

    @Test func viewState_whenBindingIsUsed_shouldBecomeActiveWhenTheViewAppears() async throws {
        // Given
        let model = Model()

        // When
        let window = hostInWindow(BindingHost(model: model))
        await waitUntil { model.changes.contains(.active) }

        // Then
        #expect(model.changes.contains(.active))
        withExtendedLifetime(window) {}
    }

    @Test func viewState_whenObjectIsUsed_shouldBecomeActiveWhenTheViewAppears() async throws {
        // Given
        let model = Model()

        // When
        let window = hostInWindow(ObjectHost(model: model))
        await waitUntil { model.viewState == .active }

        // Then
        #expect(model.viewState == .active)
        withExtendedLifetime(window) {}
    }
}
#endif
