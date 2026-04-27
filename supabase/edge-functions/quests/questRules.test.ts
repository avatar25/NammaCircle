import { assertEquals, assertThrows } from "https://deno.land/std@0.224.0/assert/mod.ts";
import {
  dailyApprovalKey,
  initialSubmissionStatus,
  isValidQuestType,
  shouldAwardPoints
} from "./questRules.ts";

Deno.test("allows only MVP quest types", () => {
  assertEquals(isValidQuestType("learn_kannada"), true);
  assertEquals(isValidQuestType("forum_help"), true);
  assertEquals(isValidQuestType("photo_walk"), true);
  assertEquals(isValidQuestType("rent_signal"), true);
  assertEquals(isValidQuestType("area_tip"), true);
  assertEquals(isValidQuestType("legacy_daily"), false);
});

Deno.test("learn Kannada quests auto-approve and other quests start pending", () => {
  assertEquals(initialSubmissionStatus("learn_kannada"), "approved");
  assertEquals(initialSubmissionStatus("forum_help"), "pending");
  assertEquals(initialSubmissionStatus("photo_walk"), "pending");
});

Deno.test("points are awarded only on first transition to approved", () => {
  assertEquals(shouldAwardPoints("pending", "approved"), true);
  assertEquals(shouldAwardPoints(null, "approved"), true);
  assertEquals(shouldAwardPoints("approved", "approved"), false);
  assertEquals(shouldAwardPoints("pending", "rejected"), false);
});

Deno.test("daily approval key requires stable user quest and date", () => {
  assertEquals(dailyApprovalKey("user-1", "quest-1", "2026-04-27"), "user-1:quest-1:2026-04-27");
  assertThrows(() => dailyApprovalKey("", "quest-1", "2026-04-27"), Error, "required");
});
