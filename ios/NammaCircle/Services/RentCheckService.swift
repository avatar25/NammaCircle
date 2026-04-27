import Foundation

protocol RentCheckServicing {
    func checkRent(input: RentCheckInput) async throws -> RentCheckResult
}

final class MockRentCheckService: RentCheckServicing {
    func checkRent(input: RentCheckInput) async throws -> RentCheckResult {
        let rent = Int(input.monthlyRent) ?? 0
        let deposit = Int(input.deposit) ?? 0
        let median = mockMedianRent(for: input.locality, bhk: input.bhk)
        let ratio = median > 0 ? Double(rent) / Double(median) : 1
        let label: String
        let score: Int

        if ratio <= 0.9 {
            label = "good_deal"
            score = 90
        } else if ratio <= 1.1 {
            label = "fair"
            score = 72
        } else if ratio <= 1.3 {
            label = "expensive"
            score = 48
        } else {
            label = "suspicious_or_overpriced"
            score = 25
        }

        let warning: String?
        if rent > 0 && deposit > rent * 10 {
            warning = "Deposit is above 10 months of rent. Ask for written refund terms."
        } else if rent > 0 && deposit > rent * 6 {
            warning = "Deposit is above 6 months of rent. Negotiate this down."
        } else {
            warning = nil
        }

        return RentCheckResult(
            label: label,
            score: score,
            explanation: "Compared with a mock median of INR \(median) for \(input.bhk) in \(input.locality?.name ?? "this area").",
            negotiationPoints: [
                "Clarify maintenance and painting charges.",
                "Ask whether deposit refund terms are written into the agreement.",
                "Compare with at least two similar homes before paying a token."
            ],
            depositWarning: warning
        )
    }

    private func mockMedianRent(for locality: Locality?, bhk: String) -> Int {
        let base = locality?.scores.rentScore ?? 6
        let bhkMultiplier = bhk == "2BHK" ? 1.65 : 1.0
        return Int(Double(52_000 - (base * 3_500)) * bhkMultiplier)
    }
}

final class SupabaseRentCheckService: RentCheckServicing {
    private let provider: SupabaseClientProvider
    private let fallback = MockRentCheckService()

    init(provider: SupabaseClientProvider = .shared) {
        self.provider = provider
    }

    func checkRent(input: RentCheckInput) async throws -> RentCheckResult {
        guard let locality = input.locality,
              let rent = Int(input.monthlyRent),
              let deposit = Int(input.deposit) else {
            return try await fallback.checkRent(input: input)
        }

        let request = SupabaseRentCheckRequest(
            localityId: locality.id,
            bhk: input.bhk,
            monthlyRent: rent,
            deposit: deposit,
            furnishing: input.furnishing,
            maintenance: Int(input.maintenance) ?? 0
        )

        do {
            let response: SupabaseRentCheckResponse = try await provider.invokeFunction("rent-check", body: request)
            return RentCheckResult(
                label: response.label,
                score: response.score,
                explanation: response.explanation,
                negotiationPoints: response.recommendedNegotiationPoints,
                depositWarning: response.depositWarning
            )
        } catch {
            return try await fallback.checkRent(input: input)
        }
    }
}
