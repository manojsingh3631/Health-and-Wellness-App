package ai.bluepond.wellness.data.model;

import com.google.gson.annotations.SerializedName;

public class Challenge {

    @SerializedName("id")
    private String id;

    @SerializedName("title")
    private String title;

    @SerializedName("description")
    private String description;

    @SerializedName("start_date")
    private String startDate;

    @SerializedName("end_date")
    private String endDate;

    @SerializedName("submission_deadline_time")
    private String submissionDeadlineTime;

    @SerializedName("allow_one_edit")
    private boolean allowOneEdit;

    @SerializedName("is_active")
    private boolean isActive;

    @SerializedName("include_steps")
    private boolean includeSteps;

    @SerializedName("include_water")
    private boolean includeWater;

    @SerializedName("include_yoga")
    private boolean includeYoga;

    @SerializedName("include_workout")
    private boolean includeWorkout;

    @SerializedName("include_sugar_free")
    private boolean includeSugarFree;

    @SerializedName("leaderboard_display_field")
    private String leaderboardDisplayField;

    @SerializedName("show_department")
    private boolean showDepartment;

    @SerializedName("team_leaderboard_enabled")
    private boolean teamLeaderboardEnabled;

    @SerializedName("tie_handling_rule")
    private String tieHandlingRule;

    @SerializedName("created_at")
    private String createdAt;

    public Challenge() {}

    // ── Getters ──────────────────────────────────────────────────────────────────

    public String getId() { return id; }
    public String getTitle() { return title; }
    public String getDescription() { return description; }
    public String getStartDate() { return startDate; }
    public String getEndDate() { return endDate; }
    public String getSubmissionDeadlineTime() { return submissionDeadlineTime; }
    public boolean isAllowOneEdit() { return allowOneEdit; }
    public boolean isActive() { return isActive; }
    public boolean isIncludeSteps() { return includeSteps; }
    public boolean isIncludeWater() { return includeWater; }
    public boolean isIncludeYoga() { return includeYoga; }
    public boolean isIncludeWorkout() { return includeWorkout; }
    public boolean isIncludeSugarFree() { return includeSugarFree; }
    public String getLeaderboardDisplayField() { return leaderboardDisplayField; }
    public boolean isShowDepartment() { return showDepartment; }
    public boolean isTeamLeaderboardEnabled() { return teamLeaderboardEnabled; }
    public String getTieHandlingRule() { return tieHandlingRule; }
    public String getCreatedAt() { return createdAt; }

    // ── Setters ──────────────────────────────────────────────────────────────────

    public void setId(String id) { this.id = id; }
    public void setTitle(String title) { this.title = title; }
    public void setDescription(String description) { this.description = description; }
    public void setStartDate(String startDate) { this.startDate = startDate; }
    public void setEndDate(String endDate) { this.endDate = endDate; }
    public void setSubmissionDeadlineTime(String submissionDeadlineTime) { this.submissionDeadlineTime = submissionDeadlineTime; }
    public void setAllowOneEdit(boolean allowOneEdit) { this.allowOneEdit = allowOneEdit; }
    public void setActive(boolean active) { isActive = active; }
    public void setIncludeSteps(boolean includeSteps) { this.includeSteps = includeSteps; }
    public void setIncludeWater(boolean includeWater) { this.includeWater = includeWater; }
    public void setIncludeYoga(boolean includeYoga) { this.includeYoga = includeYoga; }
    public void setIncludeWorkout(boolean includeWorkout) { this.includeWorkout = includeWorkout; }
    public void setIncludeSugarFree(boolean includeSugarFree) { this.includeSugarFree = includeSugarFree; }
    public void setLeaderboardDisplayField(String leaderboardDisplayField) { this.leaderboardDisplayField = leaderboardDisplayField; }
    public void setShowDepartment(boolean showDepartment) { this.showDepartment = showDepartment; }
    public void setTeamLeaderboardEnabled(boolean teamLeaderboardEnabled) { this.teamLeaderboardEnabled = teamLeaderboardEnabled; }
    public void setTieHandlingRule(String tieHandlingRule) { this.tieHandlingRule = tieHandlingRule; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}
