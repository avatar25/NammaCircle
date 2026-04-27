import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState
    @State private var customTag = ""

    private let suggestedTags = ["cafes", "metro", "quiet", "nightlife", "budget", "english friendly"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Find your Bangalore starting point")
                            .font(.largeTitle.bold())
                        Text("Tell NammaCircle what matters for your first home base. This is mock-only for now.")
                            .foregroundStyle(.secondary)
                    }

                    SectionCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Work and budget").font(.headline)
                            TextField("Office location or landmark", text: $appState.onboarding.workLocationText)
                                .textFieldStyle(.roundedBorder)

                            Stepper("Budget min: INR \(appState.onboarding.budgetMin)", value: $appState.onboarding.budgetMin, in: 5_000...150_000, step: 5_000)
                            Stepper("Budget max: INR \(appState.onboarding.budgetMax)", value: $appState.onboarding.budgetMax, in: 10_000...250_000, step: 5_000)
                            Stepper("Commute tolerance: \(appState.onboarding.commuteToleranceMinutes) min", value: $appState.onboarding.commuteToleranceMinutes, in: 10...120, step: 5)
                        }
                    }

                    SectionCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Lifestyle").font(.headline)
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], alignment: .leading) {
                                ForEach(suggestedTags, id: \.self) { tag in
                                    Toggle(tag, isOn: tagBinding(tag))
                                        .toggleStyle(.button)
                                }
                            }
                            HStack {
                                TextField("Add tag", text: $customTag)
                                    .textFieldStyle(.roundedBorder)
                                Button("Add") {
                                    addCustomTag()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    }

                    SectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Preferences").font(.headline)
                            Toggle("Prefer quiet streets", isOn: $appState.onboarding.wantsQuiet)
                            Toggle("Want social life nearby", isOn: $appState.onboarding.wantsSocialLife)
                            Toggle("Prioritize low cost", isOn: $appState.onboarding.wantsLowCost)
                            Toggle("Want food options", isOn: $appState.onboarding.wantsFoodOptions)
                            Toggle("Prefer lower Kannada dependency", isOn: $appState.onboarding.wantsLowKannadaDependency)
                            Toggle("Prefer lower broker risk", isOn: $appState.onboarding.wantsLowBrokerRisk)
                        }
                    }

                    Button {
                        appState.hasCompletedOnboarding = true
                    } label: {
                        Text("Show my NammaCircle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding()
            }
            .background(Color(.secondarySystemBackground))
        }
    }

    private func tagBinding(_ tag: String) -> Binding<Bool> {
        Binding {
            appState.onboarding.lifestyleTags.contains(tag)
        } set: { isOn in
            if isOn {
                if !appState.onboarding.lifestyleTags.contains(tag) {
                    appState.onboarding.lifestyleTags.append(tag)
                }
            } else {
                appState.onboarding.lifestyleTags.removeAll { $0 == tag }
            }
        }
    }

    private func addCustomTag() {
        let tag = customTag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !tag.isEmpty, !appState.onboarding.lifestyleTags.contains(tag) else { return }
        appState.onboarding.lifestyleTags.append(tag)
        customTag = ""
    }
}
