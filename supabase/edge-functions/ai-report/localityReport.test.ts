import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { generateLocalityReport } from "./localityReport.ts";
import type {
  AreaRecommendationInput,
  RecommendationCandidate
} from "../area-recommendations/areaRecommendations.ts";

Deno.test("generates a deterministic locality report from recommendation candidates", () => {
  const report = generateLocalityReport({
    recommendation_input: baseInput(),
    candidates: [
      candidate("hsr-layout", "HSR Layout", 8, 8, 8, 8, 6, 3, 3, "high"),
      candidate("btm-layout", "BTM Layout", 9, 6, 7, 6, 7, 4, 4, "medium"),
      candidate("bellandur", "Bellandur", 5, 8, 7, 7, 4, 6, 4, "medium"),
      candidate("whitefield", "Whitefield", 6, 5, 7, 6, 7, 5, 5, "medium"),
      candidate("indiranagar", "Indiranagar", 3, 6, 9, 9, 4, 6, 3, "high"),
      candidate("hebbal", "Hebbal", 6, 4, 6, 5, 8, 5, 5, "low")
    ]
  });

  assertEquals(report.top_5_areas.length, 5);
  assertEquals(report.source_of_truth, "deterministic_area_recommendations");
  assertEquals(report.explanation_mode, "template");
  assertEquals(report.top_5_areas[0].rent_note.includes("rent_score"), true);
  assertEquals(report.top_5_areas[0].commute_note.includes("commute_score"), true);
  assertEquals(report.confidence_level, "medium");
});

Deno.test("supports swapping the explanation generator without changing scoring", () => {
  const report = generateLocalityReport({
    recommendation_input: baseInput(),
    candidates: [
      candidate("hsr-layout", "HSR Layout", 8, 8, 8, 8, 6, 3, 3, "high")
    ],
    explanation_generator: {
      summary: () => "Custom explanation.",
      rentNote: (area) => `${area.name}: custom rent note.`,
      commuteNote: (area) => `${area.name}: custom commute note.`,
      survivalTips: () => ["Custom tip."]
    }
  });

  assertEquals(report.summary, "Custom explanation.");
  assertEquals(report.rent_notes[0], "HSR Layout: custom rent note.");
  assertEquals(report.survival_tips, ["Custom tip."]);
});

function baseInput(): AreaRecommendationInput {
  return {
    work_location_text: "Bellandur",
    budget_min: 18000,
    budget_max: 35000,
    commute_tolerance_minutes: 40,
    lifestyle_tags: ["food", "budget"],
    preferences: {
      wants_quiet: false,
      wants_social_life: true,
      wants_low_cost: true,
      wants_food_options: true,
      wants_low_kannada_dependency: true,
      wants_low_broker_risk: true
    }
  };
}

function candidate(
  slug: string,
  name: string,
  rent: number,
  commute: number,
  food: number,
  social: number,
  quiet: number,
  brokerRisk: number,
  kannadaDependency: number,
  confidence: "low" | "medium" | "high"
): RecommendationCandidate {
  return {
    id: `${slug}-id`,
    locality_id: `${slug}-id`,
    name,
    slug,
    city: "Bengaluru",
    description: null,
    rent_score: rent,
    commute_score: commute,
    food_score: food,
    social_life_score: social,
    quiet_score: quiet,
    safety_confidence_score: 6,
    newcomer_friendliness_score: 7,
    kannada_dependency_score: kannadaDependency,
    broker_risk_score: brokerRisk,
    water_reliability_score: 6,
    last_verified_at: "2026-04-26T00:00:00Z",
    confidence_level: confidence
  };
}
