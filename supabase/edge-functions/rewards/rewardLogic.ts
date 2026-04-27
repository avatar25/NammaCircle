export type RewardAction =
  | "complete_kannada_lesson"
  | "complete_daily_quest"
  | "answer_forum_question"
  | "accept_forum_answer";

export type RankName =
  | "Newcomer"
  | "Settler"
  | "Street Smart"
  | "Area Scout"
  | "Local Guide"
  | "City Sage";

export type StreakState = {
  current_streak: number;
  longest_streak: number;
  last_activity_date: string | null;
};

export type StreakResult = StreakState & {
  incremented: boolean;
};

export type RewardRule = {
  eventType: string;
  sourceType: string;
  points: number;
  updatesStreak: boolean;
};

export const rankThresholds: Array<{ name: RankName; points: number }> = [
  { name: "Newcomer", points: 0 },
  { name: "Settler", points: 100 },
  { name: "Street Smart", points: 500 },
  { name: "Area Scout", points: 1500 },
  { name: "Local Guide", points: 5000 },
  { name: "City Sage", points: 15000 }
];

export function rankForPoints(totalPoints: number): RankName {
  return [...rankThresholds]
    .reverse()
    .find((rank) => totalPoints >= rank.points)?.name ?? "Newcomer";
}

export function nextRankForPoints(totalPoints: number) {
  return rankThresholds.find((rank) => rank.points > totalPoints) ?? null;
}

export function staticRewardRule(action: RewardAction): RewardRule | null {
  switch (action) {
    case "complete_kannada_lesson":
      return {
        eventType: "kannada_lesson_completed",
        sourceType: "kannada_lesson",
        points: 10,
        updatesStreak: true
      };
    case "answer_forum_question":
      return {
        eventType: "forum_answer_created",
        sourceType: "forum_answer",
        points: 5,
        updatesStreak: false
      };
    case "accept_forum_answer":
      return {
        eventType: "forum_answer_accepted",
        sourceType: "accepted_answer",
        points: 25,
        updatesStreak: false
      };
    case "complete_daily_quest":
      return null;
  }
}

export function dailyQuestRewardRule(points: number): RewardRule {
  if (!Number.isFinite(points) || points < 0) {
    throw new Error("Quest points must be a non-negative number.");
  }

  return {
    eventType: "daily_quest_completed",
    sourceType: "daily_quest",
    points,
    updatesStreak: true
  };
}

export function applyStreakActivity(
  state: StreakState | null,
  activityDate: string
): StreakResult {
  const current = state ?? {
    current_streak: 0,
    longest_streak: 0,
    last_activity_date: null
  };

  if (current.last_activity_date === activityDate) {
    return {
      ...current,
      incremented: false
    };
  }

  const previousDate = current.last_activity_date ? parseDate(current.last_activity_date) : null;
  const today = parseDate(activityDate);
  const yesterday = addDays(today, -1);
  const continuesStreak = previousDate?.getTime() === yesterday.getTime();
  const currentStreak = continuesStreak ? current.current_streak + 1 : 1;

  return {
    current_streak: currentStreak,
    longest_streak: Math.max(current.longest_streak, currentStreak),
    last_activity_date: activityDate,
    incremented: true
  };
}

export function assertSourceID(sourceID: string | undefined) {
  if (!sourceID) {
    throw new Error("source_id is required for reward events.");
  }
}

function parseDate(value: string): Date {
  const date = new Date(`${value}T00:00:00.000Z`);

  if (Number.isNaN(date.getTime())) {
    throw new Error(`Invalid calendar date: ${value}`);
  }

  return date;
}

function addDays(date: Date, days: number): Date {
  const copy = new Date(date);
  copy.setUTCDate(copy.getUTCDate() + days);
  return copy;
}
