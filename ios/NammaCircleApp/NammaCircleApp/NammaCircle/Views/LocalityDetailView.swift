import SwiftUI

struct LocalityDetailView: View {
    let locality: Locality

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SectionCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(locality.name)
                                    .font(.largeTitle.bold())
                                Text(locality.city)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(locality.recommendation.score)")
                                .font(.title.bold())
                                .foregroundStyle(FitColor.color(for: locality.recommendation.fit))
                        }
                        Text(locality.description)
                            .foregroundStyle(.secondary)
                    }
                }

                SectionCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Scores").font(.headline)
                        ScorePill(title: "Rent", value: locality.scores.rentScore)
                        ScorePill(title: "Commute", value: locality.scores.commuteScore)
                        ScorePill(title: "Food", value: locality.scores.foodScore)
                        ScorePill(title: "Social life", value: locality.scores.socialLifeScore)
                        ScorePill(title: "Quiet", value: locality.scores.quietScore)
                        ScorePill(title: "Newcomer friendliness", value: locality.scores.newcomerFriendlinessScore)
                    }
                }

                SectionCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Risks").font(.headline)
                        ForEach(locality.recommendation.risks, id: \.self) { risk in
                            Label(risk, systemImage: "exclamationmark.triangle")
                                .font(.subheadline)
                        }
                    }
                }

                SectionCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rent estimate").font(.headline)
                        Text("Placeholder estimate from seeded MVP rent baselines. Run a rent check before making decisions.")
                            .foregroundStyle(.secondary)
                    }
                }

                SectionCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent signals").font(.headline)
                        Text("Mock signal: commute and rent data are directional until verified by admins.")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .background(Color(.secondarySystemBackground))
        .navigationTitle(locality.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
