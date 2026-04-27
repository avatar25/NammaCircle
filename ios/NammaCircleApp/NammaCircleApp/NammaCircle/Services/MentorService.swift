import Foundation

protocol MentorServicing {
    func fetchMentors() async throws -> [Mentor]
    func fetchBookingStatuses() async throws -> [UUID: MentorBookingStatus]
    func requestBooking(mentor: Mentor, topic: String, preferredTime: String) async throws -> MentorBookingStatus
}

final class MockMentorService: MentorServicing {
    private var statuses: [UUID: MentorBookingStatus] = [:]

    func fetchMentors() async throws -> [Mentor] {
        MockData.mentors
    }

    func fetchBookingStatuses() async throws -> [UUID: MentorBookingStatus] {
        statuses
    }

    func requestBooking(mentor: Mentor, topic: String, preferredTime: String) async throws -> MentorBookingStatus {
        statuses[mentor.id] = .pending
        return .pending
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

    func fetchBookingStatuses() async throws -> [UUID: MentorBookingStatus] {
        let session = try await provider.authenticatedSessionForWrite()
        let rows: [SupabaseMentorBookingRow] = try await provider.fetchTable(
            "mentor_bookings",
            queryItems: [
                URLQueryItem(name: "select", value: "id,mentor_id,user_id,topic,preferred_time_text,status,scheduled_at,created_at"),
                URLQueryItem(name: "user_id", value: "eq.\(session.userID.uuidString)"),
                URLQueryItem(name: "order", value: "created_at.desc")
            ],
            authenticated: true
        )

        var statuses: [UUID: MentorBookingStatus] = [:]
        for row in rows where statuses[row.mentorId] == nil {
            statuses[row.mentorId] = MentorBookingStatus(rawValue: row.status) ?? .pending
        }
        return statuses
    }

    func requestBooking(mentor: Mentor, topic: String, preferredTime: String) async throws -> MentorBookingStatus {
        let session = try await provider.authenticatedSessionForWrite()
        let payload = SupabaseMentorBookingInsert(
            mentorId: mentor.id,
            userId: session.userID,
            topic: topic,
            preferredTimeText: preferredTime.isEmpty ? nil : preferredTime,
            status: MentorBookingStatus.pending.rawValue
        )
        let _: [SupabaseMentorBookingRow] = try await provider.insert(
            into: "mentor_bookings",
            payload: payload,
            authenticated: true
        )
        return .pending
    }
}
