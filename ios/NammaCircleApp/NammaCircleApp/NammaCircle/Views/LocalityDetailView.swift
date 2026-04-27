import SwiftUI

struct LocalityDetailView: View {
    let locality: Locality

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                SectionCard(tone: .hero) {
                    VStack(alignment: .leading, spacing: 14) {
                        BengaluruIllustrationView(scene: .locality)
                            .frame(height: 170)

                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text(locality.name)
                                    .font(.largeTitle.bold())
                                    .foregroundStyle(NammaColor.ink)
                                Text(locality.city)
                                    .foregroundStyle(NammaColor.muted)
                            }
                            Spacer()
                            VStack(spacing: 4) {
                                Text("\(locality.recommendation.score)")
                                    .font(.title.bold())
                                    .foregroundStyle(FitColor.color(for: locality.recommendation.fit))
                                Text("score")
                                    .font(.caption)
                                    .foregroundStyle(NammaColor.muted)
                            }
                        }
                        Text(locality.description)
                            .font(.subheadline)
                            .foregroundStyle(NammaColor.muted)
                        NammaBadge(
                            text: locality.recommendation.fit.title,
                            systemImage: "checkmark.seal.fill",
                            tone: FitColor.color(for: locality.recommendation.fit)
                        )
                    }
                }

                SectionCard(tone: .leaf) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Scores")
                            .font(.headline)
                            .foregroundStyle(NammaColor.ink)
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
                        Text("Risks")
                            .font(.headline)
                            .foregroundStyle(NammaColor.ink)
                        ForEach(locality.recommendation.risks, id: \.self) { risk in
                            Label(risk, systemImage: "exclamationmark.triangle")
                                .font(.subheadline)
                                .foregroundStyle(NammaColor.terracotta)
                        }
                    }
                }

                SectionCard(tone: .sky) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rent estimate")
                            .font(.headline)
                            .foregroundStyle(NammaColor.ink)
                        Text("Placeholder estimate from seeded MVP rent baselines. Run a rent check before making decisions.")
                            .font(.subheadline)
                            .foregroundStyle(NammaColor.muted)
                    }
                }

                SectionCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent signals")
                            .font(.headline)
                            .foregroundStyle(NammaColor.ink)
                        Text("Mock signal: commute and rent data are directional until verified by admins.")
                            .font(.subheadline)
                            .foregroundStyle(NammaColor.muted)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
        }
        .background(NammaBackground().ignoresSafeArea())
        .navigationTitle(locality.name)
        .navigationBarTitleDisplayMode(.inline)
        .tint(NammaColor.deepGreen)
    }
}
