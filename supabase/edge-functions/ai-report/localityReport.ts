import {
  recommendAreas,
  type AreaRecommendation,
  type AreaRecommendationInput,
  type ConfidenceLevel,
  type FitLabel,
  type RecommendationCandidate
} from "../area-recommendations/areaRecommendations.ts";

export type LocalityReportInput = {
  recommendation_input: AreaRecommendationInput;
  candidates: RecommendationCandidate[];
  recommendations?: AreaRecommendation[];
  explanation_generator?: LocalityReportExplanationGenerator;
};

export type LocalityReportArea = {
  locality_id: string;
  name: string;
  slug: string;
  fit: FitLabel;
  score: number;
  reasons: string[];
  risks: string[];
  rent_note: string;
  commute_note: string;
  confidence_level: ConfidenceLevel;
  last_verified_at: string | null;
};

export type LocalityReport = {
  summary: string;
  top_5_areas: LocalityReportArea[];
  fit_counts: Record<FitLabel, number>;
  risks: string[];
  rent_notes: string[];
  commute_notes: string[];
  survival_tips: string[];
  confidence_level: ConfidenceLevel;
  explanation_mode: "template";
  source_of_truth: "deterministic_area_recommendations";
};

export type ExplanationContext = {
  recommendationInput: AreaRecommendationInput;
  recommendations: AreaRecommendation[];
  candidatesById: Map<string, RecommendationCandidate>;
};

export interface LocalityReportExplanationGenerator {
  summary(context: ExplanationContext): string;
  rentNote(area: AreaRecommendation, candidate?: RecommendationCandidate): string;
  commuteNote(area: AreaRecommendation, candidate?: RecommendationCandidate): string;
  survivalTips(context: ExplanationContext): string[];
}

export const templateExplanationGenerator: LocalityReportExplanationGenerator = {
  summary(context) {
    const top = context.recommendations[0];
    if (!top) {
      return "No locality recommendations are available from the current deterministic data.";
    }

    return `${top.name} is the strongest deterministic match for the current work location, budget, and lifestyle inputs. Review the fit, risks, and confidence before deciding.`;
  },
  rentNote(area, candidate) {
    if (!candidate) {
      return `${area.name}: rent guidance is limited because the score row was not found.`;
    }

    return `${area.name}: rent fit uses stored rent_score ${candidate.rent_score}/10 and does not estimate a live market price.`;
  },
  commuteNote(area, candidate) {
    if (!candidate) {
      return `${area.name}: commute guidance is limited because the score row was not found.`;
    }

    return `${area.name}: commute fit uses stored commute_score ${candidate.commute_score}/10 for the MVP recommendation.`;
  },
  survivalTips(context) {
    const tips = [
      "Verify actual commute at the time you would travel.",
      "Run a rent fairness check before paying a token or deposit.",
      "Ask for written deposit refund terms before signing."
    ];

    if (context.recommendationInput.preferences?.wants_low_kannada_dependency) {
      tips.push("Save a few Kannada phrases for autos, shops, and building staff.");
    }

    if (context.recommendationInput.preferences?.wants_low_broker_risk) {
      tips.push("Prefer listings with clear owner/broker terms and avoid cash-only pressure.");
    }

    return tips;
  }
};

export function generateLocalityReport(input: LocalityReportInput): LocalityReport {
  const recommendations =
    input.recommendations ?? recommendAreas(input.recommendation_input, input.candidates, 5);
  const generator = input.explanation_generator ?? templateExplanationGenerator;
  const candidatesById = new Map(input.candidates.map((candidate) => [candidate.locality_id, candidate]));
  const context: ExplanationContext = {
    recommendationInput: input.recommendation_input,
    recommendations,
    candidatesById
  };
  const topAreas = recommendations.slice(0, 5).map((area) => {
    const candidate = candidatesById.get(area.locality_id);
    return {
      locality_id: area.locality_id,
      name: area.name,
      slug: area.slug,
      fit: area.fit,
      score: area.score,
      reasons: area.top_reasons,
      risks: area.risks,
      rent_note: generator.rentNote(area, candidate),
      commute_note: generator.commuteNote(area, candidate),
      confidence_level: area.confidence_level,
      last_verified_at: area.last_verified_at
    };
  });

  return {
    summary: generator.summary(context),
    top_5_areas: topAreas,
    fit_counts: countFits(topAreas),
    risks: unique(topAreas.flatMap((area) => area.risks)),
    rent_notes: topAreas.map((area) => area.rent_note),
    commute_notes: topAreas.map((area) => area.commute_note),
    survival_tips: generator.survivalTips(context),
    confidence_level: aggregateConfidence(topAreas.map((area) => area.confidence_level)),
    explanation_mode: "template",
    source_of_truth: "deterministic_area_recommendations"
  };
}

function countFits(areas: LocalityReportArea[]): Record<FitLabel, number> {
  return areas.reduce(
    (counts, area) => ({
      ...counts,
      [area.fit]: counts[area.fit] + 1
    }),
    { green: 0, yellow: 0, red: 0 }
  );
}

function aggregateConfidence(levels: ConfidenceLevel[]): ConfidenceLevel {
  if (levels.includes("low")) {
    return "low";
  }

  if (levels.includes("medium")) {
    return "medium";
  }

  return levels.length > 0 ? "high" : "low";
}

function unique(values: string[]): string[] {
  return [...new Set(values)];
}
