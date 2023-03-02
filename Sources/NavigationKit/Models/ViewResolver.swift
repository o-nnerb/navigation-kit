//
//  File.swift
//  
//
//  Created by Brenno on 23/02/23.
//

import SwiftUI

public struct ViewResolver {

    private let _viewResolver: _ViewResolver

    init(_ _viewResolver: _ViewResolver) {
        self._viewResolver = _viewResolver
    }

    public func callAsFunction<Item: Hashable>(_ item: Item) -> some View {
        _viewResolver(ObjectIdentifier(Item.self))(item)
    }
}
