// Copyright 2026 Brenno Giovanini de Moura
// SPDX-License-Identifier: MIT

import SwiftUI

/// Creates the object behind a screen, usually its view model, and keeps it for as long as the input
/// stays the same.
///
/// A view is a value that SwiftUI creates again whenever its parent is evaluated, so the object cannot be
/// stored in the view. A `@StateObject` keeps the object from the first time and ignores later changes
/// to the input of the view. `ObjectConnection` creates the object from the input, keeps it while the
/// input is equal to the previous one, and creates a new object when the input changes.
///
/// The object does not need to be an `ObservableObject`. An `@Observable` type works as well, and
/// the content is rendered again when the properties it reads change.
///
/// ```swift
/// struct UserCoordinator: View {
///
///     // This needs to be Hashable
///     let scene: UserScene
///
///     var body: some View {
///         ObjectConnection(scene, UserViewModel.init) { viewModel in
///             UserView(viewModel: viewModel)
///         }
///     }
/// }
/// ```
///
/// The closure that creates the object runs on the main actor, once per input.
///
/// See <doc:Coordinators> for how to combine it with the navigation.
@MainActor
public struct ObjectConnection<Input, Content, ViewModel>: View where Input: Hashable, Content: View {

    @StateObject private var state = ObjectConnectionState<ViewModel>()

    private let input: Input
    private let viewModel: @MainActor (Input) -> ViewModel
    private let content: (ViewModel) -> Content

    /// Initializes a new instance of the view model connection with the provided input, view model, and content.
    ///
    /// - Parameters:
    ///    - input: The input value used to generate the view model.
    ///    - viewModel: The closure used to generate the view model.
    ///    - content: The closure used to generate the content view.
    public init(
        _ input: Input,
        _ viewModel: @MainActor @escaping (Input) -> ViewModel,
        @ViewBuilder content: @escaping (ViewModel) -> Content
    ) {
        self.input = input
        self.viewModel = viewModel
        self.content = content
    }

    /// Initializes a new instance of the view model connection with the provided view model and content.
    ///
    /// This initializer is intended to be used when the input value is a `UUID`.
    ///
    /// - Parameters:
    ///    - viewModel: The closure used to generate the view model.
    ///    - content: The closure used to generate the content view.
    public init(
        viewModel: @MainActor @escaping () -> ViewModel,
        @ViewBuilder content: @escaping (ViewModel) -> Content
    ) where Input == UUID {
        self.init(
            UUID(),
            { _ in viewModel() },
            content: content
        )
    }

    /// The content built with the object of the current input.
    @ViewBuilder
    public var body: some View {
        content(state.resolveInTheFly(input, viewModel))
            .onValueChange(of: input) {
                state.updateIfNeeded($0, viewModel)
            }
    }
}

@MainActor
private final class ObjectConnectionState<ViewModel>: ObservableObject {

    private var input: AnyHashable?
    private var viewModel: ViewModel?

    init() {}

    func resolveInTheFly<Input: Hashable>(
        _ input: Input,
        _ closure: @MainActor @escaping (Input) -> ViewModel
    ) -> ViewModel {
        let (_, viewModel) = updates(input, closure)
        return viewModel
    }

    func updateIfNeeded<Input: Hashable>(
        _ input: Input,
        _ closure: @MainActor @escaping (Input) -> ViewModel
    ) {
        let (updated, _) = updates(input, closure)

        if updated {
            objectWillChange.send()
        }
    }

    func updates<Input: Hashable>(
        _ input: Input,
        _ closure: @MainActor @escaping (Input) -> ViewModel
    ) -> (Bool, ViewModel) {
        if self.input != AnyHashable(input) {
            self.input = AnyHashable(input)
            self.viewModel = nil
        }

        if let viewModel {
            return (false, viewModel)
        }

        let viewModel = closure(input)
        self.viewModel = viewModel
        return (true, viewModel)
    }
}
