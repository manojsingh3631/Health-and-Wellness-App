package ai.bluepond.wellness.utils;

import android.content.Context;
import android.content.SharedPreferences;

import ai.bluepond.wellness.data.model.AuthResponse;
import ai.bluepond.wellness.data.model.Participant;

public class SessionManager {

    private static final String PREF_NAME = "bluepond_wellness_session";
    private static final int PRIVATE_MODE = Context.MODE_PRIVATE;

    private static final String KEY_ACCESS_TOKEN = "access_token";
    private static final String KEY_REFRESH_TOKEN = "refresh_token";
    private static final String KEY_USER_ID = "user_id";
    private static final String KEY_PARTICIPANT_ID = "participant_id";
    private static final String KEY_PARTICIPANT_ROLE = "participant_role";
    private static final String KEY_PARTICIPANT_EMAIL = "participant_email";
    private static final String KEY_DISPLAY_NAME = "display_name";
    private static final String KEY_DEPARTMENT = "department";
    private static final String KEY_TEAM = "team";
    private static final String KEY_SHIFT_TYPE = "shift_type";
    private static final String KEY_SHIFT_START = "shift_start_time";
    private static final String KEY_SHIFT_END = "shift_end_time";
    private static final String KEY_IS_LOGGED_IN = "is_logged_in";
    private static final String KEY_CONSENT_ACCEPTED = "consent_accepted";
    private static final String KEY_ONBOARDING_COMPLETE = "onboarding_complete";
    private static final String KEY_CURRENT_STREAK = "current_streak";
    private static final String KEY_LONGEST_STREAK = "longest_streak";
    private static final String KEY_EMPLOYEE_ID = "employee_id";

    private final SharedPreferences prefs;
    private final SharedPreferences.Editor editor;

    public SessionManager(Context context) {
        prefs = context.getApplicationContext().getSharedPreferences(PREF_NAME, PRIVATE_MODE);
        editor = prefs.edit();
    }

    /**
     * Saves full session data from auth response and participant profile.
     */
    public void saveSession(AuthResponse authResponse, Participant participant) {
        editor.putBoolean(KEY_IS_LOGGED_IN, true);

        if (authResponse != null) {
            editor.putString(KEY_ACCESS_TOKEN, authResponse.getAccessToken());
            editor.putString(KEY_REFRESH_TOKEN, authResponse.getRefreshToken());
            if (authResponse.getUser() != null) {
                editor.putString(KEY_USER_ID, authResponse.getUser().getId());
                editor.putString(KEY_PARTICIPANT_EMAIL, authResponse.getUser().getEmail());
            }
        }

        if (participant != null) {
            editor.putString(KEY_PARTICIPANT_ID, participant.getId());
            editor.putString(KEY_PARTICIPANT_ROLE, participant.getRole());
            editor.putString(KEY_DISPLAY_NAME, participant.getDisplayName());
            editor.putString(KEY_DEPARTMENT, participant.getDepartment());
            editor.putString(KEY_TEAM, participant.getTeam());
            editor.putString(KEY_SHIFT_TYPE, participant.getShiftType());
            editor.putString(KEY_SHIFT_START, participant.getShiftStartTime());
            editor.putString(KEY_SHIFT_END, participant.getShiftEndTime());
            editor.putBoolean(KEY_CONSENT_ACCEPTED, participant.isConsentAccepted());
            editor.putBoolean(KEY_ONBOARDING_COMPLETE, participant.isOnboardingComplete());
            editor.putInt(KEY_CURRENT_STREAK, participant.getCurrentStreak());
            editor.putInt(KEY_LONGEST_STREAK, participant.getLongestStreak());
            editor.putString(KEY_EMPLOYEE_ID, participant.getEmployeeId());
            if (participant.getEmail() != null) {
                editor.putString(KEY_PARTICIPANT_EMAIL, participant.getEmail());
            }
        }

        editor.apply();
    }

    /**
     * Updates only the access and refresh tokens (e.g. after token refresh).
     */
    public void updateTokens(String accessToken, String refreshToken) {
        editor.putString(KEY_ACCESS_TOKEN, accessToken);
        editor.putString(KEY_REFRESH_TOKEN, refreshToken);
        editor.apply();
    }

    /**
     * Updates the locally cached participant profile fields.
     */
    public void updateParticipantCache(Participant participant) {
        if (participant == null) return;
        editor.putString(KEY_DISPLAY_NAME, participant.getDisplayName());
        editor.putString(KEY_DEPARTMENT, participant.getDepartment());
        editor.putString(KEY_TEAM, participant.getTeam());
        editor.putString(KEY_SHIFT_TYPE, participant.getShiftType());
        editor.putString(KEY_SHIFT_START, participant.getShiftStartTime());
        editor.putString(KEY_SHIFT_END, participant.getShiftEndTime());
        editor.putInt(KEY_CURRENT_STREAK, participant.getCurrentStreak());
        editor.putInt(KEY_LONGEST_STREAK, participant.getLongestStreak());
        editor.apply();
    }

    /**
     * Clears all session data on logout.
     */
    public void clearSession() {
        editor.clear();
        editor.apply();
    }

    // ── Accessors ─────────────────────────────────────────────────────────────────

    public boolean isLoggedIn() {
        return prefs.getBoolean(KEY_IS_LOGGED_IN, false);
    }

    public String getAccessToken() {
        return prefs.getString(KEY_ACCESS_TOKEN, null);
    }

    public String getRefreshToken() {
        return prefs.getString(KEY_REFRESH_TOKEN, null);
    }

    public String getUserId() {
        return prefs.getString(KEY_USER_ID, null);
    }

    public String getParticipantId() {
        return prefs.getString(KEY_PARTICIPANT_ID, null);
    }

    public String getParticipantRole() {
        return prefs.getString(KEY_PARTICIPANT_ROLE, "participant");
    }

    public String getParticipantEmail() {
        return prefs.getString(KEY_PARTICIPANT_EMAIL, null);
    }

    public String getDisplayName() {
        return prefs.getString(KEY_DISPLAY_NAME, null);
    }

    public boolean isOnboardingComplete() {
        return prefs.getBoolean(KEY_ONBOARDING_COMPLETE, false);
    }

    /**
     * Marks onboarding as seen/completed.
     * Called by OnboardingActivity after the user taps "Get Started" or "Skip".
     */
    public void setOnboardingSeen(boolean seen) {
        editor.putBoolean(KEY_ONBOARDING_COMPLETE, seen);
        editor.apply();
    }

    /**
     * Reconstructs a Participant object from cached SharedPreferences data.
     * This is a lightweight cached version — full data should be fetched from network.
     */
    public Participant getCurrentParticipant() {
        if (!isLoggedIn()) return null;

        Participant p = new Participant();
        p.setId(prefs.getString(KEY_PARTICIPANT_ID, null));
        p.setAuthUserId(prefs.getString(KEY_USER_ID, null));
        p.setEmail(prefs.getString(KEY_PARTICIPANT_EMAIL, null));
        p.setDisplayName(prefs.getString(KEY_DISPLAY_NAME, null));
        p.setDepartment(prefs.getString(KEY_DEPARTMENT, null));
        p.setTeam(prefs.getString(KEY_TEAM, null));
        p.setShiftType(prefs.getString(KEY_SHIFT_TYPE, "day"));
        p.setShiftStartTime(prefs.getString(KEY_SHIFT_START, "09:00"));
        p.setShiftEndTime(prefs.getString(KEY_SHIFT_END, "18:00"));
        p.setRole(prefs.getString(KEY_PARTICIPANT_ROLE, "participant"));
        p.setConsentAccepted(prefs.getBoolean(KEY_CONSENT_ACCEPTED, false));
        p.setOnboardingComplete(prefs.getBoolean(KEY_ONBOARDING_COMPLETE, false));
        p.setCurrentStreak(prefs.getInt(KEY_CURRENT_STREAK, 0));
        p.setLongestStreak(prefs.getInt(KEY_LONGEST_STREAK, 0));
        p.setEmployeeId(prefs.getString(KEY_EMPLOYEE_ID, null));
        return p;
    }
}
