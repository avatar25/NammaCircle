import Foundation

@MainActor
final class MentorViewModel: ObservableObject {
    @Published var mentors: [Mentor] = []
    @Published var bookingTopic = ""
    @Published var requestedMentorIDs: Set<UUID> = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: MentorServicing

    init(service: MentorServicing = ServiceFactory.shared.mentorService) {
        self.service = service
    }

    func load() {
        Task {
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }

            do {
                mentors = try await service.fetchMentors()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func requestBooking(for mentor: Mentor) {
        Task {
            errorMessage = nil

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
