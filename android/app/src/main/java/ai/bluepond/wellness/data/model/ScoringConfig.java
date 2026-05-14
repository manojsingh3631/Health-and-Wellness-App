package ai.bluepond.wellness.data.model;

import com.google.gson.annotations.SerializedName;

public class ScoringConfig {

    @SerializedName("id")
    private String id;

    @SerializedName("challenge_id")
    private String challengeId;

    @SerializedName("activity_type")
    private String activityType;

    @SerializedName("points_per_unit")
    private double pointsPerUnit;

    @SerializedName("unit_description")
    private String unitDescription;

    @SerializedName("unit_threshold")
    private double unitThreshold;

    @SerializedName("daily_max_points")
    private double dailyMaxPoints;

    @SerializedName("bonus_threshold")
    private double bonusThreshold;

    @SerializedName("bonus_points")
    private double bonusPoints;

    @SerializedName("is_active")
    private boolean isActive;

    public ScoringConfig() {}

    // ── Getters ──────────────────────────────────────────────────────────────────

    public String getId() { return id; }
    public String getChallengeId() { return challengeId; }
    public String getActivityType() { return activityType; }
    public double getPointsPerUnit() { return pointsPerUnit; }
    public String getUnitDescription() { return unitDescription; }
    public double getUnitThreshold() { return unitThreshold; }
    public double getDailyMaxPoints() { return dailyMaxPoints; }
    public double getBonusThreshold() { return bonusThreshold; }
    public double getBonusPoints() { return bonusPoints; }
    public boolean isActive() { return isActive; }

    // ── Setters ──────────────────────────────────────────────────────────────────

    public void setId(String id) { this.id = id; }
    public void setChallengeId(String challengeId) { this.challengeId = challengeId; }
    public void setActivityType(String activityType) { this.activityType = activityType; }
    public void setPointsPerUnit(double pointsPerUnit) { this.pointsPerUnit = pointsPerUnit; }
    public void setUnitDescription(String unitDescription) { this.unitDescription = unitDescription; }
    public void setUnitThreshold(double unitThreshold) { this.unitThreshold = unitThreshold; }
    public void setDailyMaxPoints(double dailyMaxPoints) { this.dailyMaxPoints = dailyMaxPoints; }
    public void setBonusThreshold(double bonusThreshold) { this.bonusThreshold = bonusThreshold; }
    public void setBonusPoints(double bonusPoints) { this.bonusPoints = bonusPoints; }
    public void setActive(boolean active) { isActive = active; }
}
