//
//  ProfileView.swift
//  Hair AI
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {

    @AppStorage("userName")          private var userName         = ""
    @AppStorage("userEmail")         private var userEmail        = ""
    @AppStorage("userAge")           private var userAge          = ""
    @AppStorage("streakDays")        private var streakDays       = 0
    @AppStorage("hairLengthGoal")    private var hairLengthGoal: Double = 30.0
    @AppStorage("currentHairLength") private var currentHairLength: Double = 0.0

    @State private var animateProfile = false
    @State private var showEditSheet  = false
    @State private var editName       = ""
    @State private var editAge        = ""

    @EnvironmentObject var authVM: AuthViewModel

    private var lastScan: ScanRecord? { ScanHistoryManager.shared.getLastScan() }
    private var totalScans: Int       { ScanHistoryManager.shared.totalScans }

    private var displayName: String {
        if !userName.isEmpty { return userName }
        if let email = authVM.currentUser?.email { return String(email.split(separator: "@").first ?? "User") }
        return "Hair Enthusiast"
    }

    private var displayEmail: String {
        if !userEmail.isEmpty { return userEmail }
        return authVM.currentUser?.email ?? "user@example.com"
    }

    private var improvement: Int {
        guard let first = ScanHistoryManager.shared.getFirstScan()?.score,
              let last  = lastScan?.score else { return 0 }
        return last - first
    }

    // ── Hair length history ───────────────────────────────────────────────
    private var lengthHistoryCount: Int {
        guard let data = UserDefaults.standard.data(forKey: "hairLengthHistory"),
              let entries = try? JSONDecoder().decode([HairLengthEntry].self, from: data)
        else { return 0 }
        return entries.count
    }

    // ── Achievements (same as ProgressView) ──────────────────────────────
    private struct Ach { let icon: String; let title: String; let earned: Bool; let color: Color }

    private var achievements: [Ach] {
        [
            Ach(icon: "camera.fill",             title: "First Scan",     earned: totalScans >= 1,            color: Color(red: 0.90, green: 0.25, blue: 0.55)),
            Ach(icon: "flame.fill",               title: "7-Day Streak",  earned: streakDays >= 7,             color: Color(red: 1.0,  green: 0.50, blue: 0.18)),
            Ach(icon: "ruler.fill",               title: "Length Logger", earned: lengthHistoryCount > 0,      color: Color(red: 0.10, green: 0.78, blue: 0.55)),
            Ach(icon: "arrow.up.right.circle.fill", title: "Improver",   earned: improvement >= 10,           color: Color(red: 0.28, green: 0.58, blue: 0.95)),
            Ach(icon: "calendar.badge.checkmark", title: "Month Warrior", earned: streakDays >= 30,            color: Color(red: 0.95, green: 0.72, blue: 0.08)),
            Ach(icon: "photo.on.rectangle.angled", title: "Compared",    earned: false,                       color: Color(red: 0.60, green: 0.38, blue: 0.95)),
            Ach(icon: "star.fill",                title: "Champion",     earned: (lastScan?.score ?? 0) >= 85, color: Color(red: 0.90, green: 0.75, blue: 0.10)),
            Ach(icon: "trophy.fill",              title: "5 Scans",      earned: totalScans >= 5,              color: Color(red: 0.45, green: 0.18, blue: 0.88))
        ]
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.04, blue: 0.12).ignoresSafeArea()

            // Blobs
            Circle()
                .fill(Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.30))
                .frame(width: 360, height: 360).blur(radius: 90)
                .offset(x: 130, y: -250).ignoresSafeArea()
            Circle()
                .fill(Color(red: 0.45, green: 0.18, blue: 0.88).opacity(0.25))
                .frame(width: 280, height: 280).blur(radius: 80)
                .offset(x: -110, y: 50).ignoresSafeArea()
            Circle()
                .fill(Color(red: 0.10, green: 0.78, blue: 0.55).opacity(0.15))
                .frame(width: 220, height: 220).blur(radius: 70)
                .offset(x: 80, y: 360).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    Spacer().frame(height: 10)

                    // ── Avatar ────────────────────────────────────────────
                    avatarSection
                        .scaleEffect(animateProfile ? 1.0 : 0.7)
                        .opacity(animateProfile ? 1.0 : 0)
                        .animation(.spring(response: 0.7, dampingFraction: 0.6), value: animateProfile)

                    // ── Stats Row ─────────────────────────────────────────
                    statsRow
                        .opacity(animateProfile ? 1.0 : 0).offset(y: animateProfile ? 0 : 16)
                        .animation(.easeOut(duration: 0.6).delay(0.20), value: animateProfile)

                    // ── Last Scan Summary ─────────────────────────────────
                    if let scan = lastScan {
                        lastScanCard(scan: scan)
                            .opacity(animateProfile ? 1.0 : 0).offset(y: animateProfile ? 0 : 16)
                            .animation(.easeOut(duration: 0.6).delay(0.24), value: animateProfile)
                    }

                    // ── Hair Growth Summary ───────────────────────────────
                    if hairLengthGoal > 0 && currentHairLength > 0 {
                        hairGrowthCard
                            .opacity(animateProfile ? 1.0 : 0).offset(y: animateProfile ? 0 : 16)
                            .animation(.easeOut(duration: 0.6).delay(0.27), value: animateProfile)
                    }

                    // ── Achievements ──────────────────────────────────────
                    achievementsCard
                        .opacity(animateProfile ? 1.0 : 0).offset(y: animateProfile ? 0 : 16)
                        .animation(.easeOut(duration: 0.6).delay(0.30), value: animateProfile)

                    // ── Personal Info ─────────────────────────────────────
                    personalInfoCard
                        .opacity(animateProfile ? 1.0 : 0).offset(y: animateProfile ? 0 : 16)
                        .animation(.easeOut(duration: 0.6).delay(0.34), value: animateProfile)

                    // ── Settings ──────────────────────────────────────────
                    settingsCard
                        .opacity(animateProfile ? 1.0 : 0).offset(y: animateProfile ? 0 : 16)
                        .animation(.easeOut(duration: 0.6).delay(0.38), value: animateProfile)

                    Spacer().frame(height: 30)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
        .onAppear { animateProfile = true }
        .sheet(isPresented: $showEditSheet) { editProfileSheet }
    }

    // MARK: - Avatar Section

    private var avatarSection: some View {
        VStack(spacing: 14) {
            ZStack {
                // Outer glow
                Circle()
                    .fill(Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.20))
                    .frame(width: 150, height: 150)

                // Gradient ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color(red: 0.90, green: 0.25, blue: 0.55), Color(red: 0.45, green: 0.18, blue: 0.88)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 118, height: 118)

                // Avatar fill
                Circle()
                    .fill(LinearGradient(
                        colors: [Color(red: 0.18, green: 0.10, blue: 0.32), Color(red: 0.12, green: 0.08, blue: 0.22)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: 110, height: 110)

                Image(systemName: "person.fill")
                    .resizable().scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundStyle(LinearGradient(
                        colors: [Color(red: 0.95, green: 0.55, blue: 0.80), Color(red: 0.70, green: 0.38, blue: 1.0)],
                        startPoint: .top, endPoint: .bottom
                    ))

                // Edit camera badge
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(red: 0.90, green: 0.25, blue: 0.55), Color(red: 0.45, green: 0.18, blue: 0.88)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 32, height: 32)
                    Image(systemName: "pencil").font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                }
                .offset(x: 40, y: 40)
                .onTapGesture { showEditSheet = true }
            }

            VStack(spacing: 4) {
                Text(displayName)
                    .font(.system(size: 24, weight: .bold, design: .rounded)).foregroundColor(.white)
                Text(displayEmail)
                    .font(.system(size: 13)).foregroundColor(Color(red: 0.75, green: 0.60, blue: 0.90))
                // Streak pill
                HStack(spacing: 5) {
                    Text("🔥").font(.system(size: 12))
                    Text("\(streakDays) day streak")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(red: 1.0, green: 0.82, blue: 0.45))
                }
                .padding(.horizontal, 14).padding(.vertical, 5)
                .background(Color(red: 1.0, green: 0.50, blue: 0.18).opacity(0.18))
                .clipShape(Capsule())
                .padding(.top, 4)
            }
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 0) {
            profileStat(value: totalScans == 0 ? "—" : "\(lastScan?.score ?? 0)%", label: "Hair Score")
            divider
            profileStat(value: "\(totalScans)", label: "Scans Done")
            divider
            profileStat(value: improvement > 0 ? "+\(improvement)%" : "—", label: "Improved")
            divider
            profileStat(value: userAge.isEmpty ? "—" : userAge + "y", label: "Age")
        }
        .padding(.vertical, 18)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }

    private var divider: some View {
        Rectangle().fill(Color.white.opacity(0.08)).frame(width: 1, height: 40)
    }

    private func profileStat(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 18, weight: .bold, design: .rounded)).foregroundColor(.white)
            Text(label).font(.system(size: 10)).foregroundColor(Color.white.opacity(0.45))
        }.frame(maxWidth: .infinity)
    }

    // MARK: - Last Scan Card

    private func lastScanCard(scan: ScanRecord) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Last AI Scan")
                    .font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.white)
                Spacer()
                Text(scan.date, format: .dateTime.month(.abbreviated).day())
                    .font(.system(size: 12)).foregroundColor(Color(red: 0.80, green: 0.65, blue: 1.0))
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color(red: 0.45, green: 0.18, blue: 0.88).opacity(0.20)).clipShape(Capsule())
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                scanDetailChip(label: "Condition", value: scan.condition, icon: "waveform.path.ecg.rectangle.fill", color: Color(red: 0.90, green: 0.25, blue: 0.55))
                scanDetailChip(label: "Scalp", value: scan.scalpHealth, icon: "drop.fill", color: Color(red: 0.28, green: 0.58, blue: 0.95))
                scanDetailChip(label: "Density", value: scan.density, icon: "square.3.layers.3d", color: Color(red: 0.10, green: 0.78, blue: 0.55))
                scanDetailChip(label: "Loss Risk", value: scan.hairLossRisk, icon: "exclamationmark.triangle.fill", color: Color(red: 1.0, green: 0.52, blue: 0.20))
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.05))
        .cornerRadius(22)
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }

    private func scanDetailChip(label: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(color.opacity(0.18)).frame(width: 32, height: 32)
                Image(systemName: icon).font(.system(size: 12, weight: .semibold)).foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.system(size: 10)).foregroundColor(Color.white.opacity(0.42))
                Text(value).font(.system(size: 13, weight: .semibold)).foregroundColor(.white).lineLimit(1)
            }
            Spacer()
        }
        .padding(10)
        .background(Color(red: 0.10, green: 0.10, blue: 0.18))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.18), lineWidth: 1))
    }

    // MARK: - Hair Growth Card

    private var hairGrowthCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Hair Growth Goal")
                    .font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.white)
                Spacer()
                let pct = min(currentHairLength / hairLengthGoal, 1.0)
                Text(String(format: "%.0f%%", pct * 100))
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(red: 0.10, green: 0.78, blue: 0.55))
            }
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.08)).frame(height: 8)
                    let pct = min(currentHairLength / hairLengthGoal, 1.0)
                    Capsule()
                        .fill(LinearGradient(
                            colors: [Color(red: 0.10, green: 0.78, blue: 0.55), Color(red: 0.28, green: 0.58, blue: 0.95)],
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .frame(width: g.size.width * CGFloat(pct), height: 8)
                }
            }.frame(height: 8)

            HStack {
                Text(String(format: "Current: %.1f cm", currentHairLength))
                    .font(.system(size: 12)).foregroundColor(Color.white.opacity(0.50))
                Spacer()
                Text(String(format: "Goal: %.0f cm", hairLengthGoal))
                    .font(.system(size: 12)).foregroundColor(Color.white.opacity(0.50))
            }
        }
        .padding(18)
        .background(LinearGradient(
            colors: [Color(red: 0.06, green: 0.28, blue: 0.20), Color(red: 0.06, green: 0.18, blue: 0.35)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        ))
        .cornerRadius(22)
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color(red: 0.10, green: 0.78, blue: 0.55).opacity(0.30), lineWidth: 1))
    }

    // MARK: - Achievements Card

    private var achievementsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Achievements")
                    .font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.white)
                Spacer()
                let earned = achievements.filter { $0.earned }.count
                Text("\(earned)/\(achievements.count)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(red: 0.90, green: 0.72, blue: 0.20))
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color(red: 0.90, green: 0.72, blue: 0.20).opacity(0.15)).clipShape(Capsule())
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                ForEach(achievements.indices, id: \.self) { i in
                    let a = achievements[i]
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(a.earned ? a.color.opacity(0.22) : Color.white.opacity(0.05))
                                .frame(width: 52, height: 52)
                            Image(systemName: a.icon)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(a.earned ? a.color : Color.white.opacity(0.15))
                            if !a.earned {
                                Image(systemName: "lock.fill").font(.system(size: 9, weight: .bold))
                                    .foregroundColor(Color.white.opacity(0.20)).offset(x: 14, y: 14)
                            }
                        }
                        Text(a.title)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(a.earned ? .white : Color.white.opacity(0.28))
                            .multilineTextAlignment(.center).lineLimit(2)
                    }
                }
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.05))
        .cornerRadius(22)
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color(red: 0.90, green: 0.72, blue: 0.20).opacity(0.20), lineWidth: 1))
    }

    // MARK: - Personal Info Card

    private var personalInfoCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("PERSONAL INFO")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(red: 0.80, green: 0.65, blue: 1.0)).tracking(1.5)
                .padding(.bottom, 12)

            VStack(spacing: 0) {
                infoRow(label: "Name",  value: displayName.isEmpty ? "Not set" : displayName, icon: "person.fill",  isLast: false)
                infoRow(label: "Email", value: displayEmail,     icon: "envelope.fill", isLast: false)
                infoRow(label: "Age",   value: userAge.isEmpty ? "Not set" : userAge + " years", icon: "calendar",  isLast: false)
                infoRow(label: "Hair Goal", value: hairLengthGoal > 0 ? String(format: "%.0f cm", hairLengthGoal) : "Not set", icon: "ruler.fill", isLast: true)
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
    }

    private func infoRow(label: String, value: String, icon: String, isLast: Bool) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.18)).frame(width: 32, height: 32)
                Image(systemName: icon).font(.system(size: 13)).foregroundColor(Color(red: 0.95, green: 0.55, blue: 0.80))
            }
            Text(label).font(.system(size: 14, weight: .medium)).foregroundColor(Color.white.opacity(0.50))
            Spacer()
            Text(value).font(.system(size: 14, weight: .semibold)).foregroundColor(.white).lineLimit(1)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .overlay(
            Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1).padding(.leading, 62),
            alignment: isLast ? .top : .bottom
        )
    }

    // MARK: - Settings Card

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("SETTINGS")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(red: 0.80, green: 0.65, blue: 1.0)).tracking(1.5)
                .padding(.bottom, 12)

            VStack(spacing: 0) {
                settingsRow(title: "Edit Profile",      icon: "pencil",                    bg: Color(red: 0.45, green: 0.18, blue: 0.88), isLast: false, isDestructive: false) { showEditSheet = true }
                settingsRow(title: "Reminders",         icon: "bell.fill",                 bg: Color(red: 0.90, green: 0.25, blue: 0.55), isLast: false, isDestructive: false) { }
                settingsRow(title: "Privacy",           icon: "lock.shield.fill",          bg: Color(red: 0.28, green: 0.58, blue: 0.95), isLast: false, isDestructive: false) { }
                settingsRow(title: "Rate the App ⭐",   icon: "star.fill",                 bg: Color(red: 1.0,  green: 0.52, blue: 0.20), isLast: false, isDestructive: false) { }
                settingsRow(title: "Sign Out",          icon: "arrow.backward.circle.fill", bg: Color(red: 0.65, green: 0.15, blue: 0.15), isLast: true,  isDestructive: true)  { authVM.logout() }
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
    }

    private func settingsRow(title: String, icon: String, bg: Color, isLast: Bool, isDestructive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9).fill(bg.opacity(0.25)).frame(width: 36, height: 36)
                    Image(systemName: icon).font(.system(size: 15, weight: .medium))
                        .foregroundColor(isDestructive ? Color(red: 1.0, green: 0.45, blue: 0.45) : .white)
                }
                Text(title).font(.system(size: 15, weight: .medium))
                    .foregroundColor(isDestructive ? Color(red: 1.0, green: 0.45, blue: 0.45) : .white)
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.20))
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            .overlay(
                Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1).padding(.leading, 66),
                alignment: isLast ? .top : .bottom
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Edit Profile Sheet

    private var editProfileSheet: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.06, green: 0.04, blue: 0.12).ignoresSafeArea()
                VStack(spacing: 22) {
                    Text("Edit Profile").font(.system(size: 22, weight: .bold, design: .rounded)).foregroundColor(.white).padding(.top, 20)

                    VStack(spacing: 16) {
                        profileField(label: "Name", placeholder: "Your name", text: $editName)
                        profileField(label: "Age",  placeholder: "Your age",  text: $editAge, keyboard: .numberPad)
                    }

                    Button(action: {
                        if !editName.isEmpty { userName = editName }
                        if !editAge.isEmpty  { userAge  = editAge  }
                        showEditSheet = false
                    }) {
                        Text("Save Changes").font(.system(size: 17, weight: .bold, design: .rounded)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 54)
                            .background(LinearGradient(
                                colors: [Color(red: 0.90, green: 0.25, blue: 0.55), Color(red: 0.45, green: 0.18, blue: 0.88)],
                                startPoint: .leading, endPoint: .trailing
                            ))
                            .cornerRadius(16)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { showEditSheet = false }
                        .foregroundColor(Color(red: 0.80, green: 0.65, blue: 1.0))
                }
            }
            .onAppear { editName = userName; editAge = userAge }
        }
    }

    private func profileField(label: String, placeholder: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.system(size: 13, weight: .semibold)).foregroundColor(Color.white.opacity(0.60))
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .font(.system(size: 16)).foregroundColor(.white)
                .padding(14)
                .background(Color.white.opacity(0.07))
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.35), lineWidth: 1))
        }
    }
}

#Preview { ProfileView().environmentObject(AuthViewModel()) }
