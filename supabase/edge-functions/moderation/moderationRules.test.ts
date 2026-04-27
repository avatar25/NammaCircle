import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import {
  adminActionForStatus,
  canUserCreateForumContentWithStatus,
  defaultForumStatus,
  isForumContentVisible,
  needsForumModeration
} from "./moderationRules.ts";

Deno.test("new forum content defaults to pending review", () => {
  assertEquals(defaultForumStatus(), "pending");
  assertEquals(needsForumModeration(defaultForumStatus()), true);
});

Deno.test("only approved legacy-visible forum content is public", () => {
  assertEquals(isForumContentVisible("approved"), true);
  assertEquals(isForumContentVisible("visible"), true);
  assertEquals(isForumContentVisible("pending"), false);
  assertEquals(isForumContentVisible("rejected"), false);
  assertEquals(isForumContentVisible("removed"), false);
});

Deno.test("user-created forum content must enter as pending", () => {
  assertEquals(canUserCreateForumContentWithStatus("pending"), true);
  assertEquals(canUserCreateForumContentWithStatus("approved"), false);
  assertEquals(canUserCreateForumContentWithStatus("visible"), false);
});

Deno.test("admin actions distinguish approve reject and review states", () => {
  assertEquals(adminActionForStatus("approved"), "approve");
  assertEquals(adminActionForStatus("visible"), "approve");
  assertEquals(adminActionForStatus("rejected"), "reject");
  assertEquals(adminActionForStatus("removed"), "reject");
  assertEquals(adminActionForStatus("flagged"), "review");
});
