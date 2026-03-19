//
//  DiscoverView.swift
//  Hair AI
//

import SwiftUI

// MARK: - Models

private struct HairFact: Identifiable {
    let id = UUID()
    let emoji: String
    let headline: String
    let detail: String
    let category: String
    let bg: [Color]
}

private struct QuizOption: Identifiable {
    let id = UUID()
    let emoji: String
    let label: String
}

private struct HairMilestone: Identifiable {
    let id = UUID()
    let era: String
    let icon: String
    let fact: String
    let color: Color
}

struct AIMessage: Identifiable {
    let id = UUID()
    let isAI: Bool
    let text: String
    let emoji: String
}

// MARK: - DiscoverView

struct DiscoverView: View {

    @State private var factIndex = 0
    @State private var selectedQuizAnswer: Int? = nil
    @State private var showQuizResult = false
    @State private var chatInput = ""
    @State private var chatMessages: [AIMessage] = DiscoverView.defaultMessages
    @State private var selectedChallenge = 0
    @State private var animateFact = false

    private let facts: [HairFact] = [
        HairFact(emoji: "👶", headline: "100,000 Follicles at Birth",
                 detail: "Babies are born with approximately 100,000 hair follicles. The human body never grows new follicles — this is your lifetime supply! 🍼",
                 category: "Biology 🧬",
                 bg: [Color(red: 0.90, green: 0.25, blue: 0.55), Color(red: 0.65, green: 0.10, blue: 0.80)]),
        HairFact(emoji: "📏", headline: "6 Inches Per Year",
                 detail: "Hair grows an average of 6 inches (15cm) per year. Growth is fastest between ages 15–30 and slows after 50. 🌱",
                 category: "Growth 🌱",
                 bg: [Color(red: 0.10, green: 0.65, blue: 0.85), Color(red: 0.05, green: 0.40, blue: 0.65)]),
        HairFact(emoji: "🏺", headline: "Cleopatra's Secret",
                 detail: "Ancient Egyptians used castor oil, rosemary, and animal fats for hair care 3,000 years ago. Castor oil is still one of the most effective oils today! ✨",
                 category: "History 🏺",
                 bg: [Color(red: 0.85, green: 0.55, blue: 0.10), Color(red: 0.65, green: 0.30, blue: 0.05)]),
        HairFact(emoji: "💪", headline: "Stronger Than Steel",
                 detail: "A single hair strand can support up to 100 grams of weight. A full head of hair could theoretically hold 2 adult elephants! 🐘",
                 category: "Science 🔬",
                 bg: [Color(red: 0.20, green: 0.70, blue: 0.45), Color(red: 0.05, green: 0.45, blue: 0.25)]),
        HairFact(emoji: "🌊", headline: "90% Growing Right Now",
                 detail: "At any moment, about 90% of your hair is in the Anagen (active growth) phase, which lasts 2–7 years per strand. 💫",
                 category: "Biology 🧬",
                 bg: [Color(red: 0.45, green: 0.18, blue: 0.88), Color(red: 0.25, green: 0.08, blue: 0.65)]),
        HairFact(emoji: "🧬", headline: "50–100 Hairs Lost Daily",
                 detail: "Losing 50–100 hairs per day is completely normal! Your body replaces them automatically — worry only if it's significantly more. 🔄",
                 category: "Health 💊",
                 bg: [Color(red: 0.95, green: 0.35, blue: 0.40), Color(red: 0.75, green: 0.15, blue: 0.20)]),
        HairFact(emoji: "🍃", headline: "Rosemary = Minoxidil",
                 detail: "A 2023 study showed rosemary oil is as effective as 2% minoxidil for hair growth, with fewer side effects! 🌿",
                 category: "Research 📚",
                 bg: [Color(red: 0.10, green: 0.68, blue: 0.48), Color(red: 0.05, green: 0.45, blue: 0.30)]),
        HairFact(emoji: "🌙", headline: "Hair Grows While You Sleep",
                 detail: "Growth hormone (HGH) is released during deep sleep, directly stimulating hair follicles. Beauty sleep is scientifically real! 😴",
                 category: "Sleep 🌙",
                 bg: [Color(red: 0.20, green: 0.35, blue: 0.85), Color(red: 0.10, green: 0.15, blue: 0.60)]),
    ]

    private let quizOptions: [QuizOption] = [
        QuizOption(emoji: "🌊", label: "Wavy"),
        QuizOption(emoji: "🔄", label: "Curly"),
        QuizOption(emoji: "〰️", label: "Straight"),
        QuizOption(emoji: "🌀", label: "Coily"),
    ]

    private let milestones: [HairMilestone] = [
        HairMilestone(era: "3000 BC", icon: "🏺", fact: "Egyptians use castor oil & henna for hair growth and colour", color: Color(red: 0.85, green: 0.55, blue: 0.10)),
        HairMilestone(era: "500 BC", icon: "🍃", fact: "Ancient Greeks apply olive oil + herbs to keep hair lustrous", color: Color(red: 0.20, green: 0.70, blue: 0.35)),
        HairMilestone(era: "1800s", icon: "🧴", fact: "First commercial shampoo invented — previously people washed hair with soap", color: Color(red: 0.45, green: 0.18, blue: 0.88)),
        HairMilestone(era: "1950s", icon: "✂️", fact: "Modern hair salons boom globally; chemical perms and dyes popularised", color: Color(red: 0.90, green: 0.25, blue: 0.55)),
        HairMilestone(era: "1990s", icon: "💊", fact: "Minoxidil approved as first FDA hair loss treatment for women", color: Color(red: 0.10, green: 0.65, blue: 0.85)),
        HairMilestone(era: "2023", icon: "🌿", fact: "Rosemary oil proven as effective as minoxidil with no side effects", color: Color(red: 0.15, green: 0.75, blue: 0.50)),
    ]

    private let weekChallenges = [
        ("💆‍♀️", "Scalp Massage Week", "5-minute daily scalp massage for 7 days", "Promotes blood circulation to follicles 🩸"),
        ("💧", "Hydration Challenge", "8 glasses of water every day for 7 days", "Hydrated scalp = softer, shinier hair 🌊"),
        ("🥗", "Hair Nutrition Week", "Eat 1 hair-healthy meal daily for 7 days", "Feed your follicles from the inside! 🌱"),
        ("🌿", "Oil Treatment Week", "Oil treatment every 2 days for 7 days", "Deep nourishment for dry or damaged hair 🌴"),
    ]

    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.04, blue: 0.12).ignoresSafeArea()
            discoverBlobs

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    discoverHeader
                    factsCarousel
                    weekChallengeSection
                    aiCoachSection
                    quizSection
                    hairHistorySection
                    trendingTopics
                    Spacer(minLength: 110)
                }
            }
        }
    }

    // MARK: - Background Blobs

    private var discoverBlobs: some View {
        ZStack {
            Circle().fill(Color(red: 0.45, green: 0.18, blue: 0.88).opacity(0.14))
                .frame(width: 350, height: 350).blur(radius: 90).offset(x: 100, y: -150)
            Circle().fill(Color(red: 0.10, green: 0.65, blue: 0.85).opacity(0.10))
                .frame(width: 280, height: 280).blur(radius: 80).offset(x: -100, y: 200)
        }
    }

    // MARK: - Header

    private var discoverHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("✨ Discover")
                    .font(.system(size: 28, weight: .bold)).foregroundColor(.white)
                Text("Hair science, facts & AI coach 🤖")
                    .font(.system(size: 13)).foregroundColor(Color.white.opacity(0.50))
            }
            Spacer()
        }
        .padding(.horizontal, 20).padding(.top, 60).padding(.bottom, 18)
    }

    // MARK: - Facts Carousel

    private var factsCarousel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🧠 Hair Facts")
                    .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                Spacer()
                Text("\(factIndex + 1) / \(facts.count)")
                    .font(.system(size: 12)).foregroundColor(Color.white.opacity(0.40))
            }
            .padding(.horizontal, 20)

            TabView(selection: $factIndex) {
                ForEach(Array(facts.enumerated()), id: \.offset) { idx, fact in
                    factCard(fact: fact)
                        .padding(.horizontal, 20)
                        .tag(idx)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .frame(height: 220)
        }
        .padding(.bottom, 20)
    }

    private func factCard(fact: HairFact) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(LinearGradient(colors: fact.bg, startPoint: .topLeading, endPoint: .bottomTrailing))

            VStack(spacing: 12) {
                HStack {
                    Text(fact.category)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.80))
                        .padding(.horizontal, 12).padding(.vertical, 5)
                        .background(Capsule().fill(Color.white.opacity(0.20)))
                    Spacer()
                    Text(fact.emoji).font(.system(size: 40))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(fact.headline)
                        .font(.system(size: 19, weight: .bold)).foregroundColor(.white)
                    Text(fact.detail)
                        .font(.system(size: 13)).foregroundColor(.white.opacity(0.85)).lineLimit(3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(20)
        }
        .frame(height: 200)
    }

    // MARK: - Weekly Challenge

    private var weekChallengeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🏆 Weekly Challenges")
                .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(Array(weekChallenges.enumerated()), id: \.offset) { idx, challenge in
                        weekChallengeCard(
                            icon: challenge.0,
                            title: challenge.1,
                            subtitle: challenge.2,
                            reward: challenge.3,
                            isSelected: selectedChallenge == idx,
                            index: idx
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 24)
    }

    private func weekChallengeCard(icon: String, title: String, subtitle: String, reward: String, isSelected: Bool, index: Int) -> some View {
        Button(action: { withAnimation(.spring()) { selectedChallenge = index } }) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(icon).font(.system(size: 32))
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color(red: 0.20, green: 0.90, blue: 0.55))
                    }
                }
                Text(title).font(.system(size: 14, weight: .bold)).foregroundColor(.white).lineLimit(1)
                Text(subtitle).font(.system(size: 11)).foregroundColor(Color.white.opacity(0.60)).lineLimit(2)
                Text(reward).font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(red: 0.90, green: 0.75, blue: 0.20))
            }
            .padding(14)
            .frame(width: 170)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(isSelected
                          ? Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.25)
                          : Color.white.opacity(0.05))
                    .overlay(RoundedRectangle(cornerRadius: 18)
                        .stroke(isSelected
                                ? Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.55)
                                : Color.white.opacity(0.10), lineWidth: 1))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - AI Coach Chat

    private var aiCoachSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🤖 AI Hair Coach")
                    .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                Spacer()
                ZStack {
                    Circle().fill(Color(red: 0.20, green: 0.90, blue: 0.55)).frame(width: 8, height: 8)
                    Circle().fill(Color(red: 0.20, green: 0.90, blue: 0.55).opacity(0.30))
                        .frame(width: 14, height: 14)
                }
                Text("Online").font(.system(size: 11)).foregroundColor(Color(red: 0.20, green: 0.90, blue: 0.55))
            }
            .padding(.horizontal, 20)

            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.white.opacity(0.04))
                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.08), lineWidth: 1))

                VStack(spacing: 12) {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(chatMessages) { msg in
                                chatBubble(message: msg)
                            }
                        }
                        .padding(.top, 10)
                    }
                    .frame(height: 220)

                    // Quick prompts
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(["💧 Water intake?", "🥑 Best foods?", "🌿 Oil tips?", "📏 Track growth?", "💊 Vitamins?"], id: \.self) { prompt in
                                Button(action: { sendQuickMessage(prompt) }) {
                                    Text(prompt).font(.system(size: 12)).foregroundColor(Color.white.opacity(0.70))
                                        .padding(.horizontal, 12).padding(.vertical, 6)
                                        .background(Capsule().fill(Color.white.opacity(0.08)))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Input bar
                    HStack(spacing: 10) {
                        TextField("Ask about your hair...", text: $chatInput)
                            .foregroundColor(.white)
                            .padding(.horizontal, 14).padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.08)))

                        Button(action: { sendMessage() }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(Color(red: 0.90, green: 0.25, blue: 0.55))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 24)
    }

    private func chatBubble(message: AIMessage) -> some View {
        HStack(alignment: .top, spacing: 8) {
            if message.isAI {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color(red: 0.45, green: 0.18, blue: 0.88),
                                                       Color(red: 0.90, green: 0.25, blue: 0.55)],
                                             startPoint: .top, endPoint: .bottom))
                        .frame(width: 30, height: 30)
                    Text(message.emoji).font(.system(size: 14))
                }
            }

            VStack(alignment: message.isAI ? .leading : .trailing, spacing: 2) {
                Text(message.text)
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(message.isAI
                                  ? Color.white.opacity(0.08)
                                  : Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.30))
                    )
                    .frame(maxWidth: 240, alignment: message.isAI ? .leading : .trailing)
            }

            if !message.isAI { Spacer() }
        }
        .frame(maxWidth: .infinity, alignment: message.isAI ? .leading : .trailing)
    }

    private func sendMessage() {
        guard !chatInput.isEmpty else { return }
        let userMsg = AIMessage(isAI: false, text: chatInput, emoji: "👤")
        chatMessages.append(userMsg)
        let question = chatInput
        chatInput = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let reply = generateAIReply(for: question)
            chatMessages.append(AIMessage(isAI: true, text: reply, emoji: "🤖"))
        }
    }

    private func sendQuickMessage(_ prompt: String) {
        chatInput = prompt
        sendMessage()
    }

    private func generateAIReply(for question: String) -> String {
        let q = question.lowercased()
        if q.contains("water") || q.contains("hydrat") {
            return "💧 Aim for 8 glasses daily! Dehydration causes hair follicles to shrink, leading to dry, brittle hair. Add lemon for a vitamin C boost! 🍋"
        } else if q.contains("food") || q.contains("eat") || q.contains("avocado") || q.contains("diet") {
            return "🥑 Top hair foods: Salmon (omega-3), Eggs (biotin), Spinach (iron), Avocado (vitamin E), Walnuts (zinc). Aim for 2 servings daily! 🐟"
        } else if q.contains("oil") {
            return "🌿 Rosemary oil is clinically proven to boost growth! Mix 3-4 drops with coconut oil, massage into scalp for 5 minutes, 2-3x per week. 🫒"
        } else if q.contains("growth") || q.contains("grow") || q.contains("track") {
            return "📏 Log your hair length in the Progress tab monthly! Consistent oiling, protein intake, and scalp massage can boost growth by 20-30%! 🌱"
        } else if q.contains("vitamin") {
            return "💊 Key vitamins: Biotin (B7), Vitamin D, Iron, Zinc, Omega-3. Get tested before supplementing — deficiency in these is the #1 cause of excess hair loss! 🧬"
        } else {
            return "🤖 Great question! For personalised hair advice, use the Scan tab to get an AI analysis of your hair health. I can then give targeted recommendations! ✨"
        }
    }

    static let defaultMessages: [AIMessage] = [
        AIMessage(isAI: true, text: "Hey! 👋 I'm your personal AI Hair Coach! Ask me anything about hair growth, nutrition, oiling, or hair care routines! ✨", emoji: "🤖"),
        AIMessage(isAI: false, text: "What helps hair grow faster?", emoji: "👤"),
        AIMessage(isAI: true, text: "🌱 Top 3 growth boosters: 1) Rosemary oil massages 3x/week 2) Biotin + Vitamin D supplementation 3) High-protein diet (eggs, salmon, lentils). Combine all three for best results! 💪", emoji: "🤖"),
    ]

    // MARK: - Hair Quiz

    private var quizSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🎯 Quick Quiz")
                .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                .padding(.horizontal, 20)

            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(LinearGradient(
                        colors: [Color(red: 0.10, green: 0.55, blue: 0.95).opacity(0.18),
                                 Color(red: 0.45, green: 0.18, blue: 0.88).opacity(0.18)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.10), lineWidth: 1))

                VStack(spacing: 16) {
                    Text("Which natural ingredient is scientifically proven to boost hair growth as effectively as minoxidil? 🔬")
                        .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    let options = [("🌿", "Rosemary Oil"), ("🥥", "Coconut Oil"), ("🫚", "Argan Oil"), ("🌰", "Castor Oil")]
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(Array(options.enumerated()), id: \.offset) { idx, opt in
                            Button(action: {
                                withAnimation(.spring()) {
                                    selectedQuizAnswer = idx
                                    showQuizResult = true
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Text(opt.0).font(.system(size: 22))
                                    Text(opt.1).font(.system(size: 13, weight: .medium)).foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(selectedQuizAnswer == idx
                                              ? (idx == 0 ? Color(red: 0.15, green: 0.80, blue: 0.45).opacity(0.35)
                                                          : Color(red: 0.90, green: 0.25, blue: 0.40).opacity(0.35))
                                              : Color.white.opacity(0.07))
                                        .overlay(RoundedRectangle(cornerRadius: 14)
                                            .stroke(selectedQuizAnswer == idx
                                                    ? (idx == 0 ? Color(red: 0.20, green: 0.90, blue: 0.55)
                                                                : Color(red: 0.95, green: 0.35, blue: 0.45))
                                                    : Color.clear, lineWidth: 1.5))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if showQuizResult {
                        HStack(spacing: 8) {
                            Text(selectedQuizAnswer == 0 ? "🎉" : "😅")
                                .font(.system(size: 24))
                            Text(selectedQuizAnswer == 0
                                 ? "Correct! Rosemary oil was proven as effective as 2% Minoxidil in a 2023 clinical study! 🌿"
                                 : "Not quite! Rosemary oil is the answer — scientifically proven in a 2023 study! 🌿")
                                .font(.system(size: 13)).foregroundColor(.white.opacity(0.85))
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.08)))

                        Button(action: { withAnimation { selectedQuizAnswer = nil; showQuizResult = false } }) {
                            Text("Try Another Quiz 🔄")
                                .font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                                .padding(.horizontal, 20).padding(.vertical, 10)
                                .background(Capsule().fill(Color(red: 0.45, green: 0.18, blue: 0.88).opacity(0.50)))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 24)
    }

    // MARK: - Hair History

    private var hairHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🏺 Hair Through History")
                .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                .padding(.horizontal, 20)

            VStack(spacing: 0) {
                ForEach(Array(milestones.enumerated()), id: \.offset) { idx, milestone in
                    HStack(alignment: .top, spacing: 14) {
                        VStack(spacing: 0) {
                            ZStack {
                                Circle().fill(milestone.color.opacity(0.25)).frame(width: 42, height: 42)
                                Text(milestone.icon).font(.system(size: 20))
                            }
                            if idx < milestones.count - 1 {
                                Rectangle()
                                    .fill(LinearGradient(colors: [milestone.color.opacity(0.40), Color.clear],
                                                         startPoint: .top, endPoint: .bottom))
                                    .frame(width: 2, height: 40)
                            }
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(milestone.era)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(milestone.color)
                            Text(milestone.fact)
                                .font(.system(size: 13)).foregroundColor(Color.white.opacity(0.78))
                        }
                        .padding(.top, 10)
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 24)
    }

    // MARK: - Trending Topics

    private var trendingTopics: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🔥 Trending Topics")
                .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                .padding(.horizontal, 20)

            let topics: [(String, String, String, Color)] = [
                ("🌿", "Rosemary Oil Boom", "68.4K posts", Color(red: 0.20, green: 0.75, blue: 0.45)),
                ("🥚", "Biotin Foods", "41.2K posts", Color(red: 0.95, green: 0.70, blue: 0.15)),
                ("💆‍♀️", "Scalp Care Routine", "95.8K posts", Color(red: 0.90, green: 0.25, blue: 0.55)),
                ("🥗", "Hair Growth Diet", "52.1K posts", Color(red: 0.10, green: 0.65, blue: 0.85)),
                ("🌙", "Overnight Oil Mask", "33.7K posts", Color(red: 0.55, green: 0.18, blue: 0.88)),
                ("🧴", "Protein Treatments", "28.9K posts", Color(red: 1.0, green: 0.45, blue: 0.20)),
            ]

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(topics, id: \.1) { topic in
                    HStack(spacing: 10) {
                        ZStack {
                            Circle().fill(topic.3.opacity(0.20)).frame(width: 40, height: 40)
                            Text(topic.0).font(.system(size: 20))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(topic.1).font(.system(size: 12, weight: .bold)).foregroundColor(.white).lineLimit(1)
                            Text(topic.2).font(.system(size: 10)).foregroundColor(topic.3)
                        }
                        Spacer()
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.05))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(topic.3.opacity(0.25), lineWidth: 1))
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 24)
    }
}

#Preview {
    DiscoverView()
}
