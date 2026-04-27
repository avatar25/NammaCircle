import Foundation
import Combine

@MainActor
final class QuestViewModel: ObservableObject {
    @Published var quests: [Quest] = []
    @Published var submissionText = ""
    @Published var photoPlaceholderSelected = false
    @Published var submissionStatuses: [UUID: QuestSubmissionStatus] = [:]
    @Published var isLoading = false
    @Published var isSubmitting = false
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
                submissionStatuses = try await service.fetchSubmissionStatuses()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func submit(_ quest: Quest) {
        Task {
            errorMessage = nil
            isSubmitting = true
            defer { isSubmitting = false }

            do {
                let status = try await service.submitQuest(
                    quest,
                    text: submissionText,
                    photoURL: photoPlaceholderSelected ? "photo-upload-placeholder" : nil
                )
                submissionStatuses[quest.id] = status
                submissionText = ""
                photoPlaceholderSelected = false
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func status(for quest: Quest) -> QuestSubmissionStatus? {
        submissionStatuses[quest.id]
    }

    func canSubmit(_ quest: Quest) -> Bool {
        if submissionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting {
            return false
        }

        return status(for: quest) != .pending && status(for: quest) != .approved
    }
}
