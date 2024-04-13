//
//  MainPage.swift
//  BritaliansTV
//
//  Created by miqo on 07.11.23.
//

import SwiftUI
import Kingfisher

struct MainPage: View {
    @EnvironmentObject var appVM: ApplicationVM
    @EnvironmentObject var playerVM: PlayerVM
    @EnvironmentObject var mainPageVM: MainPageVM
    @EnvironmentObject var contentVM: ContentVM
    
    @State private var tabSelection: Int = 0
    let tabs: [TabItem] = TabItem.allCases
    
    var body: some View {
        CustomTabView(tabs: tabs, selection: $tabSelection) { index in
            switch tabs[index] {
            case .home:
                HomePage()
            case .list:
                MyListPage()
            default:
                TabPage()
            }
        }
        //.ignoresSafeArea()
        .task(loadData)
        .onChange(of: tabSelection, onTabSelection)
        .onChange(of: mainPageVM.updateAdData, onUpdateAdData)
    }
    
    @Sendable @MainActor
    func loadData() async {
        if !appVM.dataLoaded {
            Task {
                await mainPageVM.loadData()
                //playerVM.adData = mainPageVM.adData
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    if let myList: Set<ItemModel> = LocalStorage.load(key: "myList") {
                        contentVM.myList[0].items = myList.map({ $0 })
                    } else {
                        LocalStorage.save(key: "myList", data: Set<ItemModel>())
                    }
                    
                    appVM.dataLoaded = true
                })
            }
        }
    }
    
    func onTabSelection(_: Int, newValue: Int) {
        let selection = tabs[newValue]
        mainPageVM.loading = true
        
        switch selection {
        case .list:
            mainPageVM.loading = false
        default:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                mainPageVM.tabSelection = selection
                mainPageVM.onTabSelection(selection: selection)
            }
        }
    }
    
    func onUpdateAdData() {
        print("================================")
        print("updating ad data")
        print("================================")
        playerVM.adData = mainPageVM.adData
    }
}
