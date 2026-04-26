export type ConfidenceLevel = "low" | "medium" | "high";
export type FitLabel = "green" | "yellow" | "red";

export type AreaRecommendationInput = {
  work_location_text: string;
  budget_min?: number | null;
  budget_max?: number | null;
  commute_tolerance_minutes?: number | null;
  lifestyle_tags?: string[];
  preferences?: {
    wants_quiet?: boolean;
    wants_social_life?: boolean;
    wants_low_cost?: boolean;
    wants_food_options?: boolean;
    wants_low_kannada_dependency?: boolean;
    wants_low_broker_risk?: boolean;
  };
};

export type LocalityScoreRow = {
  locality_id: string;
  rent_score: number;
  commute_score: number;
  food_score: number;
  social_life_score: number;
  quiet_score: number;
  safety_confidence_score?: number | null;
  newcomer_friendliness_score: number;
  kannada_dependency_score: number;
  broker_risk_score: number;
  water_reliability_score?: number | null;
  last_verified_at: string | null;
  confidence_level: ConfidenceLevel;
};

export type LocalityRow = {
  id: string;
  name: string;
  slug: string;
  city?: string | null;
  description?: string | null;
};

export type RecommendationCandidate = LocalityRow & LocalityScoreRow;

export type AreaRecommendation = {
  locality_id: string;
  name: string;
  slug: string;
  fit: FitLabel;
  score: number;
  top_reasons: string[];
  risks: string[];
  confidence_level: ConfidenceLevel;
  last_verified_at: string | null;
};

type WeightedComponent = {
  key: string;
  label: string;
  value: number;
  weight: number;
};

export function recommendAreas(
  input: AreaRecommendationInput,
  candidates: RecommendationCandidate[],
  limit = 5
): AreaRecommendation[] {
  validateInput(input);

  return candidates
    .map((candidate) => scoreCandidate(input, candidate))
    .sort((a, b) => b.score - a.score || a.name.localeCompare(b.name))
    .slice(0, limit);
}

export function scoreCandidate(
  input: AreaRecommendationInput,
  candidate: RecommendationCandidate
): AreaRecommendation {
  const components = buildWeightedComponents(input, candidate);
  const totalWeight = components.reduce((sum, component) => sum + component.weight, 0);
  const weightedScore =
    components.reduce(
      (sum, component) => sum + normalizeScore(component.value) * component.weight,
      0
    ) / totalWeight;
  const budgetAdjustment = budgetFitAdjustment(input, candidate);
  const workLocationAdjustment = workLocationTextAdjustment(input.work_location_text, candidate);
  const score = clamp(Math.round(weightedScore + budgetAdjustment + workLocationAdjustment), 0, 100);

  return {
    locality_id: candidate.locality_id,
    name: candidate.name,
    slug: candidate.slug,
    fit: fitForScore(score),
    score,
    top_reasons: buildTopReasons(
      input,
      candidate,
      components,
      budgetAdjustment,
      workLocationAdjustment
    ),
    risks: buildRisks(input, candidate),
    confidence_level: candidate.confidence_level,
    last_verified_at: candidate.last_verified_at
  };
}

export function invertRiskScore(score: number): number {
  return 11 - clamp(score, 1, 10);
}

function validateInput(input: AreaRecommendationInput) {
  if (!input.work_location_text?.trim()) {
    throw new Error("work_location_text is required.");
  }

  if (input.budget_min != null && input.budget_min < 0) {
    throw new Error("budget_min cannot be negative.");
  }

  if (input.budget_max != null && input.budget_max < 0) {
    throw new Error("budget_max cannot be negative.");
  }

  if (
    input.budget_min != null &&
    input.budget_max != null &&
    input.budget_min > input.budget_max
  ) {
    throw new Error("budget_min cannot be greater than budget_max.");
  }

  if (input.commute_tolerance_minutes != null && input.commute_tolerance_minutes < 0) {
    throw new Error("commute_tolerance_minutes cannot be negative.");
  }
}

function getEffectivePreferences(input: AreaRecommendationInput) {
  const tags = new Set((input.lifestyle_tags ?? []).map((tag) => normalizeText(tag)));
  const preferences = input.preferences ?? {};

  return {
    wants_quiet: preferences.wants_quiet ?? tags.has("quiet"),
    wants_social_life:
      preferences.wants_social_life ?? (tags.has("social") || tags.has("nightlife")),
    wants_low_cost:
      preferences.wants_low_cost ?? (tags.has("budget") || tags.has("low cost")),
    wants_food_options:
      preferences.wants_food_options ?? (tags.has("cafes") || tags.has("food")),
    wants_low_kannada_dependency:
      preferences.wants_low_kannada_dependency ??
      (tags.has("low kannada dependency") || tags.has("english friendly")),
    wants_low_broker_risk:
      preferences.wants_low_broker_risk ??
      (tags.has("low broker risk") || tags.has("no broker"))
  };
}

function buildWeightedComponents(
  input: AreaRecommendationInput,
  candidate: RecommendationCandidate
): WeightedComponent[] {
  const preferences = getEffectivePreferences(input);
  const wantsQuiet = Boolean(preferences.wants_quiet);
  const wantsSocial = Boolean(preferences.wants_social_life);
  const rentWeight = preferences.wants_low_cost ? 0.28 : 0.22;
  const commuteWeight = (input.commute_tolerance_minutes ?? 45) <= 30 ? 0.28 : 0.22;
  const foodWeight = preferences.wants_food_options ? 0.14 : 0.09;
  const brokerWeight = preferences.wants_low_broker_risk ? 0.12 : 0.08;
  const kannadaWeight = preferences.wants_low_kannada_dependency ? 0.1 : 0.03;

  return [
    {
      key: "rent_score",
      label: "affordability",
      value: candidate.rent_score,
      weight: rentWeight
    },
    {
      key: "commute_score",
      label: "commute",
      value: candidate.commute_score,
      weight: commuteWeight
    },
    {
      key: "newcomer_friendliness_score",
      label: "newcomer friendliness",
      value: candidate.newcomer_friendliness_score,
      weight: 0.14
    },
    {
      key: "food_score",
      label: "food options",
      value: candidate.food_score,
      weight: foodWeight
    },
    {
      key: wantsQuiet && !wantsSocial ? "quiet_score" : "social_life_score",
      label: wantsQuiet && !wantsSocial ? "quiet streets" : "social life",
      value: wantsQuiet && !wantsSocial ? candidate.quiet_score : candidate.social_life_score,
      weight: 0.1
    },
    {
      key: "broker_risk_score",
      label: "lower broker risk",
      value: invertRiskScore(candidate.broker_risk_score),
      weight: brokerWeight
    },
    {
      key: "kannada_dependency_score",
      label: "lower Kannada dependency",
      value: invertRiskScore(candidate.kannada_dependency_score),
      weight: kannadaWeight
    }
  ];
}

function buildTopReasons(
  input: AreaRecommendationInput,
  candidate: RecommendationCandidate,
  components: WeightedComponent[],
  budgetAdjustment: number,
  workLocationAdjustment: number
): string[] {
  const reasons = components
    .filter((component) => component.value >= 7)
    .sort((a, b) => b.value * b.weight - a.value * a.weight)
    .slice(0, 3)
    .map((component) => `${candidate.name} scores well for ${component.label}.`);

  if (budgetAdjustment > 0) {
    reasons.push("Budget preference aligns with this locality's affordability score.");
  }

  if (workLocationAdjustment > 0) {
    reasons.push("Work location text appears to match this locality.");
  }

  if (reasons.length === 0) {
    reasons.push("This locality has a balanced MVP score across the selected preferences.");
  }

  return reasons.slice(0, 4);
}

function buildRisks(input: AreaRecommendationInput, candidate: RecommendationCandidate): string[] {
  const risks: string[] = [];
  const preferences = getEffectivePreferences(input);

  if (candidate.rent_score <= 4) {
    risks.push("Rent may stretch the selected budget.");
  }

  if (candidate.commute_score <= 4) {
    risks.push("Commute score is weak for the current MVP data.");
  }

  if (candidate.broker_risk_score >= 7) {
    risks.push("Broker risk is elevated; verify fees and deposit terms carefully.");
  }

  if (
    preferences.wants_low_kannada_dependency &&
    candidate.kannada_dependency_score >= 7
  ) {
    risks.push("Kannada dependency may be higher than preferred.");
  }

  if (preferences.wants_quiet && candidate.quiet_score <= 4) {
    risks.push("This may not be a quiet locality.");
  }

  if (candidate.confidence_level === "low") {
    risks.push("Locality score confidence is low and should be treated as directional.");
  }

  if (risks.length === 0) {
    risks.push("No major MVP scoring risks found; still verify rent and commute before deciding.");
  }

  return risks.slice(0, 4);
}

function budgetFitAdjustment(input: AreaRecommendationInput, candidate: RecommendationCandidate): number {
  if (!input.budget_max) {
    return 0;
  }

  if (input.budget_max <= 25000 && candidate.rent_score >= 8) {
    return 5;
  }

  if (input.budget_max <= 35000 && candidate.rent_score >= 7) {
    return 3;
  }

  if (input.budget_max <= 25000 && candidate.rent_score <= 4) {
    return -8;
  }

  if (input.budget_max <= 35000 && candidate.rent_score <= 5) {
    return -4;
  }

  return 0;
}

function workLocationTextAdjustment(workLocationText: string, candidate: RecommendationCandidate): number {
  const normalizedWorkText = normalizeText(workLocationText);

  if (!normalizedWorkText) {
    return 0;
  }

  const name = normalizeText(candidate.name);
  const slug = normalizeText(candidate.slug.replaceAll("-", " "));

  if (normalizedWorkText.includes(name) || normalizedWorkText.includes(slug)) {
    return 6;
  }

  return 0;
}

function normalizeScore(score: number): number {
  return clamp(score, 0, 10) * 10;
}

function fitForScore(score: number): FitLabel {
  if (score >= 75) {
    return "green";
  }

  if (score >= 55) {
    return "yellow";
  }

  return "red";
}

function normalizeText(value: string): string {
  return value.trim().toLowerCase().replace(/\s+/g, " ");
}

function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}
