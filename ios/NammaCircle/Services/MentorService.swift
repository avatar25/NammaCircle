import Foundation

protocol MentorServicing {
    func fetchMentors() async throws -> [Mentor]
    func requestBooking(mentor: Mentor, topic: String) async throws
}

final class MockMentorService: MentorServicing {
    func fetchMentors() async throws -> [Mentor] {
        MockData.mentors
    }

    func requestBooking(mentor: Mentor, topic: String) async throws {
        // TODO: show local pending state after MVP flows settle.
    }
}

final class SupabaseMentorService: MentorServicing {
    private let provider: SupabaseClientProvider

    init(provider: SupabaseClientProvider = .shared) {
        self.provider = provider
    }

    func fetchMentors() async throws -> [Mentor] {
        let rows: [SupabaseMentorRow] = try await provider.fetchTable(
            "mentors",
            queryItems: [
                URLQueryItem(name: "select", value: "id,user_id,display_name,bio,specialties,hourly_rate_inr,is_verified"),
                URLQueryItem(name: "is_verified", value: "eq.true"),
                URLQueryItem(name: "order", value: "created_at.desc")
            ]
        )

        return rows.map {
            Mentor(
                id: $0.id,
                displayName: $0.displayName,
                bio: $0.bio ?? "",
                specialties: $0.specialties ?? [],
                hourlyRateInr: $0.hourlyRateInr,
                isVerified: $0.isVerified
            )
        }
    }

    func requestBooking(mentor: Mentor, topic: String) async throws {
        // TODO: insert mentor_bookings once auth exists.
        throw ServicePlaceholderError.notImplemented
    }
}
