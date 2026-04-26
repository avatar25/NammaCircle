import {
  assertEquals,
  assertThrows
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import {
  invertRiskScore,
  recommendAreas,
  scoreCandidate,
  type AreaRecommendationInput,
  type RecommendationCandidate
} from "./areaRecommendations.ts";

Deno.test("inverts risk-style scores", () => {
  assertEquals(invertRiskScore(1), 10);
  assertEquals(invertRiskScore(10), 1);
});

Deno.test("returns top 5 localities sorted by deterministic score", () => {
  const recommendations = recommendAreas(baseInput(), [
    candidate("a", "A", 9, 9, 8, 8, 6, 2, 2, "high"),
    candidate("b", "B", 2, 3, 4, 4, 8, 8, 8, "medium"),
    candidate("c", "C", 7, 7, 7, 7, 7, 4, 4, "medium"),
    candidate("d", "D", 6, 6, 6, 6, 6, 5, 5, "medium"),
    candidate("e", "E", 5, 5, 5, 5, 5, 6, 6, "low"),
    candidate("f", "F", 4, 4, 4, 4, 4, 7, 7, "low")
  ]);

  assertEquals(recommendations.length, 5);
  assertEquals(recommendations[0].name, "A");
  assertEquals(recommendations.some((recommendation) => recommendation.name === "F"), false);
});

Deno.test("quiet preference rewards quiet score over social life", () => {
  const loudSocial = candidate("social", "Social", 7, 7, 7, 10, 2, 3, 3, "high");
  const quietArea = candidate("quiet", "Quiet", 7, 7, 7, 4, 10, 3, 3, "high");
  const quietInput = {
    ...baseInput(),
    preferences: {
      ...baseInput().preferences,
      wants_quiet: true,
      wants_social_life: false
    }
  };

  const recommendations = recommendAreas(quietInput, [loudSocial, quietArea]);

  assertEquals(recommendations[0].name, "Quiet");
});

Deno.test("low broker and low Kannada preferences penalize high risk/dependency", () => {
  const lowRisk = candidate("low", "Low Risk", 7, 7, 7, 7, 7, 2, 2, "high");
  const highRisk = candidate("high", "High Risk", 7, 7, 7, 7, 7, 9, 9, "high");
  const recommendations = recommendAreas(baseInput(), [highRisk, lowRisk]);

  assertEquals(recommendations[0].name, "Low Risk");
  assertEquals(
    scoreCandidate(baseInput(), highRisk).risks.includes(
      "Kannada dependency may be higher than preferred."
    ),
    true
  );
});

Deno.test("low budget boosts affordable areas and flags expensive areas", () => {
  const affordable = candidate("btm", "BTM Layout", 9, 6, 6, 6, 6, 4, 4, "medium");
  const expensive = candidate("indiranagar", "Indiranagar", 3, 8, 9, 9, 5, 6, 3, "high");
  const recommendations = recommendAreas(baseInput(), [expensive, affordable]);

  assertEquals(recommendations[0].name, "BTM Layout");
  assertEquals(
    scoreCandidate(baseInput(), expensive).risks.includes("Rent may stretch the selected budget."),
    true
  );
});

Deno.test("requires work location text", () => {
  assertThrows(
    () => recommendAreas({ ...baseInput(), work_location_text: "" }, []),
    Error,
    "work_location_text is required"
  );
});

function baseInput(): AreaRecommendationInput {
  return {
    work_location_text: "Bellandur",
    budget_min: 18000,
    budget_max: 30000,
    commute_tolerance_minutes: 35,
    lifestyle_tags: ["cafes", "metro"],
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
