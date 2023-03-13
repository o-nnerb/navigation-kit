/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI

/**
 A view model connection that takes an input value, a view model, and a content view to display.

 This connection automatically handles the creation, update, and disposal of the view model based on changes to the input value.

 ```swift
 struct UserCoordinator: View {

     // This needs to be Hashable
     let scene: UserScene

     var body: some View {
         ViewModelConnection(scene, UserViewModel.init) { viewModel in
             UserView(viewModel: viewModel)
         }
     }
 }
 ```
 */
@MainActor
public struct ViewModelConnection<Input, Content, ViewModel>: View where Input: Hashable, Content: View {

    @StateObject private var state = State()

    private let input: Input
    private let viewModel: @MainActor (Input) -> ViewModel
    private let content: (ViewModel) -> Content

    /**
     Initializes a new instance of the view model connection with the provided input, view model, and content.

     - Parameters:
        - input: The input value used to generate the view model.
        - viewModel: The closure used to generate the view model.
        - content: The closure used to generate the content view.
     */
    public init(
        _ input: Input,
        _ viewModel: @MainActor @escaping (Input) -> ViewModel,
        @ViewBuilder content: @escaping (ViewModel) -> Content
    ) {
        self.input = input
        self.viewModel = viewModel
        self.content = content
    }

    /**
     Initializes a new instance of the view model connection with the provided view model and content.

     This initializer is intended to be used when the input value is a `UUID`.

     - Parameters:
        - viewModel: The closure used to generate the view model.
        - content: The closure used to generate the content view.
     */
    public init(
        viewModel: @MainActor @escaping () -> ViewModel,
        @ViewBuilder content: @escaping (ViewModel) -> Content
    ) where Input == UUID {
        self.init(
            UUID(), { _ in viewModel() },
            content: content
        )
    }

    @ViewBuilder
    public var body: some View {
        content(state.resolveInTheFly(input, viewModel))
            .onChange(of: input) {
                state.updateIfNeeded($0, viewModel)
            }
    }
}

private extension ViewModelConnection {

    @MainActor
    class State: ObservableObject {

        private var input: Input?
        private var viewModel: ViewModel?

        init() {}

        func resolveInTheFly(
            _ input: Input,
            _ closure: @MainActor @escaping (Input) -> ViewModel
        ) -> ViewModel {
            let (_, viewModel) = updates(input, closure)
            return viewModel
        }

        func updateIfNeeded(
            _ input: Input,
            _ closure: @MainActor @escaping (Input) -> ViewModel
        ) {
            let (updated, _) = updates(input, closure)

            if updated {
                objectWillChange.send()
            }
        }

        func updates(
            _ input: Input,
            _ closure: @MainActor @escaping (Input) -> ViewModel
        ) -> (Bool, ViewModel) {
            if self.input != input {
                self.input = input
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
}
