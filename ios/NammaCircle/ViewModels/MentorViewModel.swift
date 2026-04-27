import Foundation

@MainActor
final class MentorViewModel: ObservableObject {
    @Published var mentors: [Mentor] = []
    @Published var bookingTopic = ""
    @Published var requestedMentorIDs: Set<UUID> = []
    @Published var errorMessage: String?

    private let service: MentorServicing

    init(service: MentorServicing = MockMentorService()) {
        self.service = service
    }

    func load() {
        Task {
            do {
                mentors = try await service.fetchMentors()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func requestBooking(for mentor: Mentor) {
        Task {
            do {
                try await service.requestBooking(mentor: mentor, topic: bookingTopic)
                requestedMentorIDs.insert(mentor.id)
                bookingTopic = ""
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
