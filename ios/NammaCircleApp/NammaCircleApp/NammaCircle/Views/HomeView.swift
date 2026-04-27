import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var localityVM = LocalityViewModel()
    @StateObject private var kannadaVM = KannadaViewModel()
    @StateObject private var questVM = QuestViewModel()
    @StateObject private var progressVM = ProgressViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                HomeHeroView(
                    locality: localityVM.recommendations.first,
                    progress: progressVM.progress
                )

                if let errorMessage = localityVM.errorMessage ?? kannadaVM.errorMessage ?? questVM.errorMessage ?? progressVM.errorMessage {
                    ErrorBanner(message: errorMessage)
                }

                if localityVM.isLoading || kannadaVM.isLoading || questVM.isLoading || progressVM.isLoading {
                    LoadingStateView(message: "Loading today’s snapshot")
                }

                ProgressSummaryCard(progress: progressVM.progress)

                HomeShortcutGrid()

                if let lesson = kannadaVM.lesson {
                    NavigationLink {
                        KannadaLessonView()
                    } label: {
                        SectionCard(tone: .leaf) {
                            HStack(spacing: 14) {
                                BengaluruIllustrationView(scene: .lesson)
                                    .frame(width: 104, height: 110)
                                VStack(alignment: .leading, spacing: 8) {
                                    NammaBadge(text: "Today’s Kannada", systemImage: "flame.fill", tone: NammaColor.terracotta)
                                    Text(lesson.phrase.kannadaText)
                                        .font(.title2.bold())
                                        .foregroundStyle(NammaColor.ink)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text(lesson.phrase.englishMeaning)
                                        .font(.subheadline)
                                        .foregroundStyle(NammaColor.muted)
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }

                if let quest = questVM.quests.first {
                    NavigationLink {
                        QuestDetailView(quest: quest, viewModel: questVM)
                    } label: {
                        SectionCard(tone: .peach) {
                            HStack(spacing: 14) {
                                VStack(alignment: .leading, spacing: 8) {
                                    NammaBadge(text: "Daily quest", systemImage: "sparkles", tone: NammaColor.rose)
                                    Text(quest.title)
                                        .font(.title3.bold())
                                        .foregroundStyle(NammaColor.ink)
                                    Text("\(quest.points) points toward your next rank")
                                        .font(.subheadline)
                                        .foregroundStyle(NammaColor.muted)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.headline)
                                    .foregroundStyle(NammaColor.deepGreen)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }

                if let locality = localityVM.recommendations.first {
                    NavigationLink {
                        LocalityDetailView(locality: locality)
                    } label: {
                        LocalityCard(locality: locality)
                    }
                    .buttonStyle(.plain)
                }

                if !localityVM.isLoading && localityVM.recommendations.isEmpty {
                    EmptyStateView(
                        title: "No recommendations yet",
                        message: "Check Supabase configuration or switch back to mock mode."
                    )
                }

                NavigationLink {
                    ForumView()
                } label: {
                    SectionCard {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Ask the forum").font(.headline)
                                    .foregroundStyle(NammaColor.ink)
                                Text("Locality, rent, commute, and settling-in questions.")
                                    .font(.subheadline)
                                    .foregroundStyle(NammaColor.muted)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(NammaColor.deepGreen)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
        }
        .background(NammaBackground().ignoresSafeArea())
        .navigationTitle("NammaCircle")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            localityVM.load(preferences: appState.onboarding)
            kannadaVM.load()
            questVM.load()
            progressVM.load()
        }
    }
}

struct HomeHeroView: View {
    let locality: Locality?
    let progress: UserProgress

    var body: some View {
        SectionCard(tone: .hero) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    NammaBrandMark()
                    VStack(alignment: .leading, spacing: 2) {
                        Text("NammaCircle")
                            .font(.title2.bold())
                            .foregroundStyle(NammaColor.deepGreen)
                        Text("Your guide. Your people. Your Bengaluru.")
                            .font(.caption)
                            .foregroundStyle(NammaColor.muted)
                    }
                    Spacer()
                    NammaBadge(text: "\(progress.currentStreak) day streak", systemImage: "flame.fill", tone: NammaColor.terracotta)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Good morning")
                        .font(.largeTitle.bold())
                        .foregroundStyle(NammaColor.ink)
                    Text("A softer landing plan for localities, rent, Kannada, and people who can help.")
                        .font(.subheadline)
                        .foregroundStyle(NammaColor.muted)
                }

                BengaluruIllustrationView(scene: .home)
                    .frame(height: 162)

                if let locality {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Locality highlight")
                                .font(.caption)
                                .foregroundStyle(NammaColor.muted)
                            Text(locality.name)
                                .font(.headline)
                                .foregroundStyle(NammaColor.ink)
                        }
                        Spacer()
                        NammaBadge(
                            text: "\(locality.recommendation.score) \(locality.recommendation.fit.title)",
                            systemImage: "leaf.fill",
                            tone: FitColor.color(for: locality.recommendation.fit)
                        )
                    }
                }
            }
        }
    }
}

struct HomeShortcutGrid: View {
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            NavigationLink {
                LocalityMapView()
            } label: {
                HomeShortcutTile(title: "Explore areas", subtitle: "Scores and fit", systemImage: "map.fill", tone: NammaColor.leaf)
            }
            .buttonStyle(.plain)

            NavigationLink {
                RentCheckView()
            } label: {
                HomeShortcutTile(title: "Check rent", subtitle: "Fairness cues", systemImage: "indianrupeesign.circle.fill", tone: NammaColor.saffron)
            }
            .buttonStyle(.plain)

            NavigationLink {
                MentorView()
            } label: {
                HomeShortcutTile(title: "Find mentors", subtitle: "Local help", systemImage: "person.2.fill", tone: NammaColor.teal)
            }
            .buttonStyle(.plain)

            NavigationLink {
                QuestsView()
            } label: {
                HomeShortcutTile(title: "Namma quests", subtitle: "Earn points", systemImage: "rosette", tone: NammaColor.rose)
            }
            .buttonStyle(.plain)
        }
    }
}

struct HomeShortcutTile: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let tone: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemImage)
                .font(.title3.weight(.bold))
                .foregroundStyle(tone)
                .frame(width: 34, height: 34)
                .background(tone.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(NammaColor.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(NammaColor.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(NammaColor.card.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(NammaColor.line.opacity(0.22), lineWidth: 1)
        }
    }
}

struct ProgressSummaryCard: View {
    let progress: UserProgress

    private var progressRatio: Double {
        guard let pointsToNextRank = progress.pointsToNextRank else { return 1 }
        let totalNeeded = progress.totalPoints + pointsToNextRank
        guard totalNeeded > 0 else { return 0 }
        return Double(progress.totalPoints) / Double(totalNeeded)
    }

    var body: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your progress")
                            .font(.caption)
                            .foregroundStyle(NammaColor.muted)
                        Text(progress.currentRank.rawValue)
                            .font(.title3.bold())
                            .foregroundStyle(NammaColor.ink)
                    }
                    Spacer()
                    Text("\(progress.totalPoints) pts")
                        .font(.headline)
                        .foregroundStyle(NammaColor.deepGreen)
                }

                NammaProgressBar(value: progressRatio)

                HStack(spacing: 10) {
                    Label("\(progress.currentStreak) day streak", systemImage: "flame.fill")
                        .foregroundStyle(NammaColor.terracotta)
                    Spacer()
                    if let nextRank = progress.nextRank, let points = progress.pointsToNextRank {
                        Text("\(points) pts to \(nextRank.rawValue)")
                            .font(.caption)
                            .foregroundStyle(NammaColor.muted)
                    } else {
                        Text("Top rank")
                            .font(.caption)
                            .foregroundStyle(NammaColor.muted)
                    }
                }
                .font(.subheadline)
            }
        }
    }
}

struct LocalityCard: View {
    let locality: Locality

    var body: some View {
        SectionCard(tone: .sky) {
            VStack(alignment: .leading, spacing: 12) {
                BengaluruIllustrationView(scene: .locality)
                    .frame(height: 128)

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Recommended locality")
                            .font(.caption)
                            .foregroundStyle(NammaColor.muted)
                        Text(locality.name)
                            .font(.title3.bold())
                            .foregroundStyle(NammaColor.ink)
                    }
                    Spacer()
                    NammaBadge(text: locality.recommendation.fit.title, systemImage: "checkmark.seal.fill", tone: FitColor.color(for: locality.recommendation.fit))
                }
                Text(locality.recommendation.topReasons.first ?? locality.description)
                    .font(.subheadline)
                    .foregroundStyle(NammaColor.muted)

                HStack {
                    Text("Overall score")
                        .font(.caption)
                        .foregroundStyle(NammaColor.muted)
                    Spacer()
                    Text("\(locality.recommendation.score)")
                        .font(.headline)
                        .foregroundStyle(NammaColor.deepGreen)
                }
            }
        }
    }
}
