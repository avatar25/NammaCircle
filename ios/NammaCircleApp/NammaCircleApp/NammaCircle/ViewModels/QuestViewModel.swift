import Foundation
import Combine

@MainActor
final class QuestViewModel: ObservableObject {
    @Published var quests: [Quest] = []
    @Published var submissionText = ""
    @Published var submittedQuestIDs: Set<UUID> = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: QuestServicing
    private let progressService: ProgressServicing

    init(
        service: QuestServicing = ServiceFactory.shared.questService,
        progressService: ProgressServicing = ServiceFactory.shared.progressService
    ) {
        self.service = service
        self.progressService = progressService
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
                _ = try await progressService.awardQuestCompletion(questID: quest.id, points: quest.points)
                submittedQuestIDs.insert(quest.id)
                submissionText = ""
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
