//
//  HomeDashboardView.swift
//  Hair AI
//

import SwiftUI

struct HomeDashboardView: View {

    @State private var selectedTab = 0

    var body: some View {

        NavigationStack {
            ZStack(alignment: .bottom) {

                // ── Tab Content ───────────────────────────────────────────────
                ZStack {
                    switch selectedTab {
                    case 0: HomeView(selectedTab: $selectedTab)
                    case 1: ScanView(selectedTab: $selectedTab)
                    case 2: DietView()
                    case 3: HairProgressView()
                    case 4: ProfileView()
                    default: HomeView(selectedTab: $selectedTab)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // ── Custom Tab Bar ────────────────────────────────────────────
                CustomTabBar(selectedTab: $selectedTab)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .bottom)
            .navigationBarHidden(true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {

    @Binding var selectedTab: Int

    struct TabItem {
        let icon: String
        let label: String
    }

    let tabs: [TabItem] = [
        TabItem(icon: "house.fill",      label: "Home"),
        TabItem(icon: "camera.fill",     label: "Scan"),
        TabItem(icon: "leaf.fill",       label: "Diet"),
        TabItem(icon: "chart.bar.fill",  label: "Progress"),
        TabItem(icon: "person.fill",     label: "Profile")
    ]

    var body: some View {

        ZStack {

            // Background card
            RoundedRectangle(cornerRadius: 34)
                .fill(Color(red: 0.08, green: 0.06, blue: 0.17))
                .overlay(
                    RoundedRectangle(cornerRadius: 34)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.55), radius: 28, y: -6)

            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in

                    if index == 1 {
                        ScanTabButton(isSelected: selectedTab == index) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.70)) {
                                selectedTab = index
                            }
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        TabBarButton(
                            icon: tab.icon,
                            label: tab.label,
                            isSelected: selectedTab == index
                        ) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.70)) {
                                selectedTab = index
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 12)
            .padding(.bottom, 26)
        }
        .frame(height: 90)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

// MARK: - Regular Tab Button

struct TabBarButton: View {

    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {

        Button(action: action) {
            VStack(spacing: 5) {

                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(
                                colors: [
                                    Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.28),
                                    Color(red: 0.45, green: 0.18, blue: 0.88).opacity(0.28)
                                ],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                            .frame(width: 50, height: 32)
                            .transition(.scale.combined(with: .opacity))
                    }

                    Image(systemName: icon)
                        .font(.system(size: 19, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected
                            ? Color(red: 0.95, green: 0.55, blue: 0.80)
                            : Color.white.opacity(0.30))
                        .scaleEffect(isSelected ? 1.10 : 1.0)
                }
                .frame(height: 32)

                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected
                        ? Color(red: 0.95, green: 0.55, blue: 0.80)
                        : Color.white.opacity(0.28))
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Scan Tab Button (elevated center)

struct ScanTabButton: View {

    let isSelected: Bool
    let action: () -> Void

    var body: some View {

        Button(action: action) {
            VStack(spacing: 6) {

                ZStack {
                    // Outer glow ring when selected
                    if isSelected {
                        Circle()
                            .fill(Color(red: 0.80, green: 0.15, blue: 0.50).opacity(0.30))
                            .frame(width: 64, height: 64)
                            .blur(radius: 10)
                    }

                    Circle()
                        .fill(LinearGradient(
                            colors: [
                                Color(red: 0.90, green: 0.25, blue: 0.55),
                                Color(red: 0.45, green: 0.18, blue: 0.88)
                            ],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 54, height: 54)
                        .shadow(
                            color: Color(red: 0.80, green: 0.15, blue: 0.50).opacity(0.55),
                            radius: 14, y: 6
                        )
                        .overlay(
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color.white.opacity(0.25), .clear],
                                    startPoint: .topLeading, endPoint: .center
                                ))
                                .frame(width: 54, height: 54)
                        )

                    Image(systemName: "camera.fill")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundColor(.white)
                }

                Text("Scan")
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected
                        ? Color(red: 0.95, green: 0.55, blue: 0.80)
                        : Color.white.opacity(0.28))
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeDashboardView()
}
