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
    func todayLesson() async throws -> KannadaLesson {
        // TODO: fetch published Kannada lesson from Supabase.
        throw ServicePlaceholderError.notImplemented
    }

    func completeLesson(_ lesson: KannadaLesson, currentStreak: Int) async throws -> Int {
        // TODO: persist lesson_attempts and user_streaks once auth exists.
        throw ServicePlaceholderError.notImplemented
    }
}
