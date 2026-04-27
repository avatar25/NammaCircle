import SwiftUI

struct RentCheckView: View {
    @StateObject private var localityVM = LocalityViewModel()
    @StateObject private var viewModel = RentCheckViewModel()

    private let bhkOptions = ["1BHK", "2BHK", "3BHK"]
    private let furnishingOptions = ["unfurnished", "semi_furnished", "fully_furnished"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SectionCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Rent fairness check").font(.title2.bold())
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
                        .buttonStyle(.borderedProminent)
                    }
                }

                if let result = viewModel.result {
                    SectionCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(result.label.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(.title2.bold())
                            Text("Score \(result.score)")
                                .foregroundStyle(.secondary)
                            Text(result.explanation)
                            if let warning = result.depositWarning {
                                Label(warning, systemImage: "exclamationmark.triangle")
                                    .foregroundStyle(.orange)
                            }
                            Text("Negotiation points").font(.headline)
                            ForEach(result.negotiationPoints, id: \.self) { point in
                                Label(point, systemImage: "checkmark.circle")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.secondarySystemBackground))
        .navigationTitle("Rent Check")
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
