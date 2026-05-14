package ai.bluepond.wellness.data.model;

import com.google.gson.annotations.SerializedName;

public class ActivityLog {

    @SerializedName("id")
    private String id;

    @SerializedName("participant_id")
    private String participantId;

    @SerializedName("challenge_id")
    private String challengeId;

    @SerializedName("activity_date")
    private String activityDate; // yyyy-MM-dd

    @SerializedName("steps_count")
    private int stepsCount;

    @SerializedName("water_intake_liters")
    private double waterIntakeLiters;

    @SerializedName("yoga_minutes")
    private int yogaMinutes;

    @SerializedName("workout_minutes")
    private int workoutMinutes;

    @SerializedName("no_added_sugar_day")
    private boolean noAddedSugarDay;

    @SerializedName("points_earned")
    private double pointsEarned;

    @SerializedName("edit_count")
    private int editCount;

    @SerializedName("data_source")
    private String dataSource;

    @SerializedName("status")
    private String status;

    @SerializedName("is_voided")
    private boolean isVoided;

    @SerializedName("submitted_at")
    private String submittedAt;

    @SerializedName("last_modified_at")
    private String lastModifiedAt;

    public ActivityLog() {}

    // ── Getters ──────────────────────────────────────────────────────────────────

    public String getId() { return id; }
    public String getParticipantId() { return participantId; }
    public String getChallengeId() { return challengeId; }
    public String getActivityDate() { return activityDate; }
    public int getStepsCount() { return stepsCount; }
    public double getWaterIntakeLiters() { return waterIntakeLiters; }
    public int getYogaMinutes() { return yogaMinutes; }
    public int getWorkoutMinutes() { return workoutMinutes; }
    public boolean isNoAddedSugarDay() { return noAddedSugarDay; }
    public double getPointsEarned() { return pointsEarned; }
    public int getEditCount() { return editCount; }
    public String getDataSource() { return dataSource; }
    public String getStatus() { return status; }
    public boolean isVoided() { return isVoided; }
    public String getSubmittedAt() { return submittedAt; }
    public String getLastModifiedAt() { return lastModifiedAt; }

    // ── Setters ──────────────────────────────────────────────────────────────────

    public void setId(String id) { this.id = id; }
    public void setParticipantId(String participantId) { this.participantId = participantId; }
    public void setChallengeId(String challengeId) { this.challengeId = challengeId; }
    public void setActivityDate(String activityDate) { this.activityDate = activityDate; }
    public void setStepsCount(int stepsCount) { this.stepsCount = stepsCount; }
    public void setWaterIntakeLiters(double waterIntakeLiters) { this.waterIntakeLiters = waterIntakeLiters; }
    public void setYogaMinutes(int yogaMinutes) { this.yogaMinutes = yogaMinutes; }
    public void setWorkoutMinutes(int workoutMinutes) { this.workoutMinutes = workoutMinutes; }
    public void setNoAddedSugarDay(boolean noAddedSugarDay) { this.noAddedSugarDay = noAddedSugarDay; }
    public void setPointsEarned(double pointsEarned) { this.pointsEarned = pointsEarned; }
    public void setEditCount(int editCount) { this.editCount = editCount; }
    public void setDataSource(String dataSource) { this.dataSource = dataSource; }
    public void setStatus(String status) { this.status = status; }
    public void setVoided(boolean voided) { isVoided = voided; }
    public void setSubmittedAt(String submittedAt) { this.submittedAt = submittedAt; }
    public void setLastModifiedAt(String lastModifiedAt) { this.lastModifiedAt = lastModifiedAt; }
}
