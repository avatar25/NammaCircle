import Foundation
import CoreLocation

enum MockData {
    static let localities: [Locality] = [
        locality("HSR Layout", slug: "hsr-layout", lat: 12.9121, lon: 77.6476, fit: .green, score: 84, rent: 6, commute: 7, food: 8, social: 7, quiet: 6, broker: 5, kannada: 4),
        locality("Indiranagar", slug: "indiranagar", lat: 12.9784, lon: 77.6412, fit: .yellow, score: 71, rent: 3, commute: 8, food: 10, social: 9, quiet: 5, broker: 6, kannada: 3),
        locality("Whitefield", slug: "whitefield", lat: 12.9698, lon: 77.7500, fit: .yellow, score: 68, rent: 7, commute: 6, food: 7, social: 6, quiet: 6, broker: 5, kannada: 4),
        locality("BTM Layout", slug: "btm-layout", lat: 12.9166, lon: 77.6101, fit: .green, score: 79, rent: 8, commute: 6, food: 7, social: 6, quiet: 5, broker: 6, kannada: 5),
        locality("Bellandur", slug: "bellandur", lat: 12.9352, lon: 77.6762, fit: .red, score: 52, rent: 5, commute: 8, food: 6, social: 5, quiet: 4, broker: 7, kannada: 4)
    ]

    static let lesson = KannadaLesson(
        id: UUID(),
        title: "Auto Basics",
        situation: "Taking an auto or cab",
        phrase: KannadaPhrase(
            id: UUID(),
            kannadaText: "ಎಷ್ಟು ಆಗುತ್ತದೆ?",
            transliteration: "Eshtu aguttade?",
            englishMeaning: "How much will it cost?",
            usageNote: "Useful before starting an auto ride."
        )
    )

    static let posts = [
        ForumPost(
            id: UUID(),
            title: "Is HSR good for a first month?",
            body: "I work near Bellandur and want cafes, gyms, and manageable commute.",
            category: "locality",
            urgency: "normal",
            localityName: "HSR Layout",
            comments: [
                ForumComment(id: UUID(), body: "HSR is a practical first landing area if budget works.", authorName: "Asha")
            ]
        ),
        ForumPost(
            id: UUID(),
            title: "What deposit is normal in Whitefield?",
            body: "Seeing 5 to 10 months depending on the building.",
            category: "rent",
            urgency: "normal",
            localityName: "Whitefield",
            comments: []
        )
    ]

    static let quests = [
        Quest(id: UUID(), title: "Learn one Kannada phrase", description: "Complete today’s phrase and try it once.", questType: "lesson", points: 10, isActive: true),
        Quest(id: UUID(), title: "Metro confidence run", description: "Take one short metro trip and note your route.", questType: "city_exploration", points: 25, isActive: true)
    ]

    static let mentors = [
        Mentor(id: UUID(), displayName: "Asha Rao", bio: "Helps newcomers compare south-east Bengaluru localities.", specialties: ["Rent", "HSR", "Bellandur"], hourlyRateInr: nil, isVerified: true),
        Mentor(id: UUID(), displayName: "Kiran M", bio: "Kannada basics and practical city navigation.", specialties: ["Kannada", "Transport"], hourlyRateInr: nil, isVerified: true)
    ]

    private static func locality(
        _ name: String,
        slug: String,
        lat: Double,
        lon: Double,
        fit: FitLabel,
        score: Int,
        rent: Int,
        commute: Int,
        food: Int,
        social: Int,
        quiet: Int,
        broker: Int,
        kannada: Int
    ) -> Locality {
        Locality(
            id: UUID(),
            name: name,
            slug: slug,
            city: "Bengaluru",
            description: "\(name) is included as seeded MVP locality data for NammaCircle.",
            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            scores: LocalityScores(
                rentScore: rent,
                commuteScore: commute,
                foodScore: food,
                socialLifeScore: social,
                quietScore: quiet,
                safetyConfidenceScore: 6,
                newcomerFriendlinessScore: 7,
                kannadaDependencyScore: kannada,
                brokerRiskScore: broker,
                waterReliabilityScore: 6,
                confidenceLevel: score >= 75 ? "high" : "medium",
                lastVerifiedAt: Date()
            ),
            recommendation: LocalityRecommendation(
                fit: fit,
                score: score,
                topReasons: ["Good MVP score for commute and newcomer fit.", "Useful food and daily-life access."],
                risks: broker >= 7 ? ["Broker risk is elevated. Verify fees and deposits carefully."] : ["Verify rent and commute before deciding."]
            )
        )
    }
}
