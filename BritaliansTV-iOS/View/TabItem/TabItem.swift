//
//  TabItem.swift
//  BritaliansTV-iOS
//
//  Created by miqo on 14.11.23.
//

import Foundation

enum TabItem: Identifiable, CaseIterable, Hashable {
    case home
    case states
    case humans
    case brands
    case list
    
    var id: Int { self.hashValue }
    
    var name: String {
        switch self {
        case .home: return "Home"
        case .states: return "States"
        case .humans: return "Humans"
        case .brands: return "Brands"
        case .list: return "My List"
        //default: return ""
        }
    }
    
    var image: String {
        switch self {
        case .list: return "list"
        default:
            return self.name.lowercased()
        }
    }
}
