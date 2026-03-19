//
//  SplashView.swift
//  Hair AI
//
//  Created by Akhila Katepalli on 3/13/26.
//

import SwiftUI

struct SplashView: View {

    @State private var navigate = false
    @State private var animateLogo = false
    @State private var animateText = false
    @State private var animateTagline = false
    @State private var animateRings = false
    @State private var scanLine = false

    var body: some View {

        if navigate {
            WelcomeView()
        } else {

            ZStack {

                // ── Rich dark background ──────────────────────────────────────
                Color(red: 0.06, green: 0.04, blue: 0.12)
                    .ignoresSafeArea()

                // Pink blob — top right
                Circle()
                    .fill(Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.45))
                    .frame(width: 380, height: 380)
                    .blur(radius: 90)
                    .offset(x: 140, y: -280)
                    .ignoresSafeArea()

                // Purple blob — left
                Circle()
                    .fill(Color(red: 0.45, green: 0.18, blue: 0.88).opacity(0.40))
                    .frame(width: 320, height: 320)
                    .blur(radius: 85)
                    .offset(x: -120, y: -60)
                    .ignoresSafeArea()

                // Teal blob — bottom
                Circle()
                    .fill(Color(red: 0.10, green: 0.78, blue: 0.60).opacity(0.22))
                    .frame(width: 260, height: 260)
                    .blur(radius: 75)
                    .offset(x: 60, y: 340)
                    .ignoresSafeArea()

                // ── Decorative background rings ───────────────────────────────
                ZStack {
                    Circle()
                        .stroke(Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.08), lineWidth: 1)
                        .frame(width: 420, height: 420)
                        .scaleEffect(animateRings ? 1.0 : 0.6)
                        .opacity(animateRings ? 1.0 : 0)
                        .animation(.easeOut(duration: 1.4), value: animateRings)

                    Circle()
                        .stroke(Color(red: 0.45, green: 0.18, blue: 0.88).opacity(0.10), lineWidth: 1)
                        .frame(width: 300, height: 300)
                        .scaleEffect(animateRings ? 1.0 : 0.6)
                        .opacity(animateRings ? 1.0 : 0)
                        .animation(.easeOut(duration: 1.2).delay(0.1), value: animateRings)

                    Circle()
                        .stroke(Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.14), lineWidth: 1)
                        .frame(width: 190, height: 190)
                        .scaleEffect(animateRings ? 1.0 : 0.6)
                        .opacity(animateRings ? 1.0 : 0)
                        .animation(.easeOut(duration: 1.0).delay(0.2), value: animateRings)
                }

                // ── Main content ──────────────────────────────────────────────
                VStack(spacing: 28) {

                    // Logo card
                    ZStack {

                        // Outer glow
                        Circle()
                            .fill(Color(red: 0.80, green: 0.15, blue: 0.50).opacity(0.25))
                            .frame(width: 150, height: 150)
                            .blur(radius: 22)
                            .scaleEffect(animateLogo ? 1.0 : 0.5)
                            .animation(.easeOut(duration: 1.0), value: animateLogo)

                        // Logo background card
                        ZStack {
                            RoundedRectangle(cornerRadius: 36)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.90, green: 0.25, blue: 0.55),
                                            Color(red: 0.45, green: 0.18, blue: 0.88)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 110, height: 110)

                            // Glass shimmer
                            RoundedRectangle(cornerRadius: 36)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.22), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .center
                                    )
                                )
                                .frame(width: 110, height: 110)

                            // Hair strands + scan line icon
                            VStack(spacing: 4) {
                                HStack(spacing: 5) {
                                    ForEach(0..<3) { i in
                                        Capsule()
                                            .fill(Color.white)
                                            .frame(width: 4, height: CGFloat([26, 34, 26][i]))
                                            .opacity(i == 1 ? 1.0 : 0.65)
                                    }
                                }

                                // Animated scan line
                                Capsule()
                                    .fill(Color.white.opacity(0.90))
                                    .frame(width: scanLine ? 44 : 10, height: 3)
                                    .animation(
                                        .easeInOut(duration: 0.8)
                                        .repeatForever(autoreverses: true)
                                        .delay(0.6),
                                        value: scanLine
                                    )
                            }
                        }
                        .shadow(
                            color: Color(red: 0.80, green: 0.15, blue: 0.50).opacity(0.55),
                            radius: 28, y: 12
                        )
                        .scaleEffect(animateLogo ? 1.0 : 0.4)
                        .opacity(animateLogo ? 1.0 : 0)
                        .animation(
                            .spring(response: 0.8, dampingFraction: 0.6),
                            value: animateLogo
                        )
                    }

                    // App name + tagline
                    VStack(spacing: 10) {

                        Text("HairSense")
                            .font(.system(size: 42, weight: .heavy, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, Color(red: 1.0, green: 0.75, blue: 0.90)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .opacity(animateText ? 1.0 : 0)
                            .offset(y: animateText ? 0 : 16)
                            .animation(.easeOut(duration: 0.7).delay(0.4), value: animateText)

                        Text("AI Hair Health Assistant")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color(red: 0.80, green: 0.65, blue: 1.0))
                            .tracking(1.5)
                            .textCase(.uppercase)
                            .opacity(animateTagline ? 1.0 : 0)
                            .offset(y: animateTagline ? 0 : 10)
                            .animation(.easeOut(duration: 0.6).delay(0.65), value: animateTagline)
                    }

                    // Loading indicator
                    VStack(spacing: 12) {

                        // Animated dots
                        HStack(spacing: 8) {
                            ForEach(0..<3) { i in
                                Circle()
                                    .fill(Color(red: 0.95, green: 0.60, blue: 0.85))
                                    .frame(width: 7, height: 7)
                                    .opacity(animateTagline ? 1.0 : 0)
                                    .scaleEffect(animateTagline ? 1.0 : 0.3)
                                    .animation(
                                        .easeInOut(duration: 0.5)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(i) * 0.18 + 0.9),
                                        value: animateTagline
                                    )
                            }
                        }

                        Text("Powered by AI")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.25))
                            .tracking(1.2)
                            .opacity(animateTagline ? 1.0 : 0)
                            .animation(.easeOut(duration: 0.5).delay(1.0), value: animateTagline)
                    }
                    .padding(.top, 10)
                }
            }
            .onAppear {
                animateRings  = true
                animateLogo   = true
                animateText   = true
                animateTagline = true
                scanLine      = true

                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        navigate = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
