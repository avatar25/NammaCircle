import Foundation
import CoreLocation

struct SupabaseLocalityRow: Decodable {
    let id: UUID
    let name: String
    let slug: String
    let city: String?
    let description: String?
}

struct SupabaseLocalityScoreRow: Decodable {
    let localityId: UUID
    let rentScore: Int?
    let commuteScore: Int?
    let foodScore: Int?
    let socialLifeScore: Int?
    let quietScore: Int?
    let safetyConfidenceScore: Int?
    let newcomerFriendlinessScore: Int?
    let kannadaDependencyScore: Int?
    let brokerRiskScore: Int?
    let waterReliabilityScore: Int?
    let lastVerifiedAt: Date?
    let confidenceLevel: String?
}

struct SupabaseKannadaLessonRow: Decodable {
    let id: UUID
    let title: String
    let situation: String
    let difficulty: String?
    let sortOrder: Int?
    let isPublished: Bool?
}

struct SupabaseKannadaPhraseRow: Decodable {
    let id: UUID
    let lessonId: UUID
    let kannadaText: String
    let transliteration: String
    let englishMeaning: String
    let usageNote: String?
    let sortOrder: Int?
}

struct SupabaseForumPostRow: Decodable {
    let id: UUID
    let userId: UUID?
    let localityId: UUID?
    let title: String
    let body: String
    let category: String
    let urgency: String?
    let moderationStatus: String?
    let createdAt: Date?
}

struct SupabaseForumCommentRow: Decodable {
    let id: UUID
    let postId: UUID
    let userId: UUID?
    let body: String
    let moderationStatus: String?
    let createdAt: Date?
}

struct SupabaseQuestRow: Decodable {
    let id: UUID
    let title: String
    let description: String
    let questType: String
    let points: Int
    let isActive: Bool
}

struct SupabaseMentorRow: Decodable {
    let id: UUID
    let userId: UUID?
    let displayName: String
    let bio: String?
    let specialties: [String]?
    let hourlyRateInr: Int?
    let isVerified: Bool
}

struct SupabaseRentCheckRequest: Encodable {
    let localityId: UUID
    let bhk: String
    let monthlyRent: Int
    let deposit: Int
    let furnishing: String
    let maintenance: Int
}

struct SupabaseRentCheckResponse: Decodable {
    let label: String
    let score: Int
    let explanation: String
    let recommendedNegotiationPoints: [String]
    let depositWarning: String?
}

struct SupabaseForumPostInsert: Encodable {
    let userId: UUID
    let title: String
    let body: String
    let category: String
    let urgency: String
    let moderationStatus: String
}

enum KnownLocalityCoordinates {
    static func coordinate(for slug: String) -> CLLocationCoordinate2D {
        switch slug {
        case "hsr-layout": return CLLocationCoordinate2D(latitude: 12.9121, longitude: 77.6476)
        case "bellandur": return CLLocationCoordinate2D(latitude: 12.9352, longitude: 77.6762)
        case "whitefield": return CLLocationCoordinate2D(latitude: 12.9698, longitude: 77.7500)
        case "marathahalli": return CLLocationCoordinate2D(latitude: 12.9569, longitude: 77.6974)
        case "koramangala": return CLLocationCoordinate2D(latitude: 12.9352, longitude: 77.6245)
        case "indiranagar": return CLLocationCoordinate2D(latitude: 12.9784, longitude: 77.6412)
        case "btm-layout": return CLLocationCoordinate2D(latitude: 12.9166, longitude: 77.6101)
        case "jp-nagar": return CLLocationCoordinate2D(latitude: 12.9063, longitude: 77.5857)
        case "electronic-city": return CLLocationCoordinate2D(latitude: 12.8452, longitude: 77.6603)
        case "hebbal": return CLLocationCoordinate2D(latitude: 13.0358, longitude: 77.5913)
        default: return CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946)
        }
    }
}
