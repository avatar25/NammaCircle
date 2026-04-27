import SwiftUI

struct KannadaLessonView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = KannadaViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let lesson = viewModel.lesson {
                    SectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(lesson.title)
                                .font(.title.bold())
                            Text(lesson.situation)
                                .foregroundStyle(.secondary)
                            Divider()
                            Text(lesson.phrase.kannadaText)
                                .font(.system(size: 40, weight: .bold))
                            Text(lesson.phrase.transliteration)
                                .font(.title3)
                            Text(lesson.phrase.englishMeaning)
                                .font(.headline)
                            Text(lesson.phrase.usageNote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    SectionCard {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Current streak")
                                    .font(.headline)
                                Text("\(appState.currentStreak) days")
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button(viewModel.isCompleted ? "Completed" : "Complete lesson") {
                                viewModel.complete(currentStreak: appState.currentStreak) { streak in
                                    appState.currentStreak = streak
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(viewModel.isCompleted)
                        }
                    }
                } else {
                    ProgressView("Loading lesson")
                }
            }
            .padding()
        }
        .background(Color(.secondarySystemBackground))
        .navigationTitle("Kannada")
        .task {
            viewModel.load()
        }
    }
}
