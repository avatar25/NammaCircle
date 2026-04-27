import Foundation

final class ServiceFactory {
    static let shared = ServiceFactory()

    private let provider = SupabaseClientProvider.shared

    var localityService: LocalityServicing {
        AppConfiguration.isMockMode ? MockLocalityService() : SupabaseLocalityService(provider: provider)
    }

    var rentCheckService: RentCheckServicing {
        AppConfiguration.isMockMode ? MockRentCheckService() : SupabaseRentCheckService(provider: provider)
    }

    var kannadaService: KannadaServicing {
        AppConfiguration.isMockMode ? MockKannadaService() : SupabaseKannadaService(provider: provider)
    }

    var forumService: ForumServicing {
        AppConfiguration.isMockMode ? MockForumService() : SupabaseForumService(provider: provider)
    }

    var questService: QuestServicing {
        AppConfiguration.isMockMode ? MockQuestService() : SupabaseQuestService(provider: provider)
    }

    var mentorService: MentorServicing {
        AppConfiguration.isMockMode ? MockMentorService() : SupabaseMentorService(provider: provider)
    }
}
