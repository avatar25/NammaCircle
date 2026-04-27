import Foundation

@MainActor
final class KannadaViewModel: ObservableObject {
    @Published var lesson: KannadaLesson?
    @Published var isCompleted = false
    @Published var errorMessage: String?

    private let service: KannadaServicing

    init(service: KannadaServicing = MockKannadaService()) {
        self.service = service
    }

    func load() {
        Task {
            do {
                lesson = try await service.todayLesson()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func complete(currentStreak: Int, onStreakUpdated: @escaping (Int) -> Void) {
        guard let lesson else { return }

        Task {
            do {
                let streak = try await service.completeLesson(lesson, currentStreak: currentStreak)
                isCompleted = true
                onStreakUpdated(streak)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
