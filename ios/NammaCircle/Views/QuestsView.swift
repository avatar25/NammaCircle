import SwiftUI

struct QuestsView: View {
    @StateObject private var viewModel = QuestViewModel()

    var body: some View {
        List {
            Section("Daily quests") {
                ForEach(viewModel.quests) { quest in
                    NavigationLink {
                        QuestDetailView(quest: quest, viewModel: viewModel)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(quest.title).font(.headline)
                            Text(quest.description)
                                .lineLimit(2)
                                .foregroundStyle(.secondary)
                            Text("\(quest.points) points")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section {
                NavigationLink {
                    MentorView()
                } label: {
                    Label("Find a mentor", systemImage: "person.2")
                }
            }
        }
        .navigationTitle("Quests")
        .task {
            viewModel.load()
        }
    }
}

struct QuestDetailView: View {
    let quest: Quest
    @ObservedObject var viewModel: QuestViewModel

    var body: some View {
        Form {
            Section("Quest") {
                Text(quest.title).font(.headline)
                Text(quest.description)
                Text("\(quest.points) points")
                    .foregroundStyle(.secondary)
            }

            Section("Submit") {
                TextEditor(text: $viewModel.submissionText)
                    .frame(minHeight: 160)
                Button(viewModel.submittedQuestIDs.contains(quest.id) ? "Submitted" : "Submit text proof") {
                    viewModel.submit(quest)
                }
                .disabled(viewModel.submissionText.isEmpty || viewModel.submittedQuestIDs.contains(quest.id))
                Label("Photo upload placeholder", systemImage: "photo")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Quest Detail")
    }
}
