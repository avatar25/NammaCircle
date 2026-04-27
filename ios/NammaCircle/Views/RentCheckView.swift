import SwiftUI

struct RentCheckView: View {
    @StateObject private var localityVM = LocalityViewModel()
    @StateObject private var viewModel = RentCheckViewModel()

    private let bhkOptions = ["1BHK", "2BHK", "3BHK"]
    private let furnishingOptions = ["unfurnished", "semi_furnished", "fully_furnished"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                NammaScreenHeader(
                    eyebrow: "Rent check",
                    title: "Check fairness before you negotiate",
                    subtitle: "Deterministic MVP guidance using locality baselines. Verify before making financial decisions.",
                    systemImage: "indianrupeesign.circle.fill"
                )

                SectionCard(tone: .peach) {
                    VStack(alignment: .leading, spacing: 14) {
                        BengaluruIllustrationView(scene: .rent)
                            .frame(height: 148)
                        Text("Rent details")
                            .font(.title2.bold())
                            .foregroundStyle(NammaColor.ink)
                        if let errorMessage = viewModel.errorMessage {
                            ErrorBanner(message: errorMessage)
                        }
                        Picker("Locality", selection: $viewModel.input.locality) {
                            Text("Choose locality").tag(Locality?.none)
                            ForEach(localityVM.localities) { locality in
                                Text(locality.name).tag(Optional(locality))
                            }
                        }
                        Picker("BHK", selection: $viewModel.input.bhk) {
                            ForEach(bhkOptions, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        TextField("Monthly rent", text: $viewModel.input.monthlyRent)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                        TextField("Deposit", text: $viewModel.input.deposit)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                        Picker("Furnishing", selection: $viewModel.input.furnishing) {
                            ForEach(furnishingOptions, id: \.self) { option in
                                Text(option.replacingOccurrences(of: "_", with: " ")).tag(option)
                            }
                        }
                        TextField("Maintenance", text: $viewModel.input.maintenance)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                        Button(viewModel.isChecking ? "Checking..." : "Check rent") {
                            viewModel.checkRent()
                        }
                        .buttonStyle(NammaPrimaryButtonStyle())
                    }
                }

                if let result = viewModel.result {
                    SectionCard(tone: .leaf) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(result.label.replacingOccurrences(of: "_", with: " ").capitalized)
                                        .font(.title2.bold())
                                        .foregroundStyle(NammaColor.ink)
                                    Text("Score \(result.score)")
                                        .font(.subheadline)
                                        .foregroundStyle(NammaColor.muted)
                                }
                                Spacer()
                                NammaBadge(text: "Result", systemImage: "checkmark.seal.fill", tone: NammaColor.leaf)
                            }
                            NammaProgressBar(value: Double(result.score) / 100, tint: NammaColor.leaf)
                            Text(result.explanation)
                                .font(.subheadline)
                                .foregroundStyle(NammaColor.muted)
                            if let warning = result.depositWarning {
                                Label(warning, systemImage: "exclamationmark.triangle")
                                    .foregroundStyle(NammaColor.terracotta)
                            }
                            Text("Negotiation points")
                                .font(.headline)
                                .foregroundStyle(NammaColor.ink)
                            ForEach(result.negotiationPoints, id: \.self) { point in
                                Label(point, systemImage: "checkmark.circle")
                                    .font(.subheadline)
                                    .foregroundStyle(NammaColor.deepGreen)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
        }
        .background(NammaBackground().ignoresSafeArea())
        .navigationTitle("Rent Check")
        .navigationBarTitleDisplayMode(.inline)
        .tint(NammaColor.deepGreen)
        .task {
            localityVM.load()
        }
        .onChange(of: localityVM.localities) { _, localities in
            if viewModel.input.locality == nil {
                viewModel.input.locality = localities.first
            }
        }
    }
}
