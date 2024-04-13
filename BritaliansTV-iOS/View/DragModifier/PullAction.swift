//
//  PullAction.swift
//  BritaliansTV-iOS
//
//  Created by miqo on 17.11.23.
//

import SwiftUI

struct PullModifier: ViewModifier {
    @State private var dragOffset: CGFloat = 0

    let onPullAction: (_ value: CGFloat) -> Void

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.height > 0 {
                            dragOffset = value.translation.height
                        }
                    }
                    .onEnded { value in
                        onPullAction(dragOffset)
                    }
            )
    }
}

extension View {
    func onPullAction(_ onPullAction: @escaping (_ value: CGFloat) -> Void) -> some View {
        self.modifier(PullModifier(onPullAction: onPullAction))
    }
}
