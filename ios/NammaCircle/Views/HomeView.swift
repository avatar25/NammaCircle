import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var localityVM = LocalityViewModel()
    @StateObject private var kannadaVM = KannadaViewModel()
    @StateObject private var questVM = QuestViewModel()
    @StateObject private var progressVM = ProgressViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Good morning")
                    .font(.largeTitle.bold())
                Text("Your Bangalore survival snapshot for today.")
                    .foregroundStyle(.secondary)

                if let errorMessage = localityVM.errorMessage ?? kannadaVM.errorMessage ?? questVM.errorMessage ?? progressVM.errorMessage {
                    ErrorBanner(message: errorMessage)
                }

                if localityVM.isLoading || kannadaVM.isLoading || questVM.isLoading || progressVM.isLoading {
                    LoadingStateView(message: "Loading today’s snapshot")
                }

                ProgressSummaryCard(progress: progressVM.progress)

                if let lesson = kannadaVM.lesson {
                    NavigationLink {
                        KannadaLessonView()
                    } label: {
                        SectionCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Today’s Kannada", systemImage: "text.book.closed")
                                    .font(.headline)
                                Text(lesson.phrase.kannadaText)
                                    .font(.title2.bold())
                                Text(lesson.phrase.englishMeaning)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }

                if let quest = questVM.quests.first {
                    NavigationLink {
                        QuestDetailView(quest: quest, viewModel: questVM)
                    } label: {
                        SectionCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Daily quest", systemImage: "sparkles")
                                    .font(.headline)
                                Text(quest.title).font(.title3.bold())
                                Text("\(quest.points) points")
                                    .foregroundStyle(.secondary)
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
                                Text("Locality, rent, commute, and settling-in questions.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .background(Color(.secondarySystemBackground))
        .navigationTitle("NammaCircle")
        .task {
            localityVM.load(preferences: appState.onboarding)
            kannadaVM.load()
            questVM.load()
            progressVM.load()
        }
    }
}

struct ProgressSummaryCard: View {
    let progress: UserProgress

    var body: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your progress")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(progress.currentRank.rawValue)
                            .font(.title3.bold())
                    }
                    Spacer()
                    Text("\(progress.totalPoints) pts")
                        .font(.headline)
                }

                HStack(spacing: 12) {
                    Label("\(progress.currentStreak) day streak", systemImage: "flame")
                    Spacer()
                    if let nextRank = progress.nextRank, let points = progress.pointsToNextRank {
                        Text("\(points) pts to \(nextRank.rawValue)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Top rank")
                            .font(.caption)
                            .foregroundStyle(.secondary)
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
        SectionCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Recommended locality")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(locality.name)
                            .font(.title3.bold())
                    }
                    Spacer()
                    Text(locality.recommendation.fit.title)
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(FitColor.color(for: locality.recommendation.fit).opacity(0.14))
                        .foregroundStyle(FitColor.color(for: locality.recommendation.fit))
                        .clipShape(Capsule())
                }
                Text("Score \(locality.recommendation.score)")
                    .foregroundStyle(.secondary)
                Text(locality.recommendation.topReasons.first ?? locality.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
