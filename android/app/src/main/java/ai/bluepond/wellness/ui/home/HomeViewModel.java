package ai.bluepond.wellness.ui.home;

import android.app.Application;

import androidx.annotation.NonNull;
import androidx.lifecycle.AndroidViewModel;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import java.util.List;

import ai.bluepond.wellness.WellnessApp;
import ai.bluepond.wellness.data.model.ActivityLog;
import ai.bluepond.wellness.data.model.Challenge;
import ai.bluepond.wellness.data.model.LeaderboardEntry;
import ai.bluepond.wellness.data.model.Participant;
import ai.bluepond.wellness.data.repository.Result;
import ai.bluepond.wellness.data.repository.WellnessRepository;
import ai.bluepond.wellness.utils.SessionManager;
import ai.bluepond.wellness.utils.ShiftAwareUtils;

public class HomeViewModel extends AndroidViewModel {

    private final WellnessRepository repository;
    private final SessionManager sessionManager;

    private final MutableLiveData<Result<Challenge>> activeChallenge = new MutableLiveData<>();
    private final MutableLiveData<Result<ActivityLog>> todayLog = new MutableLiveData<>();
    private final MutableLiveData<Result<Participant>> myProfile = new MutableLiveData<>();
    private final MutableLiveData<Result<List<LeaderboardEntry>>> leaderboard = new MutableLiveData<>();
    private final MutableLiveData<Result<List<ActivityLog>>> recentLogs = new MutableLiveData<>();

    public HomeViewModel(@NonNull Application application) {
        super(application);
        WellnessApp app = (WellnessApp) application;
        repository = new WellnessRepository(
                app.getSupabaseClient().getApiService(),
                app.getSessionManager());
        sessionManager = app.getSessionManager();
    }

    public LiveData<Result<Challenge>> getActiveChallenge() { return activeChallenge; }
    public LiveData<Result<ActivityLog>> getTodayLog() { return todayLog; }
    public LiveData<Result<Participant>> getMyProfile() { return myProfile; }
    public LiveData<Result<List<LeaderboardEntry>>> getLeaderboard() { return leaderboard; }
    public LiveData<Result<List<ActivityLog>>> getRecentLogs() { return recentLogs; }

    /**
     * Loads all home screen data sequentially:
     * profile → challenge → today's log + leaderboard rank
     */
    public void refreshAll() {
        loadProfile();
        loadChallenge();
    }

    public void loadProfile() {
        repository.getMyProfile().observeForever(result -> {
            myProfile.postValue(result);
        });
    }

    public void loadChallenge() {
        repository.getActiveChallenge().observeForever(result -> {
            activeChallenge.postValue(result);

            if (result != null && result.isSuccess() && result.getData() != null) {
                String challengeId = result.getData().getId();
                loadTodayLog(challengeId);
                loadLeaderboard(challengeId);
                loadRecentLogs(challengeId);
            }
        });
    }

    private void loadTodayLog(String challengeId) {
        Participant cachedParticipant = sessionManager.getCurrentParticipant();
        String activeDate = ShiftAwareUtils.getActiveDateString(cachedParticipant);
        String participantId = sessionManager.getParticipantId();

        if (participantId == null) return;

        repository.getMyActivityLogs(challengeId).observeForever(result -> {
            if (result != null && result.isSuccess() && result.getData() != null) {
                ActivityLog todayEntry = null;
                for (ActivityLog log : result.getData()) {
                    if (activeDate.equals(log.getActivityDate()) && !log.isVoided()) {
                        todayEntry = log;
                        break;
                    }
                }
                todayLog.postValue(Result.success(todayEntry)); // null = not logged yet
                recentLogs.postValue(result);
            } else if (result != null && result.isError()) {
                todayLog.postValue(Result.error(result.getErrorMessage()));
            }
        });
    }

    private void loadLeaderboard(String challengeId) {
        repository.getLeaderboard(challengeId, "overall").observeForever(result -> {
            leaderboard.postValue(result);
        });
    }

    private void loadRecentLogs(String challengeId) {
        // Already handled in loadTodayLog via recentLogs
    }

    /**
     * Returns an appropriate greeting based on the participant's shift type and
     * the current hour of day.
     */
    public String getShiftAwareGreeting(Participant participant) {
        return ShiftAwareUtils.getShiftAwareGreeting(participant);
    }

    /**
     * Returns the number of days remaining in the challenge, or 0 if ended.
     */
    public int getDaysRemaining(Challenge challenge) {
        if (challenge == null || challenge.getEndDate() == null) return 0;
        try {
            java.time.LocalDate end = java.time.LocalDate.parse(challenge.getEndDate());
            java.time.LocalDate today = java.time.LocalDate.now();
            long days = java.time.temporal.ChronoUnit.DAYS.between(today, end);
            return (int) Math.max(0, days);
        } catch (Exception e) {
            return 0;
        }
    }

    /**
     * Returns the participant's rank from the leaderboard list, or 0 if not found.
     */
    public int getMyRank(List<LeaderboardEntry> entries) {
        if (entries == null) return 0;
        String myId = sessionManager.getParticipantId();
        if (myId == null) return 0;
        for (LeaderboardEntry entry : entries) {
            if (myId.equals(entry.getParticipantId())) {
                return entry.getRank();
            }
        }
        return 0;
    }
}
