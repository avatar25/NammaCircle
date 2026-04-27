import SwiftUI

struct LoadingStateView: View {
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(NammaColor.deepGreen)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(NammaColor.muted)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "leaf.fill")
                .font(.title2)
                .foregroundStyle(NammaColor.leaf)
            Text(title)
                .font(.headline)
                .foregroundStyle(NammaColor.ink)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(NammaColor.muted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct ErrorBanner: View {
    let message: String

    var body: some View {
        Label(message, systemImage: "exclamationmark.triangle")
            .font(.subheadline)
            .foregroundStyle(NammaColor.danger)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(NammaColor.danger.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(NammaColor.danger.opacity(0.12), lineWidth: 1)
            }
    }
}
