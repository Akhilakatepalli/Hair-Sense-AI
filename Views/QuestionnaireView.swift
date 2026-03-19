//
//  QuestionnaireView.swift
//  Hair AI
//

import SwiftUI

struct QuestionnaireView: View {

    @EnvironmentObject var authVM: AuthViewModel
    @State private var currentStep          = 0
    @State private var profile              = UserProfile()
    @State private var selectedProblems: Set<String> = []
    @State private var animateCard          = false
    @State private var navigateToDashboard  = false

    let totalSteps = 6

    var body: some View {

        ZStack {

            Color(red: 0.05, green: 0.05, blue: 0.10).ignoresSafeArea()

            RadialGradient(
                colors: [Color(red: 0.10, green: 0.62, blue: 0.45).opacity(0.30), .clear],
                center: .top, startRadius: 0, endRadius: 400
            ).ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Progress bar ──────────────────────────────────────────────
                VStack(spacing: 12) {
                    HStack {
                        Text("Step \(currentStep + 1) of \(totalSteps)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.50))
                        Spacer()
                        Text("\(Int((Double(currentStep + 1) / Double(totalSteps)) * 100))%")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(red: 0.55, green: 1.0, blue: 0.75))
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.10))
                                .frame(height: 6)
                            Capsule()
                                .fill(LinearGradient(
                                    colors: [Color(red: 0.10, green: 0.62, blue: 0.45),
                                             Color(red: 0.55, green: 1.0, blue: 0.75)],
                                    startPoint: .leading, endPoint: .trailing
                                ))
                                .frame(width: geo.size.width * CGFloat(currentStep + 1) / CGFloat(totalSteps), height: 6)
                                .animation(.easeInOut(duration: 0.4), value: currentStep)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 32)

                // ── Step content ──────────────────────────────────────────────
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {

                        switch currentStep {
                        case 0: stepBasicInfo
                        case 1: stepHairType
                        case 2: stepHairProblem
                        case 3: stepStressLevel
                        case 4: stepDietType
                        case 5: stepSleepHours
                        default: stepBasicInfo
                        }

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 24)
                }

                // ── Navigation buttons ────────────────────────────────────────
                HStack(spacing: 16) {

                    if currentStep > 0 {
                        Button(action: {
                            withAnimation { currentStep -= 1 }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(Color.white.opacity(0.60))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(red: 0.10, green: 0.10, blue: 0.18))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
                            )
                        }
                    }

                    Button(action: {
                        if currentStep < totalSteps - 1 {
                            withAnimation { currentStep += 1 }
                        } else {
                            UserDefaults.standard.set(true, forKey: "hasCompletedQuestionnaire")
                            navigateToDashboard = true
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text(currentStep == totalSteps - 1 ? "Get Started" : "Next")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                            Image(systemName: currentStep == totalSteps - 1 ? "checkmark" : "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
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
                        .shadow(color: Color(red: 0.10, green: 0.62, blue: 0.45).opacity(0.40), radius: 12, y: 5)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .padding(.top, 16)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToDashboard) {
            HomeDashboardView()
                .environmentObject(authVM)
        }
    }

    // MARK: - Step 1: Basic Info
    var stepBasicInfo: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepHeader(
                icon: "person.fill",
                title: "Tell us about yourself",
                subtitle: "This helps us personalise your hair health plan"
            )

            VStack(spacing: 16) {
                questionField(label: "YOUR AGE", placeholder: "e.g. 25", text: $profile.age)

                VStack(alignment: .leading, spacing: 10) {
                    Text("GENDER")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(red: 0.55, green: 0.80, blue: 0.70))
                        .tracking(1.5)

                    HStack(spacing: 12) {
                        ForEach(["Male", "Female", "Other"], id: \.self) { option in
                            optionChip(title: option, isSelected: profile.gender == option) {
                                profile.gender = option
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Step 2: Hair Type
    var stepHairType: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepHeader(
                icon: "wand.and.stars",
                title: "What's your hair type?",
                subtitle: "Select the option that best describes your hair"
            )

            VStack(spacing: 12) {
                ForEach(["Straight", "Wavy", "Curly", "Coily"], id: \.self) { type in
                    optionRow(title: type, isSelected: profile.hairType == type) {
                        profile.hairType = type
                    }
                }
            }
        }
    }

    // MARK: - Step 3: Hair Problem (multiple selection)
    var stepHairProblem: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepHeader(
                icon: "exclamationmark.triangle.fill",
                title: "Hair concerns?",
                subtitle: "Select all that apply to you"
            )

            VStack(spacing: 12) {
                ForEach(["Hair Fall", "Hair Thinning", "Dandruff", "Dry Scalp",
                         "Oily Scalp", "Slow Growth", "Grey Hair", "Baldness"], id: \.self) { problem in
                    multiOptionRow(title: problem, isSelected: selectedProblems.contains(problem)) {
                        if selectedProblems.contains(problem) {
                            selectedProblems.remove(problem)
                        } else {
                            selectedProblems.insert(problem)
                        }
                        profile.hairProblem = selectedProblems.joined(separator: ", ")
                    }
                }
            }
        }
    }

    // MARK: - Step 4: Stress Level
    var stepStressLevel: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepHeader(
                icon: "brain.head.profile",
                title: "How stressed are you?",
                subtitle: "Stress is a major factor in hair health"
            )

            VStack(spacing: 12) {
                ForEach(["Low — I feel relaxed most days",
                         "Medium — Occasionally stressed",
                         "High — Stressed most of the time"], id: \.self) { level in
                    optionRow(title: level, isSelected: profile.stressLevel == level) {
                        profile.stressLevel = level
                    }
                }
            }
        }
    }

    // MARK: - Step 5: Diet Type
    var stepDietType: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepHeader(
                icon: "leaf.fill",
                title: "What's your diet type?",
                subtitle: "We'll suggest foods that match your diet"
            )

            VStack(spacing: 12) {
                ForEach(["Non-Vegetarian", "Vegetarian", "Vegan",
                         "Dairy-Free", "Gluten-Free"], id: \.self) { diet in
                    optionRow(title: diet, isSelected: profile.dietType == diet) {
                        profile.dietType = diet
                    }
                }
            }
        }
    }

    // MARK: - Step 6: Sleep Hours
    var stepSleepHours: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepHeader(
                icon: "moon.fill",
                title: "How much do you sleep?",
                subtitle: "Sleep directly affects hair growth and health"
            )

            VStack(spacing: 12) {
                ForEach(["Less than 5 hours",
                         "5-6 hours",
                         "7-8 hours",
                         "More than 8 hours"], id: \.self) { sleep in
                    optionRow(title: sleep, isSelected: profile.sleepHours == sleep) {
                        profile.sleepHours = sleep
                    }
                }
            }
        }
    }

    // MARK: - Reusable Components

    private func stepHeader(icon: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.10, green: 0.62, blue: 0.45).opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(Color(red: 0.55, green: 1.0, blue: 0.75))
            }

            Text(title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(subtitle)
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0.55, green: 0.53, blue: 0.65))
        }
    }

    private func questionField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(red: 0.55, green: 0.80, blue: 0.70))
                .tracking(1.5)

            TextField("", text: text,
                      prompt: Text(placeholder).foregroundColor(Color.white.opacity(0.25)))
            .foregroundColor(.white)
            .keyboardType(.numberPad)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(Color(red: 0.10, green: 0.10, blue: 0.18))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 0.55, green: 0.80, blue: 0.70).opacity(0.20), lineWidth: 1)
            )
        }
    }

    // Single select row
    private func optionRow(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : Color.white.opacity(0.70))
                Spacer()
                ZStack {
                    Circle()
                        .stroke(isSelected
                                ? Color(red: 0.55, green: 1.0, blue: 0.75)
                                : Color.white.opacity(0.20),
                                lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(Color(red: 0.55, green: 1.0, blue: 0.75))
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(isSelected
                        ? Color(red: 0.10, green: 0.62, blue: 0.45).opacity(0.15)
                        : Color(red: 0.10, green: 0.10, blue: 0.18))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected
                            ? Color(red: 0.55, green: 1.0, blue: 0.75).opacity(0.40)
                            : Color.white.opacity(0.07),
                            lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // Multi select row (checkbox)
    private func multiOptionRow(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : Color.white.opacity(0.70))
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(isSelected
                                ? Color(red: 0.55, green: 1.0, blue: 0.75)
                                : Color.white.opacity(0.20),
                                lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color(red: 0.55, green: 1.0, blue: 0.75))
                            .frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(isSelected
                        ? Color(red: 0.10, green: 0.62, blue: 0.45).opacity(0.15)
                        : Color(red: 0.10, green: 0.10, blue: 0.18))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected
                            ? Color(red: 0.55, green: 1.0, blue: 0.75).opacity(0.40)
                            : Color.white.opacity(0.07),
                            lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // Chip button
    private func optionChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : Color.white.opacity(0.60))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(isSelected
                            ? Color(red: 0.10, green: 0.62, blue: 0.45)
                            : Color(red: 0.10, green: 0.10, blue: 0.18))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected
                                ? Color(red: 0.55, green: 1.0, blue: 0.75).opacity(0.40)
                                : Color.white.opacity(0.10),
                                lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        QuestionnaireView()
            .environmentObject(AuthViewModel())
    }
}
