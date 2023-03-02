//
//  File.swift
//  
//
//  Created by Brenno on 23/02/23.
//

import SwiftUI

@MainActor
public struct ViewModelConnection<Input, Content, ViewModel>: View where Input: Hashable, Content: View {

    @StateObject private var state = State()

    private let input: Input
    private let viewModel: @MainActor (Input) -> ViewModel
    private let content: (ViewModel) -> Content

    public init(
        _ input: Input,
        _ viewModel: @MainActor @escaping (Input) -> ViewModel,
        @ViewBuilder content: @escaping (ViewModel) -> Content
    ) {
        self.input = input
        self.viewModel = viewModel
        self.content = content
    }

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
