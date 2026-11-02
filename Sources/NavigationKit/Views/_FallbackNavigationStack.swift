// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

#if os(iOS) || os(tvOS) || os(macOS)
import SwiftUI

/// A navigation stack for the OS versions without `NavigationStack`.
///
/// On iOS and tvOS it is a `NavigationView` with a chain of hidden `NavigationLink`s, one for each
/// item of the state. macOS has no push navigation in `NavigationView` before macOS 13, so the items
/// are stacked on top of the content instead.
struct _FallbackNavigationStack<Content: View>: View {

    @ObservedObject var state: FallbackNavigationState
    let pendingItems: PendingNavigationItems?
    let isEmbedded: Bool
    let content: Content

    var body: some View {
        let _ = state.update(pendingItems)

        #if os(macOS)
        macOSStack
        #else
        if isEmbedded {
            links
        } else {
            NavigationView {
                links
            }
            .navigationViewStyle(.stack)
        }
        #endif
    }
}

#if os(macOS)

extension _FallbackNavigationStack {

    private var macOSStack: some View {
        content
            .allowsHitTesting(state.entries.isEmpty)
            .overlayPreferenceValue(FallbackDestinationsKey.self) { destinations in
                _FallbackStackLevel(
                    state: state,
                    index: 0,
                    destinations: destinations
                )
            }
    }
}

/// An item of the stack on macOS, shown on top of the content and of the previous items.
private struct _FallbackStackLevel: View {

    @ObservedObject var state: FallbackNavigationState
    let index: Int
    let destinations: FallbackDestinations

    var body: some View {
        if index < state.entries.count {
            let entry = state.entries[index]
            let isTop = index == state.entries.count - 1

            (destinations.view(for: entry.value) ?? AnyView(EmptyView()))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .windowBackgroundColor))
                .allowsHitTesting(isTop)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        if isTop {
                            Button {
                                state.truncate(to: index)
                            } label: {
                                Image(systemName: "chevron.backward")
                            }
                        }
                    }
                }
                .overlayPreferenceValue(FallbackDestinationsKey.self) { local in
                    _FallbackStackLevel(
                        state: state,
                        index: index + 1,
                        destinations: destinations.merging(local)
                    )
                }
                .transition(.move(edge: .trailing))
        }
    }
}

#else

extension _FallbackNavigationStack {

    private var links: some View {
        content
            .background(
                _FallbackNavigationControllerReader(state: state)
                    .frame(width: 0, height: 0)
                    .allowsHitTesting(false)
            )
            .backgroundPreferenceValue(FallbackDestinationsKey.self) { destinations in
                _FallbackStackLink(
                    state: state,
                    index: 0,
                    destinations: destinations
                )
            }
    }
}

/// Remembers the last non-`nil` entry shown by a level, so a level being popped keeps its content.
/// A reference type that is not observed: it only changes what the view renders in the same pass.
@MainActor
private final class FallbackEntryBox {

    private var entry: NavigationEntry?

    func remember(_ entry: NavigationEntry?) -> NavigationEntry? {
        if let entry {
            self.entry = entry
        }

        return self.entry
    }
}

/// Finds the `UINavigationController` behind the `NavigationView`, to ask it whether a push can start.
///
/// The system ignores a push started during another one, and how long a transition takes depends on
/// the device, so the stack waits for the navigation to be idle instead of guessing.
private struct _FallbackNavigationControllerReader: UIViewControllerRepresentable {

    let state: FallbackNavigationState

    func makeUIViewController(context: Context) -> Controller {
        Controller(state: state)
    }

    func updateUIViewController(_ controller: Controller, context: Context) {}

    final class Controller: UIViewController {

        private let state: FallbackNavigationState

        init(state: FallbackNavigationState) {
            self.state = state
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            attach()
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            attach()
        }

        private func attach() {
            guard let navigationController else {
                return
            }

            // The view controller of the navigation that holds this view: the ones pushed by the
            // stack come after it.
            var root: UIViewController? = self

            while let current = root, !navigationController.viewControllers.contains(current) {
                root = current.parent
            }

            guard let root, let index = navigationController.viewControllers.firstIndex(of: root) else {
                return
            }

            state.isReadyForPush = { [weak navigationController] displayedCount in
                guard let navigationController else {
                    return true
                }

                return navigationController.transitionCoordinator == nil
                    && navigationController.viewControllers.count == index + 1 + displayedCount
            }
        }
    }
}

/// The link that shows the item at `index`. It is active while the state has that item, and
/// removes it from the state when the user navigates back.
private struct _FallbackStackLink: View {

    @ObservedObject var state: FallbackNavigationState
    let index: Int
    let destinations: FallbackDestinations

    @State private var remembered = FallbackEntryBox()

    var body: some View {
        // Keeps showing the last item while the link is popped, instead of an empty screen.
        let entry = remembered.remember(state.entries.indices.contains(index) ? state.entries[index] : nil)

        let link = NavigationLink(
            isActive: Binding(
                get: { state.displayedCount > index },
                set: { isActive in
                    if !isActive {
                        state.truncate(to: index)
                    }
                }
            ),
            destination: {
                _FallbackStackDestination(
                    state: state,
                    index: index,
                    entry: entry,
                    destinations: destinations
                )
            },
            label: {
                EmptyView()
            }
        )

        #if os(iOS)
        // Keeps the link out of the detail column of a split view.
        link.isDetailLink(false).hidden()
        #else
        link.hidden()
        #endif
    }
}

private struct _FallbackStackDestination: View {

    let state: FallbackNavigationState
    let index: Int
    let entry: NavigationEntry?
    let destinations: FallbackDestinations

    var body: some View {
        if let entry {
            (destinations.view(for: entry.value) ?? AnyView(EmptyView()))
                .onAppear {
                    state.didAppear(at: index)
                }
                .backgroundPreferenceValue(FallbackDestinationsKey.self) { local in
                    _FallbackStackLink(
                        state: state,
                        index: index + 1,
                        destinations: destinations.merging(local)
                    )
                }
        }
    }
}

#endif

#endif
