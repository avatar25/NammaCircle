import Foundation

protocol QuestServicing {
    func fetchQuests() async throws -> [Quest]
    func fetchSubmissionStatuses() async throws -> [UUID: QuestSubmissionStatus]
    func submitQuest(_ quest: Quest, text: String, proofImage: QuestProofImage?) async throws -> QuestSubmissionStatus
}

struct QuestProofImage {
    let data: Data
    let mimeType: String
    let fileExtension: String
}

final class MockQuestService: QuestServicing {
    private var statuses: [UUID: QuestSubmissionStatus] = [:]

    func fetchQuests() async throws -> [Quest] {
        MockData.quests
    }

    func fetchSubmissionStatuses() async throws -> [UUID: QuestSubmissionStatus] {
        statuses
    }

    func submitQuest(_ quest: Quest, text: String, proofImage: QuestProofImage?) async throws -> QuestSubmissionStatus {
        let status: QuestSubmissionStatus = quest.autoApproves ? .approved : .pending
        statuses[quest.id] = status
        return status
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

    func fetchSubmissionStatuses() async throws -> [UUID: QuestSubmissionStatus] {
        let session = try await provider.authenticatedSessionForWrite()
        let rows: [SupabaseQuestSubmissionRow] = try await provider.fetchTable(
            "quest_submissions",
            queryItems: [
                URLQueryItem(name: "select", value: "id,quest_id,user_id,text_response,photo_url,verification_status,created_at"),
                URLQueryItem(name: "user_id", value: "eq.\(session.userID.uuidString)"),
                URLQueryItem(name: "order", value: "created_at.desc")
            ],
            authenticated: true
        )

        var statuses: [UUID: QuestSubmissionStatus] = [:]
        for row in rows where statuses[row.questId] == nil {
            statuses[row.questId] = QuestSubmissionStatus(rawValue: row.verificationStatus) ?? .pending
        }
        return statuses
    }

    func submitQuest(_ quest: Quest, text: String, proofImage: QuestProofImage?) async throws -> QuestSubmissionStatus {
        let session = try await provider.authenticatedSessionForWrite()
        let photoURL: String?
        if let proofImage {
            photoURL = try await provider.uploadQuestProofImage(
                data: proofImage.data,
                mimeType: proofImage.mimeType,
                fileExtension: proofImage.fileExtension,
                session: session
            )
        } else {
            photoURL = nil
        }
        let status: QuestSubmissionStatus = quest.autoApproves ? .approved : .pending
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let payload = SupabaseQuestSubmissionInsert(
            questId: quest.id,
            userId: session.userID,
            textResponse: trimmedText.isEmpty ? nil : trimmedText,
            photoUrl: photoURL,
            verificationStatus: status.rawValue
        )
        let _: [SupabaseQuestSubmissionRow] = try await provider.insert(
            into: "quest_submissions",
            payload: payload,
            authenticated: true
        )
        return status
    }
}
