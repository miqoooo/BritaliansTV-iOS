//
//  HomePage.swift
//  BritaliansTV-iOS
//
//  Created by miqo on 14.11.23.
//

import SwiftUI
import Kingfisher

struct HomePage: View {
    @EnvironmentObject var mainPageVM: MainPageVM
    @EnvironmentObject var contentVM: ContentVM
    
    @State var selectedSeason: ItemModel? = nil
    @State var selectedVideo: ItemModel? = nil
    
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
                    
                        CollectionSection()
                            .opacity(mainPageVM.loading ? 0 : 1)
                    }
                    .navigationDestination(item: $selectedSeason, destination: { item in
                        ContentPage(item: item)
                    })
                    .navigationDestination(item: $selectedVideo, destination: { item in
                        ContentPage(item: item)
                    })
                }
            }
        }
        .animation(.easeInOut, value: mainPageVM.loading)
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    func CollectionSection() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                Image("appLogo")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
            
                ForEach(Array(data!.enumerated()), id: \.offset) { (rowIndex, row) in
                    VStack(spacing: 10) {
                        HStack {
                            Text(row.title)
                                .font(.raleway(size: 24, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.leading, 10)
                            Spacer()
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 5) {
                                ForEach(Array(row.items.enumerated()), id:\.offset) { (colIndex, item) in
                                    CardView(
                                        imagePath: item.poster,
                                        isInMyList: contentVM.isInMyList(id: item.id),
                                        ifPressed: {
                                            DispatchQueue.main.async {
                                                if item.isVideo {
                                                    selectedVideo = item
                                                } else if item.isSeries || item.isList {
                                                    selectedSeason = item
                                                }
                                            }
                                        })
                                }
                            }
                            .padding(.horizontal)
                            Spacer()
                        }
                    }
                }
            }
            .padding(.top, 80)
        }
    }
}
