//
//  SeasonPage.swift
//  BritaliansTV-iOS
//
//  Created by miqo on 16.11.23.
//

import SwiftUI
import Kingfisher

struct ContentPage: View {
    private enum CoordinateSpaces { case scrollView }
    
    @EnvironmentObject var contentVM: ContentVM
    @EnvironmentObject var playerVM: PlayerVM

    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) var scenePhase
    
    @State var selectedVideo: ItemModel? = nil
    var item: ItemModel
    
    @State var backButtonVisible: Bool = true
    @State var isInMyList: Bool = false

    @State var scrollYChange: CGFloat = 0
    @State var isInfoPresented: Bool = false
    @State var isPlayerPresented: Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "#0F0F1E")
            
            ScrollView(.vertical, showsIndicators: false) {
                ParallaxHeader(
                    coordinateSpace: CoordinateSpaces.scrollView,
                    minY: $scrollYChange
                ) {
                    KFImage(URL(string: item.poster))
                        .resizable()
                        .overlay {
                            ZStack {
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, Color(hex: "#0F0F1E").opacity(0.8), Color(hex: "#0F0F1E")]),
                                    startPoint: .center,
                                    endPoint: .bottom
                                )
                            }
                        }
                }
                
                ContentSection()
                    .frame(maxHeight: .infinity)
                    .offset(y: -UIScreen.screenHeight*0.2)
            }
            .navigationDestination(item: $selectedVideo, destination: { item in
                ContentPage(item: item)
            })
            
            HStack {
                if backButtonVisible {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.white)
                    }
                    .background {
                        Color.gray.opacity(0.5)
                            .clipShape(Circle())
                            .frame(width: 36, height: 36)
                    }
                }
                
                Spacer()
            }
            .padding(.top, 50)
            .padding(.horizontal, 20)
        }
        .onAppear {
            isInMyList = contentVM.isInMyList(id: item.id)
        }
        .animation(.default, value: backButtonVisible)
        .onChange(of: scrollYChange, { _, value in
            if value < -40 || value > 80 {
                backButtonVisible = false
            } else {
                backButtonVisible = true
            }
        })
        .coordinateSpace(name: CoordinateSpaces.scrollView)
        .sheet(isPresented: $isInfoPresented, content: {
            ItemInfoContent(currentItem: item)
        })
        .fullScreenCover(
            isPresented: $isPlayerPresented,
            onDismiss: {
                AppDelegate.orientationLock = .portrait
                playerVM.reset()
            },
            content: {
                VideoPlayerView(url: URL(string: item.link)!)
            }
        )
        .onChange(of: scenePhase) { _, newPhase in
                        if newPhase != .active {
                            isPlayerPresented = false
                            print("Background")
                        }
                    }
        .navigationBarHidden(true)
        .ignoresSafeArea(.all)
    }
    
    @ViewBuilder
    func ContentSection() -> some View {
        VStack(alignment: .center, spacing: 30) {
            VStack(spacing: item.isVideo ? 20 : -10) {
                HeaderInfoView()
                
                ZStack {
                    VStack {
                        Spacer()
                        if item
                            .isVideo {
                            PlayButton()
                        }
                        Spacer()
                    }
                    
                    HStack(spacing: 0) {
                        AddToListButton()
                        
                        Spacer()
                        
                        InfoButton()
                    }
                }
            }
            .padding()
            .foregroundStyle(.white)
            
            var rowData: [RowModel] {
                if item.isVideo {
                    return item.videoRow
                } else {
                    return item.seasons
                }
            }
            
            ForEach(Array(rowData.enumerated()), id: \.offset) { (rowIndex, row) in
                LazyVStack(spacing: -10) {
                    HStack {
                        Text(row.title)
                            .font(.raleway(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    
                    let rowWidth: CGFloat = (rowIndex == 0 && !item.isVideo ? 150 : 100)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: -10) {
                            ForEach(Array(row.items.enumerated()), id:\.offset) { (colIndex, item) in
                                CardView(
                                    imagePath: item.poster,
                                    size: CGSize(width: rowWidth, height: rowWidth*1.4),
                                    cornerRadius: 1,
                                    ifPressed: {
                                        DispatchQueue.main.async {
                                            if !self.item.isVideo {
                                                selectedVideo = item
                                            }
                                        }
                                    })
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color(hex: "#0F0F1E").opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    
    @ViewBuilder
    func AddToListButton() -> some View {
        Button(action: {
            print("is in list: \(isInMyList)")
            if isInMyList {
                let index = contentVM.myList[0].items.firstIndex(where: { $0.id == item.id })!
                contentVM.myList[0].items.remove(at: index)
            } else {
                contentVM.myList[0].items.append(item)
            }
            isInMyList = contentVM.isInMyList(id: item.id)
        }, label: {
            VStack(spacing: 5) {
                Image(systemName: isInMyList ? "minus.circle" : "plus.circle")
                    .resizable()
                    .frame(width: 25, height: 25)
                
                Text("My List")
                    .font(.raleway(size: 13))
            }
        })
        .disabled(item.isVideo ? false : true)
        .foregroundStyle(item.isVideo ? .white : .gray)
    }
    
    @ViewBuilder
    func PlayButton() -> some View {
        Button(action: { isPlayerPresented = true }, label: {
            HStack(spacing: 5) {
                Image("play")
                    .resizable().scaledToFit()
                    .frame(height: 25)
                Text("Play")
                    .font(.raleway(size: 20, weight: .semibold))
                    .foregroundStyle(.black)
            }
            .frame(width: 110, height: 45)
            .background(Color(hex: "#C4C4C4"))
            .clipShape(RoundedRectangle(cornerRadius: 5))
        })
    }
    
    @ViewBuilder
    func InfoButton() -> some View {
        Button(action: { isInfoPresented = true }, label: {
            VStack(spacing: 5) {
                Image("info")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 25, height: 25)
                Text("Info")
                    .font(.raleway(size: 13))
            }
        })
        .disabled(item.isVideo ? true : false)
        .foregroundStyle(item.isVideo ? .gray : .white)
    }
     
    @ViewBuilder
    func HeaderInfoView() -> some View {
        HStack(spacing: 10) {
            if item.isSeries {
                Text("\(item.seasonCount)")
                    .font(.system(size: 14, weight: .bold))
                Text("Seasons")
                    .font(.raleway(size: 13, weight: .bold))
                
            } else {
                Text("\(item.releaseYear)")
                    .font(.system(size: 13, weight: .medium))
                Text("\(item.duration)")
                    .font(.system(size: 13, weight: .medium))
            }
            
            if item.isSeries || item.isVideo {
                Text("HD")
                    .overlay {
                        RoundedRectangle(cornerRadius: 1)
                            .inset(by: -1).stroke(lineWidth: 2)
                    }
                    .font(.raleway(size: 13, weight: .heavy))
            }
        }
    }
}
