//
//  HomeView.swift
//  Hair AI
//

import SwiftUI

struct HomeView: View {

    @Binding var selectedTab: Int
    @StateObject private var hk = HealthKitService.shared
    @State private var showHealthSettings = false

    // ── Daily wellness (auto-reset each day) ─────────────────────────────
    @AppStorage("waterGlasses")       private var waterGlasses      = 0
    @AppStorage("waterDate")          private var waterDate          = ""
    @AppStorage("sleepHours")         private var sleepHours         = 7.0
    @AppStorage("stressLevel")        private var stressLevel        = 1
    @AppStorage("checkOilMassage")    private var checkOilMassage    = false
    @AppStorage("checkVitamins")      private var checkVitamins      = false
    @AppStorage("checkHydration")     private var checkHydration     = false
    @AppStorage("checkScalpMassage")  private var checkScalpMassage  = false
    @AppStorage("streakDays")         private var streakDays         = 0
    @AppStorage("lastActiveDate")     private var lastActiveDate     = ""
    @AppStorage("userName")           private var userName           = ""
    @AppStorage("currentHairLength")  private var currentHairLength  = 0.0
    @AppStorage("hairLengthGoal")     private var hairLengthGoal     = 30.0

    @State private var animateScore  = false
    @State private var animateCards  = false

    // ── Computed helpers ──────────────────────────────────────────────────
    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 12 { return "Good Morning" }
        if h < 17 { return "Good Afternoon" }
        return "Good Evening"
    }

    private var lastScore: Int {
        ScanHistoryManager.shared.getLastScan()?.score ?? 0
    }

    private var hasDoneFirstScan: Bool {
        ScanHistoryManager.shared.totalScans > 0
    }

    private var scorePercent: Double { Double(lastScore) / 100.0 }

    private var scoreLabel: String {
        switch lastScore {
        case 85...100: return "Excellent ✨"
        case 70...84:  return "Good Condition"
        case 50...69:  return "Needs Care"
        default:       return "Needs Attention"
        }
    }

    private var waterProgress: Double { min(Double(waterGlasses) / 8.0, 1.0) }

    private var checklistDone: Int {
        [checkOilMassage, checkVitamins, checkHydration, checkScalpMassage].filter { $0 }.count
    }
    private var checklistProgress: Double { Double(checklistDone) / 4.0 }

    private var growthProgress: Double {
        guard hairLengthGoal > 0, currentHairLength > 0 else { return 0 }
        return min(currentHairLength / hairLengthGoal, 1.0)
    }

    private var todayTip: (emoji: String, title: String, body: String) {
        let tips: [(String, String, String)] = [
            ("🫧", "Scalp Massage", "Massage your scalp for 5 minutes today to boost blood circulation and stimulate hair growth."),
            ("💧", "Stay Hydrated", "Drinking 8+ glasses of water daily keeps your scalp moisturized and hair healthy from the inside out."),
            ("🥚", "Biotin Boost", "Eggs are rich in biotin and protein — the building blocks of strong, thick hair. Have them for breakfast!"),
            ("🌿", "Rosemary Oil", "Apply a few drops of rosemary oil to your scalp. Studies show it works as well as minoxidil for growth."),
            ("😴", "Prioritise Sleep", "7-9 hours of quality sleep allows your body to repair hair follicles and produce growth hormones overnight."),
            ("☀️", "Vitamin D", "Get 15 minutes of sunlight today. Vitamin D deficiency is a leading cause of hair thinning and loss."),
            ("🥦", "Iron Rich Foods", "Eat spinach, lentils, or red meat today — iron deficiency is one of the top causes of hair shedding.")
        ]
        let day = Calendar.current.component(.weekday, from: Date())
        return tips[day % tips.count]
    }

    // ── Body ──────────────────────────────────────────────────────────────
    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.04, blue: 0.12).ignoresSafeArea()

            Circle()
                .fill(Color(red: 0.45, green: 0.18, blue: 0.88).opacity(0.35))
                .frame(width: 380, height: 380).blur(radius: 95)
                .offset(x: 150, y: -200).ignoresSafeArea()
            Circle()
                .fill(Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.28))
                .frame(width: 300, height: 300).blur(radius: 85)
                .offset(x: -120, y: 80).ignoresSafeArea()
            Circle()
                .fill(Color(red: 0.10, green: 0.78, blue: 0.55).opacity(0.18))
                .frame(width: 240, height: 240).blur(radius: 75)
                .offset(x: 90, y: 380).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {

                    headerSection
                        .opacity(animateCards ? 1 : 0).offset(y: animateCards ? 0 : 10)
                        .animation(.easeOut(duration: 0.5), value: animateCards)

                    scoreCard
                        .opacity(animateCards ? 1 : 0).offset(y: animateCards ? 0 : 16)
                        .animation(.easeOut(duration: 0.5).delay(0.05), value: animateCards)

                    wellnessCard
                        .opacity(animateCards ? 1 : 0).offset(y: animateCards ? 0 : 16)
                        .animation(.easeOut(duration: 0.5).delay(0.10), value: animateCards)

                    checklistCard
                        .opacity(animateCards ? 1 : 0).offset(y: animateCards ? 0 : 16)
                        .animation(.easeOut(duration: 0.5).delay(0.14), value: animateCards)

                    if hairLengthGoal > 0 {
                        growthGoalCard
                            .opacity(animateCards ? 1 : 0).offset(y: animateCards ? 0 : 16)
                            .animation(.easeOut(duration: 0.5).delay(0.17), value: animateCards)
                    }

                    quickActionsSection
                        .opacity(animateCards ? 1 : 0).offset(y: animateCards ? 0 : 16)
                        .animation(.easeOut(duration: 0.5).delay(0.20), value: animateCards)

                    tipOfDayCard
                        .opacity(animateCards ? 1 : 0).offset(y: animateCards ? 0 : 16)
                        .animation(.easeOut(duration: 0.5).delay(0.24), value: animateCards)

                    tipsCarousel
                        .opacity(animateCards ? 1 : 0).offset(y: animateCards ? 0 : 16)
                        .animation(.easeOut(duration: 0.5).delay(0.28), value: animateCards)

                    didYouKnowCard
                        .opacity(animateCards ? 1 : 0).offset(y: animateCards ? 0 : 16)
                        .animation(.easeOut(duration: 0.5).delay(0.32), value: animateCards)

                    appleHealthCard
                        .opacity(animateCards ? 1 : 0).offset(y: animateCards ? 0 : 16)
                        .animation(.easeOut(duration: 0.5).delay(0.36), value: animateCards)

                    Spacer().frame(height: 110)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showHealthSettings) {
            HealthAndNotificationsView()
        }
        .onAppear {
            resetDailyDataIfNeeded()
            updateStreak()
            withAnimation { animateCards = true; animateScore = true }
            if hk.isAuthorized { hk.fetchAll() }
        }
    }

    // MARK: - Apple Health Card

    private var appleHealthCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.08), lineWidth: 1))

            VStack(spacing: 14) {
                // Header
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill").font(.system(size: 16))
                            .foregroundColor(Color(red: 0.95, green: 0.35, blue: 0.45))
                        Text("Apple Health").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                        if hk.isAuthorized {
                            Text("⌚ Live").font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color(red: 0.20, green: 0.90, blue: 0.55))
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(Capsule().fill(Color(red: 0.20, green: 0.90, blue: 0.55).opacity(0.15)))
                        }
                    }
                    Spacer()
                    Button(action: { showHealthSettings = true }) {
                        Text(hk.isAuthorized ? "Details →" : "Connect →")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 0.90, green: 0.55, blue: 0.80))
                    }
                    .buttonStyle(.plain)
                }

                if hk.isAuthorized {
                    // Live stats grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                        miniHealthStat(emoji: "😴", value: hk.sleepHours > 0 ? String(format: "%.1fh", hk.sleepHours) : "--", label: "Sleep",
                                       color: Color(red: 0.55, green: 0.25, blue: 0.88))
                        miniHealthStat(emoji: "👟", value: hk.steps > 0 ? "\(hk.steps / 1000)K" : "--", label: "Steps",
                                       color: Color(red: 0.20, green: 0.80, blue: 0.50))
                        miniHealthStat(emoji: "❤️", value: hk.heartRate > 0 ? "\(Int(hk.heartRate))" : "--", label: "BPM",
                                       color: Color(red: 0.95, green: 0.35, blue: 0.45))
                        miniHealthStat(emoji: "💧", value: hk.waterLiters > 0 ? String(format: "%.1fL", hk.waterLiters) : "--", label: "Water",
                                       color: Color(red: 0.20, green: 0.65, blue: 0.95))
                        miniHealthStat(emoji: "🔥", value: hk.activeCalories > 0 ? "\(Int(hk.activeCalories))" : "--", label: "kcal",
                                       color: Color(red: 0.95, green: 0.55, blue: 0.15))
                        miniHealthStat(emoji: "🧠", value: hk.stressLevel, label: "Stress",
                                       color: Color(red: 0.90, green: 0.25, blue: 0.55))
                    }

                    // AI insight strip
                    let insight = hk.sleepInsight
                    HStack(spacing: 10) {
                        Text(insight.emoji).font(.system(size: 18))
                        Text(insight.text).font(.system(size: 12)).foregroundColor(.white.opacity(0.78)).lineLimit(2)
                        Spacer()
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 14).fill(insight.color.opacity(0.12))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(insight.color.opacity(0.25), lineWidth: 1)))

                } else {
                    // Not connected — prompt
                    HStack(spacing: 14) {
                        Text("❤️\n⌚\n💧").font(.system(size: 20)).multilineTextAlignment(.center)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Connect for AI-powered insights").font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                            Text("Sleep, steps, heart rate, HRV & water from Apple Watch — all powering your hair health score")
                                .font(.system(size: 11)).foregroundColor(Color.white.opacity(0.55)).lineLimit(3)
                        }
                        Spacer()
                    }
                    Button(action: { showHealthSettings = true }) {
                        HStack {
                            Image(systemName: "heart.fill").font(.system(size: 14))
                            Text("Connect Apple Health")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                        .background(LinearGradient(colors: [Color(red: 0.95, green: 0.30, blue: 0.45),
                                                             Color(red: 0.70, green: 0.15, blue: 0.50)],
                                                   startPoint: .leading, endPoint: .trailing))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
    }

    private func miniHealthStat(emoji: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(emoji).font(.system(size: 18))
            Text(value).font(.system(size: 15, weight: .bold)).foregroundColor(.white).lineLimit(1).minimumScaleFactor(0.7)
            Text(label).font(.system(size: 9)).foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 12).fill(color.opacity(0.10)))
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(red: 0.80, green: 0.65, blue: 1.0))
                    .tracking(1.8)
                Text(userName.isEmpty ? "Welcome Back! 👋" : userName)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(LinearGradient(
                        colors: [.white, Color(red: 0.90, green: 0.80, blue: 1.0)],
                        startPoint: .leading, endPoint: .trailing
                    ))
            }
            Spacer()
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(red: 1.0, green: 0.50, blue: 0.18), Color(red: 0.95, green: 0.72, blue: 0.08)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 50, height: 50)
                        .shadow(color: Color(red: 0.90, green: 0.40, blue: 0.12).opacity(0.55), radius: 10, y: 4)
                    Text("🔥")
                        .font(.system(size: 24))
                }
                Text("\(streakDays) day\(streakDays == 1 ? "" : "s")")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.82, blue: 0.45))
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Score Card

    private var scoreCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(LinearGradient(
                    colors: [Color(red: 0.70, green: 0.18, blue: 0.52),
                             Color(red: 0.38, green: 0.14, blue: 0.82),
                             Color(red: 0.12, green: 0.45, blue: 0.82)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
            RoundedRectangle(cornerRadius: 30)
                .fill(LinearGradient(
                    colors: [Color.white.opacity(0.18), .clear],
                    startPoint: .topLeading, endPoint: .center
                ))
            Circle().fill(Color.white.opacity(0.06)).frame(width: 230).offset(x: 110, y: -70)
            Circle().fill(Color.white.opacity(0.04)).frame(width: 140).offset(x: -80, y: 80)

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("HAIR HEALTH SCORE")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.70))
                        .tracking(2.0)

                    if !hasDoneFirstScan {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("—")
                                .font(.system(size: 60, weight: .heavy, design: .rounded))
                                .foregroundColor(.white.opacity(0.40))
                            Button(action: { selectedTab = 3 }) {
                                Text("Take your first scan →")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14).padding(.vertical, 7)
                                    .background(Color.white.opacity(0.20))
                                    .clipShape(Capsule())
                            }
                        }
                    } else {
                        Text("\(lastScore)%")
                            .font(.system(size: 68, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .white.opacity(0.20), radius: 16)
                            .scaleEffect(animateScore ? 1.0 : 0.75)
                            .opacity(animateScore ? 1.0 : 0)
                            .animation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.2), value: animateScore)

                        HStack(spacing: 6) {
                            Image(systemName: "sparkles").font(.system(size: 12))
                                .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.40))
                            Text(scoreLabel).font(.system(size: 13, weight: .semibold)).foregroundColor(.white.opacity(0.92))
                        }
                        .padding(.horizontal, 14).padding(.vertical, 7)
                        .background(Color.white.opacity(0.18)).clipShape(Capsule())
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.20)).frame(height: 5)
                            Capsule()
                                .fill(LinearGradient(
                                    colors: [Color(red: 1.0, green: 0.80, blue: 0.40), .white],
                                    startPoint: .leading, endPoint: .trailing
                                ))
                                .frame(width: animateScore ? geo.size.width * CGFloat(scorePercent) : 0, height: 5)
                                .animation(.easeOut(duration: 1.0).delay(0.4), value: animateScore)
                        }
                    }
                    .frame(height: 5).padding(.top, 6)
                }

                Spacer()

                ZStack {
                    Circle().stroke(Color.white.opacity(0.18), lineWidth: 8).frame(width: 84, height: 84)
                    Circle()
                        .trim(from: 0, to: animateScore ? CGFloat(scorePercent) : 0)
                        .stroke(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.80, blue: 0.40), .white],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 84, height: 84)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 1.2).delay(0.3), value: animateScore)
                    Text(hasDoneFirstScan ? "\(lastScore)" : "—")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 26).padding(.vertical, 30)
        }
        .frame(maxWidth: .infinity)
        .shadow(color: Color(red: 0.55, green: 0.10, blue: 0.45).opacity(0.55), radius: 32, y: 14)
    }

    // MARK: - Wellness Card

    private var wellnessCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Wellness")
                    .font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(.white)
                Spacer()
                Text("Tap to update")
                    .font(.system(size: 11)).foregroundColor(Color.white.opacity(0.35))
            }

            HStack(spacing: 8) {
                wellnessRing(icon: "drop.fill", title: "Water", value: "\(waterGlasses)/8",
                             progress: waterProgress, color: Color(red: 0.28, green: 0.58, blue: 0.95)) {
                    withAnimation(.spring()) { if waterGlasses < 10 { waterGlasses += 1 } }
                }
                wellnessRing(icon: "moon.fill", title: "Sleep", value: String(format: "%.0fh", sleepHours),
                             progress: sleepHours / 9.0, color: Color(red: 0.60, green: 0.38, blue: 0.95)) {
                    withAnimation(.spring()) { sleepHours = sleepHours >= 9 ? 5 : sleepHours + 0.5 }
                }
                wellnessRing(icon: "brain.head.profile", title: "Stress",
                             value: ["Low", "Med", "High"][stressLevel],
                             progress: Double(stressLevel + 1) / 3.0,
                             color: [Color(red: 0.10, green: 0.78, blue: 0.55), Color(red: 0.95, green: 0.72, blue: 0.08), Color(red: 0.90, green: 0.30, blue: 0.30)][stressLevel]) {
                    withAnimation(.spring()) { stressLevel = (stressLevel + 1) % 3 }
                }
                wellnessRing(icon: "pill.fill", title: "Vitamins",
                             value: checkVitamins ? "Done!" : "Take",
                             progress: checkVitamins ? 1.0 : 0.0, color: Color(red: 0.90, green: 0.50, blue: 0.18)) {
                    withAnimation(.spring()) { checkVitamins.toggle() }
                }
            }

            // Water bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "drop.fill").font(.system(size: 11)).foregroundColor(Color(red: 0.28, green: 0.58, blue: 0.95))
                    Text("Daily Water Goal").font(.system(size: 12, weight: .medium)).foregroundColor(Color.white.opacity(0.60))
                    Spacer()
                    Text("\(waterGlasses)/8 glasses").font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                }
                GeometryReader { g in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.08)).frame(height: 8)
                        Capsule()
                            .fill(LinearGradient(
                                colors: [Color(red: 0.28, green: 0.58, blue: 0.95), Color(red: 0.10, green: 0.78, blue: 0.85)],
                                startPoint: .leading, endPoint: .trailing
                            ))
                            .frame(width: g.size.width * CGFloat(waterProgress), height: 8)
                            .animation(.easeOut(duration: 0.5), value: waterProgress)
                    }
                }.frame(height: 8)
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.05))
        .cornerRadius(22)
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }

    private func wellnessRing(icon: String, title: String, value: String, progress: Double, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle().stroke(Color.white.opacity(0.10), lineWidth: 4).frame(width: 54, height: 54)
                    Circle()
                        .trim(from: 0, to: min(progress, 1.0))
                        .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 54, height: 54).rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 0.5), value: progress)
                    Image(systemName: icon).font(.system(size: 14, weight: .semibold)).foregroundColor(color)
                }
                Text(title).font(.system(size: 10, weight: .medium)).foregroundColor(Color.white.opacity(0.45))
                Text(value).font(.system(size: 10, weight: .bold)).foregroundColor(.white).lineLimit(1).minimumScaleFactor(0.7)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Checklist Card

    private var checklistCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today's Hair Routine")
                        .font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(.white)
                    Text("Build healthy habits every day").font(.system(size: 11)).foregroundColor(Color.white.opacity(0.38))
                }
                Spacer()
                ZStack {
                    Circle().stroke(Color.white.opacity(0.12), lineWidth: 3).frame(width: 38, height: 38)
                    Circle()
                        .trim(from: 0, to: checklistProgress)
                        .stroke(
                            LinearGradient(colors: [Color(red: 0.90, green: 0.25, blue: 0.55), Color(red: 0.45, green: 0.18, blue: 0.88)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 38, height: 38).rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 0.4), value: checklistProgress)
                    Text("\(checklistDone)/4").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                }
            }
            VStack(spacing: 10) {
                checklistRow(title: "Oil Massage", sub: "Scalp nourishment", icon: "drop.triangle.fill",
                             color: Color(red: 0.90, green: 0.50, blue: 0.18), binding: $checkOilMassage)
                checklistRow(title: "Take Vitamins", sub: "Biotin, D3, Iron", icon: "pill.fill",
                             color: Color(red: 0.60, green: 0.38, blue: 0.95), binding: $checkVitamins)
                checklistRow(title: "Stay Hydrated", sub: "8 glasses of water", icon: "drop.fill",
                             color: Color(red: 0.28, green: 0.58, blue: 0.95), binding: $checkHydration)
                checklistRow(title: "Scalp Massage", sub: "5 min circular motion", icon: "hands.sparkles.fill",
                             color: Color(red: 0.90, green: 0.25, blue: 0.55), binding: $checkScalpMassage)
            }

            if checklistDone == 4 {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill").foregroundColor(Color(red: 1.0, green: 0.82, blue: 0.20))
                    Text("Perfect routine day! 🎉").font(.system(size: 13, weight: .semibold)).foregroundColor(Color(red: 1.0, green: 0.82, blue: 0.20))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color(red: 0.95, green: 0.72, blue: 0.08).opacity(0.10))
                .cornerRadius(12)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.05))
        .cornerRadius(22)
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }

    private func checklistRow(title: String, sub: String, icon: String, color: Color, binding: Binding<Bool>) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) { binding.wrappedValue.toggle() }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9).fill(color.opacity(0.18)).frame(width: 36, height: 36)
                    Image(systemName: icon).font(.system(size: 14, weight: .semibold)).foregroundColor(color)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.system(size: 14, weight: .semibold))
                        .foregroundColor(binding.wrappedValue ? Color.white.opacity(0.35) : .white)
                        .strikethrough(binding.wrappedValue, color: Color.white.opacity(0.35))
                    Text(sub).font(.system(size: 11)).foregroundColor(Color.white.opacity(0.35))
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(binding.wrappedValue ? Color(red: 0.10, green: 0.78, blue: 0.55) : Color.white.opacity(0.10))
                        .frame(width: 24, height: 24)
                    if binding.wrappedValue {
                        Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Hair Growth Goal Card

    private var growthGoalCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hair Growth Goal")
                        .font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(.white)
                    Text("Track your journey to \(Int(hairLengthGoal)) cm")
                        .font(.system(size: 11)).foregroundColor(Color.white.opacity(0.40))
                }
                Spacer()
                Text(String(format: "%.0f%%", growthProgress * 100))
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(LinearGradient(
                        colors: [Color(red: 0.10, green: 0.78, blue: 0.55), Color(red: 0.28, green: 0.58, blue: 0.95)],
                        startPoint: .leading, endPoint: .trailing
                    ))
            }
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.10)).frame(height: 10)
                    Capsule()
                        .fill(LinearGradient(
                            colors: [Color(red: 0.10, green: 0.78, blue: 0.55), Color(red: 0.28, green: 0.58, blue: 0.95)],
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .frame(width: g.size.width * CGFloat(growthProgress), height: 10)
                        .animation(.easeOut(duration: 0.8), value: growthProgress)
                }
            }.frame(height: 10)

            HStack {
                Label(String(format: "%.1f cm", currentHairLength), systemImage: "ruler")
                    .font(.system(size: 12, weight: .medium)).foregroundColor(Color.white.opacity(0.55))
                Spacer()
                Label(String(format: "Goal: %.0f cm", hairLengthGoal), systemImage: "flag.fill")
                    .font(.system(size: 12, weight: .medium)).foregroundColor(Color.white.opacity(0.55))
            }
        }
        .padding(18)
        .background(LinearGradient(
            colors: [Color(red: 0.06, green: 0.28, blue: 0.20), Color(red: 0.06, green: 0.18, blue: 0.35)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        ))
        .cornerRadius(22)
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color(red: 0.10, green: 0.78, blue: 0.55).opacity(0.30), lineWidth: 1))
        .shadow(color: Color(red: 0.06, green: 0.35, blue: 0.25).opacity(0.40), radius: 16, y: 8)
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Quick Actions")
                .font(.system(size: 18, weight: .bold, design: .rounded)).foregroundColor(.white)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                quickCard(icon: "camera.fill", title: "AI Hair Scan", sub: "Analyze now",
                          gradient: [Color(red: 0.90, green: 0.25, blue: 0.55), Color(red: 0.65, green: 0.10, blue: 0.78)],
                          shadow: Color(red: 0.80, green: 0.15, blue: 0.50)) { selectedTab = 3 }

                quickCard(icon: "chart.line.uptrend.xyaxis", title: "Growth Tracker", sub: "Log length",
                          gradient: [Color(red: 0.10, green: 0.62, blue: 0.42), Color(red: 0.05, green: 0.42, blue: 0.72)],
                          shadow: Color(red: 0.08, green: 0.50, blue: 0.38)) { selectedTab = 3 }

                quickCard(icon: "leaf.fill", title: "Diet & Nutrition", sub: "Hair superfoods",
                          gradient: [Color(red: 0.35, green: 0.62, blue: 0.12), Color(red: 0.12, green: 0.48, blue: 0.30)],
                          shadow: Color(red: 0.28, green: 0.52, blue: 0.10)) { selectedTab = 2 }

                quickCard(icon: "person.fill", title: "My Profile", sub: "Achievements",
                          gradient: [Color(red: 1.0, green: 0.46, blue: 0.18), Color(red: 0.95, green: 0.72, blue: 0.08)],
                          shadow: Color(red: 0.90, green: 0.40, blue: 0.12)) { selectedTab = 4 }
            }
        }
    }

    private func quickCard(icon: String, title: String, sub: String, gradient: [Color], shadow: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    Circle().fill(Color.white.opacity(0.22)).frame(width: 48, height: 48)
                    Image(systemName: icon).font(.system(size: 20, weight: .semibold)).foregroundColor(.white)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.white).lineLimit(1)
                    Text(sub).font(.system(size: 12, weight: .medium)).foregroundColor(.white.opacity(0.70)).lineLimit(1)
                }
                HStack { Spacer(); Image(systemName: "arrow.right").font(.system(size: 11, weight: .bold)).foregroundColor(.white.opacity(0.60)) }
                    .padding(.top, 8)
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 148, alignment: .leading)
            .background(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
            .cornerRadius(24)
            .overlay(RoundedRectangle(cornerRadius: 24).fill(LinearGradient(colors: [Color.white.opacity(0.16), .clear], startPoint: .topLeading, endPoint: .center)))
            .shadow(color: shadow.opacity(0.45), radius: 18, y: 8)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tip of Day

    private var tipOfDayCard: some View {
        HStack(spacing: 16) {
            Text(todayTip.emoji)
                .font(.system(size: 36))
                .frame(width: 68, height: 68)
                .background(Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.15))
                .cornerRadius(18)

            VStack(alignment: .leading, spacing: 5) {
                Text("TIP OF THE DAY")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color(red: 0.90, green: 0.25, blue: 0.55))
                    .tracking(1.2)
                Text(todayTip.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.white)
                Text(todayTip.body)
                    .font(.system(size: 12)).foregroundColor(Color.white.opacity(0.52))
                    .fixedSize(horizontal: false, vertical: true).lineLimit(3)
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.05))
        .cornerRadius(22)
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.22), lineWidth: 1))
    }

    // MARK: - Tips Carousel

    private var tipsCarousel: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Hair Care Tips")
                    .font(.system(size: 18, weight: .bold, design: .rounded)).foregroundColor(.white)
                Spacer()
                Text("Swipe →").font(.system(size: 11)).foregroundColor(Color.white.opacity(0.28))
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    tipCard(emoji: "🫧", title: "Scalp Massage", sub: "5 min daily circulation boost", color: Color(red: 0.90, green: 0.25, blue: 0.55))
                    tipCard(emoji: "🧴", title: "Right Shampoo", sub: "Match your hair type always", color: Color(red: 0.45, green: 0.18, blue: 0.88))
                    tipCard(emoji: "💧", title: "Hydration", sub: "8 glasses keeps scalp moisturised", color: Color(red: 0.28, green: 0.58, blue: 0.95))
                    tipCard(emoji: "🥚", title: "Biotin Foods", sub: "Eggs, nuts for strong hair shaft", color: Color(red: 1.0, green: 0.75, blue: 0.25))
                    tipCard(emoji: "🌿", title: "Rosemary Oil", sub: "Clinically proven growth booster", color: Color(red: 0.10, green: 0.78, blue: 0.52))
                    tipCard(emoji: "😴", title: "Sleep Well", sub: "7-9 hrs for follicle repair", color: Color(red: 0.60, green: 0.38, blue: 0.95))
                    tipCard(emoji: "☀️", title: "Vitamin D", sub: "15 min sun prevents hair loss", color: Color(red: 1.0, green: 0.52, blue: 0.20))
                    tipCard(emoji: "🎯", title: "Gentle Brush", sub: "Wide-tooth comb on wet hair", color: Color(red: 0.55, green: 0.80, blue: 0.30))
                }
                .padding(.bottom, 4)
            }
        }
    }

    private func tipCard(emoji: String, title: String, sub: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(emoji).font(.system(size: 32)).frame(width: 54, height: 54).background(color.opacity(0.18)).cornerRadius(14)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(.white)
                Text(sub).font(.system(size: 12)).foregroundColor(Color.white.opacity(0.55)).fixedSize(horizontal: false, vertical: true).lineLimit(2)
            }
        }
        .padding(16)
        .frame(width: 168)
        .background(Color.white.opacity(0.07))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(color.opacity(0.28), lineWidth: 1))
    }

    // MARK: - Did You Know Card

    private var didYouKnowCard: some View {
        let facts = [
            "Hair grows about 15 cm (6 inches) per year on average.",
            "Your hair is the second fastest growing tissue in the body after bone marrow.",
            "A single strand of hair can support up to 100 grams of weight.",
            "Hair is made of keratin — the same protein that forms your nails.",
            "The average person has 100,000–150,000 hair follicles on their scalp.",
            "Hair grows fastest in warm weather and during sleep.",
            "Scalp massage for just 4 minutes a day can increase hair thickness."
        ]
        let day = Calendar.current.component(.day, from: Date())
        let fact = facts[day % facts.count]

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color(red: 0.90, green: 0.25, blue: 0.55), Color(red: 0.45, green: 0.18, blue: 0.88)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: 44, height: 44)
                Text("💡").font(.system(size: 20))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("DID YOU KNOW?")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color(red: 0.80, green: 0.65, blue: 1.0)).tracking(1.2)
                Text(fact)
                    .font(.system(size: 13)).foregroundColor(Color.white.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.05))
        .cornerRadius(22)
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color(red: 0.45, green: 0.18, blue: 0.88).opacity(0.22), lineWidth: 1))
    }

    // MARK: - Daily Reset & Streak

    private func resetDailyDataIfNeeded() {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        if waterDate != today {
            waterDate    = today
            waterGlasses = 0
            checkOilMassage   = false
            checkHydration    = false
            checkScalpMassage = false
        }
    }

    private func updateStreak() {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        if lastActiveDate == today { return }
        let yesterday = DateFormatter.localizedString(from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, dateStyle: .short, timeStyle: .none)
        if lastActiveDate == yesterday {
            streakDays += 1
        } else if lastActiveDate.isEmpty {
            streakDays = 1
        } else {
            streakDays = 1
        }
        lastActiveDate = today
    }
}

#Preview { HomeView(selectedTab: .constant(0)) }
