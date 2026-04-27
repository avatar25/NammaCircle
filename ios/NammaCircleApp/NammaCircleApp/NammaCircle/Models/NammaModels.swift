import Foundation
import CoreLocation

struct OnboardingPreferences {
    var workLocationText = ""
    var budgetMin = 20_000
    var budgetMax = 45_000
    var commuteToleranceMinutes = 45
    var lifestyleTags: [String] = ["cafes", "metro"]
    var wantsQuiet = false
    var wantsSocialLife = true
    var wantsLowCost = true
    var wantsFoodOptions = true
    var wantsLowKannadaDependency = true
    var wantsLowBrokerRisk = true
}

enum FitLabel: String, Codable {
    case green
    case yellow
    case red

    var title: String {
        switch self {
        case .green: return "Strong fit"
        case .yellow: return "Possible fit"
        case .red: return "Weak fit"
        }
    }
}

struct Locality: Identifiable, Hashable {
    let id: UUID
    let name: String
    let slug: String
    let city: String
    let description: String
    let coordinate: CLLocationCoordinate2D
    let scores: LocalityScores
    let recommendation: LocalityRecommendation

    static func == (lhs: Locality, rhs: Locality) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct LocalityScores {
    let rentScore: Int
    let commuteScore: Int
    let foodScore: Int
    let socialLifeScore: Int
    let quietScore: Int
    let safetyConfidenceScore: Int
    let newcomerFriendlinessScore: Int
    let kannadaDependencyScore: Int
    let brokerRiskScore: Int
    let waterReliabilityScore: Int
    let confidenceLevel: String
    let lastVerifiedAt: Date?
}

struct LocalityRecommendation {
    let fit: FitLabel
    let score: Int
    let topReasons: [String]
    let risks: [String]
}

struct RentCheckInput {
    var locality: Locality?
    var bhk = "1BHK"
    var monthlyRent = ""
    var deposit = ""
    var furnishing = "semi_furnished"
    var maintenance = ""
}

struct RentCheckResult {
    let label: String
    let score: Int
    let explanation: String
    let negotiationPoints: [String]
    let depositWarning: String?
}

struct UserProgress {
    let currentStreak: Int
    let longestStreak: Int
    let totalPoints: Int
    let currentRank: RankName
    let nextRank: RankName?
    let pointsToNextRank: Int?
}

enum RankName: String, CaseIterable {
    case newcomer = "Newcomer"
    case settler = "Settler"
    case streetSmart = "Street Smart"
    case areaScout = "Area Scout"
    case localGuide = "Local Guide"
    case citySage = "City Sage"

    static func rank(for points: Int) -> RankName {
        switch points {
        case 15_000...: return .citySage
        case 5_000...: return .localGuide
        case 1_500...: return .areaScout
        case 500...: return .streetSmart
        case 100...: return .settler
        default: return .newcomer
        }
    }

    static func nextRank(after points: Int) -> (rank: RankName, threshold: Int)? {
        let thresholds: [(RankName, Int)] = [
            (.settler, 100),
            (.streetSmart, 500),
            (.areaScout, 1_500),
            (.localGuide, 5_000),
            (.citySage, 15_000)
        ]

        return thresholds.first { points < $0.1 }
    }
}

struct KannadaLesson: Identifiable {
    let id: UUID
    let title: String
    let situation: String
    let phrase: KannadaPhrase
}

struct KannadaPhrase: Identifiable {
    let id: UUID
    let kannadaText: String
    let transliteration: String
    let englishMeaning: String
    let usageNote: String
}

struct ForumPost: Identifiable {
    let id: UUID
    let title: String
    let body: String
    let category: String
    let urgency: String
    let localityName: String?
    let comments: [ForumComment]
}

struct ForumComment: Identifiable {
    let id: UUID
    let body: String
    let authorName: String
}

struct Quest: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let questType: String
    let points: Int
    let isActive: Bool
}

struct Mentor: Identifiable {
    let id: UUID
    let displayName: String
    let bio: String
    let specialties: [String]
    let hourlyRateInr: Int?
    let isVerified: Bool
}
