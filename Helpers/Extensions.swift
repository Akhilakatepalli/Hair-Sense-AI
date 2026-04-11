//
//  Extensions.swift
//  Hair AI
//
//  Created by Akhila Katepalli on 3/13/26.
//

import SwiftUI

// MARK: - Glassmorphism Card

extension View {
    /// Frosted-glass card: ultra-thin material + gradient border + layered shadow.
    func glassCard(cornerRadius: CGFloat = 20, tint: Color = .clear) -> some View {
        self.modifier(GlassCardModifier(cornerRadius: cornerRadius, tint: tint))
    }

    /// Lighter glass — for inner chips, badges, and secondary containers.
    func glassPill(cornerRadius: CGFloat = 12) -> some View {
        self
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(Capsule().stroke(Color.white.opacity(0.22), lineWidth: 0.8))
            )
    }

    /// A neon-coloured glow border — pairs well with glassCard.
    func neonBorder(_ color: Color, cornerRadius: CGFloat = 20, width: CGFloat = 1.2) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    LinearGradient(
                        colors: [color.opacity(0.70), color.opacity(0.20), color.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: width
                )
        )
    }

    /// Depth shadow stack — a strong far shadow + a crisp near shadow.
    func depthShadow(color: Color = .black, farOpacity: Double = 0.35, nearOpacity: Double = 0.18) -> some View {
        self
            .shadow(color: color.opacity(farOpacity),  radius: 24, x: 0, y: 12)
            .shadow(color: color.opacity(nearOpacity), radius:  5, x: 0, y:  3)
    }

    /// Sweeping shimmer highlight — good for hero / score cards.
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

// MARK: - GlassCardModifier

struct GlassCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let tint: Color

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                    if tint != .clear {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(tint.opacity(0.07))
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.38),
                                Color.white.opacity(0.12),
                                Color.white.opacity(0.06)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.0
                    )
            )
            .shadow(color: Color.black.opacity(0.38), radius: 22, x: 0, y: 11)
            .shadow(color: Color.black.opacity(0.16), radius:  4, x: 0, y:  2)
    }
}

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { _ in
                    LinearGradient(
                        stops: [
                            .init(color: .clear,               location: max(0, phase - 0.2)),
                            .init(color: .white.opacity(0.18), location: phase),
                            .init(color: .clear,               location: min(1, phase + 0.2))
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .blendMode(.overlay)
                }
            )
            .onAppear {
                withAnimation(.linear(duration: 2.2).delay(0.3).repeatForever(autoreverses: false)) {
                    phase = 1.4
                }
            }
    }
}
