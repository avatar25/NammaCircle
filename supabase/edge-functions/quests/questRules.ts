export type QuestType =
  | "learn_kannada"
  | "forum_help"
  | "photo_walk"
  | "rent_signal"
  | "area_tip";

export type QuestSubmissionStatus = "pending" | "approved" | "rejected" | "flagged";

export function isValidQuestType(value: string): value is QuestType {
  return [
    "learn_kannada",
    "forum_help",
    "photo_walk",
    "rent_signal",
    "area_tip"
  ].includes(value);
}

export function initialSubmissionStatus(questType: QuestType): QuestSubmissionStatus {
  return questType === "learn_kannada" ? "approved" : "pending";
}

export function shouldAwardPoints(
  previousStatus: QuestSubmissionStatus | null,
  nextStatus: QuestSubmissionStatus
): boolean {
  return nextStatus === "approved" && previousStatus !== "approved";
}

export function dailyApprovalKey(userID: string, questID: string, calendarDate: string): string {
  if (!userID || !questID || !calendarDate) {
    throw new Error("userID, questID, and calendarDate are required.");
  }

  return `${userID}:${questID}:${calendarDate}`;
}
