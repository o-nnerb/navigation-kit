// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

#if canImport(AppKit) || (canImport(UIKit) && !os(watchOS))
import SwiftUI
import Testing

@testable import NavigationKit

@MainActor
@Suite struct ObjectConnectionViewModelTests {

    @MainActor
    private final class ViewModel {
        let identifier: Int

        init(identifier: Int) {
            self.identifier = identifier
        }
    }

    @MainActor
    private final class Recorder {
        var created = 0
        var rendered = [Int]()
    }

    private struct Host: View {

        let recorder: Recorder

        var body: some View {
            ObjectConnection(
                viewModel: {
                    recorder.created += 1
                    return ViewModel(identifier: recorder.created)
                },
                content: { viewModel in
                    Probe { recorder.rendered.append(viewModel.identifier) }
                }
            )
        }
    }

    @Test func objectConnection_whenCreatedWithoutInput_shouldBuildTheViewModelOnce() async throws {
        // Given
        let recorder = Recorder()

        // When
        let window = hostInWindow(Host(recorder: recorder))
        await waitUntil { !recorder.rendered.isEmpty }

        // Then
        #expect(recorder.created == 1)
        #expect(recorder.rendered == [1])
        withExtendedLifetime(window) {}
    }
}
#endif
