//
//  DietView.swift
//  Hair AI
//

import SwiftUI

// MARK: - Models

struct DietRecipe: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let bgColors: [Color]
    let prepTime: String
    let calories: String
    let benefit: String
    let category: String
    let ingredients: [String]
    let steps: [String]
    var isFavorite: Bool = false
}

struct DietFoodItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let emoji: String
    let benefit: String
    let nutrition: String
    let bgColor: Color
}

// MARK: - DietView

struct DietView: View {

    @State private var selectedCategory = 0
    @State private var selectedRecipe: DietRecipe? = nil
    @State private var recipes: [DietRecipe] = DietView.allRecipes
    @State private var eatenToday: Set<UUID> = []
    @State private var showMealPlan = false
    @State private var waterGlassCount = 0

    private let categories = ["🌟 All", "🥗 Salads", "🍳 Breakfast", "🐟 Protein", "🍵 Drinks", "🥣 Bowls"]

    private var filteredRecipes: [DietRecipe] {
        switch selectedCategory {
        case 1: return recipes.filter { $0.category == "Salad" }
        case 2: return recipes.filter { $0.category == "Breakfast" }
        case 3: return recipes.filter { $0.category == "Protein" }
        case 4: return recipes.filter { $0.category == "Drink" }
        case 5: return recipes.filter { $0.category == "Bowl" }
        default: return recipes
        }
    }

    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.04, blue: 0.12).ignoresSafeArea()
            dietBlobs

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    dietHeader
                    hairNutritionScore
                    waterTrackerRow
                    todaysMealBanner
                    categoryFilter
                    recipeGrid
                    topFoodsSection
                    Spacer(minLength: 110)
                }
            }
        }
        .sheet(item: $selectedRecipe) { recipe in
            RecipeDetailSheet(recipe: recipe)
        }
    }

    // MARK: - Background

    private var dietBlobs: some View {
        ZStack {
            Circle().fill(Color(red: 0.20, green: 0.75, blue: 0.35).opacity(0.12))
                .frame(width: 350, height: 350).blur(radius: 90).offset(x: -100, y: -100)
            Circle().fill(Color(red: 0.95, green: 0.65, blue: 0.10).opacity(0.10))
                .frame(width: 280, height: 280).blur(radius: 80).offset(x: 130, y: 200)
        }
    }

    // MARK: - Header

    private var dietHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("🥗 Hair Nutrition")
                    .font(.system(size: 28, weight: .bold)).foregroundColor(.white)
                Text("Feed your follicles from the inside 🌱")
                    .font(.system(size: 13)).foregroundColor(Color.white.opacity(0.50))
            }
            Spacer()
            Button(action: { showMealPlan = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar").font(.system(size: 14))
                    Text("Plan").font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(Capsule().fill(Color(red: 0.20, green: 0.75, blue: 0.35).opacity(0.35)))
                .overlay(Capsule().stroke(Color(red: 0.25, green: 0.85, blue: 0.45).opacity(0.50), lineWidth: 1))
            }
        }
        .padding(.horizontal, 20).padding(.top, 60).padding(.bottom, 16)
    }

    // MARK: - Hair Nutrition Score

    private var hairNutritionScore: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(LinearGradient(
                    colors: [Color(red: 0.10, green: 0.60, blue: 0.35), Color(red: 0.05, green: 0.40, blue: 0.22)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.12), lineWidth: 1))

            HStack(spacing: 0) {
                // Mascot
                VStack(spacing: 4) {
                    Text("🥑").font(.system(size: 56))
                    Text("Hair Buddy").font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.80))
                }
                .padding(.leading, 16)

                Spacer()

                // Stats
                VStack(spacing: 8) {
                    Text("Today's Nutrition").font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.75))
                    HStack(spacing: 16) {
                        nutrientBadge(label: "Protein", value: "52g", icon: "💪")
                        nutrientBadge(label: "Biotin", value: "8mcg", icon: "🧬")
                        nutrientBadge(label: "Iron", value: "14mg", icon: "⚡")
                    }
                    // Progress bar
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Hair Health Score").font(.system(size: 11)).foregroundColor(.white.opacity(0.60))
                            Spacer()
                            Text("74/100 🌟").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.white.opacity(0.15)).frame(height: 6)
                                Capsule()
                                    .fill(LinearGradient(colors: [Color(red: 0.20, green: 0.90, blue: 0.55),
                                                                   Color(red: 0.10, green: 0.70, blue: 0.35)],
                                                          startPoint: .leading, endPoint: .trailing))
                                    .frame(width: geo.size.width * 0.74, height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                    .frame(width: 180)
                }
                .padding(.trailing, 16)
            }
            .padding(.vertical, 16)
        }
        .padding(.horizontal, 20).padding(.bottom, 16)
    }

    private func nutrientBadge(label: String, value: String, icon: String) -> some View {
        VStack(spacing: 2) {
            Text(icon).font(.system(size: 16))
            Text(value).font(.system(size: 13, weight: .bold)).foregroundColor(.white)
            Text(label).font(.system(size: 9)).foregroundColor(.white.opacity(0.60))
        }
    }

    // MARK: - Water Tracker

    private var waterTrackerRow: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 0.10, green: 0.45, blue: 0.85).opacity(0.20))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(red: 0.30, green: 0.65, blue: 1.0).opacity(0.30), lineWidth: 1))

            HStack(spacing: 12) {
                Text("💧").font(.system(size: 28))
                VStack(alignment: .leading, spacing: 3) {
                    Text("Water Intake").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                    Text("\(waterGlassCount)/8 glasses").font(.system(size: 11)).foregroundColor(Color.white.opacity(0.55))
                }

                Spacer()

                // Glass dots
                HStack(spacing: 5) {
                    ForEach(0..<8, id: \.self) { i in
                        Circle()
                            .fill(i < waterGlassCount
                                  ? Color(red: 0.30, green: 0.70, blue: 1.0)
                                  : Color.white.opacity(0.15))
                            .frame(width: 10, height: 10)
                    }
                }

                Button(action: { if waterGlassCount < 8 { waterGlassCount += 1 } }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(Color(red: 0.30, green: 0.70, blue: 1.0))
                }
                .buttonStyle(.plain)
            }
            .padding(14)
        }
        .padding(.horizontal, 20).padding(.bottom, 16)
    }

    // MARK: - Today's Meal Banner

    private var todaysMealBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("🍽️ Today's Meal Plan")
                .font(.system(size: 16, weight: .bold)).foregroundColor(.white).padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(DietView.mealPlanItems, id: \.name) { meal in
                        mealPlanCard(meal: meal)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 20)
    }

    private func mealPlanCard(meal: (emoji: String, name: String, time: String, cal: String, bg: [Color])) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(LinearGradient(colors: meal.bg, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 130, height: 110)

            VStack(spacing: 6) {
                Text(meal.emoji).font(.system(size: 36))
                Text(meal.name).font(.system(size: 12, weight: .bold)).foregroundColor(.white).lineLimit(1)
                HStack(spacing: 6) {
                    timeBadge(text: meal.time, color: Color.black.opacity(0.25))
                    timeBadge(text: meal.cal, color: Color(red: 0.20, green: 0.80, blue: 0.45).opacity(0.70))
                }
            }
        }
    }

    static let mealPlanItems: [(emoji: String, name: String, time: String, cal: String, bg: [Color])] = [
        (emoji: "🍳", name: "Egg Bowl",   time: "⏱ 10m", cal: "🔥 280", bg: [Color(red: 0.95, green: 0.70, blue: 0.15), Color(red: 0.85, green: 0.45, blue: 0.05)]),
        (emoji: "🥗", name: "Salmon Salad", time: "⏱ 15m", cal: "🔥 320", bg: [Color(red: 0.10, green: 0.65, blue: 0.85), Color(red: 0.05, green: 0.40, blue: 0.65)]),
        (emoji: "🫐", name: "Berry Smoothie", time: "⏱ 5m",  cal: "🔥 180", bg: [Color(red: 0.70, green: 0.25, blue: 0.90), Color(red: 0.45, green: 0.10, blue: 0.70)]),
        (emoji: "🥜", name: "Walnut Mix",  time: "⏱ 2m",  cal: "🔥 210", bg: [Color(red: 0.85, green: 0.50, blue: 0.10), Color(red: 0.65, green: 0.30, blue: 0.05)]),
        (emoji: "🐟", name: "Grilled Fish", time: "⏱ 20m", cal: "🔥 380", bg: [Color(red: 0.15, green: 0.55, blue: 0.40), Color(red: 0.05, green: 0.35, blue: 0.22)]),
    ]

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(categories.enumerated()), id: \.offset) { idx, cat in
                    Button(action: { withAnimation { selectedCategory = idx } }) {
                        Text(cat)
                            .font(.system(size: 13, weight: selectedCategory == idx ? .bold : .medium))
                            .foregroundColor(selectedCategory == idx ? .white : Color.white.opacity(0.50))
                            .padding(.horizontal, 16).padding(.vertical, 9)
                            .background(Group {
                                if selectedCategory == idx {
                                    LinearGradient(colors: [Color(red: 0.20, green: 0.75, blue: 0.35),
                                                             Color(red: 0.10, green: 0.55, blue: 0.25)],
                                                   startPoint: .leading, endPoint: .trailing)
                                        .clipShape(Capsule())
                                } else {
                                    Color.white.opacity(0.07).clipShape(Capsule())
                                }
                            })
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 16)
    }

    // MARK: - Recipe Grid (photo-style cards)

    private var recipeGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🍽️ Recipes for Hair Growth")
                    .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                Spacer()
                Text("\(filteredRecipes.count) recipes")
                    .font(.system(size: 12)).foregroundColor(Color.white.opacity(0.40))
            }
            .padding(.horizontal, 20)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                ForEach($recipes) { $recipe in
                    if filteredRecipes.contains(where: { $0.id == recipe.id }) {
                        RecipePhotoCard(recipe: $recipe) {
                            selectedRecipe = recipe
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 24)
    }

    // MARK: - Top Foods

    private var topFoodsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("⭐ Top Hair Foods")
                .font(.system(size: 16, weight: .bold)).foregroundColor(.white).padding(.horizontal, 20)

            LazyVStack(spacing: 10) {
                ForEach(DietView.topFoods) { food in
                    topFoodRow(food: food)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 24)
    }

    private func topFoodRow(food: DietFoodItem) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(food.bgColor.opacity(0.22)).frame(width: 52, height: 52)
                Text(food.emoji).font(.system(size: 28))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(food.name).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                Text(food.benefit).font(.system(size: 12)).foregroundColor(Color.white.opacity(0.65)).lineLimit(1)
                Text(food.nutrition).font(.system(size: 10)).foregroundColor(food.bgColor).lineLimit(1)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 12))
                .foregroundColor(Color.white.opacity(0.25))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(food.bgColor.opacity(0.20), lineWidth: 1))
        )
    }

    // MARK: - Data

    static let allRecipes: [DietRecipe] = [
        DietRecipe(
            name: "Greek Salad with Chicken",
            emoji: "🥗",
            bgColors: [Color(red: 0.15, green: 0.65, blue: 0.40), Color(red: 0.05, green: 0.45, blue: 0.25)],
            prepTime: "20 min ⏱", calories: "173 Cal 🔥",
            benefit: "Boosts shine & growth",
            category: "Salad",
            ingredients: ["Chicken breast 🍗", "Cucumber 🥒", "Tomatoes 🍅", "Olives 🫒", "Feta cheese 🧀", "Olive oil 🫙"],
            steps: ["Grill chicken 5 min each side", "Chop all vegetables", "Mix with olive oil & feta", "Season with herbs"]
        ),
        DietRecipe(
            name: "Coleslaw",
            emoji: "🥬",
            bgColors: [Color(red: 0.50, green: 0.80, blue: 0.20), Color(red: 0.30, green: 0.60, blue: 0.08)],
            prepTime: "10 min ⏱", calories: "21 Cal 🔥",
            benefit: "Rich in Vitamin C",
            category: "Salad",
            ingredients: ["Cabbage 🥬", "Carrots 🥕", "Apple cider vinegar 🍶", "Honey 🍯", "Parsley 🌿"],
            steps: ["Shred cabbage and carrots finely", "Mix with vinegar & honey", "Toss with fresh parsley"]
        ),
        DietRecipe(
            name: "Veggie Dip Bowl",
            emoji: "🥕",
            bgColors: [Color(red: 0.95, green: 0.60, blue: 0.15), Color(red: 0.80, green: 0.40, blue: 0.05)],
            prepTime: "10 min ⏱", calories: "27 Cal 🔥",
            benefit: "Beta-carotene for scalp",
            category: "Salad",
            ingredients: ["Carrots 🥕", "Celery 🌿", "Hummus 🫘", "Bell peppers 🫑", "Cucumber 🥒"],
            steps: ["Slice all veggies into sticks", "Serve with hummus dip", "Garnish with paprika"]
        ),
        DietRecipe(
            name: "Waldorf Salad",
            emoji: "🍎",
            bgColors: [Color(red: 0.90, green: 0.25, blue: 0.50), Color(red: 0.65, green: 0.10, blue: 0.30)],
            prepTime: "15 min ⏱", calories: "103 Cal 🔥",
            benefit: "Walnuts boost hair density",
            category: "Salad",
            ingredients: ["Apple 🍎", "Walnuts 🌰", "Celery 🌿", "Greek yogurt 🥛", "Lemon juice 🍋"],
            steps: ["Dice apple and celery", "Mix yogurt with lemon", "Fold in walnuts", "Combine everything"]
        ),
        DietRecipe(
            name: "Biotin Egg Bowl",
            emoji: "🍳",
            bgColors: [Color(red: 0.95, green: 0.75, blue: 0.15), Color(red: 0.85, green: 0.50, blue: 0.05)],
            prepTime: "10 min ⏱", calories: "310 Cal 🔥",
            benefit: "Biotin for hair keratin",
            category: "Breakfast",
            ingredients: ["Eggs 🥚", "Spinach 🌿", "Avocado 🥑", "Whole grain toast 🍞", "Seeds 🌱"],
            steps: ["Poach or scramble eggs", "Sauté spinach with garlic", "Slice avocado", "Assemble on toast"]
        ),
        DietRecipe(
            name: "Berry Smoothie Bowl",
            emoji: "🫐",
            bgColors: [Color(red: 0.65, green: 0.20, blue: 0.88), Color(red: 0.40, green: 0.08, blue: 0.65)],
            prepTime: "5 min ⏱", calories: "185 Cal 🔥",
            benefit: "Antioxidants for shine",
            category: "Breakfast",
            ingredients: ["Blueberries 🫐", "Strawberries 🍓", "Banana 🍌", "Almond milk 🥛", "Chia seeds 🌱", "Granola"],
            steps: ["Blend berries with banana and almond milk", "Pour into bowl", "Top with granola and seeds"]
        ),
        DietRecipe(
            name: "Grilled Salmon Plate",
            emoji: "🐟",
            bgColors: [Color(red: 0.10, green: 0.55, blue: 0.85), Color(red: 0.05, green: 0.35, blue: 0.65)],
            prepTime: "20 min ⏱", calories: "380 Cal 🔥",
            benefit: "Omega-3 prevents hair loss",
            category: "Protein",
            ingredients: ["Salmon fillet 🐟", "Lemon 🍋", "Dill 🌿", "Olive oil 🫙", "Asparagus 🌿"],
            steps: ["Season salmon with lemon and herbs", "Grill 4 min each side", "Roast asparagus", "Plate with lemon wedge"]
        ),
        DietRecipe(
            name: "Lentil Power Soup",
            emoji: "🍲",
            bgColors: [Color(red: 0.85, green: 0.45, blue: 0.10), Color(red: 0.65, green: 0.25, blue: 0.05)],
            prepTime: "25 min ⏱", calories: "280 Cal 🔥",
            benefit: "Iron prevents hair shedding",
            category: "Bowl",
            ingredients: ["Red lentils 🫘", "Spinach 🌿", "Tomatoes 🍅", "Cumin 🌶️", "Garlic 🧄", "Onion 🧅"],
            steps: ["Sauté onion and garlic", "Add lentils and tomatoes", "Simmer 20 minutes", "Stir in spinach last 2 min"]
        ),
        DietRecipe(
            name: "Rosemary Green Tea",
            emoji: "🍵",
            bgColors: [Color(red: 0.15, green: 0.65, blue: 0.55), Color(red: 0.05, green: 0.45, blue: 0.35)],
            prepTime: "5 min ⏱", calories: "5 Cal 🔥",
            benefit: "Stimulates follicles",
            category: "Drink",
            ingredients: ["Green tea 🍵", "Fresh rosemary 🌿", "Honey 🍯", "Lemon 🍋"],
            steps: ["Steep tea 3 minutes", "Add rosemary sprig", "Add honey and lemon", "Drink warm daily"]
        ),
        DietRecipe(
            name: "Avocado Protein Bowl",
            emoji: "🥑",
            bgColors: [Color(red: 0.25, green: 0.72, blue: 0.30), Color(red: 0.10, green: 0.52, blue: 0.18)],
            prepTime: "15 min ⏱", calories: "420 Cal 🔥",
            benefit: "Vitamin E for scalp health",
            category: "Bowl",
            ingredients: ["Avocado 🥑", "Quinoa 🌾", "Edamame 🫘", "Cucumber 🥒", "Sesame seeds 🌱", "Soy sauce"],
            steps: ["Cook quinoa 12 minutes", "Slice avocado and cucumber", "Assemble bowl", "Drizzle with soy sauce and seeds"]
        ),
        DietRecipe(
            name: "Walnut Oat Breakfast",
            emoji: "🌰",
            bgColors: [Color(red: 0.80, green: 0.50, blue: 0.20), Color(red: 0.60, green: 0.30, blue: 0.08)],
            prepTime: "10 min ⏱", calories: "340 Cal 🔥",
            benefit: "Zinc for strong strands",
            category: "Breakfast",
            ingredients: ["Rolled oats 🌾", "Walnuts 🌰", "Pumpkin seeds 🎃", "Honey 🍯", "Cinnamon 🌿", "Almond milk 🥛"],
            steps: ["Heat oats with milk 5 min", "Top with walnuts and seeds", "Drizzle honey", "Sprinkle cinnamon"]
        ),
        DietRecipe(
            name: "Collagen Bone Broth",
            emoji: "🍜",
            bgColors: [Color(red: 0.90, green: 0.30, blue: 0.55), Color(red: 0.65, green: 0.10, blue: 0.35)],
            prepTime: "30 min ⏱", calories: "95 Cal 🔥",
            benefit: "Collagen for hair structure",
            category: "Drink",
            ingredients: ["Bone broth 🦴", "Ginger 🫚", "Turmeric 🌶️", "Garlic 🧄", "Herbs 🌿"],
            steps: ["Heat broth gently", "Add ginger and turmeric", "Simmer 10 min", "Strain and sip warm"]
        ),
    ]

    static let topFoods: [DietFoodItem] = [
        DietFoodItem(name: "Salmon",   emoji: "🐟", benefit: "Omega-3 prevents hair loss",   nutrition: "Protein: 25g • Omega-3: 2.5g",  bgColor: Color(red: 0.10, green: 0.65, blue: 0.85)),
        DietFoodItem(name: "Eggs",     emoji: "🥚", benefit: "Biotin builds keratin",         nutrition: "Biotin: 10mcg • Protein: 13g",  bgColor: Color(red: 0.95, green: 0.75, blue: 0.15)),
        DietFoodItem(name: "Spinach",  emoji: "🌿", benefit: "Iron prevents shedding",        nutrition: "Iron: 2.7mg • Folate: 15%",     bgColor: Color(red: 0.20, green: 0.75, blue: 0.40)),
        DietFoodItem(name: "Walnuts",  emoji: "🌰", benefit: "Zinc strengthens strands",      nutrition: "Zinc: 0.9mg • Omega-3: 2.6g",   bgColor: Color(red: 0.80, green: 0.50, blue: 0.15)),
        DietFoodItem(name: "Avocado",  emoji: "🥑", benefit: "Vitamin E for scalp health",    nutrition: "Vit E: 10% • Healthy fats: 15g", bgColor: Color(red: 0.35, green: 0.70, blue: 0.20)),
        DietFoodItem(name: "Blueberries", emoji: "🫐", benefit: "Antioxidants for shine",    nutrition: "Vit C: 24% • Antioxidants: High", bgColor: Color(red: 0.50, green: 0.20, blue: 0.85)),
        DietFoodItem(name: "Sweet Potato", emoji: "🍠", benefit: "Beta-carotene = Vitamin A", nutrition: "Vit A: 107% • Fiber: 4g",       bgColor: Color(red: 0.95, green: 0.50, blue: 0.15)),
    ]
}

// MARK: - Recipe Photo Card

struct RecipePhotoCard: View {
    @Binding var recipe: DietRecipe
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                // Background gradient "photo"
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(colors: recipe.bgColors,
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 170)

                // Large emoji centred
                Text(recipe.emoji)
                    .font(.system(size: 58))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(y: -16)

                // Favorite star top-right
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { recipe.isFavorite.toggle() }) {
                            Image(systemName: recipe.isFavorite ? "star.fill" : "star")
                                .font(.system(size: 14))
                                .foregroundColor(recipe.isFavorite ? Color(red: 0.95, green: 0.80, blue: 0.15) : .white.opacity(0.70))
                                .padding(7)
                                .background(Circle().fill(Color.black.opacity(0.30)))
                        }
                        .buttonStyle(.plain)
                        .padding(10)
                    }
                    Spacer()
                }

                // Info overlay at bottom
                VStack(alignment: .leading, spacing: 5) {
                    // Time + Cal badges
                    HStack(spacing: 6) {
                        timeBadge(text: recipe.prepTime, color: Color.black.opacity(0.45))
                        timeBadge(text: recipe.calories, color: Color(red: 0.15, green: 0.65, blue: 0.35).opacity(0.80))
                    }
                }
                .padding(.horizontal, 10).padding(.bottom, 10)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                VStack {
                    Spacer()
                    Text(recipe.name)
                        .font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                        .lineLimit(1).padding(.horizontal, 4)
                }
                .offset(y: 26)
            )
            .padding(.bottom, 28)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Time Badge helper

func timeBadge(text: String, color: Color) -> some View {
    Text(text)
        .font(.system(size: 11, weight: .bold))
        .foregroundColor(.white)
        .padding(.horizontal, 10).padding(.vertical, 5)
        .background(Capsule().fill(color))
}

// MARK: - Recipe Detail Sheet

struct RecipeDetailSheet: View {
    let recipe: DietRecipe
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.04, blue: 0.12).ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hero
                    ZStack {
                        LinearGradient(colors: recipe.bgColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                            .frame(height: 240)
                        VStack(spacing: 8) {
                            Text(recipe.emoji).font(.system(size: 80))
                            HStack(spacing: 10) {
                                timeBadge(text: recipe.prepTime, color: Color.black.opacity(0.40))
                                timeBadge(text: recipe.calories, color: Color(red: 0.15, green: 0.65, blue: 0.35).opacity(0.80))
                                timeBadge(text: "✨ " + recipe.benefit, color: Color.black.opacity(0.30))
                            }
                        }

                        // Close button
                        VStack {
                            HStack {
                                Spacer()
                                Button(action: { dismiss() }) {
                                    Image(systemName: "xmark").font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(10).background(Circle().fill(Color.black.opacity(0.40)))
                                }
                                .padding()
                            }
                            Spacer()
                        }
                    }

                    VStack(alignment: .leading, spacing: 20) {
                        Text(recipe.name)
                            .font(.system(size: 24, weight: .bold)).foregroundColor(.white)

                        // Ingredients
                        VStack(alignment: .leading, spacing: 10) {
                            Text("🛒 Ingredients").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                            ForEach(recipe.ingredients, id: \.self) { ing in
                                HStack(spacing: 10) {
                                    Circle().fill(Color(red: 0.20, green: 0.75, blue: 0.40)).frame(width: 6, height: 6)
                                    Text(ing).font(.system(size: 14)).foregroundColor(Color.white.opacity(0.80))
                                }
                            }
                        }

                        // Steps
                        VStack(alignment: .leading, spacing: 10) {
                            Text("👩‍🍳 How to Make").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                            ForEach(Array(recipe.steps.enumerated()), id: \.offset) { idx, step in
                                HStack(alignment: .top, spacing: 12) {
                                    ZStack {
                                        Circle().fill(Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.30))
                                            .frame(width: 28, height: 28)
                                        Text("\(idx + 1)").font(.system(size: 13, weight: .bold))
                                            .foregroundColor(Color(red: 0.90, green: 0.25, blue: 0.55))
                                    }
                                    Text(step).font(.system(size: 14)).foregroundColor(Color.white.opacity(0.80))
                                        .padding(.top, 4)
                                }
                            }
                        }

                        // Hair benefit
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0.20, green: 0.75, blue: 0.40).opacity(0.18))
                                .overlay(RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 0.20, green: 0.85, blue: 0.50).opacity(0.35), lineWidth: 1))
                            HStack(spacing: 12) {
                                Text("🌱").font(.system(size: 28))
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Hair Benefit").font(.system(size: 12, weight: .bold))
                                        .foregroundColor(Color(red: 0.20, green: 0.85, blue: 0.50))
                                    Text(recipe.benefit).font(.system(size: 14)).foregroundColor(.white)
                                }
                                Spacer()
                            }
                            .padding(14)
                        }
                    }
                    .padding(20)
                    Spacer(minLength: 40)
                }
            }
        }
    }
}

#Preview {
    DietView()
}
