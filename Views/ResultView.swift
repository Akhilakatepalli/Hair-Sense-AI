//
//  ResultView.swift
//  Hair AI
//

import SwiftUI

struct ResultView: View {

    var result: HairAnalysisResult? = nil
    var image: UIImage?             = nil
    var comparisonText: String      = ""

    @Environment(\.dismiss) var dismiss
    @State private var animateScore = false
    @State private var animateCards = false
    @State private var expandedSection: String? = nil

    private var score: Int        { result?.overallScore ?? 0 }
    private var condition: String { result?.condition    ?? "Unknown" }

    private var scoreGradientColors: [Color] {
        switch score {
        case 80...100: return [Color(red: 0.05, green: 0.45, blue: 0.30), Color(red: 0.10, green: 0.62, blue: 0.45)]
        case 60...79:  return [Color(red: 0.18, green: 0.35, blue: 0.85), Color(red: 0.05, green: 0.55, blue: 0.70)]
        case 40...59:  return [Color(red: 0.55, green: 0.30, blue: 0.05), Color(red: 0.72, green: 0.48, blue: 0.10)]
        default:       return [Color(red: 0.65, green: 0.15, blue: 0.15), Color(red: 0.85, green: 0.30, blue: 0.20)]
        }
    }

    private var scoreAccentColor: Color {
        switch score {
        case 80...100: return Color(red: 0.55, green: 1.0,  blue: 0.75)
        case 60...79:  return Color(red: 0.50, green: 0.85, blue: 1.0)
        case 40...59:  return Color(red: 1.0,  green: 0.82, blue: 0.45)
        default:       return Color(red: 1.0,  green: 0.60, blue: 0.55)
        }
    }

    private var scoreLabel: String {
        switch score {
        case 80...100: return "Excellent 🌿"
        case 60...79:  return "Good Condition"
        case 40...59:  return "Needs Care"
        default:       return "Needs Attention"
        }
    }

    var body: some View {

        ZStack {

            Color(red: 0.05, green: 0.05, blue: 0.10).ignoresSafeArea()

            RadialGradient(
                colors: [scoreGradientColors[0].opacity(0.30), .clear],
                center: .top, startRadius: 0, endRadius: 420
            ).ignoresSafeArea()

            if result == nil {
                // ── No Result ─────────────────────────────────────────────────
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.35, blue: 0.35).opacity(0.15))
                            .frame(width: 100, height: 100)
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.45))
                    }
                    VStack(spacing: 10) {
                        Text("Analysis Failed")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("We couldn't analyze this image. Please make sure the scalp is clearly visible and well lit.")
                            .font(.system(size: 14))
                            .foregroundColor(Color.white.opacity(0.60))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    Button(action: { dismiss() }) {
                        Text("Try Again")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(LinearGradient(
                                colors: [Color(red: 0.10, green: 0.62, blue: 0.45),
                                         Color(red: 0.05, green: 0.45, blue: 0.30)],
                                startPoint: .leading, endPoint: .trailing
                            ))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 24)
                }

            } else {
                // ── Full Results ──────────────────────────────────────────────
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {

                        // Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ANALYSIS COMPLETE")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(scoreAccentColor.opacity(0.8))
                                .tracking(2.0)
                            Text("Hair Analysis Result")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(LinearGradient(
                                    colors: [.white, scoreAccentColor.opacity(0.85)],
                                    startPoint: .leading, endPoint: .trailing
                                ))
                        }
                        .padding(.top, 10)
                        .opacity(animateCards ? 1.0 : 0)
                        .animation(.easeOut(duration: 0.5), value: animateCards)

                        // Scanned image
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay(RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.10), lineWidth: 1))
                        }

                        // Score card
                        ZStack {
                            RoundedRectangle(cornerRadius: 26)
                                .fill(LinearGradient(
                                    colors: scoreGradientColors,
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ))
                            RoundedRectangle(cornerRadius: 26)
                                .fill(LinearGradient(
                                    colors: [Color.white.opacity(0.15), .clear],
                                    startPoint: .topLeading, endPoint: .center
                                ))
                            Circle()
                                .fill(Color.white.opacity(0.05))
                                .frame(width: 180, height: 180)
                                .offset(x: 100, y: -50)

                            HStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("HAIR HEALTH SCORE")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.65))
                                        .tracking(2.0)
                                    Text("\(score)%")
                                        .font(.system(size: 62, weight: .heavy, design: .rounded))
                                        .foregroundColor(.white)
                                        .scaleEffect(animateScore ? 1.0 : 0.75)
                                        .opacity(animateScore ? 1.0 : 0)
                                        .animation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.2), value: animateScore)
                                    HStack(spacing: 5) {
                                        Image(systemName: "checkmark.seal.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(scoreAccentColor)
                                        Text(scoreLabel)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.white.opacity(0.90))
                                    }
                                    .padding(.horizontal, 12).padding(.vertical, 6)
                                    .background(Color.white.opacity(0.15))
                                    .clipShape(Capsule())
                                }
                                Spacer()
                                ZStack {
                                    Circle()
                                        .stroke(Color.white.opacity(0.15), lineWidth: 7)
                                        .frame(width: 76, height: 76)
                                    Circle()
                                        .trim(from: 0, to: animateScore ? CGFloat(score) / 100.0 : 0)
                                        .stroke(Color.white, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                                        .frame(width: 76, height: 76)
                                        .rotationEffect(.degrees(-90))
                                        .animation(.easeOut(duration: 1.2).delay(0.3), value: animateScore)
                                    Text("\(score)")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(24)
                        }
                        .shadow(color: scoreGradientColors[0].opacity(0.45), radius: 24, y: 10)

                        // Stats row
                        HStack(spacing: 12) {
                            statCard(label: "Hair Type",   value: result?.hairType    ?? "-", icon: "wand.and.stars")
                            statCard(label: "Density",     value: result?.density     ?? "-", icon: "chart.bar.fill")
                            statCard(label: "Scalp",       value: result?.scalpHealth ?? "-", icon: "waveform.path.ecg")
                            statCard(label: "Loss Risk",   value: result?.hairLossRisk ?? "-", icon: "arrow.down.circle.fill")
                        }

                        // Progress comparison
                        if !comparisonText.isEmpty {
                            sectionCard(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Progress Since First Scan",
                                color: scoreAccentColor
                            ) {
                                Text(comparisonText)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.white.opacity(0.80))
                                    .lineSpacing(5)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        // Main issues
                        if let issues = result?.mainIssues, !issues.isEmpty {
                            sectionCard(
                                icon: "exclamationmark.triangle.fill",
                                title: "Detected Issues",
                                color: Color(red: 1.0, green: 0.75, blue: 0.30)
                            ) {
                                VStack(spacing: 8) {
                                    ForEach(issues, id: \.self) { issue in
                                        HStack(spacing: 10) {
                                            Circle()
                                                .fill(Color(red: 1.0, green: 0.75, blue: 0.30))
                                                .frame(width: 6, height: 6)
                                            Text(issue)
                                                .font(.system(size: 13))
                                                .foregroundColor(Color.white.opacity(0.85))
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }

                        // Clinical recommendations
                        if let recs = result?.recommendations, !recs.isEmpty {
                            sectionCard(
                                icon: "cross.case.fill",
                                title: "Clinical Recommendations",
                                color: Color(red: 0.50, green: 0.85, blue: 1.0)
                            ) {
                                VStack(spacing: 10) {
                                    ForEach(Array(recs.enumerated()), id: \.offset) { i, rec in
                                        HStack(alignment: .top, spacing: 12) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color(red: 0.50, green: 0.85, blue: 1.0).opacity(0.15))
                                                    .frame(width: 24, height: 24)
                                                Text("\(i+1)")
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundColor(Color(red: 0.50, green: 0.85, blue: 1.0))
                                            }
                                            Text(rec)
                                                .font(.system(size: 13))
                                                .foregroundColor(Color.white.opacity(0.85))
                                                .fixedSize(horizontal: false, vertical: true)
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }

                        // Oil massage
                        if let r = result {
                            sectionCard(
                                icon: "drop.fill",
                                title: "Oil Massage Therapy",
                                color: Color(red: 0.75, green: 0.55, blue: 1.0)
                            ) {
                                VStack(alignment: .leading, spacing: 12) {
                                    infoRow(label: "Recommended Oil", value: r.oilMassageName)
                                    infoRow(label: "Frequency",       value: r.oilMassageFrequency)
                                    infoRow(label: "Duration",        value: r.oilMassageDuration)
                                    if !r.oilMassageTechnique.isEmpty {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text("Technique")
                                                .font(.system(size: 11, weight: .semibold))
                                                .foregroundColor(Color.white.opacity(0.40))
                                                .tracking(1.2)
                                            Text(r.oilMassageTechnique)
                                                .font(.system(size: 13))
                                                .foregroundColor(Color.white.opacity(0.80))
                                                .lineSpacing(4)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                    if !r.oilMassageBenefits.isEmpty {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text("Benefits for You")
                                                .font(.system(size: 11, weight: .semibold))
                                                .foregroundColor(Color.white.opacity(0.40))
                                                .tracking(1.2)
                                            Text(r.oilMassageBenefits)
                                                .font(.system(size: 13))
                                                .foregroundColor(Color(red: 0.75, green: 0.55, blue: 1.0).opacity(0.90))
                                                .lineSpacing(4)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                }
                            }
                        }

                        // Hair care routine
                        if let r = result {
                            sectionCard(
                                icon: "calendar.badge.clock",
                                title: "Your Hair Care Routine",
                                color: Color(red: 0.55, green: 1.0, blue: 0.75)
                            ) {
                                VStack(alignment: .leading, spacing: 12) {
                                    routineRow(icon: "sunrise.fill",    label: "Morning",   value: r.routineMorning,      color: Color(red: 1.0, green: 0.82, blue: 0.45))
                                    routineRow(icon: "moon.fill",       label: "Evening",   value: r.routineEvening,      color: Color(red: 0.50, green: 0.85, blue: 1.0))
                                    routineRow(icon: "calendar",        label: "Weekly",    value: r.routineWeekly,       color: Color(red: 0.75, green: 0.55, blue: 1.0))
                                    routineRow(icon: "drop.fill",       label: "Shampooing", value: r.routineShampooing,  color: Color(red: 0.55, green: 1.0, blue: 0.75))
                                    routineRow(icon: "sparkles",        label: "Conditioning", value: r.routineConditioning, color: Color(red: 1.0, green: 0.60, blue: 0.55))
                                }
                            }
                        }

                        // Product recommendations
                        if let r = result {
                            sectionCard(
                                icon: "bag.fill",
                                title: "Product Recommendations",
                                color: Color(red: 1.0, green: 0.82, blue: 0.45)
                            ) {
                                VStack(alignment: .leading, spacing: 12) {
                                    productRow(label: "✅ Shampoo",     value: r.shampooRec,      isAvoid: false)
                                    productRow(label: "✅ Conditioner", value: r.conditionerRec,  isAvoid: false)
                                    productRow(label: "✅ Treatment",   value: r.treatmentRec,    isAvoid: false)
                                    productRow(label: "❌ Avoid",       value: r.productsToAvoid, isAvoid: true)
                                }
                            }
                        }

                        // Dos and Donts
                        if let r = result, (!r.dos.isEmpty || !r.donts.isEmpty) {
                            sectionCard(
                                icon: "checkmark.shield.fill",
                                title: "Do's & Don'ts",
                                color: Color(red: 0.55, green: 1.0, blue: 0.75)
                            ) {
                                VStack(alignment: .leading, spacing: 16) {
                                    if !r.dos.isEmpty {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("DO'S")
                                                .font(.system(size: 11, weight: .semibold))
                                                .foregroundColor(Color(red: 0.55, green: 1.0, blue: 0.75))
                                                .tracking(1.5)
                                            ForEach(r.dos, id: \.self) { item in
                                                HStack(alignment: .top, spacing: 10) {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(Color(red: 0.55, green: 1.0, blue: 0.75))
                                                    Text(item)
                                                        .font(.system(size: 13))
                                                        .foregroundColor(Color.white.opacity(0.85))
                                                        .fixedSize(horizontal: false, vertical: true)
                                                    Spacer()
                                                }
                                            }
                                        }
                                    }
                                    if !r.donts.isEmpty {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("DON'TS")
                                                .font(.system(size: 11, weight: .semibold))
                                                .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.45))
                                                .tracking(1.5)
                                            ForEach(r.donts, id: \.self) { item in
                                                HStack(alignment: .top, spacing: 10) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.45))
                                                    Text(item)
                                                        .font(.system(size: 13))
                                                        .foregroundColor(Color.white.opacity(0.85))
                                                        .fixedSize(horizontal: false, vertical: true)
                                                    Spacer()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Diet tips
                        if let tips = result?.dietTips, !tips.isEmpty {
                            sectionCard(
                                icon: "leaf.fill",
                                title: "Diet for Hair Health",
                                color: Color(red: 0.10, green: 0.62, blue: 0.45)
                            ) {
                                VStack(spacing: 8) {
                                    ForEach(tips, id: \.self) { tip in
                                        HStack(alignment: .top, spacing: 10) {
                                            Image(systemName: "leaf.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color(red: 0.55, green: 1.0, blue: 0.75))
                                            Text(tip)
                                                .font(.system(size: 13))
                                                .foregroundColor(Color.white.opacity(0.85))
                                                .fixedSize(horizontal: false, vertical: true)
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                        // Meal Recipes
                        if let recipes = result?.mealRecipes, !recipes.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {

                                HStack(spacing: 10) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(red: 0.10, green: 0.62, blue: 0.45).opacity(0.15))
                                            .frame(width: 32, height: 32)
                                        Image(systemName: "fork.knife")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(red: 0.55, green: 1.0, blue: 0.75))
                                    }
                                    Text("Meal Recipes for Hair Health")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }

                                ForEach(recipes, id: \.name) { recipe in
                                    RecipeCard(recipe: recipe)
                                }
                            }
                            .opacity(animateCards ? 1.0 : 0)
                            .offset(y: animateCards ? 0 : 16)
                            .animation(.easeOut(duration: 0.6).delay(0.10), value: animateCards)
                        }
                        // Vitamins
                        if let vitamins = result?.vitaminsNeeded, !vitamins.isEmpty {
                            sectionCard(
                                icon: "pill.fill",
                                title: "Vitamins & Nutrients",
                                color: Color(red: 1.0, green: 0.60, blue: 0.55)
                            ) {
                                VStack(spacing: 8) {
                                    ForEach(vitamins, id: \.self) { vitamin in
                                        HStack(alignment: .top, spacing: 10) {
                                            Image(systemName: "pill.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color(red: 1.0, green: 0.60, blue: 0.55))
                                            Text(vitamin)
                                                .font(.system(size: 13))
                                                .foregroundColor(Color.white.opacity(0.85))
                                                .fixedSize(horizontal: false, vertical: true)
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }

                        // When to see doctor
                        if let warning = result?.whenToSeeDoctor, !warning.isEmpty {
                            sectionCard(
                                icon: "stethoscope",
                                title: "When to See a Doctor",
                                color: Color(red: 1.0, green: 0.45, blue: 0.45)
                            ) {
                                Text(warning)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.white.opacity(0.80))
                                    .lineSpacing(5)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        // Scan again
                        Button(action: { dismiss() }) {
                            HStack(spacing: 10) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Scan Again")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(LinearGradient(
                                colors: [Color(red: 0.10, green: 0.62, blue: 0.45),
                                         Color(red: 0.05, green: 0.45, blue: 0.30)],
                                startPoint: .leading, endPoint: .trailing
                            ))
                            .cornerRadius(16)
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationBarHidden(false)
        .navigationBarBackButtonHidden(false)
        .onAppear {
            animateCards = true
            animateScore = true
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func sectionCard<Content: View>(icon: String, title: String, color: Color, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(color)
                }
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            content()
        }
        .padding(18)
        .background(Color(red: 0.10, green: 0.10, blue: 0.18))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
        .opacity(animateCards ? 1.0 : 0)
        .offset(y: animateCards ? 0 : 16)
        .animation(.easeOut(duration: 0.6).delay(0.10), value: animateCards)
    }

    private func statCard(label: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(scoreAccentColor)
            Text(value)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(Color.white.opacity(0.40))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(red: 0.10, green: 0.10, blue: 0.18))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.07), lineWidth: 1))
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.white.opacity(0.45))
                .frame(width: 110, alignment: .leading)
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
    }

    private func routineRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 28, height: 28)
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(color)
                    .tracking(0.5)
                Text(value)
                    .font(.system(size: 13))
                    .foregroundColor(Color.white.opacity(0.80))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)
            }
            Spacer()
        }
    }

    private func productRow(label: String, value: String, isAvoid: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(isAvoid
                                 ? Color(red: 1.0, green: 0.45, blue: 0.45)
                                 : Color(red: 0.55, green: 1.0, blue: 0.75))
                .tracking(0.5)
            Text(value)
                .font(.system(size: 13))
                .foregroundColor(Color.white.opacity(0.80))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isAvoid
                    ? Color(red: 1.0, green: 0.25, blue: 0.25).opacity(0.08)
                    : Color.white.opacity(0.04))
        .cornerRadius(10)
    }
}
// MARK: - Recipe Card

struct RecipeCard: View {

    let recipe: MealRecipe
    @State private var isExpanded = false

    var body: some View {

        VStack(alignment: .leading, spacing: 0) {

            // Header
            Button(action: { withAnimation(.easeInOut(duration: 0.3)) { isExpanded.toggle() } }) {
                HStack(spacing: 14) {

                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.10, green: 0.62, blue: 0.45).opacity(0.15))
                            .frame(width: 48, height: 48)
                        Text("🍽️")
                            .font(.system(size: 22))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(recipe.name)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text(recipe.benefit)
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.55, green: 1.0, blue: 0.75))
                            .lineLimit(1)
                    }

                    Spacer()

                    VStack(spacing: 4) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.40))
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 10))
                                .foregroundColor(Color.white.opacity(0.35))
                            Text(recipe.prepTime)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.35))
                        }
                    }
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {

                    Divider()
                        .background(Color.white.opacity(0.08))
                        .padding(.horizontal, 14)

                    // Nutrients
                    if !recipe.nutrients.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("KEY NUTRIENTS")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(Color.white.opacity(0.35))
                                .tracking(1.3)
                                .padding(.horizontal, 14)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(recipe.nutrients, id: \.self) { nutrient in
                                        Text(nutrient)
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(Color(red: 0.55, green: 1.0, blue: 0.75))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color(red: 0.10, green: 0.62, blue: 0.45).opacity(0.15))
                                            .cornerRadius(8)
                                    }
                                }
                                .padding(.horizontal, 14)
                            }
                        }
                    }

                    // Ingredients
                    if !recipe.ingredients.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("INGREDIENTS")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(Color.white.opacity(0.35))
                                .tracking(1.3)
                                .padding(.horizontal, 14)

                            VStack(spacing: 6) {
                                ForEach(recipe.ingredients, id: \.self) { ingredient in
                                    HStack(spacing: 10) {
                                        Circle()
                                            .fill(Color(red: 0.55, green: 1.0, blue: 0.75))
                                            .frame(width: 5, height: 5)
                                        Text(ingredient)
                                            .font(.system(size: 13))
                                            .foregroundColor(Color.white.opacity(0.80))
                                        Spacer()
                                    }
                                    .padding(.horizontal, 14)
                                }
                            }
                        }
                    }

                    // Steps
                    if !recipe.steps.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PREPARATION")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(Color.white.opacity(0.35))
                                .tracking(1.3)
                                .padding(.horizontal, 14)

                            VStack(spacing: 10) {
                                ForEach(Array(recipe.steps.enumerated()), id: \.offset) { i, step in
                                    HStack(alignment: .top, spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(Color(red: 0.10, green: 0.62, blue: 0.45).opacity(0.20))
                                                .frame(width: 22, height: 22)
                                            Text("\(i+1)")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(Color(red: 0.55, green: 1.0, blue: 0.75))
                                        }
                                        Text(step)
                                            .font(.system(size: 13))
                                            .foregroundColor(Color.white.opacity(0.80))
                                            .fixedSize(horizontal: false, vertical: true)
                                            .lineSpacing(3)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 14)
                                }
                            }
                        }
                    }

                    Spacer().frame(height: 6)
                }
            }
        }
        .background(Color(red: 0.10, green: 0.10, blue: 0.18))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 0.55, green: 1.0, blue: 0.75).opacity(0.12), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        ResultView(result: nil, image: nil, comparisonText: "")
    }
}
