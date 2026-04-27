import SwiftUI

struct ForumView: View {
    @StateObject private var viewModel = ForumViewModel()
    @State private var isCreating = false

    var body: some View {
        List {
            if let errorMessage = viewModel.errorMessage {
                ErrorBanner(message: errorMessage)
            }

            Section {
                Button {
                    isCreating = true
                } label: {
                    Label("Create post", systemImage: "square.and.pencil")
                }
            }

            Section("Questions") {
                if viewModel.isLoading {
                    LoadingStateView(message: "Loading forum")
                } else if viewModel.posts.isEmpty {
                    EmptyStateView(title: "No posts", message: "No approved forum posts are available yet.")
                } else {
                    ForEach(viewModel.posts) { post in
                        NavigationLink {
                            ForumPostDetailView(post: post)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(post.title).font(.headline)
                                Text(post.body)
                                    .lineLimit(2)
                                    .foregroundStyle(.secondary)
                                HStack {
                                    Text(post.category)
                                    if let locality = post.localityName {
                                        Text(locality)
                                    }
                                    Text("\(post.comments.count) comments")
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Forum")
        .sheet(isPresented: $isCreating) {
            NavigationStack {
                CreatePostView(viewModel: viewModel)
            }
        }
        .task {
            viewModel.load()
        }
    }
}

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ForumViewModel

    var body: some View {
        Form {
            TextField("Title", text: $viewModel.draftTitle)
            TextField("Category", text: $viewModel.draftCategory)
            TextEditor(text: $viewModel.draftBody)
                .frame(minHeight: 180)
            Button("Post question") {
                viewModel.createPost()
                dismiss()
            }
            .disabled(viewModel.draftTitle.isEmpty || viewModel.draftBody.isEmpty || viewModel.isSaving)
        }
        .navigationTitle("Create Post")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}

struct ForumPostDetailView: View {
    let post: ForumPost
    @State private var draftComment = ""

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(post.title).font(.title2.bold())
                    Text(post.body)
                    Text("\(post.category) / \(post.urgency)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Comments") {
                ForEach(post.comments) { comment in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(comment.authorName).font(.caption.bold())
                        Text(comment.body)
                    }
                }
                HStack {
                    TextField("Add comment placeholder", text: $draftComment)
                    Button("Send") {
                        draftComment = ""
                    }
                }
            }
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
    }
}
