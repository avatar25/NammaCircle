import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct QuestsView: View {
    @StateObject private var viewModel = QuestViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                NammaScreenHeader(
                    eyebrow: "Namma quests",
                    title: "Tiny challenges for finding your feet",
                    subtitle: "Complete useful city tasks, build confidence, and earn progress points.",
                    systemImage: "sparkles"
                )

            if let errorMessage = viewModel.errorMessage {
                ErrorBanner(message: errorMessage)
            }

                if viewModel.isLoading {
                    LoadingStateView(message: "Loading quests")
                } else if viewModel.quests.isEmpty {
                    EmptyStateView(title: "No quests", message: "No active quests are available yet.")
                } else {
                    ForEach(viewModel.quests) { quest in
                        NavigationLink {
                            QuestDetailView(quest: quest, viewModel: viewModel)
                        } label: {
                            QuestCard(quest: quest, status: viewModel.status(for: quest))
                        }
                        .buttonStyle(.plain)
                    }
                }

                NavigationLink {
                    MentorView()
                } label: {
                    SectionCard(tone: .sky) {
                        HStack {
                            Label("Find a mentor", systemImage: "person.2.fill")
                                .font(.headline)
                                .foregroundStyle(NammaColor.ink)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(NammaColor.deepGreen)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
        }
        .background(NammaBackground().ignoresSafeArea())
        .navigationTitle("Quests")
        .navigationBarTitleDisplayMode(.inline)
        .tint(NammaColor.deepGreen)
        .task {
            viewModel.load()
        }
    }
}

struct QuestCard: View {
    let quest: Quest
    let status: QuestSubmissionStatus?

    var body: some View {
        SectionCard(tone: .peach) {
            HStack(spacing: 14) {
                BengaluruIllustrationView(scene: .quest)
                    .frame(width: 94, height: 96)
                VStack(alignment: .leading, spacing: 8) {
                    Text(quest.title)
                        .font(.headline)
                        .foregroundStyle(NammaColor.ink)
                    Text(quest.description)
                        .font(.subheadline)
                        .lineLimit(2)
                        .foregroundStyle(NammaColor.muted)
                    HStack {
                        NammaBadge(text: "+\(quest.points) points", systemImage: "rosette", tone: NammaColor.rose)
                        if let status {
                            NammaBadge(text: status.title, systemImage: "checkmark.seal", tone: statusTint(status))
                        }
                    }
                }
                Spacer()
            }
        }
    }
}

struct QuestDetailView: View {
    let quest: Quest
    @ObservedObject var viewModel: QuestViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                SectionCard(tone: .hero) {
                    VStack(alignment: .leading, spacing: 12) {
                        BengaluruIllustrationView(scene: .quest)
                            .frame(height: 150)
                        Text(quest.title)
                            .font(.title2.bold())
                            .foregroundStyle(NammaColor.ink)
                        Text(quest.description)
                            .foregroundStyle(NammaColor.muted)
                        NammaBadge(text: "\(quest.points) points", systemImage: "sparkles", tone: NammaColor.rose)
                    }
                }

                SectionCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Submit proof")
                            .font(.headline)
                            .foregroundStyle(NammaColor.ink)
                        if let status = viewModel.status(for: quest) {
                            Label(status.title, systemImage: statusIcon(status))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(statusTint(status))
                        } else if quest.autoApproves {
                            Label("Auto-approves after submit", systemImage: "bolt.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(NammaColor.deepGreen)
                        }
                        TextEditor(text: $viewModel.submissionText)
                            .frame(minHeight: 160)
                            .scrollContentBackground(.hidden)
                            .padding(10)
                            .background(.white.opacity(0.62))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        VStack(alignment: .leading, spacing: 8) {
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                Label(viewModel.selectedProofImage == nil ? "Attach quest photo" : "Replace quest photo", systemImage: "photo")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(NammaColor.deepGreen)
                            }
                            .onChange(of: selectedPhotoItem) { _, item in
                                prepareProofImage(from: item)
                            }
                            if viewModel.isPreparingPhoto {
                                Label("Preparing photo", systemImage: "hourglass")
                                    .font(.caption)
                                    .foregroundStyle(NammaColor.muted)
                            } else if let label = viewModel.selectedProofImageLabel {
                                HStack {
                                    Label(label, systemImage: "checkmark.circle.fill")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(NammaColor.deepGreen)
                                    Spacer()
                                    Button("Remove") {
                                        selectedPhotoItem = nil
                                        viewModel.clearProofImage()
                                    }
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(NammaColor.rose)
                                }
                            }
                        }
                        Button(submitTitle(for: quest, status: viewModel.status(for: quest))) {
                            viewModel.submit(quest)
                        }
                        .buttonStyle(NammaPrimaryButtonStyle())
                        .disabled(!viewModel.canSubmit(quest))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
        }
        .background(NammaBackground().ignoresSafeArea())
        .navigationTitle("Quest Detail")
        .navigationBarTitleDisplayMode(.inline)
        .tint(NammaColor.deepGreen)
    }

    private func prepareProofImage(from item: PhotosPickerItem?) {
        guard let item else {
            viewModel.clearProofImage()
            return
        }

        Task {
            viewModel.beginPreparingProofImage()
            do {
                guard let data = try await item.loadTransferable(type: Data.self) else {
                    throw ServicePlaceholderError.supabaseRequestFailed("Could not read the selected image.")
                }

                let contentType = item.supportedContentTypes.first { $0.conforms(to: .image) } ?? .jpeg
                viewModel.setProofImage(
                    data: data,
                    mimeType: contentType.preferredMIMEType ?? "image/jpeg",
                    fileExtension: contentType.preferredFilenameExtension ?? "jpg"
                )
            } catch {
                viewModel.failPreparingProofImage(error)
            }
        }
    }
}

private func submitTitle(for quest: Quest, status: QuestSubmissionStatus?) -> String {
    switch status {
    case .pending: return "Pending review"
    case .approved: return "Approved"
    case .rejected: return "Resubmit proof"
    case nil: return quest.autoApproves ? "Submit and auto-approve" : "Submit for review"
    }
}

private func statusIcon(_ status: QuestSubmissionStatus) -> String {
    switch status {
    case .pending: return "clock.fill"
    case .approved: return "checkmark.seal.fill"
    case .rejected: return "xmark.octagon.fill"
    }
}

private func statusTint(_ status: QuestSubmissionStatus) -> Color {
    switch status {
    case .pending: return NammaColor.saffron
    case .approved: return NammaColor.deepGreen
    case .rejected: return NammaColor.rose
    }
}
