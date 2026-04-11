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

// MARK: - Animated Tab Background (Photo + Orbs + Symbol)

struct AnimatedTabBackground: View {

    let theme: TabTheme

    @State private var orbOpacity: Double  = 0.38
    @State private var orb1Offset: CGSize  = .zero
    @State private var orb2Offset: CGSize  = .zero
    @State private var orb3Offset: CGSize  = .zero
    @State private var symbolRotation: Double  = 0
    @State private var symbolOffsetY: CGFloat  = 0
    @State private var symbolScale: CGFloat    = 1.0
    @State private var symbolOpacity: Double   = 0.07
    @State private var scanBeamY: CGFloat      = -500

    var body: some View {
        GeometryReader { geo in
            ZStack {

                // ── Layer 1: Base — photo or animated canvas ─────────────
                if theme == .progress {
                    progressCanvas(geo: geo)
                } else {
                    AsyncImage(url: URL(string: photoURL)) { phase in
                        switch phase {
                        case .success(let img):
                            img
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                                .blur(radius: theme == .diet ? 14 : 0)
                        default:
                            fallbackGradient
                        }
                    }
                    .ignoresSafeArea()
                }

                // ── Layer 2: Dark scrim ───────────────────────────────────
                LinearGradient(
                    stops: [
                        .init(color: .black.opacity(theme == .diet ? 0.88 : 0.72), location: 0.0),
                        .init(color: .black.opacity(theme == .diet ? 0.55 : 0.22), location: 0.38),
                        .init(color: .black.opacity(theme == .diet ? 0.62 : 0.32), location: 0.65),
                        .init(color: .black.opacity(theme == .progress ? 0.70 : 0.90), location: 1.0)
                    ],
                    startPoint: .bottom, endPoint: .top
                )
                .ignoresSafeArea()

                // ── Layer 3: Colour tint per tab ──────────────────────────
                tabTint.ignoresSafeArea()

                // ── Layer 4: Floating glowing orbs ───────────────────────
                orbLayer(geo: geo)

                // ── Layer 5: Thematic symbol watermark ───────────────────
                symbolLayer

                // ── Layer 6: Scan sweep beam ─────────────────────────────
                if theme == .scan {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    Color(red: 0.0, green: 0.95, blue: 1.0).opacity(0.22),
                                    Color(red: 0.0, green: 0.95, blue: 1.0).opacity(0.08),
                                    .clear
                                ],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .frame(height: 90)
                        .offset(y: scanBeamY)
                        .ignoresSafeArea()
                }
            }
        }
        .ignoresSafeArea()
        .onAppear { startAnimations() }
    }

    // MARK: - Photo URLs (Unsplash — swap for bundled assets in production)

    private var photoURL: String {
        switch theme {
        case .home:
            return "https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=900&q=80&fit=crop"
        case .diet:
            return "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=900&q=80&fit=crop"
        case .progress:
            return "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=900&q=80&fit=crop"
        case .scan:
            return "https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?w=900&q=80&fit=crop"
        case .profile:
            return "https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=900&q=80&fit=crop"
        }
    }

    // MARK: - Fallback Gradient (shown while photo loads)

    private var fallbackGradient: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                .init(0, 0),   .init(0.5, 0),   .init(1, 0),
                .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                .init(0, 1),   .init(0.5, 1),   .init(1, 1)
            ],
            colors: fallbackColors
        )
        .ignoresSafeArea()
    }

    private var fallbackColors: [Color] {
        switch theme {
        case .home:
            return [
                Color(red: 0.22, green: 0.05, blue: 0.14), Color(red: 0.46, green: 0.10, blue: 0.24), Color(red: 0.16, green: 0.05, blue: 0.28),
                Color(red: 0.32, green: 0.07, blue: 0.18), Color(red: 0.22, green: 0.06, blue: 0.34), Color(red: 0.10, green: 0.05, blue: 0.24),
                Color(red: 0.22, green: 0.09, blue: 0.07), Color(red: 0.26, green: 0.07, blue: 0.20), Color(red: 0.06, green: 0.05, blue: 0.20)
            ]
        case .diet:
            return [
                Color(red: 0.05, green: 0.22, blue: 0.10), Color(red: 0.07, green: 0.30, blue: 0.12), Color(red: 0.20, green: 0.16, blue: 0.05),
                Color(red: 0.06, green: 0.24, blue: 0.14), Color(red: 0.12, green: 0.22, blue: 0.07), Color(red: 0.26, green: 0.18, blue: 0.05),
                Color(red: 0.05, green: 0.12, blue: 0.12), Color(red: 0.07, green: 0.16, blue: 0.05), Color(red: 0.18, green: 0.12, blue: 0.05)
            ]
        case .progress:
            return [
                Color(red: 0.05, green: 0.10, blue: 0.26), Color(red: 0.07, green: 0.22, blue: 0.40), Color(red: 0.12, green: 0.08, blue: 0.32),
                Color(red: 0.05, green: 0.20, blue: 0.32), Color(red: 0.07, green: 0.28, blue: 0.36), Color(red: 0.16, green: 0.10, blue: 0.34),
                Color(red: 0.05, green: 0.14, blue: 0.22), Color(red: 0.07, green: 0.18, blue: 0.30), Color(red: 0.10, green: 0.08, blue: 0.24)
            ]
        case .scan:
            return [
                Color(red: 0.05, green: 0.07, blue: 0.24), Color(red: 0.10, green: 0.14, blue: 0.34), Color(red: 0.05, green: 0.20, blue: 0.28),
                Color(red: 0.07, green: 0.12, blue: 0.30), Color(red: 0.05, green: 0.18, blue: 0.32), Color(red: 0.05, green: 0.24, blue: 0.26),
                Color(red: 0.05, green: 0.07, blue: 0.18), Color(red: 0.05, green: 0.12, blue: 0.24), Color(red: 0.05, green: 0.16, blue: 0.20)
            ]
        case .profile:
            return [
                Color(red: 0.26, green: 0.07, blue: 0.16), Color(red: 0.44, green: 0.10, blue: 0.24), Color(red: 0.18, green: 0.07, blue: 0.30),
                Color(red: 0.34, green: 0.09, blue: 0.20), Color(red: 0.28, green: 0.07, blue: 0.28), Color(red: 0.12, green: 0.07, blue: 0.26),
                Color(red: 0.20, green: 0.07, blue: 0.09), Color(red: 0.24, green: 0.07, blue: 0.18), Color(red: 0.07, green: 0.05, blue: 0.20)
            ]
        }
    }

    // MARK: - Tab Colour Tint Overlay

    private var tabTint: some View {
        switch theme {
        case .home:
            return AnyView(
                LinearGradient(
                    colors: [Color(red: 0.55, green: 0.10, blue: 0.30).opacity(0.30), Color(red: 0.28, green: 0.06, blue: 0.50).opacity(0.18)],
                    startPoint: .topTrailing, endPoint: .bottomLeading
                )
            )
        case .diet:
            return AnyView(
                LinearGradient(
                    colors: [Color(red: 0.06, green: 0.45, blue: 0.22).opacity(0.25), Color(red: 0.40, green: 0.28, blue: 0.06).opacity(0.18)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
        case .progress:
            return AnyView(
                LinearGradient(
                    colors: [Color(red: 0.06, green: 0.22, blue: 0.60).opacity(0.28), Color(red: 0.06, green: 0.45, blue: 0.44).opacity(0.20)],
                    startPoint: .topTrailing, endPoint: .bottomLeading
                )
            )
        case .scan:
            return AnyView(
                LinearGradient(
                    colors: [Color(red: 0.04, green: 0.16, blue: 0.55).opacity(0.30), Color(red: 0.04, green: 0.55, blue: 0.55).opacity(0.18)],
                    startPoint: .top, endPoint: .bottom
                )
            )
        case .profile:
            return AnyView(
                LinearGradient(
                    colors: [Color(red: 0.60, green: 0.12, blue: 0.32).opacity(0.28), Color(red: 0.32, green: 0.06, blue: 0.50).opacity(0.20)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
        }
    }

    // MARK: - Orb Layer

    @ViewBuilder
    private func orbLayer(geo: GeometryProxy) -> some View {
        let w = geo.size.width
        let h = geo.size.height
        ZStack {
            Circle()
                .fill(orb1Color)
                .frame(width: orb1Size)
                .blur(radius: 52)
                .opacity(orbOpacity * 0.88)
                .offset(x: orb1BaseX(w) + orb1Offset.width,
                        y: orb1BaseY(h) + orb1Offset.height)

            Circle()
                .fill(orb2Color)
                .frame(width: 170)
                .blur(radius: 44)
                .opacity(orbOpacity * 0.72)
                .offset(x: w * 0.32 + orb2Offset.width,
                        y: -h * 0.05 + orb2Offset.height)

            Circle()
                .fill(orb3Color)
                .frame(width: 130)
                .blur(radius: 34)
                .opacity(orbOpacity * 0.60)
                .offset(x: -w * 0.20 + orb3Offset.width,
                        y: h * 0.22 + orb3Offset.height)
        }
        .ignoresSafeArea()
    }

    // MARK: - Symbol Watermark

    @ViewBuilder
    private var symbolLayer: some View {
        let grad = LinearGradient(
            colors: [Color.white.opacity(symbolOpacity),
                     Color.white.opacity(symbolOpacity * 0.15)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
        switch theme {
        case .home:
            Image(systemName: "wand.and.stars")
                .font(.system(size: 250, weight: .ultraLight))
                .foregroundStyle(grad)
                .rotationEffect(.degrees(symbolRotation))
                .offset(x: 70, y: -50)
                .ignoresSafeArea()
        case .diet:
            Image(systemName: "leaf.fill")
                .font(.system(size: 270, weight: .ultraLight))
                .foregroundStyle(grad)
                .rotationEffect(.degrees(22))
                .offset(x: 85, y: -48 + symbolOffsetY)
                .ignoresSafeArea()
        case .progress:
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 230, weight: .ultraLight))
                .foregroundStyle(grad)
                .scaleEffect(symbolScale)
                .offset(x: 55, y: -78)
                .ignoresSafeArea()
        case .scan:
            Image(systemName: "camera.aperture")
                .font(.system(size: 290, weight: .ultraLight))
                .foregroundStyle(grad)
                .rotationEffect(.degrees(symbolRotation))
                .offset(x: 55, y: -38)
                .ignoresSafeArea()
        case .profile:
            ZStack {
                Circle()
                    .fill(RadialGradient(
                        colors: [Color(red: 0.92, green: 0.28, blue: 0.52).opacity(symbolOpacity * 1.6), .clear],
                        center: .center, startRadius: 8, endRadius: 155
                    ))
                    .frame(width: 310 * symbolScale)
                    .blur(radius: 28)
                    .offset(x: 65, y: -58)
                    .ignoresSafeArea()
                Image(systemName: "person.circle")
                    .font(.system(size: 290, weight: .ultraLight))
                    .foregroundStyle(grad)
                    .scaleEffect(symbolScale)
                    .offset(x: 65, y: -58)
                    .ignoresSafeArea()
            }
        }
    }

    // MARK: - Animations

    private func startAnimations() {
        withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) { orb1Offset = CGSize(width: 58, height: -68) }
        withAnimation(.easeInOut(duration: 9).repeatForever(autoreverses: true))  { orb2Offset = CGSize(width: -48, height: 52) }
        withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true))  { orb3Offset = CGSize(width: 44, height: 58) }
        withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true))  { orbOpacity = 0.72 }

        switch theme {
        case .home:
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) { symbolRotation = 360 }
        case .diet:
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) { symbolOffsetY = 20 }
        case .progress:
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) { symbolScale = 1.06 }
        case .scan:
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) { symbolRotation = 360 }
            withAnimation(.linear(duration: 4.5).repeatForever(autoreverses: false)) { scanBeamY = 600 }
        case .profile:
            withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true)) {
                symbolScale = 1.05
                symbolOpacity = 0.10
            }
        }
    }

    // MARK: - Orb Colours & Sizes

    private var orb1Color: Color {
        switch theme {
        case .home:     return Color(red: 0.90, green: 0.50, blue: 0.55)
        case .diet:     return Color(red: 0.14, green: 0.78, blue: 0.42)
        case .progress: return Color(red: 0.16, green: 0.44, blue: 0.95)
        case .scan:     return Color(red: 0.0,  green: 0.92, blue: 1.0)
        case .profile:  return Color(red: 0.95, green: 0.30, blue: 0.56)
        }
    }
    private var orb2Color: Color {
        switch theme {
        case .home:     return Color(red: 0.82, green: 0.20, blue: 0.56)
        case .diet:     return Color(red: 0.12, green: 0.60, blue: 0.46)
        case .progress: return Color(red: 0.12, green: 0.76, blue: 0.72)
        case .scan:     return Color(red: 0.24, green: 0.48, blue: 0.96)
        case .profile:  return Color(red: 0.80, green: 0.16, blue: 0.76)
        }
    }
    private var orb3Color: Color {
        switch theme {
        case .home:     return Color(red: 0.76, green: 0.50, blue: 0.14)
        case .diet:     return Color(red: 0.66, green: 0.44, blue: 0.10)
        case .progress: return Color(red: 0.26, green: 0.12, blue: 0.76)
        case .scan:     return Color(red: 0.10, green: 0.58, blue: 0.64)
        case .profile:  return Color(red: 0.58, green: 0.40, blue: 0.92)
        }
    }
    private var orb1Size: CGFloat {
        switch theme {
        case .progress: return 280
        default:        return 252
        }
    }
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
        case .progress: return -h * 0.25
        default:        return -h * 0.20
        }
    }

    // MARK: - Progress Canvas (animated hair-growth visualization)

    @ViewBuilder
    private func progressCanvas(geo: GeometryProxy) -> some View {
        // Deep dark base
        Color(red: 0.04, green: 0.06, blue: 0.16).ignoresSafeArea()

        TimelineView(.animation) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate

                // ── 1. Rising hair-strand curves ──────────────────────────
                let strandCount = 12
                for i in 0..<strandCount {
                    let xBase = size.width * Double(i) / Double(strandCount - 1)
                    let phase  = Double(i) * 0.85 + t * 0.25
                    let amp    = 18.0 + Double(i % 3) * 10.0

                    var path = Path()
                    path.move(to: CGPoint(x: xBase + sin(phase) * amp * 0.3, y: size.height + 10))

                    let steps = 60
                    for s in 1...steps {
                        let progress = Double(s) / Double(steps)
                        let y = size.height * (1 - progress)
                        let wave = sin(phase + progress * 5.5) * amp * progress
                        path.addLine(to: CGPoint(x: xBase + wave, y: y))
                    }

                    let baseOpacity = 0.055 + 0.03 * sin(phase * 0.7)
                    let tealBlue = GraphicsContext.Shading.color(
                        Color(red: 0.18 + 0.12 * sin(phase),
                              green: 0.68 + 0.18 * cos(phase * 0.5),
                              blue: 0.92).opacity(baseOpacity)
                    )
                    ctx.stroke(path, with: tealBlue,
                               style: StrokeStyle(lineWidth: 1.2, lineCap: .round))
                }

                // ── 2. Ascending glow particles ───────────────────────────
                let particleCount = 28
                for i in 0..<particleCount {
                    let seed   = Double(i) * 137.508
                    let xPos   = (seed * 0.618).truncatingRemainder(dividingBy: size.width)
                    let speed  = 0.035 + (seed * 0.0009).truncatingRemainder(dividingBy: 0.055)
                    let raw    = t * speed * size.height + seed * 11
                    let yPos   = size.height - raw.truncatingRemainder(dividingBy: size.height + 16)
                    let opac   = 0.25 + 0.35 * abs(sin(t * 0.8 + seed * 0.04))
                    let radius = CGFloat(1.4 + (seed * 0.007).truncatingRemainder(dividingBy: 2.2))

                    let r = CGRect(x: xPos - radius, y: yPos - radius,
                                   width: radius * 2, height: radius * 2)
                    let pColor = i % 3 == 0
                        ? Color(red: 0.14, green: 0.82, blue: 0.72).opacity(opac)
                        : Color(red: 0.42, green: 0.65, blue: 1.0).opacity(opac)
                    ctx.fill(Path(ellipseIn: r), with: .color(pColor))
                }

                // ── 3. Large pulsing growth ring ──────────────────────────
                let cx = size.width * 0.78
                let cy = size.height * 0.22
                let baseR: Double = min(size.width, size.height) * 0.22
                let pulse  = baseR + 10 * sin(t * 0.6)
                let arcEnd = -90 + 300 * ((sin(t * 0.18) + 1) / 2 * 0.85 + 0.10)

                // Outer faint ring
                var outerRing = Path()
                outerRing.addArc(center: CGPoint(x: cx, y: cy), radius: pulse + 18,
                                 startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
                ctx.stroke(outerRing, with: .color(Color(red: 0.18, green: 0.68, blue: 0.92).opacity(0.06)),
                           lineWidth: 1)

                // Progress arc
                var arc = Path()
                arc.addArc(center: CGPoint(x: cx, y: cy), radius: pulse,
                           startAngle: .degrees(-90), endAngle: .degrees(arcEnd), clockwise: false)
                ctx.stroke(arc, with: .color(Color(red: 0.14, green: 0.82, blue: 0.72).opacity(0.22)),
                           style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

                // Inner glow dot at arc tip
                let tipAngle = arcEnd * .pi / 180
                let tipX = cx + pulse * cos(tipAngle)
                let tipY = cy + pulse * sin(tipAngle)
                let dotR: CGFloat = 5
                ctx.fill(Path(ellipseIn: CGRect(x: tipX - dotR, y: tipY - dotR,
                                                width: dotR * 2, height: dotR * 2)),
                         with: .color(Color(red: 0.14, green: 0.90, blue: 0.78).opacity(0.70)))

                // ── 4. Horizontal growth-bar lines ────────────────────────
                let barCount = 5
                for b in 0..<barCount {
                    let yLine = size.height * (0.45 + Double(b) * 0.095)
                    let barWidth = size.width * (0.25 + 0.55 * abs(sin(t * 0.12 + Double(b) * 0.9)))
                    var bar = Path()
                    bar.move(to: CGPoint(x: 0, y: yLine))
                    bar.addLine(to: CGPoint(x: barWidth, y: yLine))
                    ctx.stroke(bar, with: .color(Color(red: 0.28, green: 0.58, blue: 0.95).opacity(0.07)),
                               lineWidth: 1)
                }
            }
            .ignoresSafeArea()
        }
    }
}
