import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState
    @State private var customTag = ""

    private let suggestedTags = ["cafes", "metro", "quiet", "nightlife", "budget", "english friendly"]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    SectionCard(tone: .hero) {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 12) {
                                NammaBrandMark()
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("NammaCircle")
                                        .font(.title2.bold())
                                        .foregroundStyle(NammaColor.deepGreen)
                                    Text("Settle into Bengaluru with better local context.")
                                        .font(.caption)
                                        .foregroundStyle(NammaColor.muted)
                                }
                            }

                            Text("Find your Bangalore starting point")
                                .font(.largeTitle.bold())
                                .foregroundStyle(NammaColor.ink)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("Tell us what matters for your first home base. The MVP uses mock data until Supabase mode is configured.")
                                .font(.subheadline)
                                .foregroundStyle(NammaColor.muted)

                            BengaluruIllustrationView(scene: .home)
                                .frame(height: 168)
                        }
                    }

                    SectionCard(tone: .sky) {
                        VStack(alignment: .leading, spacing: 14) {
                            Label("Work and budget", systemImage: "building.2.fill")
                                .font(.headline)
                                .foregroundStyle(NammaColor.ink)
                            TextField("Office location or landmark", text: $appState.onboarding.workLocationText)
                                .textFieldStyle(.roundedBorder)

                            Stepper("Budget min: INR \(appState.onboarding.budgetMin)", value: $appState.onboarding.budgetMin, in: 5_000...150_000, step: 5_000)
                            Stepper("Budget max: INR \(appState.onboarding.budgetMax)", value: $appState.onboarding.budgetMax, in: 10_000...250_000, step: 5_000)
                            Stepper("Commute tolerance: \(appState.onboarding.commuteToleranceMinutes) min", value: $appState.onboarding.commuteToleranceMinutes, in: 10...120, step: 5)
                        }
                    }

                    SectionCard(tone: .peach) {
                        VStack(alignment: .leading, spacing: 14) {
                            Label("Lifestyle", systemImage: "leaf.fill")
                                .font(.headline)
                                .foregroundStyle(NammaColor.ink)
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
                                .buttonStyle(NammaSecondaryButtonStyle())
                            }
                        }
                    }

                    SectionCard(tone: .leaf) {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Preferences", systemImage: "slider.horizontal.3")
                                .font(.headline)
                                .foregroundStyle(NammaColor.ink)
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
                    .buttonStyle(NammaPrimaryButtonStyle())
                    .controlSize(.large)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
            }
            .background(NammaBackground().ignoresSafeArea())
            .tint(NammaColor.deepGreen)
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
