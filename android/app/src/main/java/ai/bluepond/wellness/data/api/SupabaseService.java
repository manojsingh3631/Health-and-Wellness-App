package ai.bluepond.wellness.data.api;

import java.util.List;

import ai.bluepond.wellness.data.model.ActivityLog;
import ai.bluepond.wellness.data.model.AppConfig;
import ai.bluepond.wellness.data.model.AuthResponse;
import ai.bluepond.wellness.data.model.Challenge;
import ai.bluepond.wellness.data.model.Faq;
import ai.bluepond.wellness.data.model.LeaderboardEntry;
import ai.bluepond.wellness.data.model.Participant;
import ai.bluepond.wellness.data.model.Reminder;
import ai.bluepond.wellness.data.model.ScoringConfig;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.Headers;
import retrofit2.http.PATCH;
import retrofit2.http.POST;
import retrofit2.http.Query;

public interface SupabaseService {

    // ── Auth endpoints ──────────────────────────────────────────────────────────

    @POST("auth/v1/token")
    Call<AuthResponse> login(
            @Query("grant_type") String grantType,
            @Body LoginRequest loginRequest);

    @POST("auth/v1/signup")
    Call<AuthResponse> register(@Body LoginRequest registerRequest);

    @POST("auth/v1/logout")
    Call<Void> logout();

    // ── Participants ─────────────────────────────────────────────────────────────

    @GET("rest/v1/participants")
    Call<List<Participant>> getParticipantByAuthId(
            @Query("auth_user_id") String authUserIdFilter,
            @Query("select") String select);

    @Headers("Prefer: return=representation")
    @POST("rest/v1/participants")
    Call<List<Participant>> insertParticipant(@Body Participant participant);

    @PATCH("rest/v1/participants")
    Call<Void> updateParticipant(
            @Query("id") String idFilter,
            @Body Participant participant);

    // ── Challenges ───────────────────────────────────────────────────────────────

    @GET("rest/v1/challenges")
    Call<List<Challenge>> getActiveChallenges(
            @Query("is_active") String isActiveFilter,
            @Query("select") String select);

    // ── Activity Logs ────────────────────────────────────────────────────────────

    @GET("rest/v1/activity_logs")
    Call<List<ActivityLog>> getActivityLogs(
            @Query("participant_id") String participantIdFilter,
            @Query("challenge_id") String challengeIdFilter,
            @Query("order") String order);

    @GET("rest/v1/activity_logs")
    Call<List<ActivityLog>> getActivityLogsByDate(
            @Query("participant_id") String participantIdFilter,
            @Query("challenge_id") String challengeIdFilter,
            @Query("activity_date") String activityDateFilter,
            @Query("order") String order);

    @Headers("Prefer: return=representation")
    @POST("rest/v1/activity_logs")
    Call<List<ActivityLog>> insertActivityLog(@Body ActivityLog activityLog);

    @PATCH("rest/v1/activity_logs")
    Call<Void> updateActivityLog(
            @Query("id") String idFilter,
            @Body ActivityLog activityLog);

    // ── Leaderboard ──────────────────────────────────────────────────────────────

    @GET("rest/v1/leaderboard_snapshots")
    Call<List<LeaderboardEntry>> getLeaderboard(
            @Query("challenge_id") String challengeIdFilter,
            @Query("leaderboard_type") String leaderboardTypeFilter,
            @Query("order") String order);

    // ── Scoring Config ───────────────────────────────────────────────────────────

    @GET("rest/v1/scoring_config")
    Call<List<ScoringConfig>> getScoringConfig(
            @Query("challenge_id") String challengeIdFilter,
            @Query("is_active") String isActiveFilter);

    // ── FAQs ─────────────────────────────────────────────────────────────────────

    @GET("rest/v1/faqs")
    Call<List<Faq>> getFaqs(
            @Query("is_published") String isPublishedFilter,
            @Query("order") String order);

    // ── App Config ───────────────────────────────────────────────────────────────

    @GET("rest/v1/app_config")
    Call<List<AppConfig>> getAppConfig(@Query("select") String select);

    // ── Reminders ────────────────────────────────────────────────────────────────

    @Headers("Prefer: return=representation")
    @POST("rest/v1/reminders")
    Call<List<Reminder>> insertReminder(@Body Reminder reminder);

    @PATCH("rest/v1/reminders")
    Call<Void> updateReminder(
            @Query("id") String idFilter,
            @Body Reminder reminder);

    @GET("rest/v1/reminders")
    Call<List<Reminder>> getReminders(@Query("participant_id") String participantIdFilter);

    // ── Inner request body ───────────────────────────────────────────────────────

    class LoginRequest {
        private final String email;
        private final String password;

        public LoginRequest(String email, String password) {
            this.email = email;
            this.password = password;
        }

        public String getEmail() { return email; }
        public String getPassword() { return password; }
    }
}
