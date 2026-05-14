package ai.bluepond.wellness.utils;

import java.util.List;
import java.util.Map;

import ai.bluepond.wellness.data.model.ActivityLog;
import ai.bluepond.wellness.data.model.AppConfig;
import ai.bluepond.wellness.data.model.Challenge;
import ai.bluepond.wellness.data.model.ScoringConfig;

public final class ScoringEngine {

    // Activity type constants — must match values stored in scoring_config.activity_type
    public static final String TYPE_STEPS    = "steps";
    public static final String TYPE_WATER    = "water";
    public static final String TYPE_YOGA     = "yoga";
    public static final String TYPE_WORKOUT  = "workout";
    public static final String TYPE_SUGAR_FREE = "sugar_free";

    // AppConfig keys for streak bonuses
    private static final String CFG_STREAK_BONUS_7  = "streak_bonus_7_days";
    private static final String CFG_STREAK_BONUS_30 = "streak_bonus_30_days";

    private ScoringEngine() {}

    /**
     * Calculates the total points earned for the given ActivityLog given the
     * challenge's active scoring configuration.
     *
     * For each activity type enabled in the challenge:
     *   baseUnits  = floor(value / unitThreshold)
     *   basePoints = baseUnits * pointsPerUnit
     *   capped     = min(basePoints, dailyMaxPoints)
     *   bonus      = bonusPoints if value >= bonusThreshold, else 0
     *   contribution = min(capped + bonus, dailyMaxPoints)
     *
     * Returns total as a double rounded to 2 decimal places.
     */
    public static double calculatePoints(
            ActivityLog log,
            List<ScoringConfig> configs,
            Challenge challenge) {

        if (log == null || configs == null || configs.isEmpty() || challenge == null) {
            return 0.0;
        }

        double total = 0.0;

        for (ScoringConfig config : configs) {
            if (!config.isActive()) continue;

            String actType = config.getActivityType();
            double value = getActivityValue(log, actType, challenge);

            if (value < 0) continue; // activity not included in challenge

            double threshold = config.getUnitThreshold();
            if (threshold <= 0) threshold = 1.0; // guard against division by zero

            long units = (long) Math.floor(value / threshold);
            double basePoints = units * config.getPointsPerUnit();

            double dailyMax = config.getDailyMaxPoints();
            double capped = (dailyMax > 0) ? Math.min(basePoints, dailyMax) : basePoints;

            double bonus = 0.0;
            if (config.getBonusThreshold() > 0 && value >= config.getBonusThreshold()) {
                bonus = config.getBonusPoints();
            }

            double contribution = (dailyMax > 0)
                    ? Math.min(capped + bonus, dailyMax)
                    : (capped + bonus);

            total += contribution;
        }

        // Round to 2 decimal places
        return Math.round(total * 100.0) / 100.0;
    }

    /**
     * Returns the streak bonus points based on the current streak length.
     * Looks up bonus values from the AppConfig map.
     *
     * @param streakDays  current consecutive days streak
     * @param configMap   key → AppConfig map from app_config table
     */
    public static double getStreakBonus(int streakDays, Map<String, AppConfig> configMap) {
        if (configMap == null || streakDays <= 0) return 0.0;

        if (streakDays >= 30) {
            AppConfig cfg = configMap.get(CFG_STREAK_BONUS_30);
            if (cfg != null && cfg.getConfigValue() != null) {
                return parseDouble(cfg.getConfigValue(), 0.0);
            }
        } else if (streakDays >= 7) {
            AppConfig cfg = configMap.get(CFG_STREAK_BONUS_7);
            if (cfg != null && cfg.getConfigValue() != null) {
                return parseDouble(cfg.getConfigValue(), 0.0);
            }
        }
        return 0.0;
    }

    // ── Private helpers ───────────────────────────────────────────────────────────

    /**
     * Returns the numeric activity value for a given type, or -1 if the
     * activity is not included in the challenge.
     */
    private static double getActivityValue(
            ActivityLog log, String actType, Challenge challenge) {

        if (actType == null) return -1;

        switch (actType.toLowerCase()) {
            case TYPE_STEPS:
                if (!challenge.isIncludeSteps()) return -1;
                return log.getStepsCount();

            case TYPE_WATER:
                if (!challenge.isIncludeWater()) return -1;
                return log.getWaterIntakeLiters();

            case TYPE_YOGA:
                if (!challenge.isIncludeYoga()) return -1;
                return log.getYogaMinutes();

            case TYPE_WORKOUT:
                if (!challenge.isIncludeWorkout()) return -1;
                return log.getWorkoutMinutes();

            case TYPE_SUGAR_FREE:
                if (!challenge.isIncludeSugarFree()) return -1;
                // Sugar-free is binary: 1 unit = full day compliance
                return log.isNoAddedSugarDay() ? 1.0 : 0.0;

            default:
                return -1;
        }
    }

    private static double parseDouble(String value, double fallback) {
        try {
            return Double.parseDouble(value);
        } catch (NumberFormatException e) {
            return fallback;
        }
    }
}
