import Foundation

protocol ProgressServicing {
    func fetchProgress() async throws -> UserProgress
    func awardKannadaLessonCompletion(lessonID: UUID) async throws -> UserProgress
    func awardQuestCompletion(questID: UUID, points: Int) async throws -> UserProgress
    func awardForumAnswer(commentID: UUID) async throws -> UserProgress
}

final class MockProgressService: ProgressServicing {
    private var totalPoints = 0
    private var currentStreak = 0
    private var longestStreak = 0
    private var lastActivityDate: Date?
    private var awardedSources = Set<String>()

    func fetchProgress() async throws -> UserProgress {
        progress()
    }

    func awardKannadaLessonCompletion(lessonID: UUID) async throws -> UserProgress {
        award(points: 10, source: "kannada_lesson:\(lessonID)", updatesStreak: true)
    }

    func awardQuestCompletion(questID: UUID, points: Int) async throws -> UserProgress {
        award(points: points, source: "daily_quest:\(questID)", updatesStreak: true)
    }

    func awardForumAnswer(commentID: UUID) async throws -> UserProgress {
        award(points: 5, source: "forum_answer:\(commentID)", updatesStreak: false)
    }

    private func award(points: Int, source: String, updatesStreak: Bool) -> UserProgress {
        if !awardedSources.contains(source) {
            awardedSources.insert(source)
            totalPoints += points

            if updatesStreak {
                applyStreakActivity()
            }
        }

        return progress()
    }

    private func applyStreakActivity() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastActivityDate, calendar.isDate(lastActivityDate, inSameDayAs: today) {
            return
        }

        if let lastActivityDate,
           let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           calendar.isDate(lastActivityDate, inSameDayAs: yesterday) {
            currentStreak += 1
        } else {
            currentStreak = 1
        }

        longestStreak = max(longestStreak, currentStreak)
        lastActivityDate = today
    }

    private func progress() -> UserProgress {
        let next = RankName.nextRank(after: totalPoints)

        return UserProgress(
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            totalPoints: totalPoints,
            currentRank: RankName.rank(for: totalPoints),
            nextRank: next?.rank,
            pointsToNextRank: next.map { max($0.threshold - totalPoints, 0) }
        )
    }
}

final class SupabaseProgressService: ProgressServicing {
    private let provider: SupabaseClientProvider

    init(provider: SupabaseClientProvider = .shared) {
        self.provider = provider
    }

    func fetchProgress() async throws -> UserProgress {
        try await invoke(action: "summary", sourceID: nil)
    }

    func awardKannadaLessonCompletion(lessonID: UUID) async throws -> UserProgress {
        try await invoke(action: "complete_kannada_lesson", sourceID: lessonID)
    }

    func awardQuestCompletion(questID: UUID, points: Int) async throws -> UserProgress {
        try await invoke(action: "complete_daily_quest", sourceID: questID)
    }

    func awardForumAnswer(commentID: UUID) async throws -> UserProgress {
        try await invoke(action: "answer_forum_question", sourceID: commentID)
    }

    private func invoke(action: String, sourceID: UUID?) async throws -> UserProgress {
        let response: SupabaseRewardResponse = try await provider.invokeFunction(
            "rewards",
            body: SupabaseRewardRequest(action: action, sourceId: sourceID),
            authenticated: true
        )

        return UserProgress(
            currentStreak: response.currentStreak,
            longestStreak: response.longestStreak,
            totalPoints: response.totalPoints,
            currentRank: RankName(rawValue: response.currentRank) ?? .newcomer,
            nextRank: response.nextRank.flatMap(RankName.init(rawValue:)),
            pointsToNextRank: response.pointsToNextRank
        )
    }
}
