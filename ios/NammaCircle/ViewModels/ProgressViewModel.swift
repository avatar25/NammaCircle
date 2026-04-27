import Foundation

@MainActor
final class ProgressViewModel: ObservableObject {
    @Published var progress = UserProgress(
        currentStreak: 0,
        longestStreak: 0,
        totalPoints: 0,
        currentRank: .newcomer,
        nextRank: .settler,
        pointsToNextRank: 100
    )
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: ProgressServicing

    init(service: ProgressServicing = ServiceFactory.shared.progressService) {
        self.service = service
    }

    func load() {
        Task {
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }

            do {
                progress = try await service.fetchProgress()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
