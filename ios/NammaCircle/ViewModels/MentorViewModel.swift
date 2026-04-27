import Foundation
import Combine

@MainActor
final class MentorViewModel: ObservableObject {
    @Published var mentors: [Mentor] = []
    @Published var bookingTopic = ""
    @Published var preferredTimeText = ""
    @Published var bookingStatuses: [UUID: MentorBookingStatus] = [:]
    @Published var isLoading = false
    @Published var isRequesting = false
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
                bookingStatuses = try await service.fetchBookingStatuses()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func requestBooking(for mentor: Mentor) {
        Task {
            errorMessage = nil
            isRequesting = true
            defer { isRequesting = false }

            do {
                let status = try await service.requestBooking(
                    mentor: mentor,
                    topic: bookingTopic,
                    preferredTime: preferredTimeText
                )
                bookingStatuses[mentor.id] = status
                bookingTopic = ""
                preferredTimeText = ""
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func status(for mentor: Mentor) -> MentorBookingStatus? {
        bookingStatuses[mentor.id]
    }

    func canRequest(_ mentor: Mentor) -> Bool {
        !bookingTopic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !isRequesting &&
        status(for: mentor) == nil
    }
}
