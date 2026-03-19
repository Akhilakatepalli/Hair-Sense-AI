//
//  WelcomeView.swift
//  Hair AI
//

import SwiftUI

struct WelcomeView: View {

    @State private var animateLogo    = false
    @State private var animateText    = false
    @State private var animateButtons = false
    @State private var animateRings   = false
    @State private var scanLine       = false

    var body: some View {

        NavigationStack {

            ZStack {

                // ── Rich dark background ──────────────────────────────────────
                Color(red: 0.06, green: 0.04, blue: 0.12).ignoresSafeArea()

                // ── Colorful gradient blobs ───────────────────────────────────
                // Hot pink blob — top right
                Circle()
                    .fill(Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.45))
                    .frame(width: 400, height: 400)
                    .blur(radius: 90)
                    .offset(x: 140, y: -280)
                    .ignoresSafeArea()

                // Deep purple blob — center left
                Circle()
                    .fill(Color(red: 0.45, green: 0.18, blue: 0.88).opacity(0.40))
                    .frame(width: 340, height: 340)
                    .blur(radius: 85)
                    .offset(x: -120, y: -60)
                    .ignoresSafeArea()

                // Coral/orange blob — bottom right
                Circle()
                    .fill(Color(red: 1.0, green: 0.40, blue: 0.20).opacity(0.28))
                    .frame(width: 280, height: 280)
                    .blur(radius: 80)
                    .offset(x: 100, y: 340)
                    .ignoresSafeArea()

                // Teal blob — bottom left
                Circle()
                    .fill(Color(red: 0.10, green: 0.78, blue: 0.60).opacity(0.22))
                    .frame(width: 220, height: 220)
                    .blur(radius: 70)
                    .offset(x: -100, y: 320)
                    .ignoresSafeArea()

                // ── Main content ──────────────────────────────────────────────
                VStack(spacing: 0) {

                    Spacer()

                    // ── Hero Glassmorphism Card ───────────────────────────────
                    ZStack {

                        RoundedRectangle(cornerRadius: 40)
                            .fill(Color.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 40)
                                    .stroke(Color.white.opacity(0.13), lineWidth: 1)
                            )

                        VStack(spacing: 26) {

                            // Logo circle with gradient
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [
                                            Color(red: 0.90, green: 0.25, blue: 0.55),
                                            Color(red: 0.45, green: 0.18, blue: 0.88)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 100, height: 100)
                                    .shadow(
                                        color: Color(red: 0.80, green: 0.15, blue: 0.50).opacity(0.60),
                                        radius: 26, y: 12
                                    )
                                    .scaleEffect(animateLogo ? 1.0 : 0.4)
                                    .opacity(animateLogo ? 1.0 : 0)
                                    .animation(.spring(response: 0.8, dampingFraction: 0.60), value: animateLogo)

                                VStack(spacing: 5) {
                                    HStack(spacing: 5) {
                                        ForEach(0..<3) { i in
                                            Capsule()
                                                .fill(Color.white)
                                                .frame(width: 4, height: CGFloat([24, 32, 24][i]))
                                                .opacity(i == 1 ? 1.0 : 0.75)
                                        }
                                    }
                                    Capsule()
                                        .fill(Color.white.opacity(0.90))
                                        .frame(width: scanLine ? 46 : 10, height: 3)
                                        .animation(
                                            .easeInOut(duration: 0.9)
                                            .repeatForever(autoreverses: true)
                                            .delay(0.5),
                                            value: scanLine
                                        )
                                }
                                .scaleEffect(animateLogo ? 1.0 : 0.4)
                                .opacity(animateLogo ? 1.0 : 0)
                                .animation(.spring(response: 0.8, dampingFraction: 0.60).delay(0.1), value: animateLogo)
                            }

                            // App name + tagline
                            VStack(spacing: 10) {
                                Text("Hair AI")
                                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                                    .foregroundStyle(LinearGradient(
                                        colors: [.white, Color(red: 1.0, green: 0.75, blue: 0.88)],
                                        startPoint: .leading, endPoint: .trailing
                                    ))
                                    .opacity(animateText ? 1.0 : 0)
                                    .offset(y: animateText ? 0 : 18)
                                    .animation(.easeOut(duration: 0.7).delay(0.35), value: animateText)

                                Text("Your AI Hair Health Assistant")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color.white.opacity(0.60))
                                    .multilineTextAlignment(.center)
                                    .opacity(animateText ? 1.0 : 0)
                                    .offset(y: animateText ? 0 : 12)
                                    .animation(.easeOut(duration: 0.6).delay(0.52), value: animateText)
                            }

                            // Feature pills
                            HStack(spacing: 10) {
                                featurePill(icon: "camera.viewfinder", label: "Scan",
                                            color: Color(red: 0.90, green: 0.25, blue: 0.55))
                                featurePill(icon: "chart.line.uptrend.xyaxis", label: "Track",
                                            color: Color(red: 0.45, green: 0.18, blue: 0.88))
                                featurePill(icon: "leaf.fill", label: "Heal",
                                            color: Color(red: 0.10, green: 0.78, blue: 0.60))
                            }
                            .opacity(animateText ? 1.0 : 0)
                            .animation(.easeOut(duration: 0.6).delay(0.68), value: animateText)
                        }
                        .padding(.horizontal, 28)
                        .padding(.vertical, 38)
                    }
                    .padding(.horizontal, 22)
                    .scaleEffect(animateLogo ? 1.0 : 0.95)
                    .opacity(animateLogo ? 1.0 : 0)
                    .animation(.easeOut(duration: 0.8), value: animateLogo)

                    Spacer()

                    // ── Buttons ───────────────────────────────────────────────
                    VStack(spacing: 14) {

                        // Login button — vibrant pink-purple gradient
                        NavigationLink(destination: LoginView()) {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.22))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                Text("Login")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white.opacity(0.75))
                            }
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity)
                            .frame(height: 64)
                            .background(LinearGradient(
                                colors: [
                                    Color(red: 0.90, green: 0.25, blue: 0.55),
                                    Color(red: 0.45, green: 0.18, blue: 0.88)
                                ],
                                startPoint: .leading, endPoint: .trailing
                            ))
                            .cornerRadius(20)
                            .shadow(
                                color: Color(red: 0.80, green: 0.15, blue: 0.50).opacity(0.52),
                                radius: 24, y: 10
                            )
                        }

                        // Sign Up button — glassmorphism
                        NavigationLink(destination: SignUpView()) {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.12))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "person.badge.plus")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                Text("Create Account")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white.opacity(0.48))
                            }
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity)
                            .frame(height: 64)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.20), lineWidth: 1.5)
                            )
                        }

                        Text("By continuing you agree to our Terms & Privacy Policy")
                            .font(.system(size: 11))
                            .foregroundColor(Color.white.opacity(0.28))
                            .multilineTextAlignment(.center)
                            .padding(.top, 2)
                    }
                    .padding(.horizontal, 24)
                    .opacity(animateButtons ? 1.0 : 0)
                    .offset(y: animateButtons ? 0 : 24)
                    .animation(.easeOut(duration: 0.7).delay(0.75), value: animateButtons)

                    Spacer().frame(height: 48)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                animateRings   = true
                animateLogo    = true
                animateText    = true
                animateButtons = true
                scanLine       = true
            }
        }
    }

    // MARK: - Feature Pill
    private func featurePill(icon: String, label: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(color.opacity(0.18))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(color.opacity(0.35), lineWidth: 1)
        )
    }
}

#Preview {
    WelcomeView()
}
