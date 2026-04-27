import SwiftUI

struct ForumView: View {
    @StateObject private var viewModel = ForumViewModel()
    @State private var isCreating = false

    var body: some View {
        List {
            if let errorMessage = viewModel.errorMessage {
                ErrorBanner(message: errorMessage)
            }

            if let submissionMessage = viewModel.submissionMessage {
                Section {
                    Label(submissionMessage, systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }

            if let reportMessage = viewModel.reportMessage {
                Section {
                    Label(reportMessage, systemImage: "flag.fill")
                        .foregroundStyle(.orange)
                }
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
                            ForumPostDetailView(post: post, viewModel: viewModel)
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
    @ObservedObject var viewModel: ForumViewModel
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
                    Button(role: .destructive) {
                        viewModel.reportPost(post)
                    } label: {
                        Label("Report post", systemImage: "flag")
                    }
                    .buttonStyle(.borderless)
                }
            }

            Section("Comments") {
                ForEach(post.comments) { comment in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(comment.authorName).font(.caption.bold())
                        Text(comment.body)
                        Button(role: .destructive) {
                            viewModel.reportComment(comment)
                        } label: {
                            Label("Report", systemImage: "flag")
                                .font(.caption)
                        }
                        .buttonStyle(.borderless)
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
