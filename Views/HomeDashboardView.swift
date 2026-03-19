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
                    case 1: DietView()
                    case 2: HairProgressView()
                    case 3: ScanView(selectedTab: $selectedTab)
                    case 4: CommunityView()
                    case 5: DiscoverView()
                    case 6: ProfileView()
                    default: HomeView(selectedTab: $selectedTab)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // ── Custom Tab Bar ────────────────────────────────────────────
                ColorfulTabBar(selectedTab: $selectedTab)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .bottom)
            .navigationBarHidden(true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Colorful Tab Bar (7 tabs)

struct ColorfulTabBar: View {

    @Binding var selectedTab: Int

    private struct TabItem {
        let icon: String
        let emoji: String
        let label: String
        let activeColor: Color
    }

    // 7 tabs — Scan at index 3 (center)
    private let tabs: [TabItem] = [
        TabItem(icon: "house.fill",       emoji: "🏠", label: "Home",      activeColor: Color(red: 0.95, green: 0.55, blue: 0.80)),
        TabItem(icon: "leaf.fill",        emoji: "🥗", label: "Nutrition", activeColor: Color(red: 0.25, green: 0.85, blue: 0.55)),
        TabItem(icon: "chart.bar.fill",   emoji: "📈", label: "Progress",  activeColor: Color(red: 0.45, green: 0.75, blue: 1.0)),
        TabItem(icon: "camera.fill",      emoji: "📷", label: "Scan",      activeColor: .white),
        TabItem(icon: "person.2.fill",    emoji: "💬", label: "Community", activeColor: Color(red: 1.0, green: 0.70, blue: 0.20)),
        TabItem(icon: "sparkles",         emoji: "✨", label: "Discover",  activeColor: Color(red: 0.80, green: 0.55, blue: 1.0)),
        TabItem(icon: "person.fill",      emoji: "👤", label: "Profile",   activeColor: Color(red: 0.95, green: 0.45, blue: 0.55)),
    ]

    var body: some View {
        ZStack {
            // Background pill
            Capsule()
                .fill(Color(red: 0.07, green: 0.05, blue: 0.16))
                .overlay(Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.55), radius: 24, y: -4)

            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    if index == 3 {
                        // Center Scan button — elevated
                        ScanCenterButton(isSelected: selectedTab == 3) {
                            withAnimation(.spring(response: 0.30, dampingFraction: 0.65)) { selectedTab = 3 }
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        SmallTabButton(
                            icon: tab.icon,
                            label: tab.label,
                            activeColor: tab.activeColor,
                            isSelected: selectedTab == index
                        ) {
                            withAnimation(.spring(response: 0.30, dampingFraction: 0.65)) { selectedTab = index }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.top, 10)
            .padding(.bottom, 24)
        }
        .frame(height: 86)
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }
}

// MARK: - Small Tab Button

struct SmallTabButton: View {
    let icon: String
    let label: String
    let activeColor: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(activeColor.opacity(0.18))
                            .frame(width: 36, height: 26)
                    }
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? activeColor : Color.white.opacity(0.28))
                        .scaleEffect(isSelected ? 1.08 : 1.0)
                }
                .frame(height: 26)

                Text(label)
                    .font(.system(size: 9, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? activeColor : Color.white.opacity(0.25))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Scan Center Button

struct ScanCenterButton: View {
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color(red: 0.80, green: 0.15, blue: 0.50).opacity(0.30))
                            .frame(width: 56, height: 56)
                            .blur(radius: 10)
                    }
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(red: 0.90, green: 0.25, blue: 0.55),
                                     Color(red: 0.45, green: 0.18, blue: 0.88)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 46, height: 46)
                        .shadow(color: Color(red: 0.80, green: 0.15, blue: 0.50).opacity(0.50), radius: 12, y: 5)
                        .overlay(
                            Circle()
                                .fill(LinearGradient(colors: [Color.white.opacity(0.22), .clear],
                                                     startPoint: .topLeading, endPoint: .center))
                                .frame(width: 46, height: 46)
                        )
                    Image(systemName: "camera.fill")
                        .font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
                }
                Text("Scan")
                    .font(.system(size: 9, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? Color(red: 0.95, green: 0.55, blue: 0.80) : Color.white.opacity(0.28))
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeDashboardView()
}
