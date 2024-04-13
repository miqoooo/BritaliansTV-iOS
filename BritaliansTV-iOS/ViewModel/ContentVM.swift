//
//  ContentPageVM.swift
//  BritaliansTV
//
//  Created by miqo on 08.11.23.
//

import SwiftUI

class ContentVM: ObservableObject {
    var myList: [RowModel] = [.init(title: "My List", items: [])] {
        didSet {
            myList[0].items = Array(Set<ItemModel>(myList[0].items))
        }
    }
    func isInMyList(id: Int) -> Bool { return nil != myList[0].items.first(where: { $0.id == id }) }
}

