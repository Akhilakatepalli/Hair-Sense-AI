//
//  HealthAndNotificationsView.swift
//  Hair AI
//

import SwiftUI
import HealthKit

struct HealthAndNotificationsView: View {

    @StateObject private var hk = HealthKitService.shared
    @StateObject private var ns = NotificationService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showHealthAlert = false
    @State private var showNotifAlert  = false

    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.04, blue: 0.12).ignoresSafeArea()

            // blobs
            Circle().fill(Color(red: 0.20, green: 0.75, blue: 0.50).opacity(0.12))
                .frame(width: 320, height: 320).blur(radius: 80).offset(x: -100, y: -150)
            Circle().fill(Color(red: 0.45, green: 0.18, blue: 0.88).opacity(0.10))
                .frame(width: 280, height: 280).blur(radius: 80).offset(x: 130, y: 200)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Nav bar
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left").font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white).padding(10)
                                .background(Circle().fill(Color.white.opacity(0.07)))
                        }
                        Spacer()
                        Text("Health & Alerts").font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                        Spacer()
                        Color.clear.frame(width: 40)
                    }
                    .padding(.horizontal, 20).padding(.top, 60)

                    // ── Apple Health ─────────────────────────────────────
                    sectionHeader(icon: "❤️", title: "Apple Health", subtitle: "Sync data from Health app & Apple Watch")

                    healthConnectCard

                    if hk.isAuthorized {
                        healthDataGrid
                        healthInsightCard
                        appleWatchCard
                    }

                    // ── Notifications ─────────────────────────────────────
                    sectionHeader(icon: "🔔", title: "Smart Reminders", subtitle: "AI-powered reminders for your hair care routine")

                    notificationsConnectCard

                    if ns.isPermissionGranted {
                        notificationToggles
                    }

                    Spacer(minLength: 60)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            hk.fetchAll()
            ns.checkPermission()
        }
    }

    // MARK: - Section Header

    private func sectionHeader(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Text(icon).font(.system(size: 28))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                Text(subtitle).font(.system(size: 12)).foregroundColor(Color.white.opacity(0.50))
            }
            Spacer()
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Apple Health Connect Card

    private var healthConnectCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(LinearGradient(
                    colors: [Color(red: 0.95, green: 0.30, blue: 0.40).opacity(0.20),
                             Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.20)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .overlay(RoundedRectangle(cornerRadius: 22)
                    .stroke(Color(red: 0.95, green: 0.40, blue: 0.50).opacity(0.35), lineWidth: 1))

            HStack(spacing: 16) {
                ZStack {
                    Circle().fill(Color(red: 0.95, green: 0.30, blue: 0.40).opacity(0.25)).frame(width: 56, height: 56)
                    Image(systemName: "heart.fill").font(.system(size: 24))
                        .foregroundColor(Color(red: 0.95, green: 0.40, blue: 0.50))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(hk.isAuthorized ? "✅ Health Connected" : "Connect Apple Health")
                        .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                    Text(hk.isAuthorized
                         ? "Syncing sleep, steps, heart rate & more from Apple Watch"
                         : "Sync sleep, steps, heart rate, HRV, water & more")
                        .font(.system(size: 12)).foregroundColor(Color.white.opacity(0.65)).lineLimit(2)
                }
                Spacer()
                if !hk.isAuthorized {
                    Button(action: {
                        hk.requestAuthorization { success in
                            if !success { showHealthAlert = true }
                        }
                    }) {
                        Text("Connect").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(Capsule().fill(Color(red: 0.95, green: 0.30, blue: 0.40)))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(18)
        }
        .padding(.horizontal, 20)
        .alert("HealthKit Unavailable", isPresented: $showHealthAlert) {
            Button("OK") {}
        } message: {
            Text("This device doesn't support HealthKit, or permission was denied in Settings.")
        }
    }

    // MARK: - Health Data Grid

    private var healthDataGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            healthStatCard(emoji: "😴", label: "Sleep", value: hk.sleepHours > 0 ? String(format: "%.1f hrs", hk.sleepHours) : "--",
                           sub: hk.sleepHours > 0 ? (hk.sleepHours >= 7 ? "Great! 🌟" : "Low ⚠️") : "No data",
                           color: Color(red: 0.45, green: 0.18, blue: 0.88))
            healthStatCard(emoji: "👟", label: "Steps", value: hk.steps > 0 ? "\(hk.steps.formatted())" : "--",
                           sub: hk.steps > 0 ? (hk.steps >= 8000 ? "Excellent! 🔥" : "Keep going") : "No data",
                           color: Color(red: 0.20, green: 0.80, blue: 0.50))
            healthStatCard(emoji: "❤️", label: "Heart Rate", value: hk.heartRate > 0 ? "\(Int(hk.heartRate)) bpm" : "--",
                           sub: hk.restingHeartRate > 0 ? "Resting: \(Int(hk.restingHeartRate))" : "No data",
                           color: Color(red: 0.95, green: 0.30, blue: 0.40))
            healthStatCard(emoji: "💧", label: "Water", value: hk.waterLiters > 0 ? String(format: "%.1fL", hk.waterLiters) : "--",
                           sub: "\(hk.waterGlasses)/8 glasses",
                           color: Color(red: 0.20, green: 0.65, blue: 0.95))
            healthStatCard(emoji: "🔥", label: "Active Cal", value: hk.activeCalories > 0 ? "\(Int(hk.activeCalories)) kcal" : "--",
                           sub: hk.activeCalories >= 300 ? "On fire! 🔥" : "Keep moving",
                           color: Color(red: 0.95, green: 0.55, blue: 0.15))
            healthStatCard(emoji: "🧠", label: "Stress (HRV)", value: hk.stressLevel,
                           sub: hk.hrvScore > 0 ? "\(Int(hk.hrvScore)) ms HRV" : "No data",
                           color: Color(red: 0.90, green: 0.25, blue: 0.55))
        }
        .padding(.horizontal, 20)
    }

    private func healthStatCard(emoji: String, label: String, value: String, sub: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18).fill(color.opacity(0.12))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(color.opacity(0.25), lineWidth: 1))
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(emoji).font(.system(size: 22))
                    Spacer()
                    Circle().fill(color.opacity(0.30)).frame(width: 8, height: 8)
                }
                Text(value).font(.system(size: 22, weight: .bold)).foregroundColor(.white)
                VStack(alignment: .leading, spacing: 2) {
                    Text(label).font(.system(size: 11, weight: .bold)).foregroundColor(color)
                    Text(sub).font(.system(size: 11)).foregroundColor(Color.white.opacity(0.55))
                }
            }
            .padding(14)
        }
    }

    // MARK: - AI Health Insight Card

    private var healthInsightCard: some View {
        let insight = hk.sleepInsight
        return ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(LinearGradient(colors: [Color(red: 0.10, green: 0.50, blue: 0.35).opacity(0.25),
                                               Color(red: 0.45, green: 0.18, blue: 0.88).opacity(0.20)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(insight.color.opacity(0.35), lineWidth: 1))

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle().fill(Color(red: 0.45, green: 0.18, blue: 0.88).opacity(0.25)).frame(width: 38, height: 38)
                        Text("🤖").font(.system(size: 18))
                    }
                    Text("AI Hair-Health Insight").font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 0.70, green: 0.55, blue: 1.0))
                }
                HStack(spacing: 10) {
                    Text(insight.emoji).font(.system(size: 28))
                    Text(insight.text).font(.system(size: 13)).foregroundColor(.white.opacity(0.85)).lineLimit(3)
                }

                // Steps insight
                let si = hk.stepsInsight
                HStack(spacing: 10) {
                    Text(si.emoji).font(.system(size: 22))
                    Text(si.text).font(.system(size: 13)).foregroundColor(.white.opacity(0.80)).lineLimit(2)
                }

                // Mindfulness
                if hk.mindfulMinutes > 0 {
                    HStack(spacing: 10) {
                        Text("🧘").font(.system(size: 22))
                        Text(String(format: "%.0f min mindfulness today — reduced cortisol supports hair growth! 🌿", hk.mindfulMinutes))
                            .font(.system(size: 13)).foregroundColor(.white.opacity(0.80)).lineLimit(2)
                    }
                }
            }
            .padding(18)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Apple Watch Card

    private var appleWatchCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 0.10, green: 0.45, blue: 0.85).opacity(0.18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(red: 0.30, green: 0.65, blue: 1.0).opacity(0.30), lineWidth: 1))

            HStack(spacing: 14) {
                Text("⌚").font(.system(size: 34))
                VStack(alignment: .leading, spacing: 4) {
                    Text("Apple Watch Synced").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                    Text("Sleep tracking, heart rate, HRV, activity rings, and mindfulness sessions automatically sync from your Apple Watch to Hair Sense AI via HealthKit.")
                        .font(.system(size: 12)).foregroundColor(Color.white.opacity(0.65)).lineLimit(3)
                }
            }
            .padding(16)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Notifications Connect Card

    private var notificationsConnectCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(LinearGradient(
                    colors: [Color(red: 0.95, green: 0.65, blue: 0.10).opacity(0.20),
                             Color(red: 0.90, green: 0.40, blue: 0.10).opacity(0.15)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .overlay(RoundedRectangle(cornerRadius: 22)
                    .stroke(Color(red: 0.95, green: 0.70, blue: 0.15).opacity(0.35), lineWidth: 1))

            HStack(spacing: 16) {
                ZStack {
                    Circle().fill(Color(red: 0.95, green: 0.65, blue: 0.10).opacity(0.25)).frame(width: 56, height: 56)
                    Image(systemName: "bell.badge.fill").font(.system(size: 22))
                        .foregroundColor(Color(red: 0.95, green: 0.70, blue: 0.20))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(ns.isPermissionGranted ? "✅ Notifications Active" : "Enable Smart Reminders")
                        .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                    Text(ns.isPermissionGranted
                         ? "Water, sleep, vitamin & scalp care reminders are running"
                         : "Water reminders, sleep tips, vitamin alerts & more")
                        .font(.system(size: 12)).foregroundColor(Color.white.opacity(0.65)).lineLimit(2)
                }
                Spacer()
                if !ns.isPermissionGranted {
                    Button(action: {
                        ns.requestPermission { granted in
                            if !granted { showNotifAlert = true }
                        }
                    }) {
                        Text("Enable").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(Capsule().fill(Color(red: 0.95, green: 0.60, blue: 0.10)))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(18)
        }
        .padding(.horizontal, 20)
        .alert("Permission Denied", isPresented: $showNotifAlert) {
            Button("Open Settings") { UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!) }
            Button("Cancel") {}
        } message: {
            Text("Please enable notifications for Hair Sense AI in Settings to receive hair care reminders.")
        }
    }

    // MARK: - Notification Toggles

    private var notificationToggles: some View {
        let items: [(String, String, String, Binding<Bool>)] = [
            ("💧", "Water Reminders", "Every 2 hours, 8 AM–8 PM", $ns.notifWater),
            ("🌙", "Bedtime Reminder", "10:00 PM daily", $ns.notifSleep),
            ("🌅", "Morning Routine", "7:30 AM daily", $ns.notifMorning),
            ("💊", "Vitamin Reminder", "9:00 AM daily", $ns.notifVitamin),
            ("🌿", "Oil Treatment", "Mon, Wed, Fri at 7 PM", $ns.notifOil),
            ("💆‍♀️", "Scalp Massage", "Tue, Thu, Sat at 8 PM", $ns.notifScalp),
            ("📊", "Weekly Scan", "Sundays at 10 AM", $ns.notifScan),
            ("🧘", "Stress Check-in", "2:00 PM daily", $ns.notifStress),
        ]

        return VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(spacing: 14) {
                    ZStack {
                        Circle().fill(Color.white.opacity(0.07)).frame(width: 42, height: 42)
                        Text(item.0).font(.system(size: 20))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.1).font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                        Text(item.2).font(.system(size: 11)).foregroundColor(Color.white.opacity(0.45))
                    }
                    Spacer()
                    Toggle("", isOn: item.3)
                        .tint(Color(red: 0.90, green: 0.25, blue: 0.55))
                        .onChange(of: item.3.wrappedValue) { _ in ns.scheduleAll() }
                }
                .padding(.horizontal, 20).padding(.vertical, 12)

                if items.firstIndex(where: { $0.1 == item.1 }) != items.count - 1 {
                    Divider().background(Color.white.opacity(0.06)).padding(.leading, 76)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.08), lineWidth: 1))
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    HealthAndNotificationsView()
}
