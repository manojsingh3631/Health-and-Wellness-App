package ai.bluepond.wellness.utils;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

import ai.bluepond.wellness.data.model.Participant;

public final class ShiftAwareUtils {

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("HH:mm");

    private static final String SHIFT_NIGHT = "night";
    private static final String SHIFT_DAY = "day";
    private static final String SHIFT_EVENING = "evening";

    private ShiftAwareUtils() {}

    /**
     * Returns the active date string (yyyy-MM-dd) for activity logging,
     * taking shift type and crossing-midnight logic into account.
     *
     * Night-shift workers who are still awake in the early hours of the next
     * calendar day should log their activity against the previous day (their
     * "shift day"). The transition happens once the shift end time has passed.
     */
    public static String getActiveDateString(Participant p) {
        if (p == null) {
            return LocalDate.now().format(DATE_FMT);
        }

        String shiftType = p.getShiftType();
        if (shiftType == null) shiftType = SHIFT_DAY;

        if (SHIFT_NIGHT.equalsIgnoreCase(shiftType)) {
            // Night shift: crosses midnight
            // shiftEndTime is typically in the morning hours (e.g. 06:00)
            LocalTime shiftEnd = parseTime(p.getShiftEndTime(), LocalTime.of(6, 0));
            LocalTime now = LocalTime.now();

            // Before the shift ends (e.g. 00:00–06:00): still on yesterday's shift day
            if (now.isBefore(shiftEnd)) {
                return LocalDate.now().minusDays(1).format(DATE_FMT);
            }
        }

        return LocalDate.now().format(DATE_FMT);
    }

    /**
     * Returns true if the current wall-clock time falls within the participant's
     * configured shift window (shiftStartTime to shiftEndTime).
     * Handles overnight windows correctly.
     */
    public static boolean isWithinActiveWindow(Participant p) {
        if (p == null) return true;

        LocalTime shiftStart = parseTime(p.getShiftStartTime(), LocalTime.of(9, 0));
        LocalTime shiftEnd = parseTime(p.getShiftEndTime(), LocalTime.of(18, 0));
        LocalTime now = LocalTime.now();

        if (shiftStart.isBefore(shiftEnd)) {
            // Regular same-day window (e.g. 09:00–18:00)
            return !now.isBefore(shiftStart) && !now.isAfter(shiftEnd);
        } else {
            // Overnight window (e.g. 22:00–06:00)
            return !now.isBefore(shiftStart) || !now.isAfter(shiftEnd);
        }
    }

    /**
     * Returns true if the current time is within the participant's rest/sleep window.
     * For night-shift workers this is typically 09:00–18:00 (their sleep period).
     * For day-shift workers this is typically 22:00–06:00.
     */
    public static boolean isQuietHours(Participant p) {
        if (p == null) return false;

        String shiftType = p.getShiftType();
        LocalTime now = LocalTime.now();

        if (SHIFT_NIGHT.equalsIgnoreCase(shiftType)) {
            // Night-shift sleep window: 09:00–18:00
            LocalTime sleepStart = LocalTime.of(9, 0);
            LocalTime sleepEnd = LocalTime.of(18, 0);
            return !now.isBefore(sleepStart) && now.isBefore(sleepEnd);
        } else {
            // Day/evening shift quiet hours: 22:00–06:00
            LocalTime quietStart = LocalTime.of(22, 0);
            LocalTime quietEnd = LocalTime.of(6, 0);
            return !now.isBefore(quietStart) || now.isBefore(quietEnd);
        }
    }

    /**
     * Returns a human-readable shift label from the raw shift type string.
     */
    public static String formatShiftLabel(String shiftType) {
        if (shiftType == null || shiftType.isEmpty()) return "Day Shift";
        switch (shiftType.toLowerCase()) {
            case SHIFT_NIGHT:   return "Night Shift";
            case SHIFT_EVENING: return "Evening Shift";
            case SHIFT_DAY:
            default:            return "Day Shift";
        }
    }

    /**
     * Returns a greeting appropriate for the participant's shift type and the
     * current hour. Night-shift workers get inverted greetings.
     */
    public static String getShiftAwareGreeting(Participant p) {
        int hour = LocalTime.now().getHour();
        String shiftType = (p != null && p.getShiftType() != null)
                ? p.getShiftType().toLowerCase() : SHIFT_DAY;

        if (SHIFT_NIGHT.equalsIgnoreCase(shiftType)) {
            // For night-shift: evening/night hours = "Good Morning" (start of their day)
            if (hour >= 20 || hour < 2)  return "Good Evening";
            if (hour >= 2  && hour < 8)  return "Good Night";
            return "Good Morning";
        } else {
            if (hour >= 5  && hour < 12) return "Good Morning";
            if (hour >= 12 && hour < 17) return "Good Afternoon";
            if (hour >= 17 && hour < 21) return "Good Evening";
            return "Good Night";
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────────

    private static LocalTime parseTime(String timeStr, LocalTime fallback) {
        if (timeStr == null || timeStr.isEmpty()) return fallback;
        try {
            // Handles both "HH:mm" and "HH:mm:ss"
            String trimmed = timeStr.length() > 5 ? timeStr.substring(0, 5) : timeStr;
            return LocalTime.parse(trimmed, TIME_FMT);
        } catch (DateTimeParseException e) {
            return fallback;
        }
    }
}
