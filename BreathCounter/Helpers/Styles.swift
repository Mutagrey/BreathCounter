//
//  Styles.swift
//  DesignCodeiOS15
//
//  Created by Sergey Petrov on 15.01.2023.
//

import SwiftUI

struct StrokeStyle: ViewModifier {
    var cornerRadius: CGFloat
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .overlay{
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        .linearGradient(
                            colors: [
                                .white.opacity(colorScheme == .dark ? 0.6 : 0.3),
                                .black.opacity(colorScheme == .dark ? 0.3 : 0.1)
                            ],
                            startPoint: .top, endPoint: .bottom)
                    )
                    .blendMode(.overlay)
            }
    }
}

struct StrokeShapeStyle<S: Shape>: ViewModifier {
    var shape: S
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .overlay{
                shape
                    .stroke(
                        .linearGradient(
                            colors: [
                                .white.opacity(colorScheme == .dark ? 0.6 : 0.3),
                                .black.opacity(colorScheme == .dark ? 0.3 : 0.1)
                            ],
                            startPoint: .top, endPoint: .bottom)
                    )
                    .blendMode(.overlay)
            }
    }
}

extension View {
    func cardify(cornerRadius: CGFloat = 20, padding: CGFloat = 10) -> some View {
        self
            .padding(padding)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(lineWidth: 0.5)
                    .fill(LinearGradient(colors: [.primary, .primary.opacity(0.3), .primary], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .blendMode(.overlay)
            }
    }
    
    func strokeStyle(cornerRadius: CGFloat = 30) -> some View{
        self
            .modifier(StrokeStyle(cornerRadius: cornerRadius))
    }
    
    func strokeStyleShape<S: Shape>(shape: S) -> some View{
        self
            .modifier(StrokeShapeStyle(shape: shape))
    }
}
