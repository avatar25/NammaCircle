# AI Report Service Placeholder

NammaCircle will eventually generate personalized locality reports. In the MVP, reports are deterministic and template-based.

## Source Of Truth

The deterministic area recommendation engine is the source of truth. It scores localities from stored `localities` and `locality_scores` data, then returns the top 5 areas with fit labels, reasons, risks, confidence, and verification timestamps.

The report service wraps that output into:

- Summary
- Top 5 areas
- Green/yellow/red fit
- Risks
- Rent notes
- Commute notes
- Survival tips
- Confidence level

## AI Boundary

AI is not called in the MVP. The current service uses a `LocalityReportExplanationGenerator` interface with a template implementation. A later AI generator can implement the same interface, but it must only explain deterministic recommendation output.

AI must never:

- Invent rent prices, deposits, or broker norms.
- Invent safety facts.
- Invent commute times or distances.
- Upgrade data confidence without evidence.
- Hide low-confidence or stale data.

AI may later:

- Rephrase deterministic reasons in a friendlier tone.
- Summarize existing risks.
- Explain why a fit is green, yellow, or red using already-computed scores.

## Implementation

- Pure report builder: `supabase/edge-functions/ai-report/localityReport.ts`
- Placeholder HTTP wrapper: `supabase/edge-functions/ai-report/index.ts`
- Tests: `supabase/edge-functions/ai-report/localityReport.test.ts`

The HTTP wrapper fetches locality data from Supabase and calls `generateLocalityReport`. No external AI API key or model provider is required.
