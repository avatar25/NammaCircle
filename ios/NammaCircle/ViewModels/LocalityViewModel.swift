import Foundation

@MainActor
final class LocalityViewModel: ObservableObject {
    @Published var localities: [Locality] = []
    @Published var recommendations: [Locality] = []
    @Published var selectedLocality: Locality?
    @Published var errorMessage: String?

    private let service: LocalityServicing

    init(service: LocalityServicing = MockLocalityService()) {
        self.service = service
    }

    func load(preferences: OnboardingPreferences = OnboardingPreferences()) {
        Task {
            do {
                localities = try await service.fetchLocalities()
                recommendations = try await service.recommendedLocalities(for: preferences)
                selectedLocality = recommendations.first ?? localities.first
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
