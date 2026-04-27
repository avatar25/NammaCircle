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
    private let provider: SupabaseClientProvider

    init(provider: SupabaseClientProvider = .shared) {
        self.provider = provider
    }

    func fetchLocalities() async throws -> [Locality] {
        let localities: [SupabaseLocalityRow] = try await provider.fetchTable(
            "localities",
            queryItems: [
                URLQueryItem(name: "select", value: "id,name,slug,city,description"),
                URLQueryItem(name: "order", value: "name.asc")
            ]
        )
        let scores: [SupabaseLocalityScoreRow] = try await provider.fetchTable(
            "locality_scores",
            queryItems: [
                URLQueryItem(name: "select", value: "locality_id,rent_score,commute_score,food_score,social_life_score,quiet_score,safety_confidence_score,newcomer_friendliness_score,kannada_dependency_score,broker_risk_score,water_reliability_score,last_verified_at,confidence_level")
            ]
        )
        let scoresByLocality = Dictionary(uniqueKeysWithValues: scores.map { ($0.localityId, $0) })

        return localities.compactMap { locality in
            guard let score = scoresByLocality[locality.id] else { return nil }
            return mapLocality(locality, score: score)
        }
    }

    func recommendedLocalities(for preferences: OnboardingPreferences) async throws -> [Locality] {
        try await fetchLocalities().sorted { first, second in
            scoreFor(preferences: preferences, locality: first) > scoreFor(preferences: preferences, locality: second)
        }
    }

    private func mapLocality(_ row: SupabaseLocalityRow, score: SupabaseLocalityScoreRow) -> Locality {
        let scores = LocalityScores(
            rentScore: score.rentScore ?? 0,
            commuteScore: score.commuteScore ?? 0,
            foodScore: score.foodScore ?? 0,
            socialLifeScore: score.socialLifeScore ?? 0,
            quietScore: score.quietScore ?? 0,
            safetyConfidenceScore: score.safetyConfidenceScore ?? 0,
            newcomerFriendlinessScore: score.newcomerFriendlinessScore ?? 0,
            kannadaDependencyScore: score.kannadaDependencyScore ?? 0,
            brokerRiskScore: score.brokerRiskScore ?? 0,
            waterReliabilityScore: score.waterReliabilityScore ?? 0,
            confidenceLevel: score.confidenceLevel ?? "low",
            lastVerifiedAt: score.lastVerifiedAt
        )
        let recommendationScore = baseRecommendationScore(scores)
        let fit = fitLabel(for: recommendationScore)

        return Locality(
            id: row.id,
            name: row.name,
            slug: row.slug,
            city: row.city ?? "Bengaluru",
            description: row.description ?? "Seeded NammaCircle locality.",
            coordinate: KnownLocalityCoordinates.coordinate(for: row.slug),
            scores: scores,
            recommendation: LocalityRecommendation(
                fit: fit,
                score: recommendationScore,
                topReasons: topReasons(for: scores, name: row.name),
                risks: risks(for: scores)
            )
        )
    }

    private func scoreFor(preferences: OnboardingPreferences, locality: Locality) -> Int {
        let scores = locality.scores
        var weighted = Double(scores.rentScore * 22 + scores.commuteScore * 22 + scores.newcomerFriendlinessScore * 14)
        weighted += Double(scores.foodScore * (preferences.wantsFoodOptions ? 14 : 9))
        weighted += Double((preferences.wantsQuiet ? scores.quietScore : scores.socialLifeScore) * 10)
        weighted += Double((11 - scores.brokerRiskScore) * (preferences.wantsLowBrokerRisk ? 12 : 8))
        weighted += Double((11 - scores.kannadaDependencyScore) * (preferences.wantsLowKannadaDependency ? 10 : 3))
        let divisor = preferences.wantsFoodOptions ? 94.0 : 89.0
        return min(100, max(0, Int((weighted / divisor) * 10)))
    }

    private func baseRecommendationScore(_ scores: LocalityScores) -> Int {
        let total = scores.rentScore + scores.commuteScore + scores.foodScore + scores.newcomerFriendlinessScore + (11 - scores.brokerRiskScore)
        return min(100, max(0, total * 2))
    }

    private func fitLabel(for score: Int) -> FitLabel {
        if score >= 75 { return .green }
        if score >= 55 { return .yellow }
        return .red
    }

    private func topReasons(for scores: LocalityScores, name: String) -> [String] {
        var reasons: [String] = []

        if scores.commuteScore >= 7 { reasons.append("\(name) scores well for commute.") }
        if scores.foodScore >= 7 { reasons.append("\(name) has strong food and daily-life access.") }
        if scores.rentScore >= 7 { reasons.append("\(name) looks relatively budget-friendly in MVP data.") }
        if scores.newcomerFriendlinessScore >= 7 { reasons.append("\(name) is newcomer-friendly in current signals.") }

        return reasons.isEmpty ? ["Balanced but still needs verification."] : Array(reasons.prefix(3))
    }

    private func risks(for scores: LocalityScores) -> [String] {
        var risks: [String] = []

        if scores.rentScore <= 4 { risks.append("Rent may stretch the selected budget.") }
        if scores.brokerRiskScore >= 7 { risks.append("Broker risk is elevated. Verify fees carefully.") }
        if scores.confidenceLevel == "low" { risks.append("Confidence is low; treat this as directional.") }

        return risks.isEmpty ? ["Verify commute and rent before deciding."] : risks
    }
}
