package ai.bluepond.wellness.data.model;

import com.google.gson.annotations.SerializedName;

public class LeaderboardEntry {

    @SerializedName("id")
    private String id;

    @SerializedName("challenge_id")
    private String challengeId;

    @SerializedName("leaderboard_type")
    private String leaderboardType;

    @SerializedName("period_label")
    private String periodLabel;

    @SerializedName("participant_id")
    private String participantId;

    @SerializedName("display_name")
    private String displayName;

    @SerializedName("department")
    private String department;

    @SerializedName("team_name")
    private String teamName;

    @SerializedName("total_points")
    private double totalPoints;

    @SerializedName("rank")
    private int rank;

    @SerializedName("is_tied")
    private boolean isTied;

    @SerializedName("generated_at")
    private String generatedAt;

    public LeaderboardEntry() {}

    // ── Getters ──────────────────────────────────────────────────────────────────

    public String getId() { return id; }
    public String getChallengeId() { return challengeId; }
    public String getLeaderboardType() { return leaderboardType; }
    public String getPeriodLabel() { return periodLabel; }
    public String getParticipantId() { return participantId; }
    public String getDisplayName() { return displayName; }
    public String getDepartment() { return department; }
    public String getTeamName() { return teamName; }
    public double getTotalPoints() { return totalPoints; }
    public int getRank() { return rank; }
    public boolean isTied() { return isTied; }
    public String getGeneratedAt() { return generatedAt; }

    // ── Setters ──────────────────────────────────────────────────────────────────

    public void setId(String id) { this.id = id; }
    public void setChallengeId(String challengeId) { this.challengeId = challengeId; }
    public void setLeaderboardType(String leaderboardType) { this.leaderboardType = leaderboardType; }
    public void setPeriodLabel(String periodLabel) { this.periodLabel = periodLabel; }
    public void setParticipantId(String participantId) { this.participantId = participantId; }
    public void setDisplayName(String displayName) { this.displayName = displayName; }
    public void setDepartment(String department) { this.department = department; }
    public void setTeamName(String teamName) { this.teamName = teamName; }
    public void setTotalPoints(double totalPoints) { this.totalPoints = totalPoints; }
    public void setRank(int rank) { this.rank = rank; }
    public void setTied(boolean tied) { isTied = tied; }
    public void setGeneratedAt(String generatedAt) { this.generatedAt = generatedAt; }
}
