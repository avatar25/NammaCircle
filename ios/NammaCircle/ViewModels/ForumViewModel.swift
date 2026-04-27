import Foundation

@MainActor
final class ForumViewModel: ObservableObject {
    @Published var posts: [ForumPost] = []
    @Published var draftTitle = ""
    @Published var draftBody = ""
    @Published var draftCategory = "locality"
    @Published var errorMessage: String?

    private let service: ForumServicing

    init(service: ForumServicing = MockForumService()) {
        self.service = service
    }

    func load() {
        Task {
            do {
                posts = try await service.fetchPosts()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func createPost() {
        Task {
            do {
                try await service.createPost(title: draftTitle, body: draftBody, category: draftCategory)
                posts = try await service.fetchPosts()
                draftTitle = ""
                draftBody = ""
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
