import Foundation
import Combine

@MainActor
final class QuestViewModel: ObservableObject {
    @Published var quests: [Quest] = []
    @Published var submissionText = ""
    @Published var selectedProofImage: QuestProofImage?
    @Published var selectedProofImageLabel: String?
    @Published var submissionStatuses: [UUID: QuestSubmissionStatus] = [:]
    @Published var isLoading = false
    @Published var isSubmitting = false
    @Published var isPreparingPhoto = false
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
                    proofImage: selectedProofImage
                )
                submissionStatuses[quest.id] = status
                submissionText = ""
                clearProofImage()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func beginPreparingProofImage() {
        isPreparingPhoto = true
        errorMessage = nil
    }

    func setProofImage(data: Data, mimeType: String, fileExtension: String) {
        selectedProofImage = QuestProofImage(
            data: data,
            mimeType: mimeType,
            fileExtension: fileExtension
        )
        selectedProofImageLabel = "\(formattedSize(data.count)) image ready"
        isPreparingPhoto = false
    }

    func failPreparingProofImage(_ error: Error) {
        selectedProofImage = nil
        selectedProofImageLabel = nil
        isPreparingPhoto = false
        errorMessage = error.localizedDescription
    }

    func clearProofImage() {
        selectedProofImage = nil
        selectedProofImageLabel = nil
    }

    func status(for quest: Quest) -> QuestSubmissionStatus? {
        submissionStatuses[quest.id]
    }

    func canSubmit(_ quest: Quest) -> Bool {
        let hasText = !submissionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasPhoto = selectedProofImage != nil
        if (!hasText && !hasPhoto) || isSubmitting || isPreparingPhoto {
            return false
        }

        return status(for: quest) != .pending && status(for: quest) != .approved
    }

    private func formattedSize(_ byteCount: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(byteCount))
    }
}
