import SwiftUI

struct MentorView: View {
    @StateObject private var viewModel = MentorViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                NammaScreenHeader(
                    eyebrow: "Mentors",
                    title: "Local help from people who have been there",
                    subtitle: "Ask practical questions before you choose a neighbourhood or negotiate.",
                    systemImage: "person.2.fill"
                )

            if let errorMessage = viewModel.errorMessage {
                ErrorBanner(message: errorMessage)
            }

            if viewModel.isLoading {
                LoadingStateView(message: "Loading mentors")
            } else if viewModel.mentors.isEmpty {
                EmptyStateView(title: "No mentors", message: "No verified mentors are available yet.")
            } else {
                ForEach(viewModel.mentors) { mentor in
                    NavigationLink {
                        MentorDetailView(mentor: mentor, viewModel: viewModel)
                    } label: {
                        MentorCard(mentor: mentor, status: viewModel.status(for: mentor))
                    }
                    .buttonStyle(.plain)
                }
            }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
        }
        .background(NammaBackground().ignoresSafeArea())
        .navigationTitle("Mentors")
        .navigationBarTitleDisplayMode(.inline)
        .tint(NammaColor.deepGreen)
        .task {
            viewModel.load()
        }
    }
}

struct MentorCard: View {
    let mentor: Mentor
    let status: MentorBookingStatus?

    var body: some View {
        SectionCard(tone: .sky) {
            HStack(spacing: 14) {
                BengaluruIllustrationView(scene: .community)
                    .frame(width: 94, height: 98)
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Text(mentor.displayName)
                            .font(.headline)
                            .foregroundStyle(NammaColor.ink)
                        if mentor.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(NammaColor.leaf)
                        }
                    }
                    Text(mentor.bio)
                        .font(.subheadline)
                        .lineLimit(2)
                        .foregroundStyle(NammaColor.muted)
                    NammaBadge(text: mentor.specialties.joined(separator: ", "), systemImage: "leaf.fill", tone: NammaColor.teal)
                    if let status {
                        NammaBadge(text: status.title, systemImage: "clock.fill", tone: statusTint(status))
                    }
                }
                Spacer()
            }
        }
    }
}

struct MentorDetailView: View {
    let mentor: Mentor
    @ObservedObject var viewModel: MentorViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                SectionCard(tone: .hero) {
                    VStack(alignment: .leading, spacing: 12) {
                        BengaluruIllustrationView(scene: .community)
                            .frame(height: 150)
                        HStack {
                            Text(mentor.displayName)
                                .font(.title2.bold())
                                .foregroundStyle(NammaColor.ink)
                            if mentor.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(NammaColor.leaf)
                            }
                        }
                        Text(mentor.bio)
                            .foregroundStyle(NammaColor.muted)
                        NammaBadge(text: mentor.specialties.joined(separator: ", "), systemImage: "leaf.fill", tone: NammaColor.teal)
                        if let rate = mentor.hourlyRateInr {
                            Text("INR \(rate)/hour")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(NammaColor.ink)
                        }
                        Text("Payments are not implemented.")
                            .font(.caption)
                            .foregroundStyle(NammaColor.muted)
                    }
                }

                SectionCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Request help")
                            .font(.headline)
                            .foregroundStyle(NammaColor.ink)
                        TextField("Topic", text: $viewModel.bookingTopic)
                            .textFieldStyle(.roundedBorder)
                        TextField("Preferred time", text: $viewModel.preferredTimeText)
                            .textFieldStyle(.roundedBorder)
                        if let status = viewModel.status(for: mentor) {
                            Label(status.title, systemImage: "clock.fill")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(statusTint(status))
                        }
                        Button(viewModel.status(for: mentor) == nil ? "Request mentor help" : "Request pending") {
                            viewModel.requestBooking(for: mentor)
                        }
                        .buttonStyle(NammaPrimaryButtonStyle())
                        .disabled(!viewModel.canRequest(mentor))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
        }
        .background(NammaBackground().ignoresSafeArea())
        .navigationTitle("Mentor")
        .navigationBarTitleDisplayMode(.inline)
        .tint(NammaColor.deepGreen)
    }
}

private func statusTint(_ status: MentorBookingStatus) -> Color {
    switch status {
    case .pending: return NammaColor.saffron
    case .accepted: return NammaColor.deepGreen
    case .completed: return NammaColor.teal
    case .cancelled: return NammaColor.rose
    }
}
