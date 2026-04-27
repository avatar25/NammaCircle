import SwiftUI

struct MentorView: View {
    @StateObject private var viewModel = MentorViewModel()

    var body: some View {
        List {
            ForEach(viewModel.mentors) { mentor in
                NavigationLink {
                    MentorDetailView(mentor: mentor, viewModel: viewModel)
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(mentor.displayName).font(.headline)
                            if mentor.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                        Text(mentor.bio)
                            .lineLimit(2)
                            .foregroundStyle(.secondary)
                        Text(mentor.specialties.joined(separator: ", "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Mentors")
        .task {
            viewModel.load()
        }
    }
}

struct MentorDetailView: View {
    let mentor: Mentor
    @ObservedObject var viewModel: MentorViewModel

    var body: some View {
        Form {
            Section("Mentor") {
                Text(mentor.displayName).font(.headline)
                Text(mentor.bio)
                Text("Specialties: \(mentor.specialties.joined(separator: ", "))")
                    .foregroundStyle(.secondary)
                Text("Booking is a placeholder. Payments are not implemented.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Request help") {
                TextField("Topic", text: $viewModel.bookingTopic)
                Button(viewModel.requestedMentorIDs.contains(mentor.id) ? "Requested" : "Request mentor help") {
                    viewModel.requestBooking(for: mentor)
                }
                .disabled(viewModel.bookingTopic.isEmpty || viewModel.requestedMentorIDs.contains(mentor.id))
            }
        }
        .navigationTitle("Mentor")
    }
}
