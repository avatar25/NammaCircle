export type RentFairnessLabel =
  | "good_deal"
  | "fair"
  | "expensive"
  | "suspicious_or_overpriced";

export type DepositWarningLevel = "none" | "warning" | "strong_warning";

export type RentCheckInput = {
  locality_id: string;
  bhk: string;
  monthly_rent: number;
  deposit?: number | null;
  furnishing?: string | null;
  maintenance?: number | null;
};

export type RentReference = {
  medianRent: number;
  reportCount: number;
  source: "reports" | "baseline";
  confidenceLevel: "low" | "medium" | "high";
};

export type RentFairnessResult = {
  label: RentFairnessLabel;
  score: number;
  medianRent: number;
  reportCount: number;
  referenceSource: "reports" | "baseline";
  confidenceLevel: "low" | "medium" | "high";
  depositWarning: DepositWarningLevel;
  explanation: string;
  recommendedNegotiationPoints: string[];
};

export function normalizeBhk(bhk: string): string {
  return bhk.trim().toUpperCase().replace(/\s+/g, "");
}

export function median(values: number[]): number {
  const sorted = values.filter(Number.isFinite).sort((a, b) => a - b);

  if (sorted.length === 0) {
    throw new Error("Cannot calculate median for an empty list.");
  }

  const middle = Math.floor(sorted.length / 2);

  if (sorted.length % 2 === 1) {
    return sorted[middle];
  }

  return Math.round((sorted[middle - 1] + sorted[middle]) / 2);
}

export function buildRentReference(
  reportRents: number[],
  baselineMedianRent: number,
  baselineConfidenceLevel: RentReference["confidenceLevel"] = "low"
): RentReference {
  const cleanReports = reportRents.filter((rent) => Number.isFinite(rent) && rent > 0);

  if (cleanReports.length >= 5) {
    return {
      medianRent: median(cleanReports),
      reportCount: cleanReports.length,
      source: "reports",
      confidenceLevel: cleanReports.length >= 15 ? "high" : "medium"
    };
  }

  if (!Number.isFinite(baselineMedianRent) || baselineMedianRent <= 0) {
    throw new Error("A positive baseline median rent is required when fewer than 5 reports exist.");
  }

  return {
    medianRent: baselineMedianRent,
    reportCount: cleanReports.length,
    source: "baseline",
    confidenceLevel: baselineConfidenceLevel
  };
}

export function evaluateRentFairness(
  input: RentCheckInput,
  reference: RentReference
): RentFairnessResult {
  if (!Number.isFinite(input.monthly_rent) || input.monthly_rent <= 0) {
    throw new Error("monthly_rent must be a positive number.");
  }

  const rentRatio = input.monthly_rent / reference.medianRent;
  const label = labelForRatio(rentRatio);
  const score = scoreForRatio(rentRatio);
  const depositWarning = getDepositWarning(input.deposit ?? 0, input.monthly_rent);
  const explanation = buildExplanation(input, reference, rentRatio, label, depositWarning);
  const recommendedNegotiationPoints = buildNegotiationPoints(
    input,
    reference,
    rentRatio,
    depositWarning
  );

  return {
    label,
    score,
    medianRent: reference.medianRent,
    reportCount: reference.reportCount,
    referenceSource: reference.source,
    confidenceLevel: reference.confidenceLevel,
    depositWarning,
    explanation,
    recommendedNegotiationPoints
  };
}

function labelForRatio(rentRatio: number): RentFairnessLabel {
  if (rentRatio <= 0.9) {
    return "good_deal";
  }

  if (rentRatio <= 1.1) {
    return "fair";
  }

  if (rentRatio <= 1.3) {
    return "expensive";
  }

  return "suspicious_or_overpriced";
}

function scoreForRatio(rentRatio: number): number {
  if (rentRatio <= 0.9) {
    return 90;
  }

  if (rentRatio <= 1.1) {
    return Math.round(85 - ((rentRatio - 0.9) / 0.2) * 20);
  }

  if (rentRatio <= 1.3) {
    return Math.round(60 - ((rentRatio - 1.1) / 0.2) * 25);
  }

  return Math.max(5, Math.round(35 - Math.min(rentRatio - 1.3, 0.7) * 40));
}

function getDepositWarning(deposit: number, monthlyRent: number): DepositWarningLevel {
  if (!Number.isFinite(deposit) || deposit <= 0) {
    return "none";
  }

  const depositMonths = deposit / monthlyRent;

  if (depositMonths > 10) {
    return "strong_warning";
  }

  if (depositMonths > 6) {
    return "warning";
  }

  return "none";
}

function buildExplanation(
  input: RentCheckInput,
  reference: RentReference,
  rentRatio: number,
  label: RentFairnessLabel,
  depositWarning: DepositWarningLevel
): string {
  const sourceText =
    reference.source === "reports"
      ? `${reference.reportCount} recent reports`
      : "seeded locality baseline data because fewer than 5 matching reports exist";
  const percent = Math.round((rentRatio - 1) * 100);
  const direction = percent >= 0 ? "above" : "below";
  const absPercent = Math.abs(percent);
  const depositText =
    depositWarning === "strong_warning"
      ? " Deposit is above 10 months of rent, which needs strong caution."
      : depositWarning === "warning"
        ? " Deposit is above 6 months of rent, so negotiate or ask why."
        : "";

  return `For ${normalizeBhk(input.bhk)}, the submitted rent is ${absPercent}% ${direction} the median rent of INR ${reference.medianRent} from ${sourceText}. Result: ${label}.${depositText}`;
}

function buildNegotiationPoints(
  input: RentCheckInput,
  reference: RentReference,
  rentRatio: number,
  depositWarning: DepositWarningLevel
): string[] {
  const points: string[] = [];

  if (rentRatio > 1.1) {
    points.push(`Ask why the rent is above the local ${normalizeBhk(input.bhk)} median of INR ${reference.medianRent}.`);
  }

  if (depositWarning === "warning") {
    points.push("Try to bring the deposit to 6 months of rent or lower.");
  }

  if (depositWarning === "strong_warning") {
    points.push("Strongly question any deposit above 10 months and ask for written refund terms.");
  }

  if ((input.maintenance ?? 0) > 0) {
    points.push("Clarify whether maintenance is included in rent and which services it covers.");
  }

  if (input.furnishing) {
    points.push(`Verify the condition and inventory for the ${input.furnishing} furnishing claim.`);
  }

  if (reference.source === "baseline") {
    points.push("Treat this as a directional check because there are fewer than 5 matching recent reports.");
  }

  if (points.length === 0) {
    points.push("Confirm maintenance, lock-in period, painting charges, and deposit refund terms before paying.");
  }

  return points;
}
