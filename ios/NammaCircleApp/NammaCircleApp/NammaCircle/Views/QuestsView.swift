import SwiftUI

struct QuestsView: View {
    @StateObject private var viewModel = QuestViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                NammaScreenHeader(
                    eyebrow: "Namma quests",
                    title: "Tiny challenges for finding your feet",
                    subtitle: "Complete useful city tasks, build confidence, and earn progress points.",
                    systemImage: "sparkles"
                )

            if let errorMessage = viewModel.errorMessage {
                ErrorBanner(message: errorMessage)
            }

                if viewModel.isLoading {
                    LoadingStateView(message: "Loading quests")
                } else if viewModel.quests.isEmpty {
                    EmptyStateView(title: "No quests", message: "No active quests are available yet.")
                } else {
                    ForEach(viewModel.quests) { quest in
                        NavigationLink {
                            QuestDetailView(quest: quest, viewModel: viewModel)
                        } label: {
                            QuestCard(quest: quest)
                        }
                        .buttonStyle(.plain)
                    }
                }

                NavigationLink {
                    MentorView()
                } label: {
                    SectionCard(tone: .sky) {
                        HStack {
                            Label("Find a mentor", systemImage: "person.2.fill")
                                .font(.headline)
                                .foregroundStyle(NammaColor.ink)
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
        .navigationTitle("Quests")
        .navigationBarTitleDisplayMode(.inline)
        .tint(NammaColor.deepGreen)
        .task {
            viewModel.load()
        }
    }
}

struct QuestCard: View {
    let quest: Quest

    var body: some View {
        SectionCard(tone: .peach) {
            HStack(spacing: 14) {
                BengaluruIllustrationView(scene: .quest)
                    .frame(width: 94, height: 96)
                VStack(alignment: .leading, spacing: 8) {
                    Text(quest.title)
                        .font(.headline)
                        .foregroundStyle(NammaColor.ink)
                    Text(quest.description)
                        .font(.subheadline)
                        .lineLimit(2)
                        .foregroundStyle(NammaColor.muted)
                    NammaBadge(text: "+\(quest.points) points", systemImage: "rosette", tone: NammaColor.rose)
                }
                Spacer()
            }
        }
    }
}

struct QuestDetailView: View {
    let quest: Quest
    @ObservedObject var viewModel: QuestViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                SectionCard(tone: .hero) {
                    VStack(alignment: .leading, spacing: 12) {
                        BengaluruIllustrationView(scene: .quest)
                            .frame(height: 150)
                        Text(quest.title)
                            .font(.title2.bold())
                            .foregroundStyle(NammaColor.ink)
                        Text(quest.description)
                            .foregroundStyle(NammaColor.muted)
                        NammaBadge(text: "\(quest.points) points", systemImage: "sparkles", tone: NammaColor.rose)
                    }
                }

                SectionCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Submit proof")
                            .font(.headline)
                            .foregroundStyle(NammaColor.ink)
                        TextEditor(text: $viewModel.submissionText)
                            .frame(minHeight: 160)
                            .scrollContentBackground(.hidden)
                            .padding(10)
                            .background(.white.opacity(0.62))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        Button(viewModel.submittedQuestIDs.contains(quest.id) ? "Submitted" : "Submit text proof") {
                            viewModel.submit(quest)
                        }
                        .buttonStyle(NammaPrimaryButtonStyle())
                        .disabled(viewModel.submissionText.isEmpty || viewModel.submittedQuestIDs.contains(quest.id))
                        Label("Photo upload placeholder", systemImage: "photo")
                            .font(.caption)
                            .foregroundStyle(NammaColor.muted)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
        }
        .background(NammaBackground().ignoresSafeArea())
        .navigationTitle("Quest Detail")
        .navigationBarTitleDisplayMode(.inline)
        .tint(NammaColor.deepGreen)
    }
}
