import {
  assertEquals,
  assertThrows
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import {
  buildRentReference,
  evaluateRentFairness,
  median,
  normalizeBhk
} from "./rentFairness.ts";

Deno.test("normalizes BHK input", () => {
  assertEquals(normalizeBhk(" 2 bhk "), "2BHK");
});

Deno.test("calculates median for odd and even report counts", () => {
  assertEquals(median([30000, 20000, 25000]), 25000);
  assertEquals(median([30000, 20000, 25000, 35000]), 27500);
});

Deno.test("uses reports when at least five matching reports exist", () => {
  const reference = buildRentReference([20000, 22000, 24000, 26000, 28000], 40000);

  assertEquals(reference, {
    medianRent: 24000,
    reportCount: 5,
    source: "reports",
    confidenceLevel: "medium"
  });
});

Deno.test("falls back to baseline when fewer than five reports exist", () => {
  const reference = buildRentReference([20000, 22000], 30000, "medium");

  assertEquals(reference, {
    medianRent: 30000,
    reportCount: 2,
    source: "baseline",
    confidenceLevel: "medium"
  });
});

Deno.test("labels submitted rent using deterministic thresholds", () => {
  const reference = buildRentReference([30000, 30000, 30000, 30000, 30000], 30000);

  assertEquals(evaluateRentFairness(baseInput(27000), reference).label, "good_deal");
  assertEquals(evaluateRentFairness(baseInput(33000), reference).label, "fair");
  assertEquals(evaluateRentFairness(baseInput(39000), reference).label, "expensive");
  assertEquals(
    evaluateRentFairness(baseInput(39001), reference).label,
    "suspicious_or_overpriced"
  );
});

Deno.test("adds deposit warnings and negotiation points", () => {
  const reference = buildRentReference([30000, 30000, 30000, 30000, 30000], 30000);
  const warningResult = evaluateRentFairness(baseInput(33000, 231000), reference);
  const strongWarningResult = evaluateRentFairness(baseInput(33000, 363000), reference);

  assertEquals(warningResult.depositWarning, "warning");
  assertEquals(strongWarningResult.depositWarning, "strong_warning");
  assertEquals(
    strongWarningResult.recommendedNegotiationPoints.some((point) =>
      point.includes("above 10 months")
    ),
    true
  );
});

Deno.test("requires baseline when reports are sparse", () => {
  assertThrows(
    () => buildRentReference([20000, 22000], 0),
    Error,
    "positive baseline median rent"
  );
});

function baseInput(monthlyRent: number, deposit = 120000) {
  return {
    locality_id: "00000000-0000-0000-0000-000000000000",
    bhk: "2BHK",
    monthly_rent: monthlyRent,
    deposit,
    furnishing: "semi_furnished",
    maintenance: 3000
  };
}
