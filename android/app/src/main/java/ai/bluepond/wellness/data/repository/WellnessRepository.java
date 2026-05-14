package ai.bluepond.wellness.data.repository;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import ai.bluepond.wellness.data.api.SupabaseService;
import ai.bluepond.wellness.data.model.ActivityLog;
import ai.bluepond.wellness.data.model.Challenge;
import ai.bluepond.wellness.data.model.Faq;
import ai.bluepond.wellness.data.model.LeaderboardEntry;
import ai.bluepond.wellness.data.model.Participant;
import ai.bluepond.wellness.data.model.Reminder;
import ai.bluepond.wellness.data.model.ScoringConfig;
import ai.bluepond.wellness.utils.ScoringEngine;
import ai.bluepond.wellness.utils.SessionManager;
import retrofit2.Response;

public class WellnessRepository {

    private static final String TAG = "WellnessRepository";

    private final SupabaseService service;
    private final SessionManager sessionManager;
    private final ExecutorService executor;

    public WellnessRepository(SupabaseService service, SessionManager sessionManager) {
        this.service = service;
        this.sessionManager = sessionManager;
        this.executor = Executors.newSingleThreadExecutor();
    }

    // ── Challenges ────────────────────────────────────────────────────────────────

    public LiveData<Result<Challenge>> getActiveChallenge() {
        MutableLiveData<Result<Challenge>> liveData = new MutableLiveData<>();
        liveData.postValue(Result.loading());

        executor.execute(() -> {
            try {
                Response<List<Challenge>> resp = service
                        .getActiveChallenges("eq.true", "*")
                        .execute();

                if (resp.isSuccessful() && resp.body() != null && !resp.body().isEmpty()) {
                    liveData.postValue(Result.success(resp.body().get(0)));
                } else if (resp.isSuccessful()) {
                    liveData.postValue(Result.error("No active challenge found."));
                } else {
                    liveData.postValue(Result.error("Failed to load challenge: " + resp.code()));
                }
            } catch (Exception e) {
                liveData.postValue(Result.error("Network error loading challenge.", e));
            }
        });

        return liveData;
    }

    // ── Activity Logs ─────────────────────────────────────────────────────────────

    public LiveData<Result<List<ActivityLog>>> getMyActivityLogs(String challengeId) {
        MutableLiveData<Result<List<ActivityLog>>> liveData = new MutableLiveData<>();
        liveData.postValue(Result.loading());

        executor.execute(() -> {
            try {
                String participantId = sessionManager.getParticipantId();
                if (participantId == null) {
                    liveData.postValue(Result.error("Not logged in."));
                    return;
                }

                Response<List<ActivityLog>> resp = service
                        .getActivityLogs(
                                "eq." + participantId,
                                "eq." + challengeId,
                                "activity_date.desc")
                        .execute();

                if (resp.isSuccessful() && resp.body() != null) {
                    liveData.postValue(Result.success(resp.body()));
                } else {
                    liveData.postValue(Result.error("Failed to load activity logs: " + resp.code()));
                }
            } catch (Exception e) {
                liveData.postValue(Result.error("Network error loading activity logs.", e));
            }
        });

        return liveData;
    }

    public LiveData<Result<ActivityLog>> submitActivityLog(
            ActivityLog log,
            List<ScoringConfig> configs,
            Challenge challenge) {

        MutableLiveData<Result<ActivityLog>> liveData = new MutableLiveData<>();
        liveData.postValue(Result.loading());

        executor.execute(() -> {
            try {
                // Calculate and set points before submission
                double points = ScoringEngine.calculatePoints(log, configs, challenge);
                log.setPointsEarned(points);
                log.setStatus("submitted");
                log.setDataSource("manual");
                log.setEditCount(0);

                Response<List<ActivityLog>> resp = service
                        .insertActivityLog(log)
                        .execute();

                if (resp.isSuccessful() && resp.body() != null && !resp.body().isEmpty()) {
                    liveData.postValue(Result.success(resp.body().get(0)));
                } else {
                    liveData.postValue(Result.error("Failed to submit activity log: " + resp.code()));
                }
            } catch (Exception e) {
                liveData.postValue(Result.error("Network error submitting activity log.", e));
            }
        });

        return liveData;
    }

    public LiveData<Result<ActivityLog>> updateActivityLog(
            ActivityLog log,
            List<ScoringConfig> configs,
            Challenge challenge) {

        MutableLiveData<Result<ActivityLog>> liveData = new MutableLiveData<>();
        liveData.postValue(Result.loading());

        executor.execute(() -> {
            try {
                if (!challenge.isAllowOneEdit() || log.getEditCount() >= 1) {
                    liveData.postValue(Result.error("Edit limit reached for this submission."));
                    return;
                }

                double points = ScoringEngine.calculatePoints(log, configs, challenge);
                log.setPointsEarned(points);
                log.setEditCount(log.getEditCount() + 1);

                Response<Void> resp = service
                        .updateActivityLog("eq." + log.getId(), log)
                        .execute();

                if (resp.isSuccessful()) {
                    liveData.postValue(Result.success(log));
                } else {
                    liveData.postValue(Result.error("Failed to update activity log: " + resp.code()));
                }
            } catch (Exception e) {
                liveData.postValue(Result.error("Network error updating activity log.", e));
            }
        });

        return liveData;
    }

    // ── Leaderboard ───────────────────────────────────────────────────────────────

    public LiveData<Result<List<LeaderboardEntry>>> getLeaderboard(
            String challengeId, String type) {

        MutableLiveData<Result<List<LeaderboardEntry>>> liveData = new MutableLiveData<>();
        liveData.postValue(Result.loading());

        executor.execute(() -> {
            try {
                Response<List<LeaderboardEntry>> resp = service
                        .getLeaderboard(
                                "eq." + challengeId,
                                "eq." + type,
                                "rank.asc")
                        .execute();

                if (resp.isSuccessful() && resp.body() != null) {
                    liveData.postValue(Result.success(resp.body()));
                } else {
                    liveData.postValue(Result.error("Failed to load leaderboard: " + resp.code()));
                }
            } catch (Exception e) {
                liveData.postValue(Result.error("Network error loading leaderboard.", e));
            }
        });

        return liveData;
    }

    // ── Scoring Config ────────────────────────────────────────────────────────────

    public LiveData<Result<List<ScoringConfig>>> getScoringConfig(String challengeId) {
        MutableLiveData<Result<List<ScoringConfig>>> liveData = new MutableLiveData<>();
        liveData.postValue(Result.loading());

        executor.execute(() -> {
            try {
                Response<List<ScoringConfig>> resp = service
                        .getScoringConfig("eq." + challengeId, "eq.true")
                        .execute();

                if (resp.isSuccessful() && resp.body() != null) {
                    liveData.postValue(Result.success(resp.body()));
                } else {
                    liveData.postValue(Result.error("Failed to load scoring config: " + resp.code()));
                }
            } catch (Exception e) {
                liveData.postValue(Result.error("Network error loading scoring config.", e));
            }
        });

        return liveData;
    }

    // ── Participant Profile ───────────────────────────────────────────────────────

    public LiveData<Result<Participant>> getMyProfile() {
        MutableLiveData<Result<Participant>> liveData = new MutableLiveData<>();
        liveData.postValue(Result.loading());

        executor.execute(() -> {
            try {
                String authUserId = sessionManager.getUserId();
                if (authUserId == null) {
                    liveData.postValue(Result.error("Not logged in."));
                    return;
                }

                Response<List<Participant>> resp = service
                        .getParticipantByAuthId("eq." + authUserId, "*")
                        .execute();

                if (resp.isSuccessful() && resp.body() != null && !resp.body().isEmpty()) {
                    Participant participant = resp.body().get(0);
                    sessionManager.updateParticipantCache(participant);
                    liveData.postValue(Result.success(participant));
                } else {
                    liveData.postValue(Result.error("Profile not found."));
                }
            } catch (Exception e) {
                liveData.postValue(Result.error("Network error loading profile.", e));
            }
        });

        return liveData;
    }

    public LiveData<Result<Boolean>> updateProfile(Participant participant) {
        MutableLiveData<Result<Boolean>> liveData = new MutableLiveData<>();
        liveData.postValue(Result.loading());

        executor.execute(() -> {
            try {
                Response<Void> resp = service
                        .updateParticipant("eq." + participant.getId(), participant)
                        .execute();

                if (resp.isSuccessful()) {
                    sessionManager.updateParticipantCache(participant);
                    liveData.postValue(Result.success(true));
                } else {
                    liveData.postValue(Result.error("Failed to update profile: " + resp.code()));
                }
            } catch (Exception e) {
                liveData.postValue(Result.error("Network error updating profile.", e));
            }
        });

        return liveData;
    }

    // ── FAQs ──────────────────────────────────────────────────────────────────────

    public LiveData<Result<List<Faq>>> getFaqs() {
        MutableLiveData<Result<List<Faq>>> liveData = new MutableLiveData<>();
        liveData.postValue(Result.loading());

        executor.execute(() -> {
            try {
                Response<List<Faq>> resp = service
                        .getFaqs("eq.true", "display_order.asc")
                        .execute();

                if (resp.isSuccessful() && resp.body() != null) {
                    liveData.postValue(Result.success(resp.body()));
                } else {
                    liveData.postValue(Result.error("Failed to load FAQs: " + resp.code()));
                }
            } catch (Exception e) {
                liveData.postValue(Result.error("Network error loading FAQs.", e));
            }
        });

        return liveData;
    }

    // ── Reminders ─────────────────────────────────────────────────────────────────

    public LiveData<Result<List<Reminder>>> getMyReminders() {
        MutableLiveData<Result<List<Reminder>>> liveData = new MutableLiveData<>();
        liveData.postValue(Result.loading());

        executor.execute(() -> {
            try {
                String participantId = sessionManager.getParticipantId();
                if (participantId == null) {
                    liveData.postValue(Result.error("Not logged in."));
                    return;
                }

                Response<List<Reminder>> resp = service
                        .getReminders("eq." + participantId)
                        .execute();

                if (resp.isSuccessful() && resp.body() != null) {
                    liveData.postValue(Result.success(resp.body()));
                } else {
                    liveData.postValue(Result.error("Failed to load reminders: " + resp.code()));
                }
            } catch (Exception e) {
                liveData.postValue(Result.error("Network error loading reminders.", e));
            }
        });

        return liveData;
    }

    public LiveData<Result<Reminder>> saveReminder(Reminder reminder) {
        MutableLiveData<Result<Reminder>> liveData = new MutableLiveData<>();
        liveData.postValue(Result.loading());

        executor.execute(() -> {
            try {
                Response<List<Reminder>> resp = service
                        .insertReminder(reminder)
                        .execute();

                if (resp.isSuccessful() && resp.body() != null && !resp.body().isEmpty()) {
                    liveData.postValue(Result.success(resp.body().get(0)));
                } else {
                    liveData.postValue(Result.error("Failed to save reminder: " + resp.code()));
                }
            } catch (Exception e) {
                liveData.postValue(Result.error("Network error saving reminder.", e));
            }
        });

        return liveData;
    }

    public LiveData<Result<Boolean>> updateReminder(Reminder reminder) {
        MutableLiveData<Result<Boolean>> liveData = new MutableLiveData<>();
        liveData.postValue(Result.loading());

        executor.execute(() -> {
            try {
                Response<Void> resp = service
                        .updateReminder("eq." + reminder.getId(), reminder)
                        .execute();

                if (resp.isSuccessful()) {
                    liveData.postValue(Result.success(true));
                } else {
                    liveData.postValue(Result.error("Failed to update reminder: " + resp.code()));
                }
            } catch (Exception e) {
                liveData.postValue(Result.error("Network error updating reminder.", e));
            }
        });

        return liveData;
    }
}
