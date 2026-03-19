//
//  DietView.swift
//  Hair AI
//
//  Created by Akhila Katepalli on 3/13/26.
//

import SwiftUI

// MARK: - Models

struct DietFood: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let subtitle: String
    let emoji: String
    let benefit: String
    let nutrition: String
    let servingTip: String
}

struct DietSection: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let foods: [DietFood]
}

// MARK: - DietView

struct DietView: View {

    @State private var animateCards = false
    @State private var selectedFood: DietFood? = nil
    @State private var mealPlan: [DietFood] = []
    @State private var eatenToday: Set<UUID> = []
    @State private var showMealPlan = false
    @State private var showChecklist = false
    @State private var addedToast: String? = nil

    let sections: [DietSection] = [
        DietSection(
            title: "Protein Rich Foods",
            subtitle: "Builds strong hair structure",
            icon: "bolt.fill",
            color: Color(red: 1.0, green: 0.75, blue: 0.30),
            foods: [
                DietFood(name: "Eggs",         subtitle: "Complete protein & biotin",  emoji: "🍳", benefit: "Strengthens hair shaft and promotes keratin production",    nutrition: "Protein: 13g • Biotin: 10mcg • Vitamin D: 6%",  servingTip: "2 eggs for breakfast, boiled or poached"),
                DietFood(name: "Almonds",      subtitle: "Healthy fats & vitamin E",   emoji: "🥜", benefit: "Reduces hair breakage and nourishes hair follicles",        nutrition: "Protein: 6g • Vitamin E: 37% • Magnesium: 19%", servingTip: "A handful (28g) as a mid-morning snack"),
                DietFood(name: "Beans",        subtitle: "Plant protein & zinc",       emoji: "🫘", benefit: "Supports hair tissue growth and repair",                    nutrition: "Protein: 15g • Zinc: 12% • Iron: 20%",          servingTip: "Half cup with lunch or dinner"),
                DietFood(name: "Greek Yogurt", subtitle: "Protein & vitamin B5",       emoji: "🥛", benefit: "Improves scalp circulation and strengthens hair",           nutrition: "Protein: 17g • B5: 14% • Calcium: 18%",         servingTip: "One cup with fruit in the morning")
            ]
        ),
        DietSection(
            title: "Vitamin Rich Foods",
            subtitle: "Nourishes scalp & roots",
            icon: "leaf.fill",
            color: Color(red: 0.55, green: 1.0, blue: 0.75),
            foods: [
                DietFood(name: "Spinach",  subtitle: "Iron, folate & vitamin A", emoji: "🥬", benefit: "Carries oxygen to hair follicles and prevents hair loss", nutrition: "Iron: 15% • Vitamin A: 56% • Folate: 15%",      servingTip: "2 cups raw or 1 cup cooked with meals"),
                DietFood(name: "Carrots",  subtitle: "Beta-carotene & vitamin A", emoji: "🥕", benefit: "Promotes sebum production for a healthy scalp",         nutrition: "Vitamin A: 184% • Fiber: 14% • Potassium: 9%",  servingTip: "1 medium carrot as a snack or in salads"),
                DietFood(name: "Avocado",  subtitle: "Vitamin E & healthy fats",  emoji: "🥑", benefit: "Protects hair from oxidative stress and adds shine",    nutrition: "Vitamin E: 21% • Healthy Fats: 21g • B6: 15%",  servingTip: "Half an avocado with lunch daily"),
                DietFood(name: "Oranges",  subtitle: "Vitamin C & antioxidants",  emoji: "🍊", benefit: "Boosts collagen production for stronger hair strands",  nutrition: "Vitamin C: 93% • Folate: 10% • Fiber: 13%",     servingTip: "1 orange or a glass of fresh juice daily")
            ]
        ),
        DietSection(
            title: "Omega-3 Foods",
            subtitle: "Deep moisture & shine",
            icon: "drop.fill",
            color: Color(red: 0.50, green: 0.85, blue: 1.0),
            foods: [
                DietFood(name: "Salmon",     subtitle: "Omega-3 & vitamin D",  emoji: "🐟", benefit: "Reduces scalp inflammation and promotes hair density",  nutrition: "Omega-3: 2.2g • Protein: 25g • Vitamin D: 97%", servingTip: "150g fillet 2-3 times per week"),
                DietFood(name: "Walnuts",    subtitle: "Omega-3 & biotin",     emoji: "🌰", benefit: "Prevents hair thinning and adds natural lustre",        nutrition: "Omega-3: 2.5g • Biotin: 5mcg • Vitamin E: 2%",  servingTip: "A small handful (30g) daily as a snack"),
                DietFood(name: "Flax Seeds", subtitle: "ALA omega-3 & fiber",  emoji: "🌱", benefit: "Hydrates hair shaft from within and reduces frizz",     nutrition: "Omega-3: 2.3g • Fiber: 28% • Magnesium: 27%",   servingTip: "1 tablespoon in smoothies or yogurt daily")
            ]
        )
    ]

    var allFoods: [DietFood] { sections.flatMap { $0.foods } }

    var body: some View {

        ZStack {

            // ── Background ────────────────────────────────────────────────────
            Color(red: 0.05, green: 0.05, blue: 0.10).ignoresSafeArea()

            RadialGradient(
                colors: [Color(red: 0.10, green: 0.62, blue: 0.45).opacity(0.25), .clear],
                center: .top, startRadius: 0, endRadius: 420
            ).ignoresSafeArea()

            RadialGradient(
                colors: [Color(red: 0.18, green: 0.35, blue: 0.85).opacity(0.15), .clear],
                center: .bottom, startRadius: 0, endRadius: 360
            ).ignoresSafeArea()

            ScrollView(showsIndicators: false) {

                VStack(alignment: .leading, spacing: 26) {

                    // ── Header ────────────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 4) {
                        Text("NUTRITION PLAN")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(red: 0.55, green: 1.0, blue: 0.75).opacity(0.8))
                            .tracking(2.0)

                        Text("Hair Diet Plan")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, Color(red: 0.55, green: 1.0, blue: 0.80)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )

                        Text("Tap any food to add it to your meal plan")
                            .font(.system(size: 13))
                            .foregroundColor(Color(red: 0.55, green: 0.53, blue: 0.65))
                            .padding(.top, 2)
                    }
                    .padding(.top, 10)
                    .opacity(animateCards ? 1.0 : 0)
                    .offset(y: animateCards ? 0 : 10)
                    .animation(.easeOut(duration: 0.5), value: animateCards)

                    // ── Action Cards Row ──────────────────────────────────────
                    HStack(spacing: 12) {

                        // Meal Plan card
                        Button(action: { showMealPlan = true }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(red: 0.10, green: 0.62, blue: 0.45).opacity(0.18))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: "list.clipboard.fill")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(Color(red: 0.55, green: 1.0, blue: 0.75))
                                }
                                Text("\(mealPlan.count)")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Text("My Plan")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(red: 0.55, green: 0.53, blue: 0.65))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(red: 0.10, green: 0.10, blue: 0.18))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 0.55, green: 1.0, blue: 0.75).opacity(0.15), lineWidth: 1)
                            )
                        }

                        // Today's checklist card
                        Button(action: { showChecklist = true }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(red: 0.50, green: 0.85, blue: 1.0).opacity(0.18))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(Color(red: 0.50, green: 0.85, blue: 1.0))
                                }
                                Text("\(eatenToday.count)/\(allFoods.count)")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Text("Eaten Today")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(red: 0.55, green: 0.53, blue: 0.65))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(red: 0.10, green: 0.10, blue: 0.18))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 0.50, green: 0.85, blue: 1.0).opacity(0.15), lineWidth: 1)
                            )
                        }

                        // Progress card
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .stroke(Color.white.opacity(0.08), lineWidth: 4)
                                    .frame(width: 36, height: 36)
                                Circle()
                                    .trim(from: 0, to: allFoods.isEmpty ? 0 : CGFloat(eatenToday.count) / CGFloat(allFoods.count))
                                    .stroke(Color(red: 1.0, green: 0.75, blue: 0.30), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                    .frame(width: 36, height: 36)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeOut(duration: 0.5), value: eatenToday.count)
                            }
                            Text("\(allFoods.isEmpty ? 0 : Int(CGFloat(eatenToday.count) / CGFloat(allFoods.count) * 100))%")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("Progress")
                                .font(.system(size: 10))
                                .foregroundColor(Color(red: 0.55, green: 0.53, blue: 0.65))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 0.10, green: 0.10, blue: 0.18))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 1.0, green: 0.75, blue: 0.30).opacity(0.15), lineWidth: 1)
                        )
                    }
                    .opacity(animateCards ? 1.0 : 0)
                    .offset(y: animateCards ? 0 : 12)
                    .animation(.easeOut(duration: 0.5).delay(0.08), value: animateCards)

                    // ── Diet Sections ─────────────────────────────────────────
                    ForEach(Array(sections.enumerated()), id: \.element.id) { sIndex, section in

                        VStack(alignment: .leading, spacing: 14) {

                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(section.color.opacity(0.18))
                                        .frame(width: 42, height: 42)
                                    Image(systemName: section.icon)
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(section.color)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(section.title)
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    Text(section.subtitle)
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(red: 0.55, green: 0.53, blue: 0.65))
                                }
                                Spacer()
                                Text("\(section.foods.count) foods")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(section.color)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(section.color.opacity(0.12))
                                    .clipShape(Capsule())
                            }

                            VStack(spacing: 0) {
                                ForEach(Array(section.foods.enumerated()), id: \.element.id) { fIndex, food in
                                    Button(action: { selectedFood = food }) {
                                        foodRow(
                                            food: food,
                                            accentColor: section.color,
                                            isInPlan: mealPlan.contains(where: { $0.id == food.id }),
                                            isEaten: eatenToday.contains(food.id),
                                            isLast: fIndex == section.foods.count - 1
                                        )
                                    }
                                }
                            }
                            .background(Color(red: 0.10, green: 0.10, blue: 0.18))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(section.color.opacity(0.12), lineWidth: 1)
                            )
                        }
                        .opacity(animateCards ? 1.0 : 0)
                        .offset(y: animateCards ? 0 : 16)
                        .animation(.easeOut(duration: 0.6).delay(Double(sIndex) * 0.10 + 0.15), value: animateCards)
                    }

                    // ── Daily Tip ─────────────────────────────────────────────
                    ZStack {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.05, green: 0.45, blue: 0.30), Color(red: 0.18, green: 0.35, blue: 0.85)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )

                        RoundedRectangle(cornerRadius: 22)
                            .fill(LinearGradient(colors: [Color.white.opacity(0.12), .clear], startPoint: .topLeading, endPoint: .center))

                        Circle()
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 150, height: 150)
                            .offset(x: 90, y: -40)

                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("DAILY TIP")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.60))
                                    .tracking(2.0)
                                Text("Drink 8 glasses of water daily to keep your scalp hydrated and support hair growth.")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.90))
                                    .lineSpacing(4)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer()
                            Image(systemName: "drop.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white.opacity(0.25))
                        }
                        .padding(20)
                    }
                    .shadow(color: Color(red: 0.05, green: 0.45, blue: 0.30).opacity(0.40), radius: 20, y: 8)
                    .opacity(animateCards ? 1.0 : 0)
                    .offset(y: animateCards ? 0 : 16)
                    .animation(.easeOut(duration: 0.6).delay(0.40), value: animateCards)

                    Spacer().frame(height: 24)
                }
                .padding(.horizontal, 20)
            }

            // ── Toast ─────────────────────────────────────────────────────────
            if let toast = addedToast {
                VStack {
                    Spacer()
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(red: 0.55, green: 1.0, blue: 0.75))
                        Text(toast)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color(red: 0.12, green: 0.14, blue: 0.22))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 0.55, green: 1.0, blue: 0.75).opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: 16, y: 6)
                    .padding(.bottom, 30)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.75), value: addedToast)
            }
        }
        .onAppear { animateCards = true }

        // ── Food detail sheet ─────────────────────────────────────────────────
        .sheet(item: $selectedFood) { food in
            FoodDetailSheet(
                food: food,
                isInPlan: mealPlan.contains(where: { $0.id == food.id }),
                isEaten: eatenToday.contains(food.id),
                onAddToPlan: {
                    if !mealPlan.contains(where: { $0.id == food.id }) {
                        mealPlan.append(food)
                        showToast("\(food.name) added to your meal plan")
                    }
                },
                onMarkEaten: {
                    if eatenToday.contains(food.id) {
                        eatenToday.remove(food.id)
                    } else {
                        eatenToday.insert(food.id)
                        showToast("\(food.name) marked as eaten today")
                    }
                }
            )
        }

        // ── Meal Plan sheet ───────────────────────────────────────────────────
        .sheet(isPresented: $showMealPlan) {
            MealPlanSheet(
                mealPlan: $mealPlan,
                eatenToday: $eatenToday,
                onMarkEaten: { food in
                    if eatenToday.contains(food.id) {
                        eatenToday.remove(food.id)
                    } else {
                        eatenToday.insert(food.id)
                    }
                }
            )
        }

        // ── Daily checklist sheet ─────────────────────────────────────────────
        .sheet(isPresented: $showChecklist) {
            DailyChecklistSheet(
                allFoods: allFoods,
                eatenToday: $eatenToday
            )
        }
    }

    // MARK: - Helpers

    private func showToast(_ message: String) {
        withAnimation { addedToast = message }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation { addedToast = nil }
        }
    }

    private func foodRow(food: DietFood, accentColor: Color, isInPlan: Bool, isEaten: Bool, isLast: Bool) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(accentColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                Text(food.emoji)
                    .font(.system(size: 24))

                // Eaten checkmark badge
                if isEaten {
                    Circle()
                        .fill(Color(red: 0.55, green: 1.0, blue: 0.75))
                        .frame(width: 16, height: 16)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(Color(red: 0.05, green: 0.10, blue: 0.10))
                        )
                        .offset(x: 14, y: -14)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(food.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Text(food.subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.55, green: 0.53, blue: 0.65))
            }

            Spacer()

            // In plan badge
            if isInPlan {
                Text("In Plan")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color(red: 0.55, green: 1.0, blue: 0.75))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.55, green: 1.0, blue: 0.75).opacity(0.12))
                    .clipShape(Capsule())
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 11))
                .foregroundColor(Color.white.opacity(0.22))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1)
                .padding(.leading, 74),
            alignment: isLast ? .top : .bottom
        )
    }
}

// MARK: - Food Detail Sheet

struct FoodDetailSheet: View {

    let food: DietFood
    let isInPlan: Bool
    let isEaten: Bool
    let onAddToPlan: () -> Void
    let onMarkEaten: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.10).ignoresSafeArea()
            RadialGradient(
                colors: [Color(red: 0.10, green: 0.62, blue: 0.45).opacity(0.22), .clear],
                center: .top, startRadius: 0, endRadius: 320
            ).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {

                    // Handle
                    HStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.18))
                            .frame(width: 40, height: 4)
                        Spacer()
                    }
                    .padding(.top, 14)

                    // Food icon + title
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 0.10, green: 0.62, blue: 0.45).opacity(0.18))
                                .frame(width: 70, height: 70)
                            Text(food.emoji)
                                .font(.system(size: 36))
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(food.name)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text(food.subtitle)
                                .font(.system(size: 13))
                                .foregroundColor(Color(red: 0.55, green: 0.80, blue: 0.70))
                        }
                    }

                    // Nutrition info
                    VStack(alignment: .leading, spacing: 10) {
                        Text("NUTRITION")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.38))
                            .tracking(1.5)

                        Text(food.nutrition)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(red: 0.55, green: 1.0, blue: 0.75))
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(red: 0.10, green: 0.62, blue: 0.45).opacity(0.12))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 0.55, green: 1.0, blue: 0.75).opacity(0.15), lineWidth: 1)
                            )
                    }

                    // Hair benefit
                    VStack(alignment: .leading, spacing: 10) {
                        Text("HAIR BENEFIT")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.38))
                            .tracking(1.5)

                        Text(food.benefit)
                            .font(.system(size: 14))
                            .foregroundColor(Color.white.opacity(0.80))
                            .lineSpacing(5)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 0.10, green: 0.10, blue: 0.18))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.07), lineWidth: 1)
                    )

                    // Serving tip
                    VStack(alignment: .leading, spacing: 10) {
                        Text("SERVING TIP")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.38))
                            .tracking(1.5)

                        HStack(spacing: 12) {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.30))
                            Text(food.servingTip)
                                .font(.system(size: 14))
                                .foregroundColor(Color.white.opacity(0.80))
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(red: 0.10, green: 0.10, blue: 0.18))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.07), lineWidth: 1)
                        )
                    }

                    // ── Action Buttons ────────────────────────────────────────
                    VStack(spacing: 12) {

                        // Add to Meal Plan
                        Button(action: {
                            onAddToPlan()
                            dismiss()
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: isInPlan ? "checkmark.circle.fill" : "plus.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                Text(isInPlan ? "Already in Meal Plan" : "Add to Meal Plan")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                isInPlan
                                    ? LinearGradient(colors: [Color(red: 0.20, green: 0.20, blue: 0.30), Color(red: 0.20, green: 0.20, blue: 0.30)], startPoint: .leading, endPoint: .trailing)
                                    : LinearGradient(colors: [Color(red: 0.10, green: 0.62, blue: 0.45), Color(red: 0.05, green: 0.45, blue: 0.30)], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(16)
                            .shadow(
                                color: isInPlan ? .clear : Color(red: 0.10, green: 0.62, blue: 0.45).opacity(0.40),
                                radius: 14, y: 6
                            )
                        }
                        .disabled(isInPlan)

                        // Mark as Eaten Today
                        Button(action: {
                            onMarkEaten()
                            dismiss()
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: isEaten ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 16))
                                    .foregroundColor(isEaten ? Color(red: 0.55, green: 1.0, blue: 0.75) : Color.white.opacity(0.60))
                                Text(isEaten ? "Eaten Today ✓" : "Mark as Eaten Today")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(isEaten ? Color(red: 0.55, green: 1.0, blue: 0.75) : Color.white.opacity(0.80))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(red: 0.10, green: 0.10, blue: 0.18))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        isEaten
                                            ? Color(red: 0.55, green: 1.0, blue: 0.75).opacity(0.35)
                                            : Color.white.opacity(0.10),
                                        lineWidth: 1.5
                                    )
                            )
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Meal Plan Sheet

struct MealPlanSheet: View {

    @Binding var mealPlan: [DietFood]
    @Binding var eatenToday: Set<UUID>
    let onMarkEaten: (DietFood) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.10).ignoresSafeArea()
            RadialGradient(
                colors: [Color(red: 0.10, green: 0.62, blue: 0.45).opacity(0.20), .clear],
                center: .top, startRadius: 0, endRadius: 300
            ).ignoresSafeArea()

            VStack(spacing: 0) {

                // Handle + header
                VStack(spacing: 16) {
                    HStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.18))
                            .frame(width: 40, height: 4)
                        Spacer()
                    }
                    .padding(.top, 14)

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("MY MEAL PLAN")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color(red: 0.55, green: 1.0, blue: 0.75).opacity(0.8))
                                .tracking(1.5)
                            Text("\(mealPlan.count) foods added")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Button(action: { dismiss() }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.08))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "xmark")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.60))
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                if mealPlan.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "list.clipboard")
                            .font(.system(size: 44))
                            .foregroundColor(Color.white.opacity(0.15))
                        Text("No foods in your plan yet")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.35))
                        Text("Tap any food and choose\n'Add to Meal Plan'")
                            .font(.system(size: 13))
                            .foregroundColor(Color.white.opacity(0.22))
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            ForEach(Array(mealPlan.enumerated()), id: \.element.id) { index, food in
                                HStack(spacing: 14) {

                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(red: 0.10, green: 0.62, blue: 0.45).opacity(0.15))
                                            .frame(width: 44, height: 44)
                                        Text(food.emoji)
                                            .font(.system(size: 24))
                                        if eatenToday.contains(food.id) {
                                            Circle()
                                                .fill(Color(red: 0.55, green: 1.0, blue: 0.75))
                                                .frame(width: 16, height: 16)
                                                .overlay(
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 8, weight: .bold))
                                                        .foregroundColor(Color(red: 0.05, green: 0.10, blue: 0.10))
                                                )
                                                .offset(x: 14, y: -14)
                                        }
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(food.name)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white)
                                        Text(food.servingTip)
                                            .font(.system(size: 11))
                                            .foregroundColor(Color(red: 0.55, green: 0.53, blue: 0.65))
                                            .lineLimit(1)
                                    }

                                    Spacer()

                                    // Mark eaten toggle
                                    Button(action: { onMarkEaten(food) }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(
                                                    eatenToday.contains(food.id)
                                                        ? Color(red: 0.55, green: 1.0, blue: 0.75).opacity(0.18)
                                                        : Color.white.opacity(0.06)
                                                )
                                                .frame(width: 32, height: 32)
                                            Image(systemName: eatenToday.contains(food.id) ? "checkmark" : "plus")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(
                                                    eatenToday.contains(food.id)
                                                        ? Color(red: 0.55, green: 1.0, blue: 0.75)
                                                        : Color.white.opacity(0.40)
                                                )
                                        }
                                    }

                                    // Remove from plan
                                    Button(action: {
                                        mealPlan.removeAll { $0.id == food.id }
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color(red: 1.0, green: 0.35, blue: 0.35).opacity(0.12))
                                                .frame(width: 32, height: 32)
                                            Image(systemName: "trash")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.45))
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 13)
                                .overlay(
                                    Rectangle()
                                        .fill(Color.white.opacity(0.06))
                                        .frame(height: 1)
                                        .padding(.leading, 78),
                                    alignment: index == mealPlan.count - 1 ? .top : .bottom
                                )
                            }
                        }
                        .background(Color(red: 0.10, green: 0.10, blue: 0.18))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.07), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
    }
}

// MARK: - Daily Checklist Sheet

struct DailyChecklistSheet: View {

    let allFoods: [DietFood]
    @Binding var eatenToday: Set<UUID>
    @Environment(\.dismiss) var dismiss

    var eatenCount: Int { eatenToday.count }
    var progress: CGFloat { allFoods.isEmpty ? 0 : CGFloat(eatenCount) / CGFloat(allFoods.count) }

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.10).ignoresSafeArea()
            RadialGradient(
                colors: [Color(red: 0.50, green: 0.85, blue: 1.0).opacity(0.18), .clear],
                center: .top, startRadius: 0, endRadius: 300
            ).ignoresSafeArea()

            VStack(spacing: 0) {

                // Handle + header
                VStack(spacing: 16) {
                    HStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.18))
                            .frame(width: 40, height: 4)
                        Spacer()
                    }
                    .padding(.top, 14)

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("TODAY'S CHECKLIST")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color(red: 0.50, green: 0.85, blue: 1.0).opacity(0.8))
                                .tracking(1.5)
                            Text("\(eatenCount) of \(allFoods.count) eaten")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Button(action: { dismiss() }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.08))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "xmark")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.60))
                            }
                        }
                    }

                    // Progress bar
                    VStack(spacing: 6) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.08))
                                    .frame(height: 8)
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(red: 0.50, green: 0.85, blue: 1.0), Color(red: 0.55, green: 1.0, blue: 0.75)],
                                            startPoint: .leading, endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * progress, height: 8)
                                    .animation(.easeOut(duration: 0.5), value: eatenCount)
                            }
                        }
                        .frame(height: 8)

                        Text("\(Int(progress * 100))% of daily nutrition goals met")
                            .font(.system(size: 11))
                            .foregroundColor(Color.white.opacity(0.35))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(Array(allFoods.enumerated()), id: \.element.id) { index, food in
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    if eatenToday.contains(food.id) {
                                        eatenToday.remove(food.id)
                                    } else {
                                        eatenToday.insert(food.id)
                                    }
                                }
                            }) {
                                HStack(spacing: 14) {

                                    // Checkbox
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(
                                                eatenToday.contains(food.id)
                                                    ? Color(red: 0.55, green: 1.0, blue: 0.75).opacity(0.20)
                                                    : Color.white.opacity(0.06)
                                            )
                                            .frame(width: 28, height: 28)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(
                                                        eatenToday.contains(food.id)
                                                            ? Color(red: 0.55, green: 1.0, blue: 0.75).opacity(0.50)
                                                            : Color.white.opacity(0.12),
                                                        lineWidth: 1
                                                    )
                                            )
                                        if eatenToday.contains(food.id) {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(Color(red: 0.55, green: 1.0, blue: 0.75))
                                        }
                                    }

                                    Text(food.emoji)
                                        .font(.system(size: 22))

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(food.name)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(eatenToday.contains(food.id) ? Color.white.opacity(0.45) : .white)
                                            .strikethrough(eatenToday.contains(food.id), color: Color.white.opacity(0.30))
                                        Text(food.servingTip)
                                            .font(.system(size: 11))
                                            .foregroundColor(Color(red: 0.55, green: 0.53, blue: 0.65))
                                            .lineLimit(1)
                                    }

                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .overlay(
                                    Rectangle()
                                        .fill(Color.white.opacity(0.06))
                                        .frame(height: 1)
                                        .padding(.leading, 76),
                                    alignment: index == allFoods.count - 1 ? .top : .bottom
                                )
                            }
                        }
                    }
                    .background(Color(red: 0.10, green: 0.10, blue: 0.18))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.07), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}

#Preview {
    DietView()
}
