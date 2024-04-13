//
//  HomePage.swift
//  BritaliansTV-iOS
//
//  Created by miqo on 14.11.23.
//

import SwiftUI
import Kingfisher

struct TabPage: View {
    @EnvironmentObject var mainPageVM: MainPageVM
    @EnvironmentObject var contentVM: ContentVM
    
    @State var isContentPresented: Bool = false
    @State var item: ItemModel? = nil
    
    var data: [RowModel]? {
        mainPageVM.rowData[mainPageVM.tabSelection.name]
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#0F0F1E")
                .ignoresSafeArea(.all)
        
            LoadingView()
                .opacity(mainPageVM.loading ? 1 : 0)
            
            if let _ = data {
                NavigationStack {
                    ZStack {
                        Color(hex: "#0F0F1E")
                            .ignoresSafeArea(.all)
                    
                        CollectionGridSection()
                            .opacity(mainPageVM.loading ? 0 : 1)
                    }
                    .navigationDestination(item: $item, destination: { item in
                        ContentPage(item: item)
                    })
                }
            }
        }
        .animation(.easeInOut, value: mainPageVM.loading)
    }
    
    @ViewBuilder
    func CollectionGridSection() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            ForEach(Array(data!.enumerated()), id: \.offset) { (rowIndex, row) in
                HStack {
                    Text(row.title)
                        .font(.raleway(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.leading, 10)
                    Spacer()
                }
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: -10) {
                    ForEach(Array(row.items.enumerated()), id:\.offset) { (colIndex, item) in
                        CardView(
                            title: item.title,
                            imagePath: item.poster,
                            size: CGSize(width: 100, height: 100*1.4),
                            ifPressed: {
                                DispatchQueue.main.async {
                                    if item.isSeries || item.isList {
                                        self.item = item
                                    }
                                }
                            })
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 80)
    }
}
