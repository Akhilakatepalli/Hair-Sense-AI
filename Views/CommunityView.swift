//
//  CommunityView.swift
//  Hair AI
//

import SwiftUI

// MARK: - Models

struct CommunityPost: Identifiable {
    let id = UUID()
    let username: String
    let handle: String
    let avatarEmoji: String
    let avatarColor: Color
    let timeAgo: String
    let caption: String
    let tag: String
    let tagColor: Color
    let cardEmoji: String
    let cardBg: [Color]
    var likes: Int
    var comments: Int
    var isLiked: Bool = false
}

private struct StoryItem {
    let name: String
    let emoji: String
    let bgColors: [Color]
    let ringColors: [Color]
}

// MARK: - CommunityView

struct CommunityView: View {

    @State private var posts: [CommunityPost] = CommunityView.samplePosts
    @State private var selectedFilter = 0
    @State private var showComposeSheet = false
    @State private var aiTipIndex = 0

    private let filters = ["✨ All", "🔄 Before/After", "💡 Tips", "📈 Progress", "🏆 Wins"]

    private let aiTips: [(String, String, String)] = [
        ("🤖", "AI Hair Coach:", "Massaging your scalp for 5 min increases blood flow, waking up dormant follicles. Try tonight! 🌴"),
        ("🧬", "Hair Science:", "Each strand grows in 3 phases — Anagen, Catagen, Telogen. Your growth phase lasts up to 7 years! 💫"),
        ("👶", "Fun Fact:", "Babies are born with ~100,000 hair follicles — and that number never increases in your lifetime! 🍼"),
        ("🏺", "Ancient Secret:", "Cleopatra used castor oil + rosemary for thick, lustrous hair. These ingredients still work today! ✨"),
        ("📏", "Growth Tip:", "Hair grows fastest between ages 15–30, averaging about 6 inches (15 cm) per year. Track yours! 🌱"),
        ("🥚", "Nutrient Tip:", "Biotin from eggs + protein builds keratin — the structural protein that makes hair strong & shiny! 🍳"),
        ("🌊", "Hydration:", "Dehydration shrinks hair follicles! Drink 8 glasses of water daily for noticeably softer hair. 💧"),
    ]

    private let stories: [StoryItem] = [
        StoryItem(name: "Priya", emoji: "💆‍♀️",
                  bgColors: [Color(red: 0.90, green: 0.25, blue: 0.55), Color(red: 0.65, green: 0.10, blue: 0.80)],
                  ringColors: [Color(red: 1.0, green: 0.50, blue: 0.20), Color(red: 0.90, green: 0.25, blue: 0.55)]),
        StoryItem(name: "Sarah", emoji: "🌿",
                  bgColors: [Color(red: 0.10, green: 0.70, blue: 0.45), Color(red: 0.05, green: 0.50, blue: 0.30)],
                  ringColors: [Color(red: 0.20, green: 0.90, blue: 0.55), Color(red: 0.05, green: 0.70, blue: 0.40)]),
        StoryItem(name: "Maria", emoji: "🥑",
                  bgColors: [Color(red: 0.55, green: 0.80, blue: 0.10), Color(red: 0.35, green: 0.60, blue: 0.05)],
                  ringColors: [Color(red: 0.70, green: 0.95, blue: 0.15), Color(red: 0.40, green: 0.75, blue: 0.10)]),
        StoryItem(name: "Aisha", emoji: "✨",
                  bgColors: [Color(red: 0.95, green: 0.75, blue: 0.10), Color(red: 0.85, green: 0.50, blue: 0.05)],
                  ringColors: [Color(red: 1.0, green: 0.85, blue: 0.20), Color(red: 0.95, green: 0.60, blue: 0.10)]),
        StoryItem(name: "Lin", emoji: "🌸",
                  bgColors: [Color(red: 0.95, green: 0.40, blue: 0.70), Color(red: 0.75, green: 0.20, blue: 0.55)],
                  ringColors: [Color(red: 1.0, green: 0.60, blue: 0.80), Color(red: 0.85, green: 0.30, blue: 0.65)]),
        StoryItem(name: "Deva", emoji: "💪",
                  bgColors: [Color(red: 0.20, green: 0.50, blue: 0.95), Color(red: 0.10, green: 0.30, blue: 0.80)],
                  ringColors: [Color(red: 0.40, green: 0.70, blue: 1.0), Color(red: 0.20, green: 0.45, blue: 0.90)]),
        StoryItem(name: "Mei", emoji: "🍵",
                  bgColors: [Color(red: 0.15, green: 0.65, blue: 0.65), Color(red: 0.05, green: 0.45, blue: 0.45)],
                  ringColors: [Color(red: 0.25, green: 0.85, blue: 0.75), Color(red: 0.10, green: 0.60, blue: 0.60)]),
    ]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(red: 0.06, green: 0.04, blue: 0.12).ignoresSafeArea()
            blobBackground

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    communityHeader
                    aiTipBanner
                    storiesSection
                    filterBarSection
                    postsFeed
                    Spacer(minLength: 110)
                }
            }

            // FAB
            Button(action: { showComposeSheet = true }) {
                HStack(spacing: 8) {
                    Text("✍️").font(.system(size: 17))
                    Text("Share").font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                }
                .padding(.horizontal, 22).padding(.vertical, 14)
                .background(
                    LinearGradient(colors: [Color(red: 0.90, green: 0.25, blue: 0.55),
                                            Color(red: 0.45, green: 0.18, blue: 0.88)],
                                   startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(Capsule())
                .shadow(color: Color(red: 0.80, green: 0.15, blue: 0.50).opacity(0.60), radius: 16, y: 6)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 108)
        }
        .sheet(isPresented: $showComposeSheet) {
            ComposePostSheet()
        }
    }

    // MARK: - Background

    private var blobBackground: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.12))
                .frame(width: 320, height: 320).blur(radius: 80).offset(x: -80, y: -200)
            Circle()
                .fill(Color(red: 0.20, green: 0.60, blue: 0.95).opacity(0.10))
                .frame(width: 280, height: 280).blur(radius: 80).offset(x: 120, y: 100)
        }
    }

    // MARK: - Header

    private var communityHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("💆‍♀️ Community")
                    .font(.system(size: 28, weight: .bold)).foregroundColor(.white)
                Text("12.4K members sharing their journey 🌟")
                    .font(.system(size: 13)).foregroundColor(Color.white.opacity(0.50))
            }
            Spacer()
            Button(action: {}) {
                Image(systemName: "bell.fill").font(.system(size: 17))
                    .foregroundColor(Color.white.opacity(0.60))
                    .padding(10).background(Color.white.opacity(0.07)).clipShape(Circle())
            }
        }
        .padding(.horizontal, 20).padding(.top, 60).padding(.bottom, 14)
    }

    // MARK: - AI Tip Banner

    private var aiTipBanner: some View {
        let tip = aiTips[aiTipIndex % aiTips.count]
        return ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(LinearGradient(
                    colors: [Color(red: 0.10, green: 0.55, blue: 0.95).opacity(0.22),
                             Color(red: 0.45, green: 0.18, blue: 0.88).opacity(0.22)],
                    startPoint: .leading, endPoint: .trailing
                ))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(red: 0.30, green: 0.65, blue: 1.0).opacity(0.35), lineWidth: 1))

            HStack(spacing: 14) {
                Text(tip.0).font(.system(size: 34))
                VStack(alignment: .leading, spacing: 3) {
                    Text(tip.1).font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 0.60, green: 0.80, blue: 1.0))
                    Text(tip.2).font(.system(size: 13)).foregroundColor(Color.white.opacity(0.82)).lineLimit(2)
                }
                Spacer()
                Button(action: { withAnimation(.spring()) { aiTipIndex += 1 } }) {
                    Image(systemName: "arrow.clockwise").font(.system(size: 15))
                        .foregroundColor(Color.white.opacity(0.45))
                        .padding(8).background(Color.white.opacity(0.07)).clipShape(Circle())
                }
            }
            .padding(14)
        }
        .padding(.horizontal, 20).padding(.bottom, 16)
    }

    // MARK: - Stories

    private var storiesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("🔥 Active Journeys")
                .font(.system(size: 16, weight: .bold)).foregroundColor(.white).padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    // "Add Story" button
                    VStack(spacing: 6) {
                        ZStack {
                            Circle().fill(Color.white.opacity(0.07)).frame(width: 64, height: 64)
                                .overlay(Circle().stroke(
                                    LinearGradient(colors: [Color(red: 0.90, green: 0.25, blue: 0.55),
                                                            Color(red: 0.45, green: 0.18, blue: 0.88)],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                                    lineWidth: 2
                                ))
                            Image(systemName: "plus").font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color(red: 0.90, green: 0.25, blue: 0.55))
                        }
                        Text("Your\nStory").font(.system(size: 10)).foregroundColor(Color.white.opacity(0.55))
                            .multilineTextAlignment(.center)
                    }

                    ForEach(stories, id: \.name) { story in
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .stroke(LinearGradient(colors: story.ringColors,
                                                           startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2.5)
                                    .frame(width: 68, height: 68)
                                Circle()
                                    .fill(LinearGradient(colors: story.bgColors, startPoint: .top, endPoint: .bottom))
                                    .frame(width: 60, height: 60)
                                Text(story.emoji).font(.system(size: 28))
                            }
                            Text(story.name).font(.system(size: 10)).foregroundColor(Color.white.opacity(0.70)).lineLimit(1)
                        }
                        .frame(width: 70)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 16)
    }

    // MARK: - Filter Bar

    private var filterBarSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(filters.enumerated()), id: \.offset) { idx, label in
                    Button(action: { withAnimation { selectedFilter = idx } }) {
                        Text(label)
                            .font(.system(size: 13, weight: selectedFilter == idx ? .bold : .medium))
                            .foregroundColor(selectedFilter == idx ? .white : Color.white.opacity(0.50))
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(
                                Group {
                                    if selectedFilter == idx {
                                        LinearGradient(colors: [Color(red: 0.90, green: 0.25, blue: 0.55),
                                                                 Color(red: 0.45, green: 0.18, blue: 0.88)],
                                                       startPoint: .leading, endPoint: .trailing)
                                            .clipShape(Capsule())
                                    } else {
                                        Color.white.opacity(0.07).clipShape(Capsule())
                                    }
                                }
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 16)
    }

    // MARK: - Posts Feed

    private var postsFeed: some View {
        LazyVStack(spacing: 16) {
            ForEach($posts) { $post in
                CommunityPostCard(post: $post)
                    .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Sample Data

    static let samplePosts: [CommunityPost] = [
        CommunityPost(
            username: "Priya Sharma", handle: "@priyahair",
            avatarEmoji: "💆‍♀️", avatarColor: Color(red: 0.90, green: 0.25, blue: 0.55),
            timeAgo: "2h",
            caption: "12 weeks of oiling & scalp massage — my hair is literally thriving! 🌿✨",
            tag: "🔄 Before/After", tagColor: Color(red: 0.20, green: 0.85, blue: 0.55),
            cardEmoji: "🌿💇‍♀️✨",
            cardBg: [Color(red: 0.10, green: 0.55, blue: 0.35), Color(red: 0.05, green: 0.35, blue: 0.20)],
            likes: 284, comments: 42
        ),
        CommunityPost(
            username: "Sarah M.", handle: "@hairgoals",
            avatarEmoji: "🥑", avatarColor: Color(red: 0.40, green: 0.70, blue: 0.20),
            timeAgo: "5h",
            caption: "Avocado + honey hair mask = silky smooth hair! Recipe in bio 🥑🍯",
            tag: "💡 Tip", tagColor: Color(red: 0.95, green: 0.70, blue: 0.15),
            cardEmoji: "🥑🍯🌿",
            cardBg: [Color(red: 0.55, green: 0.78, blue: 0.10), Color(red: 0.30, green: 0.55, blue: 0.05)],
            likes: 512, comments: 87
        ),
        CommunityPost(
            username: "Aisha K.", handle: "@aishacurls",
            avatarEmoji: "✨", avatarColor: Color(red: 0.85, green: 0.55, blue: 0.10),
            timeAgo: "1d",
            caption: "3-month rosemary oil + biotin journey. Photos don't lie! 📏🌹",
            tag: "📈 Progress", tagColor: Color(red: 0.55, green: 0.35, blue: 0.95),
            cardEmoji: "📏🌹🏆",
            cardBg: [Color(red: 0.70, green: 0.25, blue: 0.85), Color(red: 0.45, green: 0.10, blue: 0.70)],
            likes: 1023, comments: 156
        ),
        CommunityPost(
            username: "Maria L.", handle: "@hairnutrition",
            avatarEmoji: "🥗", avatarColor: Color(red: 0.20, green: 0.75, blue: 0.50),
            timeAgo: "2d",
            caption: "My hair-growth breakfast bowl! Salmon salad for lunch = hair goals 🐟🥣",
            tag: "🥗 Recipe", tagColor: Color(red: 0.10, green: 0.80, blue: 0.55),
            cardEmoji: "🥣🫐🐟🥚",
            cardBg: [Color(red: 0.10, green: 0.65, blue: 0.85), Color(red: 0.05, green: 0.40, blue: 0.65)],
            likes: 634, comments: 91
        ),
        CommunityPost(
            username: "Lin Zhang", handle: "@linshaircare",
            avatarEmoji: "🌸", avatarColor: Color(red: 0.90, green: 0.40, blue: 0.65),
            timeAgo: "3d",
            caption: "Weekly scalp massage with warm oil changed my entire hair health! 💆‍♀️🫧",
            tag: "🏆 Win", tagColor: Color(red: 1.0, green: 0.75, blue: 0.15),
            cardEmoji: "💆‍♀️🫧💜",
            cardBg: [Color(red: 0.85, green: 0.20, blue: 0.60), Color(red: 0.55, green: 0.10, blue: 0.80)],
            likes: 421, comments: 63
        ),
        CommunityPost(
            username: "Dev R.", handle: "@devhairjourney",
            avatarEmoji: "💪", avatarColor: Color(red: 0.20, green: 0.50, blue: 0.90),
            timeAgo: "4d",
            caption: "Men's hair care is underrated! My oiling + protein routine results 💪🔥",
            tag: "📈 Progress", tagColor: Color(red: 0.55, green: 0.35, blue: 0.95),
            cardEmoji: "💪🔥✂️",
            cardBg: [Color(red: 0.15, green: 0.40, blue: 0.90), Color(red: 0.05, green: 0.20, blue: 0.65)],
            likes: 387, comments: 54
        ),
    ]
}

// MARK: - Post Card

struct CommunityPostCard: View {
    @Binding var post: CommunityPost

    var body: some View {
        VStack(spacing: 0) {
            // Header row
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [post.avatarColor, post.avatarColor.opacity(0.60)],
                                            startPoint: .top, endPoint: .bottom))
                        .frame(width: 44, height: 44)
                    Text(post.avatarEmoji).font(.system(size: 22))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.username).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                    Text(post.handle + " · " + post.timeAgo)
                        .font(.system(size: 11)).foregroundColor(Color.white.opacity(0.42))
                }
                Spacer()
                Text(post.tag)
                    .font(.system(size: 10, weight: .bold)).foregroundColor(.white)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Capsule().fill(post.tagColor.opacity(0.28)))
                    .overlay(Capsule().stroke(post.tagColor.opacity(0.55), lineWidth: 1))
            }
            .padding(.horizontal, 14).padding(.top, 14).padding(.bottom, 10)

            // Emoji "image" card
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(colors: post.cardBg,
                                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 150)
                VStack(spacing: 6) {
                    Text(post.cardEmoji).font(.system(size: 52))
                    Text(post.caption)
                        .font(.system(size: 12, weight: .medium)).foregroundColor(.white.opacity(0.88))
                        .multilineTextAlignment(.center).padding(.horizontal, 16).lineLimit(2)
                }
            }
            .padding(.horizontal, 14)

            // Actions
            HStack(spacing: 24) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        post.isLiked.toggle()
                        post.likes += post.isLiked ? 1 : -1
                    }
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 15))
                            .foregroundColor(post.isLiked ? Color(red: 0.95, green: 0.30, blue: 0.55) : Color.white.opacity(0.50))
                            .scaleEffect(post.isLiked ? 1.2 : 1.0)
                        Text("\(post.likes)").font(.system(size: 13)).foregroundColor(Color.white.opacity(0.50))
                    }
                }
                .buttonStyle(.plain)

                HStack(spacing: 5) {
                    Image(systemName: "bubble.right").font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.45))
                    Text("\(post.comments)").font(.system(size: 13)).foregroundColor(Color.white.opacity(0.45))
                }

                Spacer()

                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up").font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.45))
                }
                .buttonStyle(.plain)

                Button(action: {}) {
                    Image(systemName: "bookmark").font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.45))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 18).padding(.vertical, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.09), lineWidth: 1))
        )
    }
}

// MARK: - Compose Sheet

struct ComposePostSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var postText = ""
    @State private var selectedTag = 0
    private let tags = ["Before/After 🔄", "Hair Tip 💡", "Progress 📈", "Recipe 🥗", "Win 🏆"]

    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.04, blue: 0.12).ignoresSafeArea()
            VStack(spacing: 20) {
                // Nav bar
                HStack {
                    Button("Cancel") { dismiss() }.foregroundColor(Color.white.opacity(0.55))
                    Spacer()
                    Text("Share Journey ✍️").font(.system(size: 17, weight: .bold)).foregroundColor(.white)
                    Spacer()
                    Button("Post") { dismiss() }.font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(red: 0.90, green: 0.25, blue: 0.55))
                }
                .padding()

                // Tag chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(tags.enumerated()), id: \.offset) { idx, tag in
                            Button(action: { selectedTag = idx }) {
                                Text(tag)
                                    .font(.system(size: 13, weight: selectedTag == idx ? .bold : .medium))
                                    .foregroundColor(selectedTag == idx ? .white : Color.white.opacity(0.50))
                                    .padding(.horizontal, 14).padding(.vertical, 8)
                                    .background(Group {
                                        if selectedTag == idx {
                                            LinearGradient(colors: [Color(red: 0.90, green: 0.25, blue: 0.55),
                                                                     Color(red: 0.45, green: 0.18, blue: 0.88)],
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
                    .padding(.horizontal)
                }

                // Text area
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05)).frame(minHeight: 150)
                    if postText.isEmpty {
                        Text("Share your hair journey, tips, or transformation... 💫")
                            .foregroundColor(Color.white.opacity(0.28)).padding(14)
                    }
                    TextEditor(text: $postText)
                        .foregroundColor(.white).padding(10).scrollContentBackground(.hidden)
                }
                .padding(.horizontal)

                // Media options
                HStack(spacing: 10) {
                    ForEach(["📸 Photo", "🎬 Reel", "📊 Chart", "🧪 Result"], id: \.self) { opt in
                        Text(opt).font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.65))
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.07)))
                    }
                }

                Spacer()
            }
        }
    }
}

#Preview {
    CommunityView()
}
