import Foundation
import CoreLocation

protocol LocalityServicing {
    func fetchLocalities() async throws -> [Locality]
    func recommendedLocalities(for preferences: OnboardingPreferences) async throws -> [Locality]
}

final class MockLocalityService: LocalityServicing {
    func fetchLocalities() async throws -> [Locality] {
        MockData.localities
    }

    func recommendedLocalities(for preferences: OnboardingPreferences) async throws -> [Locality] {
        MockData.localities.sorted { first, second in
            first.recommendation.score > second.recommendation.score
        }
    }
}

final class SupabaseLocalityService: LocalityServicing {
    func fetchLocalities() async throws -> [Locality] {
        // TODO: fetch localities and locality_scores from Supabase.
        throw ServicePlaceholderError.notImplemented
    }

    func recommendedLocalities(for preferences: OnboardingPreferences) async throws -> [Locality] {
        // TODO: call area-recommendations edge function once auth and env config exist.
        throw ServicePlaceholderError.notImplemented
    }
}
