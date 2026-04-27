import Foundation
import Combine

@MainActor
final class LocalityViewModel: ObservableObject {
    @Published var localities: [Locality] = []
    @Published var recommendations: [Locality] = []
    @Published var selectedLocality: Locality?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: LocalityServicing

    init(service: LocalityServicing = ServiceFactory.shared.localityService) {
        self.service = service
    }

    func load(preferences: OnboardingPreferences = OnboardingPreferences()) {
        Task {
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }

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
