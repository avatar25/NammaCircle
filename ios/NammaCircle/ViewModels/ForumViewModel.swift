import Foundation

@MainActor
final class ForumViewModel: ObservableObject {
    @Published var posts: [ForumPost] = []
    @Published var draftTitle = ""
    @Published var draftBody = ""
    @Published var draftCategory = "locality"
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?

    private let service: ForumServicing

    init(service: ForumServicing = ServiceFactory.shared.forumService) {
        self.service = service
    }

    func load() {
        Task {
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }

            do {
                posts = try await service.fetchPosts()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func createPost() {
        Task {
            isSaving = true
            errorMessage = nil
            defer { isSaving = false }

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
