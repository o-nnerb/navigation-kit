// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

#if canImport(AppKit) || (canImport(UIKit) && !os(watchOS))
import SwiftUI
import Testing

@testable import NavigationKit

private final class SplitViewRecorder {

    @MainActor var action: NavigationAction?
    @MainActor var columns = Set<String>()
}

/// The split view takes the columns in four initializers, and each one runs in the system layout or in
/// the fallback one.
@MainActor
private enum SplitViewScenario {

    private struct Column: View {

        @Environment(\.navigationAction) var navigationAction
        let name: String
        let recorder: SplitViewRecorder

        var body: some View {
            Probe {
                recorder.columns.insert(name)
                recorder.action = navigationAction
            }
        }
    }

    static func regular(_ recorder: SplitViewRecorder) -> some View {
        NKNavigationSplitView {
            Column(name: "sidebar", recorder: recorder)
        } detail: {
            Column(name: "detail", recorder: recorder)
        }
    }

    static func full(_ recorder: SplitViewRecorder) -> some View {
        NKNavigationSplitView {
            Column(name: "sidebar", recorder: recorder)
        } content: {
            Column(name: "content", recorder: recorder)
        } detail: {
            Column(name: "detail", recorder: recorder)
        }
    }

    @available(iOS 16.0, tvOS 16.0, macOS 13.0, *)
    static func columnVisibility(_ recorder: SplitViewRecorder) -> some View {
        NKNavigationSplitView(columnVisibility: .constant(.all)) {
            Column(name: "sidebar", recorder: recorder)
        } detail: {
            Column(name: "detail", recorder: recorder)
        }
    }

    @available(iOS 16.0, tvOS 16.0, macOS 13.0, *)
    static func columnVisibilityFull(_ recorder: SplitViewRecorder) -> some View {
        NKNavigationSplitView(columnVisibility: .constant(.all)) {
            Column(name: "sidebar", recorder: recorder)
        } content: {
            Column(name: "content", recorder: recorder)
        } detail: {
            Column(name: "detail", recorder: recorder)
        }
    }
}

extension NavigationStackSuites {

    @MainActor
    @Suite struct NavigationSplitViewTests {

        @Test func splitView_whenCreatedWithSidebarAndDetail_shouldShowBothColumns() async throws {
            // Given
            let recorder = SplitViewRecorder()

            // When
            let window = hostInWindow(SplitViewScenario.regular(recorder))
            await waitUntil { recorder.columns.contains("detail") }

            // Then
            #expect(recorder.columns.contains("detail"))
            #expect(recorder.action?.count == 0)
            withExtendedLifetime(window) {}
        }

        @Test func splitView_whenCreatedWithThreeColumns_shouldShowTheDetail() async throws {
            // Given
            let recorder = SplitViewRecorder()

            // When
            let window = hostInWindow(SplitViewScenario.full(recorder))
            await waitUntil { recorder.columns.contains("detail") }

            // Then
            #expect(recorder.columns.contains("detail"))
            #expect(recorder.action?.count == 0)
            withExtendedLifetime(window) {}
        }

        @available(iOS 16.0, tvOS 16.0, macOS 13.0, *)
        @Test func splitView_whenCreatedWithColumnVisibility_shouldShowTheDetail() async throws {
            // Given
            let recorder = SplitViewRecorder()

            // When
            let window = hostInWindow(SplitViewScenario.columnVisibility(recorder))
            await waitUntil { recorder.columns.contains("detail") }

            // Then
            #expect(recorder.columns.contains("detail"))
            #expect(recorder.action?.count == 0)
            withExtendedLifetime(window) {}
        }

        @available(iOS 16.0, tvOS 16.0, macOS 13.0, *)
        @Test func splitView_whenCreatedWithColumnVisibilityAndThreeColumns_shouldShowTheDetail() async throws {
            // Given
            let recorder = SplitViewRecorder()

            // When
            let window = hostInWindow(SplitViewScenario.columnVisibilityFull(recorder))
            await waitUntil { recorder.columns.contains("detail") }

            // Then
            #expect(recorder.columns.contains("detail"))
            #expect(recorder.action?.count == 0)
            withExtendedLifetime(window) {}
        }
    }

    #if os(iOS) || os(tvOS) || os(macOS)
    @MainActor
    @Suite(.forcedFallback) struct FallbackNavigationSplitViewTests {

        @Test func splitView_whenCreatedWithThreeColumns_shouldShowTheSidebar() async throws {
            // Given
            let recorder = SplitViewRecorder()

            // When
            let window = hostInWindow(SplitViewScenario.full(recorder))
            await waitUntil { recorder.columns.contains("sidebar") }

            // Then
            #expect(recorder.columns.contains("sidebar"))
            #expect(recorder.action?.count == 0)
            withExtendedLifetime(window) {}
        }

        @Test func splitView_whenCreatedWithSidebarAndDetail_shouldShowTheSidebar() async throws {
            // Given
            let recorder = SplitViewRecorder()

            // When
            let window = hostInWindow(SplitViewScenario.regular(recorder))
            await waitUntil { recorder.columns.contains("sidebar") }

            // Then
            #expect(recorder.columns.contains("sidebar"))
            #expect(recorder.action?.count == 0)
            withExtendedLifetime(window) {}
        }
    }
    #endif
}
#endif
