/*
 See LICENSE for this package's licensing information.
*/

import SwiftUI

private struct NavigationActionKey: EnvironmentKey {
    static var defaultValue: NavigationAction?
}

extension EnvironmentValues {

    var _navigationAction: NavigationAction? {
        get { self[NavigationActionKey.self] }
        set { self[NavigationActionKey.self] = newValue }
    }

    public var navigationAction: NavigationAction {
        guard let navigationAction = _navigationAction else {
            fatalError()
        }

        return navigationAction
    }
}
