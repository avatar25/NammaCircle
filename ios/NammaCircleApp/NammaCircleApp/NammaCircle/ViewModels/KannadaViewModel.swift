import Foundation
import Combine

@MainActor
final class KannadaViewModel: ObservableObject {
    @Published var lesson: KannadaLesson?
    @Published var isCompleted = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: KannadaServicing
    private let progressService: ProgressServicing

    init(
        service: KannadaServicing = ServiceFactory.shared.kannadaService,
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
                lesson = try await service.todayLesson()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func complete(currentStreak: Int, onStreakUpdated: @escaping (Int) -> Void) {
        guard let lesson else { return }

        Task {
            errorMessage = nil

            do {
                _ = try await service.completeLesson(lesson, currentStreak: currentStreak)
                let progress = try await progressService.awardKannadaLessonCompletion(lessonID: lesson.id)
                isCompleted = true
                onStreakUpdated(progress.currentStreak)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
