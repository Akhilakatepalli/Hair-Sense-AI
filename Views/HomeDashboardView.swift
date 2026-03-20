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
        let label: String
        let activeColor: Color
    }

    // Short labels so all tabs look equal width
    private let tabs: [TabItem] = [
        TabItem(icon: "house.fill",     label: "Home",    activeColor: Color(red: 0.95, green: 0.55, blue: 0.80)),
        TabItem(icon: "leaf.fill",      label: "Diet",    activeColor: Color(red: 0.25, green: 0.85, blue: 0.55)),
        TabItem(icon: "chart.bar.fill", label: "Progress",activeColor: Color(red: 0.45, green: 0.75, blue: 1.0)),
        TabItem(icon: "camera.fill",    label: "Scan",    activeColor: .white),
        TabItem(icon: "person.2.fill",  label: "Social",  activeColor: Color(red: 1.0,  green: 0.70, blue: 0.20)),
        TabItem(icon: "sparkles",       label: "Explore", activeColor: Color(red: 0.80, green: 0.55, blue: 1.0)),
        TabItem(icon: "person.fill",    label: "Profile", activeColor: Color(red: 0.95, green: 0.45, blue: 0.55)),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background bar
            RoundedRectangle(cornerRadius: 26)
                .fill(Color(red: 0.07, green: 0.05, blue: 0.16))
                .overlay(RoundedRectangle(cornerRadius: 26).stroke(Color.white.opacity(0.10), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.55), radius: 24, y: -4)
                .frame(height: 78)

            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    if index == 3 {
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
            .frame(height: 60)
            .padding(.horizontal, 4)
        }
        .frame(height: 78)
        .padding(.horizontal, 10)
        .padding(.bottom, 10)
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
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(activeColor.opacity(0.16))
                            .frame(width: 34, height: 24)
                    }
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? activeColor : Color.white.opacity(0.30))
                }
                .frame(width: 34, height: 24)

                Text(label)
                    .font(.system(size: 9, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? activeColor : Color.white.opacity(0.28))
                    .lineLimit(1)
                    .fixedSize()
            }
            .frame(height: 50)
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
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color(red: 0.80, green: 0.15, blue: 0.50).opacity(0.28))
                            .frame(width: 50, height: 50)
                            .blur(radius: 8)
                    }
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(red: 0.90, green: 0.25, blue: 0.55),
                                     Color(red: 0.45, green: 0.18, blue: 0.88)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 42, height: 42)
                        .shadow(color: Color(red: 0.80, green: 0.15, blue: 0.50).opacity(0.45), radius: 10, y: 4)
                    Image(systemName: "camera.fill")
                        .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                }
                .frame(width: 42, height: 24)

                Text("Scan")
                    .font(.system(size: 9, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? Color(red: 0.95, green: 0.55, blue: 0.80) : Color.white.opacity(0.28))
                    .fixedSize()
            }
            .frame(height: 50)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeDashboardView()
}
