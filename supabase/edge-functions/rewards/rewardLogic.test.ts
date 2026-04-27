import { assertEquals, assertThrows } from "https://deno.land/std@0.224.0/assert/mod.ts";
import {
  applyStreakActivity,
  assertSourceID,
  dailyQuestRewardRule,
  nextRankForPoints,
  rankForPoints,
  staticRewardRule
} from "./rewardLogic.ts";

Deno.test("maps static reward rules", () => {
  assertEquals(staticRewardRule("complete_kannada_lesson"), {
    eventType: "kannada_lesson_completed",
    sourceType: "kannada_lesson",
    points: 10,
    updatesStreak: true
  });
  assertEquals(staticRewardRule("answer_forum_question")?.points, 5);
  assertEquals(staticRewardRule("accept_forum_answer")?.points, 25);
});

Deno.test("uses quest points for daily quest rewards", () => {
  assertEquals(dailyQuestRewardRule(40), {
    eventType: "daily_quest_completed",
    sourceType: "daily_quest",
    points: 40,
    updatesStreak: true
  });
  assertThrows(() => dailyQuestRewardRule(-1), Error, "non-negative");
});

Deno.test("increments streak once per calendar day", () => {
  const first = applyStreakActivity(null, "2026-04-27");
  const duplicateSameDay = applyStreakActivity(first, "2026-04-27");
  const nextDay = applyStreakActivity(first, "2026-04-28");
  const broken = applyStreakActivity(nextDay, "2026-04-30");

  assertEquals(first.current_streak, 1);
  assertEquals(first.longest_streak, 1);
  assertEquals(first.incremented, true);
  assertEquals(duplicateSameDay.current_streak, 1);
  assertEquals(duplicateSameDay.incremented, false);
  assertEquals(nextDay.current_streak, 2);
  assertEquals(nextDay.longest_streak, 2);
  assertEquals(broken.current_streak, 1);
  assertEquals(broken.longest_streak, 2);
});

Deno.test("maps ranks from derived point totals", () => {
  assertEquals(rankForPoints(0), "Newcomer");
  assertEquals(rankForPoints(100), "Settler");
  assertEquals(rankForPoints(499), "Settler");
  assertEquals(rankForPoints(500), "Street Smart");
  assertEquals(rankForPoints(1500), "Area Scout");
  assertEquals(rankForPoints(5000), "Local Guide");
  assertEquals(rankForPoints(15000), "City Sage");
  assertEquals(nextRankForPoints(1499)?.name, "Area Scout");
  assertEquals(nextRankForPoints(15000), null);
});

Deno.test("requires source IDs to prevent duplicate reward ambiguity", () => {
  assertThrows(() => assertSourceID(undefined), Error, "source_id is required");
});
