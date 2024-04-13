//
//  ParallaxEffect.swift
//  BritaliansTV-iOS
//
//  Created by miqo on 17.11.23.
//

import SwiftUI

struct ParallaxHeader<Content: View, Space: Hashable>: View {
    let coordinateSpace: Space
    @Binding var minY: CGFloat
    @Binding var minX: CGFloat
    let content: () -> Content
    
    init(
        coordinateSpace: Space,
        minY: Binding<CGFloat> = .constant(0),
        minX: Binding<CGFloat> = .constant(0),
        content: @escaping () -> Content
    ) {
        self.coordinateSpace = coordinateSpace
        self._minY = minY
        self._minX = minX
        self.content = content
    }

    var body: some View {
        GeometryReader { proxy in
            let offset = offset(for: proxy)
            let scale = scaleModifier(for: proxy)
            
            content()
                .edgesIgnoringSafeArea(.horizontal)
                .scaleEffect(1 + scale, anchor: .top)
                .aspectRatio(contentMode: .fit)
                .offset(y: offset)
                .onChange(of: proxy.frame(in: .named(coordinateSpace))) { _, value in
                    minY = value.minY
                    minX = value.minX
                }
        }
        .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight*0.7)
    }
    
    private func offset(for proxy: GeometryProxy) -> CGFloat {
        let frame = proxy.frame(in: .named(coordinateSpace))
        if frame.minY < 0 {
            return -frame.minY * 0.4
        }
        return -frame.minY
    }
    
    private func scaleModifier(for proxy: GeometryProxy) -> CGFloat {
        let frame = proxy.frame(in: .named(coordinateSpace))
        return max(0, frame.minY/proxy.size.height)
    }
}
