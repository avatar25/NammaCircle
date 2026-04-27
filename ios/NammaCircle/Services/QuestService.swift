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
    private let provider: SupabaseClientProvider

    init(provider: SupabaseClientProvider = .shared) {
        self.provider = provider
    }

    func fetchQuests() async throws -> [Quest] {
        let rows: [SupabaseQuestRow] = try await provider.fetchTable(
            "quests",
            queryItems: [
                URLQueryItem(name: "select", value: "id,title,description,quest_type,points,is_active"),
                URLQueryItem(name: "is_active", value: "eq.true"),
                URLQueryItem(name: "order", value: "created_at.desc")
            ]
        )

        return rows.map {
            Quest(
                id: $0.id,
                title: $0.title,
                description: $0.description,
                questType: $0.questType,
                points: $0.points,
                isActive: $0.isActive
            )
        }
    }

    func submitQuest(_ quest: Quest, text: String) async throws {
        // TODO: insert quest_submissions once auth exists.
        throw ServicePlaceholderError.notImplemented
    }
}
