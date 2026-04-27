import SwiftUI

struct KannadaLessonView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = KannadaViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                NammaScreenHeader(
                    eyebrow: "Learn Kannada",
                    title: "Small phrases for real city moments",
                    subtitle: "\(appState.currentStreak) day streak. Practice the phrase, then use it once.",
                    systemImage: "text.book.closed.fill"
                )

                if let errorMessage = viewModel.errorMessage {
                    ErrorBanner(message: errorMessage)
                }

                if viewModel.isLoading {
                    LoadingStateView(message: "Loading today’s lesson")
                } else if let lesson = viewModel.lesson {
                    SectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            BengaluruIllustrationView(scene: .lesson)
                                .frame(height: 158)
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(lesson.title)
                                        .font(.title.bold())
                                        .foregroundStyle(NammaColor.ink)
                                    Text(lesson.situation)
                                        .font(.subheadline)
                                        .foregroundStyle(NammaColor.muted)
                                }
                                Spacer()
                                NammaBadge(text: "Daily goal", systemImage: "flame.fill", tone: NammaColor.terracotta)
                            }
                            Text(lesson.phrase.kannadaText)
                                .font(.system(size: 40, weight: .bold))
                                .foregroundStyle(NammaColor.deepGreen)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(lesson.phrase.transliteration)
                                .font(.title3)
                                .foregroundStyle(NammaColor.ink)
                            Text(lesson.phrase.englishMeaning)
                                .font(.headline)
                                .foregroundStyle(NammaColor.terracotta)
                            Text(lesson.phrase.usageNote)
                                .font(.subheadline)
                                .foregroundStyle(NammaColor.muted)
                        }
                    }

                    SectionCard(tone: .leaf) {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Current streak")
                                        .font(.headline)
                                        .foregroundStyle(NammaColor.ink)
                                    Text("\(appState.currentStreak) days")
                                        .font(.subheadline)
                                        .foregroundStyle(NammaColor.muted)
                                }
                                Spacer()
                                Image(systemName: viewModel.isCompleted ? "checkmark.seal.fill" : "speaker.wave.2.fill")
                                    .font(.title2)
                                    .foregroundStyle(viewModel.isCompleted ? NammaColor.leaf : NammaColor.saffron)
                            }
                            Button(viewModel.isCompleted ? "Completed" : "Complete lesson") {
                                viewModel.complete(currentStreak: appState.currentStreak) { streak in
                                    appState.currentStreak = streak
                                }
                            }
                            .buttonStyle(NammaPrimaryButtonStyle())
                            .disabled(viewModel.isCompleted)
                        }
                    }
                } else {
                    EmptyStateView(title: "No lesson", message: "No published Kannada lesson is available.")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
        }
        .background(NammaBackground().ignoresSafeArea())
        .navigationTitle("Kannada")
        .navigationBarTitleDisplayMode(.inline)
        .tint(NammaColor.deepGreen)
        .task {
            viewModel.load()
        }
    }
}
