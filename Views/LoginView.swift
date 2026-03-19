//
//  LoginView.swift
//  Hair AI
//

import SwiftUI

struct LoginView: View {

    @EnvironmentObject var authVM: AuthViewModel

    @State private var email          = ""
    @State private var password       = ""
    @State private var showPassword   = false
    @State private var animateLogo    = false
    @State private var animateForm    = false
    @State private var showResetAlert = false
    @State private var resetEmail     = ""

    var body: some View {

        ZStack {

            // ── Rich dark background ──────────────────────────────────────────
            Color(red: 0.06, green: 0.04, blue: 0.12).ignoresSafeArea()

            // ── Colorful blobs ────────────────────────────────────────────────
            Circle()
                .fill(Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.40))
                .frame(width: 360, height: 360)
                .blur(radius: 90)
                .offset(x: 130, y: -300)
                .ignoresSafeArea()

            Circle()
                .fill(Color(red: 0.45, green: 0.18, blue: 0.88).opacity(0.35))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -110, y: -80)
                .ignoresSafeArea()

            Circle()
                .fill(Color(red: 0.10, green: 0.78, blue: 0.55).opacity(0.18))
                .frame(width: 240, height: 240)
                .blur(radius: 75)
                .offset(x: 80, y: 380)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    Spacer().frame(height: 60)

                    // ── Logo ──────────────────────────────────────────────────
                    VStack(spacing: 20) {

                        ZStack {
                            // Outer glow ring
                            Circle()
                                .fill(Color(red: 0.80, green: 0.15, blue: 0.50).opacity(0.20))
                                .frame(width: 140, height: 140)
                                .blur(radius: 20)
                                .scaleEffect(animateLogo ? 1.0 : 0.6)
                                .animation(.easeOut(duration: 1.0), value: animateLogo)

                            // Ring border
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.40),
                                            Color(red: 0.45, green: 0.18, blue: 0.88).opacity(0.40)
                                        ],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                                .frame(width: 112, height: 112)
                                .scaleEffect(animateLogo ? 1.0 : 0.6)
                                .animation(.easeOut(duration: 0.9).delay(0.1), value: animateLogo)

                            // Logo circle
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [
                                            Color(red: 0.90, green: 0.25, blue: 0.55),
                                            Color(red: 0.45, green: 0.18, blue: 0.88)
                                        ],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 90, height: 90)

                                Circle()
                                    .fill(LinearGradient(
                                        colors: [Color.white.opacity(0.22), .clear],
                                        startPoint: .topLeading, endPoint: .center
                                    ))
                                    .frame(width: 90, height: 90)

                                VStack(spacing: 4) {
                                    HStack(spacing: 5) {
                                        ForEach(0..<3) { i in
                                            Capsule()
                                                .fill(Color.white)
                                                .frame(width: 3.5, height: CGFloat([20, 26, 20][i]))
                                                .opacity(i == 1 ? 1.0 : 0.70)
                                        }
                                    }
                                    Capsule()
                                        .fill(Color.white.opacity(0.90))
                                        .frame(width: 34, height: 2.5)
                                }
                            }
                            .shadow(color: Color(red: 0.80, green: 0.15, blue: 0.50).opacity(0.55), radius: 20, y: 8)
                            .scaleEffect(animateLogo ? 1.0 : 0.5)
                            .animation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.2), value: animateLogo)
                        }

                        VStack(spacing: 6) {
                            Text("Hair AI")
                                .font(.system(size: 34, weight: .heavy, design: .rounded))
                                .foregroundStyle(LinearGradient(
                                    colors: [.white, Color(red: 1.0, green: 0.75, blue: 0.88)],
                                    startPoint: .leading, endPoint: .trailing
                                ))
                            Text("AI-Powered Hair Diagnosis")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(red: 0.80, green: 0.65, blue: 1.0))
                                .tracking(1.2)
                                .textCase(.uppercase)
                        }
                        .opacity(animateLogo ? 1.0 : 0)
                        .offset(y: animateLogo ? 0 : 10)
                        .animation(.easeOut(duration: 0.7).delay(0.4), value: animateLogo)
                    }

                    Spacer().frame(height: 48)

                    // ── Form Card ─────────────────────────────────────────────
                    VStack(spacing: 16) {

                        // Error banner
                        if !authVM.errorMessage.isEmpty {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.45))
                                Text(authVM.errorMessage)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.45))
                                Spacer()
                            }
                            .padding(14)
                            .background(Color(red: 1.0, green: 0.20, blue: 0.20).opacity(0.12))
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(red: 1.0, green: 0.35, blue: 0.35).opacity(0.30), lineWidth: 1))
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        // Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("EMAIL")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color(red: 0.80, green: 0.65, blue: 1.0))
                                .tracking(1.5)
                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(red: 0.80, green: 0.55, blue: 1.0))
                                    .frame(width: 20)
                                TextField("", text: $email,
                                          prompt: Text("your@email.com").foregroundColor(Color.white.opacity(0.25)))
                                .foregroundColor(.white)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            }
                            .padding(.horizontal, 18).padding(.vertical, 16)
                            .background(Color.white.opacity(0.07))
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 0.70, green: 0.45, blue: 1.0).opacity(0.25), lineWidth: 1))
                        }

                        // Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PASSWORD")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color(red: 0.80, green: 0.65, blue: 1.0))
                                .tracking(1.5)
                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(red: 0.80, green: 0.55, blue: 1.0))
                                    .frame(width: 20)
                                if showPassword {
                                    TextField("", text: $password,
                                              prompt: Text("••••••••").foregroundColor(Color.white.opacity(0.25)))
                                    .foregroundColor(.white)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                } else {
                                    SecureField("", text: $password,
                                                prompt: Text("••••••••").foregroundColor(Color.white.opacity(0.25)))
                                    .foregroundColor(.white)
                                }
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color.white.opacity(0.35))
                                }
                            }
                            .padding(.horizontal, 18).padding(.vertical, 16)
                            .background(Color.white.opacity(0.07))
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 0.70, green: 0.45, blue: 1.0).opacity(0.25), lineWidth: 1))
                        }

                        // Forgot password
                        HStack {
                            Spacer()
                            Button(action: { showResetAlert = true }) {
                                Text("Forgot Password?")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(red: 0.90, green: 0.55, blue: 0.90))
                            }
                        }

                        // Login button
                        Button(action: {
                            authVM.login(email: email, password: password)
                        }) {
                            ZStack {
                                HStack(spacing: 10) {
                                    Text("Login")
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    if !authVM.isLoading {
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(.white.opacity(0.80))
                                    }
                                }
                                .opacity(authVM.isLoading ? 0 : 1)
                                if authVM.isLoading {
                                    ProgressView().tint(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(LinearGradient(
                                colors: [
                                    Color(red: 0.90, green: 0.25, blue: 0.55),
                                    Color(red: 0.45, green: 0.18, blue: 0.88)
                                ],
                                startPoint: .leading, endPoint: .trailing
                            ))
                            .cornerRadius(18)
                            .shadow(color: Color(red: 0.80, green: 0.15, blue: 0.50).opacity(0.50), radius: 20, y: 8)
                        }
                        .disabled(authVM.isLoading || email.isEmpty || password.isEmpty)
                        .opacity(authVM.isLoading || email.isEmpty || password.isEmpty ? 0.60 : 1.0)
                        .padding(.top, 6)
                    }
                    .padding(22)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(28)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .opacity(animateForm ? 1.0 : 0)
                    .offset(y: animateForm ? 0 : 20)
                    .animation(.easeOut(duration: 0.7).delay(0.5), value: animateForm)

                    Spacer().frame(height: 36)

                    HStack(spacing: 14) {
                        Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1)
                        Text("or").font(.system(size: 13)).foregroundColor(Color.white.opacity(0.30))
                        Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1)
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 28)

                    HStack(spacing: 6) {
                        Text("Don't have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(Color.white.opacity(0.40))
                        NavigationLink(destination: SignUpView()) {
                            Text("Sign Up")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(LinearGradient(
                                    colors: [Color(red: 0.90, green: 0.25, blue: 0.55),
                                             Color(red: 0.45, green: 0.18, blue: 0.88)],
                                    startPoint: .leading, endPoint: .trailing
                                ))
                        }
                    }

                    Spacer().frame(height: 48)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            animateLogo = true
            animateForm = true
            authVM.errorMessage = ""
        }
        .alert("Reset Password", isPresented: $showResetAlert) {
            TextField("your@email.com", text: $resetEmail)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            Button("Send Reset Email") {
                authVM.resetPassword(email: resetEmail)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter your email and we'll send you a reset link.")
        }
    }
}

#Preview {
    NavigationStack {
        LoginView().environmentObject(AuthViewModel())
    }
}
