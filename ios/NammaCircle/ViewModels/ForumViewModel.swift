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
    @Published var submissionMessage: String?
    @Published var reportMessage: String?

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
            submissionMessage = nil
            defer { isSaving = false }

            do {
                try await service.createPost(title: draftTitle, body: draftBody, category: draftCategory)
                posts = try await service.fetchPosts()
                draftTitle = ""
                draftBody = ""
                submissionMessage = "Submitted for review."
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func reportPost(_ post: ForumPost) {
        Task {
            errorMessage = nil
            reportMessage = nil

            do {
                try await service.reportPost(postID: post.id, reason: "User reported from iOS")
                reportMessage = "Report submitted for review."
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func reportComment(_ comment: ForumComment) {
        Task {
            errorMessage = nil
            reportMessage = nil

            do {
                try await service.reportComment(commentID: comment.id, reason: "User reported from iOS")
                reportMessage = "Report submitted for review."
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
