import Foundation
import Combine

final class AppState: ObservableObject {
    @Published var hasCompletedOnboarding = true
    @Published var onboarding = OnboardingPreferences()
    @Published var currentStreak = 0
}
