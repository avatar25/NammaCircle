import Foundation

protocol KannadaServicing {
    func todayLesson() async throws -> KannadaLesson
    func completeLesson(_ lesson: KannadaLesson, currentStreak: Int) async throws -> Int
}

final class MockKannadaService: KannadaServicing {
    func todayLesson() async throws -> KannadaLesson {
        MockData.lesson
    }

    func completeLesson(_ lesson: KannadaLesson, currentStreak: Int) async throws -> Int {
        currentStreak + 1
    }
}

final class SupabaseKannadaService: KannadaServicing {
    private let provider: SupabaseClientProvider

    init(provider: SupabaseClientProvider = .shared) {
        self.provider = provider
    }

    func todayLesson() async throws -> KannadaLesson {
        let lessons: [SupabaseKannadaLessonRow] = try await provider.fetchTable(
            "kannada_lessons",
            queryItems: [
                URLQueryItem(name: "select", value: "id,title,situation,difficulty,sort_order,is_published"),
                URLQueryItem(name: "is_published", value: "eq.true"),
                URLQueryItem(name: "order", value: "sort_order.asc"),
                URLQueryItem(name: "limit", value: "1")
            ]
        )

        guard let lesson = lessons.first else {
            throw ServicePlaceholderError.supabaseRequestFailed("No published Kannada lessons found.")
        }

        let phrases: [SupabaseKannadaPhraseRow] = try await provider.fetchTable(
            "kannada_phrases",
            queryItems: [
                URLQueryItem(name: "select", value: "id,lesson_id,kannada_text,transliteration,english_meaning,usage_note,sort_order"),
                URLQueryItem(name: "lesson_id", value: "eq.\(lesson.id.uuidString)"),
                URLQueryItem(name: "order", value: "sort_order.asc"),
                URLQueryItem(name: "limit", value: "1")
            ]
        )

        guard let phrase = phrases.first else {
            throw ServicePlaceholderError.supabaseRequestFailed("No phrases found for today’s Kannada lesson.")
        }

        return KannadaLesson(
            id: lesson.id,
            title: lesson.title,
            situation: lesson.situation,
            phrase: KannadaPhrase(
                id: phrase.id,
                kannadaText: phrase.kannadaText,
                transliteration: phrase.transliteration,
                englishMeaning: phrase.englishMeaning,
                usageNote: phrase.usageNote ?? ""
            )
        )
    }

    func completeLesson(_ lesson: KannadaLesson, currentStreak: Int) async throws -> Int {
        currentStreak + 1
    }
}
