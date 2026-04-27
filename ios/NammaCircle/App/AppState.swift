import Foundation

final class AppState: ObservableObject {
    @Published var hasCompletedOnboarding = false
    @Published var onboarding = OnboardingPreferences()
    @Published var currentStreak = 0
}
