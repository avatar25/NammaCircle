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
    func fetchMentors() async throws -> [Mentor] {
        // TODO: fetch verified mentors from Supabase.
        throw ServicePlaceholderError.notImplemented
    }

    func requestBooking(mentor: Mentor, topic: String) async throws {
        // TODO: insert mentor_bookings once auth exists.
        throw ServicePlaceholderError.notImplemented
    }
}
