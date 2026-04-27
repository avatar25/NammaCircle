import Foundation

protocol QuestServicing {
    func fetchQuests() async throws -> [Quest]
    func submitQuest(_ quest: Quest, text: String) async throws
}

final class MockQuestService: QuestServicing {
    func fetchQuests() async throws -> [Quest] {
        MockData.quests
    }

    func submitQuest(_ quest: Quest, text: String) async throws {
        // TODO: store local submission state for richer mock flows.
    }
}

final class SupabaseQuestService: QuestServicing {
    func fetchQuests() async throws -> [Quest] {
        // TODO: fetch active quests from Supabase.
        throw ServicePlaceholderError.notImplemented
    }

    func submitQuest(_ quest: Quest, text: String) async throws {
        // TODO: insert quest_submissions once auth exists.
        throw ServicePlaceholderError.notImplemented
    }
}
