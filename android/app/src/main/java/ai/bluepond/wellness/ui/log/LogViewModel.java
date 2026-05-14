package ai.bluepond.wellness.ui.log;

import android.app.Application;

import androidx.annotation.NonNull;
import androidx.lifecycle.AndroidViewModel;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import java.util.List;

import ai.bluepond.wellness.WellnessApp;
import ai.bluepond.wellness.data.model.ActivityLog;
import ai.bluepond.wellness.data.model.Challenge;
import ai.bluepond.wellness.data.model.ScoringConfig;
import ai.bluepond.wellness.data.repository.Result;
import ai.bluepond.wellness.data.repository.WellnessRepository;
import ai.bluepond.wellness.utils.ScoringEngine;
import ai.bluepond.wellness.utils.SessionManager;
import ai.bluepond.wellness.utils.ShiftAwareUtils;

public class LogViewModel extends AndroidViewModel {

    private final WellnessRepository repository;
    private final SessionManager sessionManager;

    private final MutableLiveData<Result<ActivityLog>> existingLog = new MutableLiveData<>();
    private final MutableLiveData<Result<Challenge>> activeChallenge = new MutableLiveData<>();
    private final MutableLiveData<Result<List<ScoringConfig>>> scoringConfigs = new MutableLiveData<>();
    private final MutableLiveData<Result<ActivityLog>> submitResult = new MutableLiveData<>();
    private final MutableLiveData<Double> estimatedPoints = new MutableLiveData<>(0.0);

    public LogViewModel(@NonNull Application application) {
        super(application);
        WellnessApp app = (WellnessApp) application;
        repository = new WellnessRepository(
                app.getSupabaseClient().getApiService(),
                app.getSessionManager());
        sessionManager = app.getSessionManager();
    }

    public LiveData<Result<ActivityLog>> getExistingLog() { return existingLog; }
    public LiveData<Result<Challenge>> getActiveChallenge() { return activeChallenge; }
    public LiveData<Result<List<ScoringConfig>>> getScoringConfigs() { return scoringConfigs; }
    public LiveData<Result<ActivityLog>> getSubmitResult() { return submitResult; }
    public LiveData<Double> getEstimatedPoints() { return estimatedPoints; }

    public void loadData() {
        loadChallenge();
    }

    private void loadChallenge() {
        repository.getActiveChallenge().observeForever(result -> {
            activeChallenge.postValue(result);
            if (result != null && result.isSuccess() && result.getData() != null) {
                String challengeId = result.getData().getId();
                loadScoringConfig(challengeId);
                loadTodayLog(challengeId);
            }
        });
    }

    private void loadScoringConfig(String challengeId) {
        repository.getScoringConfig(challengeId).observeForever(result -> {
            scoringConfigs.postValue(result);
        });
    }

    private void loadTodayLog(String challengeId) {
        repository.getMyActivityLogs(challengeId).observeForever(result -> {
            if (result != null && result.isSuccess() && result.getData() != null) {
                String activeDate = ShiftAwareUtils.getActiveDateString(
                        sessionManager.getCurrentParticipant());
                ActivityLog todayEntry = null;
                for (ActivityLog log : result.getData()) {
                    if (activeDate.equals(log.getActivityDate()) && !log.isVoided()) {
                        todayEntry = log;
                        break;
                    }
                }
                existingLog.postValue(Result.success(todayEntry));
                if (todayEntry != null) {
                    estimatedPoints.postValue(todayEntry.getPointsEarned());
                }
            } else if (result != null && result.isError()) {
                existingLog.postValue(Result.error(result.getErrorMessage()));
            }
        });
    }

    /**
     * Recalculates estimated points in real-time as user edits fields.
     * Should be called from TextWatcher callbacks with current field values.
     */
    public void recalculateEstimatedPoints(
            int steps, double water, int yoga, int workout, boolean sugarFree) {

        Result<Challenge> challengeResult = activeChallenge.getValue();
        Result<List<ScoringConfig>> configResult = scoringConfigs.getValue();

        if (challengeResult == null || !challengeResult.isSuccess()
                || configResult == null || !configResult.isSuccess()) {
            estimatedPoints.postValue(0.0);
            return;
        }

        ActivityLog tempLog = new ActivityLog();
        tempLog.setStepsCount(steps);
        tempLog.setWaterIntakeLiters(water);
        tempLog.setYogaMinutes(yoga);
        tempLog.setWorkoutMinutes(workout);
        tempLog.setNoAddedSugarDay(sugarFree);

        double pts = ScoringEngine.calculatePoints(
                tempLog, configResult.getData(), challengeResult.getData());
        estimatedPoints.postValue(pts);
    }

    public void submitLog(ActivityLog log) {
        Result<Challenge> challengeResult = activeChallenge.getValue();
        Result<List<ScoringConfig>> configResult = scoringConfigs.getValue();

        if (challengeResult == null || !challengeResult.isSuccess()
                || configResult == null || !configResult.isSuccess()) {
            submitResult.postValue(Result.error("Challenge data not loaded. Please try again."));
            return;
        }

        log.setParticipantId(sessionManager.getParticipantId());
        log.setChallengeId(challengeResult.getData().getId());
        log.setActivityDate(ShiftAwareUtils.getActiveDateString(
                sessionManager.getCurrentParticipant()));

        repository.submitActivityLog(log, configResult.getData(), challengeResult.getData())
                .observeForever(result -> submitResult.postValue(result));
    }

    public void updateLog(ActivityLog log) {
        Result<Challenge> challengeResult = activeChallenge.getValue();
        Result<List<ScoringConfig>> configResult = scoringConfigs.getValue();

        if (challengeResult == null || !challengeResult.isSuccess()
                || configResult == null || !configResult.isSuccess()) {
            submitResult.postValue(Result.error("Challenge data not loaded. Please try again."));
            return;
        }

        repository.updateActivityLog(log, configResult.getData(), challengeResult.getData())
                .observeForever(result -> submitResult.postValue(result));
    }
}
