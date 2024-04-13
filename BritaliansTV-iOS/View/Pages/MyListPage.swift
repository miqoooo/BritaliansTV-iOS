//
//  HomePage.swift
//  BritaliansTV-iOS
//
//  Created by miqo on 14.11.23.
//

import SwiftUI
import Kingfisher

struct MyListPage: View {
    @EnvironmentObject var contentVM: ContentVM
    @EnvironmentObject var mainPageVM: MainPageVM
    
    @State var selectedItem: ItemModel? = nil
    @State var data: [RowModel] = []
    
    var body: some View {
        ZStack {
            Color(hex: "#0F0F1E")
                .ignoresSafeArea(.all)
            
                LoadingView()
                    .opacity(mainPageVM.loading ? 1 : 0)
                
            if !mainPageVM.loading {
                NavigationStack {
                    ZStack {
                        Color(hex: "#0F0F1E")
                            .ignoresSafeArea(.all)
                        
                        CollectionGridSection()
                    }
                    .navigationDestination(item: $selectedItem, destination: { item in
                        ContentPage(item: item)
                    })
                }
            }
        }
        .onAppear {
            updateData()
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    func CollectionGridSection() -> some View {
        VStack {
            ForEach(Array(data.enumerated()), id: \.offset) { (rowIndex, row) in
                HStack(alignment: .center) {
                    Text(row.title)
                        .font(.raleway(size: 24, weight: .semibold))
                        .padding(.leading, 10)
                    
                    Spacer()
                    
                    Button(action: updateData, label: {
                        Image(systemName: "gobackward")
                            .imageScale(.large)
                            .rotationEffect(.degrees(-60))
                    })
                }
                .foregroundStyle(.white)
                .padding()
                
                if row.items.isEmpty {
                    VStack {
                        Spacer().frame(height: 120)
                        
                        Image(systemName: "x.circle")
                            .resizable().scaledToFit()
                            .frame(width: 100)
                            .foregroundStyle(.white)
                    }
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: -10) {
                            ForEach(Array(row.items.enumerated()), id:\.offset) { (colIndex, item) in
                                CardView(
                                    title: item.title,
                                    imagePath: item.poster,
                                    size: CGSize(width: 100, height: 100*1.4),
                                    ifPressed: {
                                        selectedItem = item
                                    })
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            Spacer()
        }
        .padding(.top, 30)
    }
    
    func updateData() {
        self.data = contentVM.myList
        
        Task {
            LocalStorage.save(key: "myList", data: Set<ItemModel>(contentVM.myList[0].items))
        }
    }
}
