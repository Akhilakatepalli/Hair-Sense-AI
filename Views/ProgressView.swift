//
//  ProgressView.swift
//  Hair AI
//

import SwiftUI
import Charts

// MARK: - Hair Length Entry Model

struct HairLengthEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    let lengthCm: Double
    let note: String
}

// MARK: - HairProgressView
// Renamed from ProgressView to avoid shadowing SwiftUI.ProgressView

struct HairProgressView: View {

    @AppStorage("streakDays")         private var streakDays   = 0
    @AppStorage("hairLengthGoal")     private var hairLengthGoal: Double = 30.0
    @AppStorage("currentHairLength")  private var currentHairLength: Double = 0.0

    @State private var animateChart        = false
    @State private var animateCards        = false
    @State private var beforeImage: UIImage? = nil
    @State private var afterImage: UIImage?  = nil
    @State private var showBeforePicker    = false
    @State private var showAfterPicker     = false
    @State private var isComparing         = false
    @State private var comparisonResult    = ""
    @State private var newLengthText       = ""
    @State private var newLengthNote       = ""
    @State private var showAddLength       = false
    @State private var showGoalSheet       = false
    @State private var goalText            = ""
    @State private var lengthUnit          = 0  // 0 = cm, 1 = inches

    private let service = HairAnalysisService()

    // ── Scan history data ─────────────────────────────────────────────────
    private var allScans: [ScanRecord] { ScanHistoryManager.shared.getAllScans() }
    private var lastScan: ScanRecord?  { allScans.last }
    private var firstScan: ScanRecord? { allScans.first }
    private var currentScore: Int      { lastScan?.score ?? 0 }

    private var improvement: Int {
        guard let f = firstScan?.score, let l = lastScan?.score else { return 0 }
        return l - f
    }

    // ── Hair length history (UserDefaults JSON) ───────────────────────────
    private var lengthHistory: [HairLengthEntry] {
        guard let data = UserDefaults.standard.data(forKey: "hairLengthHistory"),
              let decoded = try? JSONDecoder().decode([HairLengthEntry].self, from: data)
        else { return [] }
        return decoded.sorted { $0.date < $1.date }
    }

    private func addLengthEntry(_ cm: Double, note: String) {
        var history = lengthHistory
        history.append(HairLengthEntry(id: UUID(), date: Date(), lengthCm: cm, note: note))
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "hairLengthHistory")
        }
        currentHairLength = cm
    }

    private func deleteLengthEntry(_ entry: HairLengthEntry) {
        var history = lengthHistory
        history.removeAll { $0.id == entry.id }
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "hairLengthHistory")
        }
    }

    // ── Colour helpers ────────────────────────────────────────────────────
    private var scoreColor: Color {
        switch currentScore {
        case 80...100: return Color(red: 0.10, green: 0.78, blue: 0.55)
        case 60...79:  return Color(red: 0.50, green: 0.85, blue: 1.0)
        case 40...59:  return Color(red: 1.0,  green: 0.82, blue: 0.45)
        default:       return Color(red: 1.0,  green: 0.55, blue: 0.55)
        }
    }

    private var scoreGradient: [Color] {
        switch currentScore {
        case 80...100: return [Color(red: 0.05, green: 0.45, blue: 0.30), Color(red: 0.10, green: 0.62, blue: 0.45)]
        case 60...79:  return [Color(red: 0.18, green: 0.35, blue: 0.85), Color(red: 0.05, green: 0.55, blue: 0.70)]
        case 40...59:  return [Color(red: 0.55, green: 0.30, blue: 0.05), Color(red: 0.72, green: 0.48, blue: 0.10)]
        default:       return [Color(red: 0.65, green: 0.15, blue: 0.15), Color(red: 0.85, green: 0.30, blue: 0.20)]
        }
    }

    private var scoreLabel: String {
        switch currentScore {
        case 80...100: return "Excellent 🌿"
        case 60...79:  return "Good Condition"
        case 40...59:  return "Needs Care"
        default:       return "No Scans Yet"
        }
    }

    // ── Achievements ──────────────────────────────────────────────────────
    private struct Achievement {
        let icon: String; let title: String; let desc: String
        let earned: Bool; let color: Color
    }

    private var achievements: [Achievement] {
        let scans = ScanHistoryManager.shared.totalScans
        return [
            Achievement(icon: "camera.fill",            title: "First Scan",        desc: "Complete your first AI analysis",   earned: scans >= 1,     color: Color(red: 0.90, green: 0.25, blue: 0.55)),
            Achievement(icon: "flame.fill",              title: "7-Day Streak",      desc: "Use the app 7 days in a row",       earned: streakDays >= 7, color: Color(red: 1.0,  green: 0.50, blue: 0.18)),
            Achievement(icon: "ruler.fill",              title: "Length Logger",     desc: "Log your first hair measurement",   earned: !lengthHistory.isEmpty, color: Color(red: 0.10, green: 0.78, blue: 0.55)),
            Achievement(icon: "arrow.up.right.circle.fill", title: "Score Booster", desc: "Improve your hair score by 10+",    earned: improvement >= 10, color: Color(red: 0.28, green: 0.58, blue: 0.95)),
            Achievement(icon: "calendar.badge.checkmark", title: "Month Warrior",   desc: "Keep a 30-day streak",              earned: streakDays >= 30, color: Color(red: 0.95, green: 0.72, blue: 0.08)),
            Achievement(icon: "photo.on.rectangle.angled", title: "Before & After", desc: "Complete a photo comparison",       earned: !comparisonResult.isEmpty, color: Color(red: 0.60, green: 0.38, blue: 0.95)),
            Achievement(icon: "star.fill",               title: "Hair Champion",    desc: "Reach a hair score of 85+",         earned: currentScore >= 85, color: Color(red: 0.90, green: 0.75, blue: 0.10)),
            Achievement(icon: "trophy.fill",             title: "5 Scans Done",     desc: "Complete 5 AI hair scans",          earned: scans >= 5,       color: Color(red: 0.45, green: 0.18, blue: 0.88))
        ]
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            AnimatedTabBackground(theme: .progress)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    // ── Header ────────────────────────────────────────────
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("YOUR PROGRESS")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color(red: 0.80, green: 0.65, blue: 1.0)).tracking(2.0)
                            Text("Hair Health Journey")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(LinearGradient(
                                    colors: [.white, Color(red: 0.90, green: 0.80, blue: 1.0)],
                                    startPoint: .leading, endPoint: .trailing
                                ))
                        }
                        Spacer()
                        // Streak badge
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 1.0, green: 0.50, blue: 0.18).opacity(0.22))
                                    .frame(width: 58, height: 58)
                                    .blur(radius: 6)
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [Color(red: 1.0, green: 0.52, blue: 0.18), Color(red: 0.95, green: 0.70, blue: 0.08)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 48, height: 48)
                                    .shadow(color: Color(red: 1.0, green: 0.50, blue: 0.18).opacity(0.55), radius: 10, y: 3)
                                Text("🔥").font(.system(size: 22))
                            }
                            Text("\(streakDays)d").font(.system(size: 11, weight: .heavy))
                                .foregroundColor(Color(red: 1.0, green: 0.82, blue: 0.45))
                        }
                    }
                    .padding(.top, 10)
                    .opacity(animateCards ? 1 : 0).offset(y: animateCards ? 0 : 10)
                    .animation(.easeOut(duration: 0.5), value: animateCards)

                    // ── Stats Row ─────────────────────────────────────────
                    HStack(spacing: 12) {
                        miniStat(value: allScans.isEmpty ? "—" : "\(currentScore)%", label: "Current", icon: "star.fill", color: scoreColor)
                        miniStat(value: improvement > 0 ? "+\(improvement)%" : (improvement == 0 && !allScans.isEmpty ? "→" : "—"),
                                 label: "Improvement", icon: "arrow.up.right", color: Color(red: 0.10, green: 0.78, blue: 0.55))
                        miniStat(value: "\(allScans.count)", label: "Total Scans", icon: "camera.fill",
                                 color: Color(red: 0.50, green: 0.85, blue: 1.0))
                        miniStat(value: lengthHistory.isEmpty ? "—" : String(format: "%.0f cm", lengthHistory.last?.lengthCm ?? 0),
                                 label: "Hair Length", icon: "ruler.fill", color: Color(red: 0.90, green: 0.50, blue: 0.18))
                    }
                    .opacity(animateCards ? 1 : 0).offset(y: animateCards ? 0 : 14)
                    .animation(.easeOut(duration: 0.5).delay(0.05), value: animateCards)

                    // ── Current Score Card ────────────────────────────────
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(LinearGradient(colors: scoreGradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                        RoundedRectangle(cornerRadius: 24)
                            .fill(LinearGradient(colors: [Color.white.opacity(0.14), .clear], startPoint: .topLeading, endPoint: .center))
                        Circle().fill(Color.white.opacity(0.05)).frame(width: 180).offset(x: 100, y: -50)

                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("CURRENT SCORE")
                                    .font(.system(size: 10, weight: .semibold)).foregroundColor(.white.opacity(0.65)).tracking(2.0)
                                Text(allScans.isEmpty ? "—" : "\(currentScore)%")
                                    .font(.system(size: 56, weight: .heavy, design: .rounded)).foregroundColor(.white)
                                HStack(spacing: 5) {
                                    Image(systemName: "checkmark.seal.fill").font(.system(size: 12)).foregroundColor(scoreColor)
                                    Text(scoreLabel).font(.system(size: 13, weight: .semibold)).foregroundColor(.white.opacity(0.90))
                                }
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(Color.white.opacity(0.15)).clipShape(Capsule())
                            }
                            Spacer()
                            ZStack {
                                Circle().stroke(Color.white.opacity(0.12), lineWidth: 6).frame(width: 76, height: 76)
                                // Gradient arc ring
                                Circle()
                                    .trim(from: 0, to: animateChart ? CGFloat(currentScore) / 100.0 : 0)
                                    .stroke(
                                        AngularGradient(
                                            gradient: Gradient(colors: [Color.white.opacity(0.90), Color.white.opacity(0.30), Color.white]),
                                            center: .center,
                                            startAngle: .degrees(-90),
                                            endAngle: .degrees(270)
                                        ),
                                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                                    )
                                    .frame(width: 76, height: 76).rotationEffect(.degrees(-90))
                                    .animation(.easeOut(duration: 1.2).delay(0.4), value: animateChart)
                                    .shadow(color: Color.white.opacity(0.50), radius: 4)
                                Text(allScans.isEmpty ? "?" : "\(currentScore)")
                                    .font(.system(size: 17, weight: .heavy, design: .rounded)).foregroundColor(.white)
                            }
                        }
                        .padding(24)
                    }
                    .shadow(color: scoreGradient[0].opacity(0.45), radius: 24, y: 10)
                    .opacity(animateCards ? 1 : 0).offset(y: animateCards ? 0 : 18)
                    .animation(.easeOut(duration: 0.5).delay(0.08), value: animateCards)

                    // ── Hair Length Tracker ───────────────────────────────
                    hairLengthSection
                        .opacity(animateCards ? 1 : 0).offset(y: animateCards ? 0 : 18)
                        .animation(.easeOut(duration: 0.5).delay(0.12), value: animateCards)

                    // ── Score Chart ───────────────────────────────────────
                    if allScans.count >= 2 {
                        scoreChartSection
                            .opacity(animateCards ? 1 : 0).offset(y: animateCards ? 0 : 18)
                            .animation(.easeOut(duration: 0.5).delay(0.16), value: animateCards)
                    }

                    // ── Photo Comparison ──────────────────────────────────
                    photoComparisonSection
                        .opacity(animateCards ? 1 : 0).offset(y: animateCards ? 0 : 18)
                        .animation(.easeOut(duration: 0.5).delay(0.20), value: animateCards)

                    // ── Achievements ──────────────────────────────────────
                    achievementsSection
                        .opacity(animateCards ? 1 : 0).offset(y: animateCards ? 0 : 18)
                        .animation(.easeOut(duration: 0.5).delay(0.24), value: animateCards)

                    // ── Scan History ──────────────────────────────────────
                    if !allScans.isEmpty {
                        scanHistorySection
                            .opacity(animateCards ? 1 : 0).offset(y: animateCards ? 0 : 18)
                            .animation(.easeOut(duration: 0.5).delay(0.28), value: animateCards)
                    }

                    Spacer().frame(height: 110)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            animateCards = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { animateChart = true }
        }
        .sheet(isPresented: $showBeforePicker) { ImagePicker(image: $beforeImage, sourceType: .photoLibrary) }
        .sheet(isPresented: $showAfterPicker)  { ImagePicker(image: $afterImage,  sourceType: .photoLibrary) }
        .sheet(isPresented: $showAddLength) { addLengthSheet }
        .sheet(isPresented: $showGoalSheet) { setGoalSheet }
    }

    // MARK: - Hair Length Sub-views

    private var lengthTrackerHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Hair Length Tracker")
                    .font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(.white)
                Text("Log measurements to track growth over time")
                    .font(.system(size: 11)).foregroundColor(Color.white.opacity(0.40))
            }
            Spacer()
            Button(action: { showGoalSheet = true }) {
                Text("Set Goal")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(red: 0.10, green: 0.78, blue: 0.55))
                    .padding(.horizontal, 12).padding(.vertical, 5)
                    .background(Color(red: 0.10, green: 0.78, blue: 0.55).opacity(0.15))
                    .clipShape(Capsule())
            }
        }
    }

    private var lengthGoalBar: some View {
        let pct = min(currentHairLength / max(hairLengthGoal, 1), 1.0)
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Goal: \(String(format: "%.0f cm", hairLengthGoal))")
                    .font(.system(size: 12, weight: .semibold)).foregroundColor(Color.white.opacity(0.65))
                Spacer()
                Text(String(format: "%.0f%% there", pct * 100))
                    .font(.system(size: 12, weight: .bold)).foregroundColor(Color(red: 0.10, green: 0.78, blue: 0.55))
            }
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.08)).frame(height: 8)
                    Capsule()
                        .fill(LinearGradient(
                            colors: [Color(red: 0.10, green: 0.78, blue: 0.55), Color(red: 0.28, green: 0.58, blue: 0.95)],
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .frame(width: g.size.width * CGFloat(pct), height: 8)
                        .animation(.easeOut(duration: 0.8), value: pct)
                }
            }.frame(height: 8)
        }
        .padding(.vertical, 4)
    }

    private var lengthChart: some View {
        let greenColor = Color(red: 0.10, green: 0.78, blue: 0.55)
        let mutedColor = Color(red: 0.55, green: 0.53, blue: 0.65)
        let axisCount = max(1, lengthHistory.count / 4)
        return Chart(lengthHistory) { entry in
            AreaMark(x: .value("Date", entry.date), y: .value("cm", animateChart ? entry.lengthCm : 0))
                .foregroundStyle(LinearGradient(colors: [greenColor.opacity(0.30), .clear], startPoint: .top, endPoint: .bottom))
                .interpolationMethod(.catmullRom)
            LineMark(x: .value("Date", entry.date), y: .value("cm", animateChart ? entry.lengthCm : 0))
                .foregroundStyle(greenColor).lineStyle(StrokeStyle(lineWidth: 2.5)).interpolationMethod(.catmullRom)
            PointMark(x: .value("Date", entry.date), y: .value("cm", animateChart ? entry.lengthCm : 0))
                .foregroundStyle(.white).symbolSize(45)
        }
        .frame(height: 140)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: axisCount)) { _ in
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    .foregroundStyle(mutedColor)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine().foregroundStyle(Color.white.opacity(0.06))
                AxisValueLabel {
                    if let v = value.as(Double.self) {
                        Text("\(Int(v)) cm").font(.system(size: 10)).foregroundColor(mutedColor)
                    }
                }
            }
        }
        .animation(.easeOut(duration: 1.0).delay(0.3), value: animateChart)
    }

    private var recentLengthEntries: some View {
        let recent = Array(lengthHistory.suffix(3).reversed())
        let greenColor = Color(red: 0.10, green: 0.78, blue: 0.55)
        return VStack(spacing: 0) {
            ForEach(recent) { entry in
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8).fill(greenColor.opacity(0.15)).frame(width: 34, height: 34)
                        Image(systemName: "ruler.fill").font(.system(size: 13)).foregroundColor(greenColor)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(format: "%.1f cm", entry.lengthCm))
                            .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                        if !entry.note.isEmpty {
                            Text(entry.note).font(.system(size: 11)).foregroundColor(Color.white.opacity(0.45)).lineLimit(1)
                        }
                    }
                    Spacer()
                    Text(entry.date, format: .dateTime.month(.abbreviated).day().year())
                        .font(.system(size: 12)).foregroundColor(Color.white.opacity(0.40))
                }
                .padding(.horizontal, 14).padding(.vertical, 11)
                .overlay(Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1), alignment: .bottom)
            }
        }
        .background(Color(red: 0.08, green: 0.08, blue: 0.16))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.07), lineWidth: 1))
    }

    // MARK: - Hair Length Tracker Section

    private var hairLengthSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            lengthTrackerHeader
            if hairLengthGoal > 0 { lengthGoalBar }
            if lengthHistory.count >= 2 { lengthChart }
            if !lengthHistory.isEmpty { recentLengthEntries }

            // Add measurement button
            Button(action: { showAddLength = true }) {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill").font(.system(size: 16, weight: .semibold))
                    Text("Log Today's Length")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity).frame(height: 50)
                .background(LinearGradient(
                    colors: [Color(red: 0.10, green: 0.62, blue: 0.42), Color(red: 0.05, green: 0.42, blue: 0.72)],
                    startPoint: .leading, endPoint: .trailing
                ))
                .cornerRadius(14)
                .shadow(color: Color(red: 0.08, green: 0.50, blue: 0.38).opacity(0.45), radius: 12, y: 5)
            }
        }
        .padding(20)
        .background(Color(red: 0.10, green: 0.10, blue: 0.18))
        .cornerRadius(22)
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color(red: 0.10, green: 0.78, blue: 0.55).opacity(0.18), lineWidth: 1))
    }

    // MARK: - Score Chart Section

    private var scoreChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Hair Score Over Time")
                    .font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.white)
                Spacer()
                Text("\(allScans.count) scans")
                    .font(.system(size: 12, weight: .medium)).foregroundColor(scoreColor)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(scoreColor.opacity(0.12)).clipShape(Capsule())
            }

            Chart(Array(allScans.enumerated()), id: \.offset) { idx, scan in
                AreaMark(x: .value("Scan", idx + 1), y: .value("Score", animateChart ? scan.score : 50))
                    .foregroundStyle(LinearGradient(
                        colors: [scoreColor.opacity(0.25), scoreColor.opacity(0.0)],
                        startPoint: .top, endPoint: .bottom
                    ))
                    .interpolationMethod(.catmullRom)
                LineMark(x: .value("Scan", idx + 1), y: .value("Score", animateChart ? scan.score : 50))
                    .foregroundStyle(scoreColor)
                    .lineStyle(StrokeStyle(lineWidth: 2.5))
                    .interpolationMethod(.catmullRom)
                PointMark(x: .value("Scan", idx + 1), y: .value("Score", animateChart ? scan.score : 50))
                    .foregroundStyle(.white).symbolSize(50)
            }
            .frame(height: 180)
            .chartYScale(domain: 0...100)
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let i = value.as(Int.self) {
                            Text("S\(i)").font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color(red: 0.55, green: 0.53, blue: 0.65))
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine().foregroundStyle(Color.white.opacity(0.06))
                    AxisValueLabel {
                        if let v = value.as(Int.self) {
                            Text("\(v)").font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color(red: 0.55, green: 0.53, blue: 0.65))
                        }
                    }
                }
            }
            .animation(.easeOut(duration: 1.2).delay(0.3), value: animateChart)
        }
        .padding(20)
        .background(Color(red: 0.10, green: 0.10, blue: 0.18))
        .cornerRadius(22)
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(scoreColor.opacity(0.12), lineWidth: 1))
    }

    // MARK: - Photo Comparison Section

    private var photoComparisonSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Photo Comparison")
                    .font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.white)
                Spacer()
                Text("Before & After")
                    .font(.system(size: 12, weight: .medium)).foregroundColor(scoreColor)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(scoreColor.opacity(0.12)).clipShape(Capsule())
            }

            HStack(spacing: 12) {
                photoSlot(label: "BEFORE", image: beforeImage, color: Color(red: 0.10, green: 0.78, blue: 0.55)) { showBeforePicker = true }
                Image(systemName: "arrow.right").font(.system(size: 18, weight: .semibold))
                    .foregroundColor(scoreColor.opacity(0.60)).frame(height: 160)
                photoSlot(label: "AFTER", image: afterImage, color: scoreColor) { showAfterPicker = true }
            }

            if beforeImage != nil && afterImage != nil {
                Button(action: comparePhotos) {
                    ZStack {
                        HStack(spacing: 10) {
                            Image(systemName: "wand.and.stars").font(.system(size: 15, weight: .semibold))
                            Text("Compare with AI").font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white).opacity(isComparing ? 0 : 1)

                        if isComparing {
                            HStack(spacing: 10) {
                                ProgressView().tint(.white)
                                Text("Comparing...").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity).frame(height: 50)
                    .background(LinearGradient(
                        colors: [Color(red: 0.35, green: 0.15, blue: 0.70), Color(red: 0.10, green: 0.55, blue: 0.45)],
                        startPoint: .leading, endPoint: .trailing
                    ))
                    .cornerRadius(14)
                }
                .disabled(isComparing)

                if !comparisonResult.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "wand.and.stars").font(.system(size: 14)).foregroundColor(scoreColor)
                            Text("AI Analysis Result").font(.system(size: 13, weight: .semibold)).foregroundColor(scoreColor)
                        }
                        Text(comparisonResult)
                            .font(.system(size: 13)).foregroundColor(Color.white.opacity(0.80))
                            .lineSpacing(5).fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(14)
                    .background(Color(red: 0.05, green: 0.05, blue: 0.12))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(scoreColor.opacity(0.20), lineWidth: 1))
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .padding(20)
        .background(Color(red: 0.10, green: 0.10, blue: 0.18))
        .cornerRadius(22)
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.07), lineWidth: 1))
    }

    private func photoSlot(label: String, image: UIImage?, color: Color, action: @escaping () -> Void) -> some View {
        VStack(spacing: 8) {
            Text(label).font(.system(size: 10, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.40)).tracking(1.5)
            Button(action: action) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16).fill(Color(red: 0.10, green: 0.10, blue: 0.18))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.07), lineWidth: 1))
                    if let img = image {
                        Image(uiImage: img).resizable().scaledToFill().clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill").font(.system(size: 28))
                                .foregroundColor(color.opacity(0.60))
                            Text("Add Photo").font(.system(size: 11, weight: .medium)).foregroundColor(Color.white.opacity(0.30))
                        }
                    }
                }.frame(height: 160)
            }.buttonStyle(.plain)
        }.frame(maxWidth: .infinity)
    }

    // MARK: - Achievements Section

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Achievements")
                    .font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(.white)
                Spacer()
                let earned = achievements.filter { $0.earned }.count
                Text("\(earned)/\(achievements.count) earned")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 0.90, green: 0.72, blue: 0.20))
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color(red: 0.90, green: 0.72, blue: 0.20).opacity(0.12)).clipShape(Capsule())
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(achievements.indices, id: \.self) { i in
                    let a = achievements[i]
                    VStack(spacing: 8) {
                        ZStack {
                            if a.earned {
                                Circle()
                                    .fill(a.color.opacity(0.16))
                                    .frame(width: 56, height: 56)
                                    .shadow(color: a.color.opacity(0.45), radius: 10, y: 3)
                                Circle()
                                    .stroke(a.color.opacity(0.45), lineWidth: 1.5)
                                    .frame(width: 54, height: 54)
                            } else {
                                Circle()
                                    .fill(Color.white.opacity(0.05))
                                    .frame(width: 54, height: 54)
                            }
                            Image(systemName: a.icon)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(a.earned ? a.color : Color.white.opacity(0.15))
                            if !a.earned {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Color.white.opacity(0.22))
                                    .offset(x: 16, y: 16)
                            }
                        }
                        Text(a.title)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(a.earned ? .white : Color.white.opacity(0.28))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                }
            }

            // Achievement progress bar
            let earnedCount = Double(achievements.filter { $0.earned }.count)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Overall Progress").font(.system(size: 12)).foregroundColor(Color.white.opacity(0.50))
                    Spacer()
                    Text(String(format: "%.0f%%", earnedCount / Double(achievements.count) * 100))
                        .font(.system(size: 12, weight: .bold)).foregroundColor(Color(red: 0.90, green: 0.72, blue: 0.20))
                }
                GeometryReader { g in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.08)).frame(height: 6)
                        Capsule()
                            .fill(LinearGradient(
                                colors: [Color(red: 0.90, green: 0.72, blue: 0.20), Color(red: 1.0, green: 0.50, blue: 0.18)],
                                startPoint: .leading, endPoint: .trailing
                            ))
                            .frame(width: g.size.width * CGFloat(earnedCount / Double(achievements.count)), height: 6)
                            .animation(.easeOut(duration: 0.8), value: earnedCount)
                    }
                }.frame(height: 6)
            }
        }
        .padding(20)
        .background(Color(red: 0.10, green: 0.09, blue: 0.20))
        .cornerRadius(22)
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color(red: 0.90, green: 0.72, blue: 0.20).opacity(0.22), lineWidth: 1))
    }

    // MARK: - Scan History Section

    private var scanHistorySection: some View {
        let recentScans = Array(allScans.suffix(5).reversed())
        return VStack(alignment: .leading, spacing: 14) {
            Text("Scan History")
                .font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.white)
            VStack(spacing: 0) {
                ForEach(recentScans.indices, id: \.self) { i in
                    scanHistoryRow(scan: recentScans[i], number: allScans.count - i)
                }
            }
            .background(Color(red: 0.08, green: 0.08, blue: 0.16))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.07), lineWidth: 1))
        }
        .padding(20)
        .background(Color(red: 0.10, green: 0.10, blue: 0.18))
        .cornerRadius(22)
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.07), lineWidth: 1))
    }

    private func scanHistoryRow(scan: ScanRecord, number: Int) -> some View {
        let rowColor: Color = {
            switch scan.score {
            case 80...100: return Color(red: 0.10, green: 0.78, blue: 0.55)
            case 60...79:  return Color(red: 0.50, green: 0.85, blue: 1.0)
            case 40...59:  return Color(red: 1.0,  green: 0.82, blue: 0.45)
            default:       return Color(red: 1.0,  green: 0.55, blue: 0.55)
            }
        }()
        return HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(rowColor.opacity(0.18)).frame(width: 36, height: 36)
                Text("#\(number)").font(.system(size: 11, weight: .bold)).foregroundColor(rowColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(scan.condition).font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                Text(scan.date, format: .dateTime.month(.abbreviated).day().year())
                    .font(.system(size: 11)).foregroundColor(Color.white.opacity(0.40))
            }
            Spacer()
            Text("\(scan.score)%")
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundColor(rowColor)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .overlay(Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1).padding(.leading, 62), alignment: .bottom)
    }

    // MARK: - Sheets

    private var addLengthSheet: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.06, green: 0.04, blue: 0.12).ignoresSafeArea()
                VStack(spacing: 28) {
                    VStack(spacing: 8) {
                        Text("Log Hair Length")
                            .font(.system(size: 24, weight: .bold, design: .rounded)).foregroundColor(.white)
                        Text("Record your current hair length to track growth over time")
                            .font(.system(size: 14)).foregroundColor(Color.white.opacity(0.50))
                            .multilineTextAlignment(.center)
                    }.padding(.top, 20)

                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Length (cm)").font(.system(size: 13, weight: .semibold)).foregroundColor(Color.white.opacity(0.60))
                            TextField("e.g. 25.5", text: $newLengthText)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
                                .padding(16)
                                .background(Color.white.opacity(0.07))
                                .cornerRadius(14)
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(red: 0.10, green: 0.78, blue: 0.55).opacity(0.40), lineWidth: 1))
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Note (optional)").font(.system(size: 13, weight: .semibold)).foregroundColor(Color.white.opacity(0.60))
                            TextField("e.g. After haircut, measured from root", text: $newLengthNote)
                                .font(.system(size: 15)).foregroundColor(.white)
                                .padding(16)
                                .background(Color.white.opacity(0.07))
                                .cornerRadius(14)
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.10), lineWidth: 1))
                        }
                    }

                    Button(action: {
                        if let val = Double(newLengthText.replacingOccurrences(of: ",", with: ".")) {
                            addLengthEntry(val, note: newLengthNote)
                            newLengthText = ""; newLengthNote = ""
                            showAddLength = false
                        }
                    }) {
                        Text("Save Measurement")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 54)
                            .background(LinearGradient(
                                colors: [Color(red: 0.10, green: 0.62, blue: 0.42), Color(red: 0.05, green: 0.42, blue: 0.72)],
                                startPoint: .leading, endPoint: .trailing
                            ))
                            .cornerRadius(16)
                            .shadow(color: Color(red: 0.08, green: 0.50, blue: 0.38).opacity(0.45), radius: 14, y: 6)
                    }
                    .disabled(newLengthText.isEmpty)
                    .opacity(newLengthText.isEmpty ? 0.50 : 1.0)

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { showAddLength = false }
                        .foregroundColor(Color(red: 0.80, green: 0.65, blue: 1.0))
                }
            }
        }
    }

    private var setGoalSheet: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.06, green: 0.04, blue: 0.12).ignoresSafeArea()
                VStack(spacing: 24) {
                    Text("Set Your Growth Goal")
                        .font(.system(size: 22, weight: .bold, design: .rounded)).foregroundColor(.white)
                        .padding(.top, 20)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Target Length (cm)").font(.system(size: 13, weight: .semibold)).foregroundColor(Color.white.opacity(0.60))
                        TextField("e.g. 45", text: $goalText)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
                            .padding(16)
                            .background(Color.white.opacity(0.07))
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.40), lineWidth: 1))
                    }

                    // Preset goals
                    HStack(spacing: 10) {
                        ForEach(["20 cm", "30 cm", "45 cm", "60 cm"], id: \.self) { preset in
                            Button(action: { goalText = preset.replacingOccurrences(of: " cm", with: "") }) {
                                Text(preset)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(goalText == preset.replacingOccurrences(of: " cm", with: "") ? .white : Color.white.opacity(0.55))
                                    .padding(.horizontal, 14).padding(.vertical, 8)
                                    .background(goalText == preset.replacingOccurrences(of: " cm", with: "") ? Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.35) : Color.white.opacity(0.07))
                                    .cornerRadius(10)
                            }
                        }
                    }

                    Button(action: {
                        if let val = Double(goalText) { hairLengthGoal = val }
                        showGoalSheet = false
                    }) {
                        Text("Save Goal")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 54)
                            .background(LinearGradient(
                                colors: [Color(red: 0.90, green: 0.25, blue: 0.55), Color(red: 0.45, green: 0.18, blue: 0.88)],
                                startPoint: .leading, endPoint: .trailing
                            ))
                            .cornerRadius(16)
                    }
                    .disabled(goalText.isEmpty)

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { showGoalSheet = false }
                        .foregroundColor(Color(red: 0.80, green: 0.65, blue: 1.0))
                }
            }
        }
    }

    // MARK: - Mini Stat Card

    private func miniStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(
                        colors: [color.opacity(0.30), color.opacity(0.12)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: 38, height: 38)
                    .shadow(color: color.opacity(0.35), radius: 6, y: 2)
                Image(systemName: icon).font(.system(size: 14, weight: .semibold)).foregroundColor(color)
            }
            Text(value).font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.white)
            Text(label).font(.system(size: 9)).foregroundColor(Color(red: 0.55, green: 0.53, blue: 0.65))
                .multilineTextAlignment(.center).lineLimit(2)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 15)
        .background(Color(red: 0.10, green: 0.09, blue: 0.20))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.22), lineWidth: 1))
    }

    // MARK: - Compare Photos

    private func comparePhotos() {
        guard let before = beforeImage, let after = afterImage else { return }
        isComparing = true; comparisonResult = ""
        service.compareHair(before: before, after: after) { result in
            isComparing = false
            switch result {
            case .success(let text): withAnimation { comparisonResult = text }
            case .failure: comparisonResult = "Could not compare photos. Please try again."
            }
        }
    }
}

#Preview { HairProgressView() }
