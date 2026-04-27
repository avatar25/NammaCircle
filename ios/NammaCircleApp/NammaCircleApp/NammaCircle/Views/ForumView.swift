import SwiftUI

struct ForumView: View {
    @StateObject private var viewModel = ForumViewModel()
    @State private var isCreating = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                NammaScreenHeader(
                    eyebrow: "Community",
                    title: "Questions from people settling in",
                    subtitle: "Ask about localities, rent, commute, and everyday Bangalore life.",
                    systemImage: "bubble.left.and.bubble.right.fill"
                )

            if let errorMessage = viewModel.errorMessage {
                ErrorBanner(message: errorMessage)
            }

            if let submissionMessage = viewModel.submissionMessage {
                SectionCard(tone: .leaf) {
                    Label(submissionMessage, systemImage: "checkmark.circle.fill")
                        .foregroundStyle(NammaColor.leaf)
                }
            }

            if let reportMessage = viewModel.reportMessage {
                SectionCard(tone: .peach) {
                    Label(reportMessage, systemImage: "flag.fill")
                        .foregroundStyle(NammaColor.terracotta)
                }
            }

            SectionCard(tone: .sky) {
                Button {
                    isCreating = true
                } label: {
                    Label("Create post", systemImage: "square.and.pencil")
                }
                .buttonStyle(NammaPrimaryButtonStyle())
            }

                if viewModel.isLoading {
                    LoadingStateView(message: "Loading forum")
                } else if viewModel.posts.isEmpty {
                    EmptyStateView(title: "No posts", message: "No approved forum posts are available yet.")
                } else {
                    ForEach(viewModel.posts) { post in
                        NavigationLink {
                            ForumPostDetailView(post: post, viewModel: viewModel)
                        } label: {
                            ForumPostCard(post: post)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
        }
        .background(NammaBackground().ignoresSafeArea())
        .navigationTitle("Community")
        .navigationBarTitleDisplayMode(.inline)
        .tint(NammaColor.deepGreen)
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

struct ForumPostCard: View {
    let post: ForumPost

    var body: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(post.title)
                            .font(.headline)
                            .foregroundStyle(NammaColor.ink)
                        Text(post.body)
                            .font(.subheadline)
                            .lineLimit(2)
                            .foregroundStyle(NammaColor.muted)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(NammaColor.deepGreen)
                }
                HStack(spacing: 8) {
                    NammaBadge(text: post.category, systemImage: nil, tone: NammaColor.teal)
                    if let locality = post.localityName {
                        NammaBadge(text: locality, systemImage: "mappin", tone: NammaColor.leaf)
                    }
                    Spacer()
                    Text("\(post.comments.count) comments")
                        .font(.caption)
                        .foregroundStyle(NammaColor.muted)
                }
            }
        }
    }
}

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ForumViewModel

    var body: some View {
        Form {
            Section {
                NammaScreenHeader(
                    eyebrow: "Community",
                    title: "Create a post",
                    subtitle: "Posts are submitted for review before they become visible.",
                    systemImage: "square.and.pencil"
                )
            }
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
        .scrollContentBackground(.hidden)
        .background(NammaBackground().ignoresSafeArea())
        .navigationTitle("Create Post")
        .tint(NammaColor.deepGreen)
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
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                SectionCard(tone: .sky) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(post.title)
                            .font(.title2.bold())
                            .foregroundStyle(NammaColor.ink)
                        Text(post.body)
                            .foregroundStyle(NammaColor.muted)
                        HStack(spacing: 8) {
                            NammaBadge(text: post.category, systemImage: nil, tone: NammaColor.teal)
                            NammaBadge(text: post.urgency, systemImage: "clock", tone: NammaColor.terracotta)
                        }
                    Button(role: .destructive) {
                        viewModel.reportPost(post)
                    } label: {
                        Label("Report post", systemImage: "flag")
                    }
                    .buttonStyle(NammaSecondaryButtonStyle())
                }
            }

                SectionCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Comments")
                            .font(.headline)
                            .foregroundStyle(NammaColor.ink)
                ForEach(post.comments) { comment in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(comment.authorName)
                                    .font(.caption.bold())
                                    .foregroundStyle(NammaColor.deepGreen)
                                Text(comment.body)
                                    .font(.subheadline)
                                    .foregroundStyle(NammaColor.muted)
                                Button(role: .destructive) {
                                    viewModel.reportComment(comment)
                                } label: {
                                    Label("Report", systemImage: "flag")
                                        .font(.caption)
                                }
                                .buttonStyle(.borderless)
                            }
                            .padding(.vertical, 4)
                        }

                        HStack {
                            TextField("Add comment placeholder", text: $draftComment)
                                .textFieldStyle(.roundedBorder)
                            Button("Send") {
                                draftComment = ""
                            }
                            .buttonStyle(NammaSecondaryButtonStyle())
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
        }
        .background(NammaBackground().ignoresSafeArea())
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .tint(NammaColor.deepGreen)
    }
}
