//
//  CardItem.swift
//  BritaliansTV-iOS
//
//  Created by miqo on 15.11.23.
//

import SwiftUI
import Kingfisher

struct CardView: View {
    var title: String = ""
    var imagePath: String?
    var isInMyList: Bool = false
    var size: CGSize = .init(width: 148, height: 148*1.4)
    var cornerRadius: CGFloat = 5
    var ifPressed: () -> Void
    
    var body: some View {
        Button(action: ifPressed, label: {
            VStack(spacing: 10) {
                KFImage.url(URL(string: imagePath ?? ""))
                    .resizable()
                    .placeholder({
                        Image("cardPlaceholder")
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .frame(width: size.width, height: size.height)
                    })
                    .fade(duration: 0.25)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .frame(width: size.width, height: size.height)
                
                if !title.isEmpty {
                    Text(title)
                        .font(.raleway(size: size.width/8))
                        .frame(maxWidth: size.width-20)
                        .lineLimit(1)
                }
            }
            .overlay {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "heart.circle")
                            .imageScale(.large)
                            .padding([.top, .trailing], 5)
                            .opacity(isInMyList ? 1 : 0)
                    }
                    Spacer()
                }
                .foregroundStyle(.blue)
            }
        })
        .padding(.vertical, 30)
        .padding(.horizontal, 10)
    }
}
