//
//  ItemInfoContent.swift
//  BritaliansTV-iOS
//
//  Created by miqo on 18.11.23.
//

import SwiftUI
import Kingfisher

struct ItemInfoContent: View {
    var currentItem: ItemModel

    var body: some View {
        ZStack(alignment: .center) {
            Color(hex: "#0F0F1E")
                .ignoresSafeArea(edges: .all)
            
            VStack(alignment: .center, spacing: 20) {
                titleSection()
                infoSection()
                descriptionSection()
                Spacer()
            }
            .padding(.vertical, 20).padding(.top, 20)
            .padding(.horizontal, 30)
            .frame(maxWidth: UIScreen.screenWidth, alignment: .center)
            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .foregroundColor(.white)
    }
    
    @ViewBuilder
    private func titleSection() -> some View {
        ZStack {
            if let logoURL = currentItem.logoURL {
                KFImage
                    .url(logoURL)
                    .resizable()
                    .scaledToFit()
            } else {
                Text(currentItem.title)
                    .font(.raleway(size: 24, weight: .bold))
                    .lineLimit(2).bold()
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxHeight: 80, alignment: .center)
    }
    
    @ViewBuilder
    private func infoSection() -> some View {
        HStack(alignment: .center, spacing: 30) {
            if currentItem.isSeries {
                Text("\(currentItem.seasonCount)")
                    .font(.system(size: 18, weight: .bold))
                Text(" Seasons")
                    .font(.raleway(size: 18, weight: .bold))
                    .padding(.leading, -18)
                
            } else {
                Text("\(currentItem.releaseYear)")
                    .font(.system(size: 18, weight: .medium))
                Text("\(currentItem.duration)")
                    .font(.system(size: 18, weight: .medium))
            }
            
            if currentItem.isSeries || currentItem.isVideo {
                Text("HD")
                    .overlay {
                        RoundedRectangle(cornerRadius: 1)
                            .inset(by: -3)
                            .stroke(lineWidth: 4)
                    }
                    .font(.raleway(size: 14, weight: .heavy))
            }
        }
        .frame(maxHeight: 60, alignment: .center)
    }
    
    @ViewBuilder
    private func descriptionSection() -> some View {
        HStack(alignment: .center, spacing: 0) {
            if currentItem.isSeries {
                Text(currentItem.description)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(Color(hex: "#137FEC"))
                    .font(.raleway(size: 30, weight: .medium))
                
            } else {
                VStack(alignment: .center, spacing: 10) {
                    Text(currentItem.title)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .font(.raleway(size: 30, weight: .bold))
                    
                    Text(currentItem.description)
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.98))
                        .font(.raleway(size: 22, weight: .regular))
                    
                }
            }
        }
        .frame(maxWidth: 650, maxHeight: 200, alignment: .center)
    }
}

