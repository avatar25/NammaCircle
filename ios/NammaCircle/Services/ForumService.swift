import Foundation

protocol ForumServicing {
    func fetchPosts() async throws -> [ForumPost]
    func createPost(title: String, body: String, category: String) async throws
    func addComment(postID: UUID, body: String) async throws
}

final class MockForumService: ForumServicing {
    private var posts = MockData.posts

    func fetchPosts() async throws -> [ForumPost] {
        posts
    }

    func createPost(title: String, body: String, category: String) async throws {
        posts.insert(
            ForumPost(
                id: UUID(),
                title: title,
                body: body,
                category: category,
                urgency: "normal",
                localityName: nil,
                comments: []
            ),
            at: 0
        )
    }

    func addComment(postID: UUID, body: String) async throws {
        // TODO: mutate local mock store when moving beyond screen skeleton.
    }
}

final class SupabaseForumService: ForumServicing {
    func fetchPosts() async throws -> [ForumPost] {
        // TODO: fetch visible forum_posts and forum_comments from Supabase.
        throw ServicePlaceholderError.notImplemented
    }

    func createPost(title: String, body: String, category: String) async throws {
        // TODO: insert forum_posts once auth exists.
        throw ServicePlaceholderError.notImplemented
    }

    func addComment(postID: UUID, body: String) async throws {
        // TODO: insert forum_comments once auth exists.
        throw ServicePlaceholderError.notImplemented
    }
}
