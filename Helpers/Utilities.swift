//
//  Utilities.swift
//  Hair AI
//
//  Created by Akhila Katepalli on 3/13/26.
//

import SwiftUI

// MARK: - Tab Theme

enum TabTheme {
    case home, diet, progress, scan, profile
}

// MARK: - Animated Tab Background

struct AnimatedTabBackground: View {

    let theme: TabTheme

    // Mesh gradient animation driver
    @State private var animateMesh = false

    // Orb position / opacity drivers
    @State private var orb1Offset: CGSize = .zero
    @State private var orb2Offset: CGSize = .zero
    @State private var orb3Offset: CGSize = .zero
    @State private var orbOpacity: Double = 0.55

    // Thematic symbol drivers
    @State private var symbolRotation: Double = 0.0
    @State private var symbolOffsetY: CGFloat = 0.0
    @State private var symbolScale: CGFloat   = 1.0
    @State private var symbolOpacity: Double  = 0.055

    // Scan beam driver
    @State private var scanBeamY: CGFloat = -420.0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Layer 1: Animated MeshGradient
                MeshGradient(
                    width: 3, height: 3,
                    points: [
                        .init(0, 0),   .init(0.5, 0),   .init(1, 0),
                        .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                        .init(0, 1),   .init(0.5, 1),   .init(1, 1)
                    ],
                    colors: animateMesh ? meshColorsB : meshColorsA
                )
                .ignoresSafeArea()
                .animation(
                    .easeInOut(duration: 8).repeatForever(autoreverses: true),
                    value: animateMesh
                )

                // Layer 2: Three floating glowing orbs
                orbLayer(geo: geo)

                // Layer 3: Thematic symbol watermark
                symbolLayer

                // Layer 4: Scan beam (Scan tab only)
                if theme == .scan {
                    scanBeam(geo: geo)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear { startAnimations() }
    }

    // MARK: - Orb Layer

    @ViewBuilder
    private func orbLayer(geo: GeometryProxy) -> some View {
        let w = geo.size.width
        let h = geo.size.height

        ZStack {
            Circle()
                .fill(orb1Color)
                .frame(width: orb1Size, height: orb1Size)
                .blur(radius: 55)
                .opacity(orbOpacity * 0.9)
                .offset(x: orb1BaseX(w) + orb1Offset.width,
                        y: orb1BaseY(h) + orb1Offset.height)

            Circle()
                .fill(orb2Color)
                .frame(width: 180, height: 180)
                .blur(radius: 45)
                .opacity(orbOpacity * 0.75)
                .offset(x: orb2BaseX(w) + orb2Offset.width,
                        y: orb2BaseY(h) + orb2Offset.height)

            Circle()
                .fill(orb3Color)
                .frame(width: 140, height: 140)
                .blur(radius: 35)
                .opacity(orbOpacity * 0.65)
                .offset(x: orb3BaseX(w) + orb3Offset.width,
                        y: orb3BaseY(h) + orb3Offset.height)
        }
        .ignoresSafeArea()
    }

    // MARK: - Symbol Layer

    @ViewBuilder
    private var symbolLayer: some View {
        let gradient = LinearGradient(
            colors: [Color.white.opacity(symbolOpacity),
                     Color.white.opacity(symbolOpacity * 0.18)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        switch theme {

        case .home:
            Image(systemName: "wand.and.stars")
                .font(.system(size: 260, weight: .ultraLight))
                .foregroundStyle(gradient)
                .rotationEffect(.degrees(symbolRotation))
                .offset(x: 70, y: -50)
                .ignoresSafeArea()

        case .diet:
            Image(systemName: "leaf.fill")
                .font(.system(size: 280, weight: .ultraLight))
                .foregroundStyle(gradient)
                .rotationEffect(.degrees(25))
                .offset(x: 90, y: -50 + symbolOffsetY)
                .ignoresSafeArea()

        case .progress:
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 240, weight: .ultraLight))
                .foregroundStyle(gradient)
                .scaleEffect(symbolScale)
                .offset(x: 60, y: -80)
                .ignoresSafeArea()

        case .scan:
            Image(systemName: "camera.aperture")
                .font(.system(size: 300, weight: .ultraLight))
                .foregroundStyle(gradient)
                .rotationEffect(.degrees(symbolRotation))
                .offset(x: 60, y: -40)
                .ignoresSafeArea()

        case .profile:
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(red: 0.92, green: 0.28, blue: 0.52).opacity(symbolOpacity * 1.8),
                                     Color.clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 160
                        )
                    )
                    .frame(width: 320 * symbolScale, height: 320 * symbolScale)
                    .blur(radius: 30)
                    .offset(x: 70, y: -60)
                    .ignoresSafeArea()

                Image(systemName: "person.circle")
                    .font(.system(size: 300, weight: .ultraLight))
                    .foregroundStyle(gradient)
                    .scaleEffect(symbolScale)
                    .offset(x: 70, y: -60)
                    .ignoresSafeArea()
            }
        }
    }

    // MARK: - Scan Beam

    @ViewBuilder
    private func scanBeam(geo: GeometryProxy) -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color(red: 0.0, green: 0.95, blue: 1.0).opacity(0.18),
                        Color(red: 0.0, green: 0.95, blue: 1.0).opacity(0.07),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(height: 80)
            .offset(y: scanBeamY)
            .ignoresSafeArea()
    }

    // MARK: - Animation Startup

    private func startAnimations() {
        animateMesh = true

        withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
            orb1Offset = CGSize(width: 60, height: -70)
        }
        withAnimation(.easeInOut(duration: 9).repeatForever(autoreverses: true)) {
            orb2Offset = CGSize(width: -50, height: 55)
        }
        withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
            orb3Offset = CGSize(width: 45, height: 60)
        }
        withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
            orbOpacity = 0.85
        }

        switch theme {
        case .home:
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                symbolRotation = 360
            }
        case .diet:
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                symbolOffsetY = 22
            }
        case .progress:
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                symbolScale = 1.06
            }
        case .scan:
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                symbolRotation = 360
            }
            withAnimation(.linear(duration: 4.5).repeatForever(autoreverses: false)) {
                scanBeamY = 500
            }
        case .profile:
            withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true)) {
                symbolScale = 1.05
                symbolOpacity = 0.085
            }
        }
    }

    // MARK: - Per-Theme Colors

    private var meshColorsA: [Color] {
        switch theme {
        case .home:
            return [
                Color(red: 0.18, green: 0.04, blue: 0.12),
                Color(red: 0.42, green: 0.08, blue: 0.22),
                Color(red: 0.14, green: 0.04, blue: 0.26),
                Color(red: 0.28, green: 0.06, blue: 0.16),
                Color(red: 0.20, green: 0.05, blue: 0.32),
                Color(red: 0.08, green: 0.04, blue: 0.22),
                Color(red: 0.20, green: 0.08, blue: 0.06),
                Color(red: 0.24, green: 0.06, blue: 0.18),
                Color(red: 0.05, green: 0.04, blue: 0.18)
            ]
        case .diet:
            return [
                Color(red: 0.04, green: 0.18, blue: 0.08),
                Color(red: 0.06, green: 0.24, blue: 0.10),
                Color(red: 0.18, green: 0.14, blue: 0.04),
                Color(red: 0.05, green: 0.20, blue: 0.12),
                Color(red: 0.10, green: 0.18, blue: 0.06),
                Color(red: 0.22, green: 0.16, blue: 0.04),
                Color(red: 0.04, green: 0.10, blue: 0.10),
                Color(red: 0.06, green: 0.14, blue: 0.04),
                Color(red: 0.16, green: 0.10, blue: 0.04)
            ]
        case .progress:
            return [
                Color(red: 0.04, green: 0.08, blue: 0.22),
                Color(red: 0.06, green: 0.18, blue: 0.36),
                Color(red: 0.10, green: 0.06, blue: 0.28),
                Color(red: 0.04, green: 0.16, blue: 0.28),
                Color(red: 0.06, green: 0.22, blue: 0.32),
                Color(red: 0.14, green: 0.08, blue: 0.30),
                Color(red: 0.04, green: 0.12, blue: 0.18),
                Color(red: 0.06, green: 0.14, blue: 0.26),
                Color(red: 0.08, green: 0.06, blue: 0.20)
            ]
        case .scan:
            return [
                Color(red: 0.04, green: 0.06, blue: 0.20),
                Color(red: 0.08, green: 0.12, blue: 0.30),
                Color(red: 0.04, green: 0.18, blue: 0.24),
                Color(red: 0.06, green: 0.10, blue: 0.26),
                Color(red: 0.04, green: 0.16, blue: 0.28),
                Color(red: 0.04, green: 0.20, blue: 0.22),
                Color(red: 0.04, green: 0.06, blue: 0.16),
                Color(red: 0.04, green: 0.10, blue: 0.20),
                Color(red: 0.04, green: 0.14, blue: 0.18)
            ]
        case .profile:
            return [
                Color(red: 0.22, green: 0.06, blue: 0.14),
                Color(red: 0.38, green: 0.08, blue: 0.20),
                Color(red: 0.16, green: 0.06, blue: 0.28),
                Color(red: 0.30, green: 0.08, blue: 0.18),
                Color(red: 0.24, green: 0.06, blue: 0.26),
                Color(red: 0.10, green: 0.06, blue: 0.24),
                Color(red: 0.18, green: 0.06, blue: 0.08),
                Color(red: 0.22, green: 0.06, blue: 0.16),
                Color(red: 0.06, green: 0.04, blue: 0.18)
            ]
        }
    }

    private var meshColorsB: [Color] {
        switch theme {
        case .home:
            return [
                Color(red: 0.28, green: 0.06, blue: 0.08),
                Color(red: 0.55, green: 0.12, blue: 0.18),
                Color(red: 0.22, green: 0.06, blue: 0.30),
                Color(red: 0.38, green: 0.10, blue: 0.12),
                Color(red: 0.32, green: 0.08, blue: 0.36),
                Color(red: 0.14, green: 0.05, blue: 0.28),
                Color(red: 0.30, green: 0.12, blue: 0.04),
                Color(red: 0.36, green: 0.10, blue: 0.14),
                Color(red: 0.08, green: 0.06, blue: 0.22)
            ]
        case .diet:
            return [
                Color(red: 0.06, green: 0.28, blue: 0.12),
                Color(red: 0.04, green: 0.36, blue: 0.16),
                Color(red: 0.26, green: 0.22, blue: 0.04),
                Color(red: 0.06, green: 0.30, blue: 0.18),
                Color(red: 0.14, green: 0.28, blue: 0.08),
                Color(red: 0.30, green: 0.22, blue: 0.04),
                Color(red: 0.04, green: 0.16, blue: 0.14),
                Color(red: 0.08, green: 0.20, blue: 0.06),
                Color(red: 0.22, green: 0.14, blue: 0.04)
            ]
        case .progress:
            return [
                Color(red: 0.04, green: 0.14, blue: 0.34),
                Color(red: 0.04, green: 0.30, blue: 0.48),
                Color(red: 0.14, green: 0.10, blue: 0.38),
                Color(red: 0.04, green: 0.26, blue: 0.40),
                Color(red: 0.06, green: 0.36, blue: 0.44),
                Color(red: 0.20, green: 0.12, blue: 0.42),
                Color(red: 0.04, green: 0.18, blue: 0.28),
                Color(red: 0.04, green: 0.22, blue: 0.36),
                Color(red: 0.10, green: 0.08, blue: 0.30)
            ]
        case .scan:
            return [
                Color(red: 0.02, green: 0.10, blue: 0.30),
                Color(red: 0.04, green: 0.22, blue: 0.44),
                Color(red: 0.02, green: 0.28, blue: 0.36),
                Color(red: 0.04, green: 0.16, blue: 0.38),
                Color(red: 0.02, green: 0.26, blue: 0.40),
                Color(red: 0.02, green: 0.32, blue: 0.32),
                Color(red: 0.02, green: 0.08, blue: 0.22),
                Color(red: 0.02, green: 0.16, blue: 0.30),
                Color(red: 0.02, green: 0.22, blue: 0.26)
            ]
        case .profile:
            return [
                Color(red: 0.34, green: 0.08, blue: 0.22),
                Color(red: 0.52, green: 0.10, blue: 0.28),
                Color(red: 0.26, green: 0.08, blue: 0.38),
                Color(red: 0.42, green: 0.10, blue: 0.26),
                Color(red: 0.36, green: 0.08, blue: 0.36),
                Color(red: 0.18, green: 0.08, blue: 0.34),
                Color(red: 0.28, green: 0.08, blue: 0.12),
                Color(red: 0.32, green: 0.08, blue: 0.22),
                Color(red: 0.10, green: 0.06, blue: 0.26)
            ]
        }
    }

    // MARK: - Orb Colors

    private var orb1Color: Color {
        switch theme {
        case .home:     return Color(red: 0.85, green: 0.55, blue: 0.50)
        case .diet:     return Color(red: 0.12, green: 0.72, blue: 0.38)
        case .progress: return Color(red: 0.14, green: 0.40, blue: 0.90)
        case .scan:     return Color(red: 0.0,  green: 0.88, blue: 1.0)
        case .profile:  return Color(red: 0.92, green: 0.28, blue: 0.52)
        }
    }
    private var orb2Color: Color {
        switch theme {
        case .home:     return Color(red: 0.78, green: 0.18, blue: 0.52)
        case .diet:     return Color(red: 0.10, green: 0.55, blue: 0.42)
        case .progress: return Color(red: 0.10, green: 0.72, blue: 0.68)
        case .scan:     return Color(red: 0.22, green: 0.44, blue: 0.92)
        case .profile:  return Color(red: 0.75, green: 0.15, blue: 0.72)
        }
    }
    private var orb3Color: Color {
        switch theme {
        case .home:     return Color(red: 0.72, green: 0.48, blue: 0.12)
        case .diet:     return Color(red: 0.62, green: 0.42, blue: 0.08)
        case .progress: return Color(red: 0.24, green: 0.10, blue: 0.72)
        case .scan:     return Color(red: 0.08, green: 0.55, blue: 0.60)
        case .profile:  return Color(red: 0.55, green: 0.38, blue: 0.88)
        }
    }
    private var orb1Size: CGFloat {
        switch theme {
        case .home, .profile: return 260
        case .diet:           return 240
        case .progress:       return 280
        case .scan:           return 250
        }
    }

    // MARK: - Orb Base Positions

    private func orb1BaseX(_ w: CGFloat) -> CGFloat {
        switch theme {
        case .home:     return -w * 0.28
        case .diet:     return  w * 0.30
        case .progress: return -w * 0.25
        case .scan:     return  w * 0.24
        case .profile:  return -w * 0.30
        }
    }
    private func orb1BaseY(_ h: CGFloat) -> CGFloat {
        switch theme {
        case .home:     return -h * 0.22
        case .diet:     return -h * 0.18
        case .progress: return -h * 0.25
        case .scan:     return -h * 0.20
        case .profile:  return -h * 0.20
        }
    }
    private func orb2BaseX(_ w: CGFloat) -> CGFloat {  w * 0.32 }
    private func orb2BaseY(_ h: CGFloat) -> CGFloat { -h * 0.05 }
    private func orb3BaseX(_ w: CGFloat) -> CGFloat { -w * 0.20 }
    private func orb3BaseY(_ h: CGFloat) -> CGFloat {  h * 0.22 }
}
