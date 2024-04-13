//
//  TabView.swift
//  BritaliansTV-iOS
//
//  Created by miqo on 15.11.23.
//

import SwiftUI

struct CustomTabView<Content: View>: View {
    let tabs: [TabItem]
    @Binding var selection: Int
    @ViewBuilder let content: (Int) -> Content
    
    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                ForEach(tabs.indices, id: \.self) { index in
                    content(index)
                        .tag(index)
                }
            }
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    ForEach(tabs.indices, id: \.self) { index in
                        Button {
                            self.selection = index
                        } label: {
                            TabItemView(data: tabs[index], isSelected: (index == selection))
                        }
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 90)
                .background(Color.black)
            }
            .padding(.bottom, 8)
        }
    }
}

struct TabItemView: View {
    let data: TabItem
    let isSelected: Bool
    
    var body: some View {
        VStack {
            Image(data.image)
                .resizable()
                .renderingMode(isSelected ? .original : .template)
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                .animation(.default, value: isSelected)
            
            Spacer().frame(height: 4)
            
            Text(data.name)
                .font(.system(size: 14))
        }
        .foregroundColor(isSelected ? .white : .gray)
    }
}
