# NammaCircle

iOS app for surviving BLR.

## Area Recommendations

The deterministic area recommendation engine lives in:

```sh
supabase/edge-functions/area-recommendations
```

It scores seeded `localities` and `locality_scores` data without external maps APIs or AI-generated facts. Run the pure scoring tests with:

```sh
deno test supabase/edge-functions/area-recommendations/areaRecommendations.test.ts
```
