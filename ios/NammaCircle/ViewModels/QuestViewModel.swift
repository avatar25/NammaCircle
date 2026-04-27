import Foundation

@MainActor
final class QuestViewModel: ObservableObject {
    @Published var quests: [Quest] = []
    @Published var submissionText = ""
    @Published var submittedQuestIDs: Set<UUID> = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: QuestServicing

    init(service: QuestServicing = ServiceFactory.shared.questService) {
        self.service = service
    }

    func load() {
        Task {
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }

            do {
                quests = try await service.fetchQuests()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func submit(_ quest: Quest) {
        Task {
            errorMessage = nil

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
