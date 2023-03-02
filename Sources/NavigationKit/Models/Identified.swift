//
//  File.swift
//  
//
//  Created by Brenno on 23/02/23.
//

import SwiftUI

struct Identified<Item: Hashable>: Identifiable {

    let item: Item

    var id: Int {
        item.hashValue
    }
}
