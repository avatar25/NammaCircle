import Foundation

@MainActor
final class QuestViewModel: ObservableObject {
    @Published var quests: [Quest] = []
    @Published var submissionText = ""
    @Published var submittedQuestIDs: Set<UUID> = []
    @Published var errorMessage: String?

    private let service: QuestServicing

    init(service: QuestServicing = MockQuestService()) {
        self.service = service
    }

    func load() {
        Task {
            do {
                quests = try await service.fetchQuests()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func submit(_ quest: Quest) {
        Task {
            do {
                try await service.submitQuest(quest, text: submissionText)
                submittedQuestIDs.insert(quest.id)
                submissionText = ""
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
