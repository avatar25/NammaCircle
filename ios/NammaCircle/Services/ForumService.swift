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
    private let provider: SupabaseClientProvider

    init(provider: SupabaseClientProvider = .shared) {
        self.provider = provider
    }

    func fetchPosts() async throws -> [ForumPost] {
        let posts: [SupabaseForumPostRow] = try await provider.fetchTable(
            "forum_posts",
            queryItems: [
                URLQueryItem(name: "select", value: "id,user_id,locality_id,title,body,category,urgency,moderation_status,created_at"),
                URLQueryItem(name: "moderation_status", value: "eq.visible"),
                URLQueryItem(name: "order", value: "created_at.desc"),
                URLQueryItem(name: "limit", value: "50")
            ]
        )
        let comments: [SupabaseForumCommentRow] = try await provider.fetchTable(
            "forum_comments",
            queryItems: [
                URLQueryItem(name: "select", value: "id,post_id,user_id,body,moderation_status,created_at"),
                URLQueryItem(name: "moderation_status", value: "eq.visible"),
                URLQueryItem(name: "order", value: "created_at.asc"),
                URLQueryItem(name: "limit", value: "100")
            ]
        )
        let commentsByPost = Dictionary(grouping: comments, by: \.postId)

        return posts.map { post in
            ForumPost(
                id: post.id,
                title: post.title,
                body: post.body,
                category: post.category,
                urgency: post.urgency ?? "normal",
                localityName: nil,
                comments: (commentsByPost[post.id] ?? []).map {
                    ForumComment(id: $0.id, body: $0.body, authorName: "Neighbor")
                }
            )
        }
    }

    func createPost(title: String, body: String, category: String) async throws {
        let session = try await provider.authenticatedSessionForWrite()
        let payload = SupabaseForumPostInsert(
            userId: session.userID,
            title: title,
            body: body,
            category: category,
            urgency: "normal",
            moderationStatus: "visible"
        )
        let _: [SupabaseForumPostRow] = try await provider.insert(
            into: "forum_posts",
            payload: payload,
            authenticated: true
        )
    }

    func addComment(postID: UUID, body: String) async throws {
        // TODO: insert forum_comments once auth exists.
        throw ServicePlaceholderError.notImplemented
    }
}
