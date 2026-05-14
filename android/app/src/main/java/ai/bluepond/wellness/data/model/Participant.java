package ai.bluepond.wellness.data.model;

import com.google.gson.annotations.SerializedName;

public class Participant {

    @SerializedName("id")
    private String id;

    @SerializedName("auth_user_id")
    private String authUserId;

    @SerializedName("display_name")
    private String displayName;

    @SerializedName("employee_id")
    private String employeeId;

    @SerializedName("email")
    private String email;

    @SerializedName("department")
    private String department;

    @SerializedName("team")
    private String team;

    @SerializedName("height_cm")
    private double heightCm;

    @SerializedName("weight_kg")
    private double weightKg;

    @SerializedName("bmi")
    private double bmi;

    @SerializedName("blood_group")
    private String bloodGroup;

    @SerializedName("shift_type")
    private String shiftType;

    @SerializedName("shift_start_time")
    private String shiftStartTime;

    @SerializedName("shift_end_time")
    private String shiftEndTime;

    @SerializedName("reminder_window_1")
    private String reminderWindow1;

    @SerializedName("reminder_window_2")
    private String reminderWindow2;

    @SerializedName("reminder_frequency")
    private String reminderFrequency;

    @SerializedName("role")
    private String role;

    @SerializedName("status")
    private String status;

    @SerializedName("consent_accepted")
    private boolean consentAccepted;

    @SerializedName("consent_date")
    private String consentDate;

    @SerializedName("onboarding_complete")
    private boolean onboardingComplete;

    @SerializedName("current_streak")
    private int currentStreak;

    @SerializedName("longest_streak")
    private int longestStreak;

    @SerializedName("created_at")
    private String createdAt;

    @SerializedName("updated_at")
    private String updatedAt;

    public Participant() {}

    // ── Getters ──────────────────────────────────────────────────────────────────

    public String getId() { return id; }
    public String getAuthUserId() { return authUserId; }
    public String getDisplayName() { return displayName; }
    public String getEmployeeId() { return employeeId; }
    public String getEmail() { return email; }
    public String getDepartment() { return department; }
    public String getTeam() { return team; }
    public double getHeightCm() { return heightCm; }
    public double getWeightKg() { return weightKg; }
    public double getBmi() { return bmi; }
    public String getBloodGroup() { return bloodGroup; }
    public String getShiftType() { return shiftType; }
    public String getShiftStartTime() { return shiftStartTime; }
    public String getShiftEndTime() { return shiftEndTime; }
    public String getReminderWindow1() { return reminderWindow1; }
    public String getReminderWindow2() { return reminderWindow2; }
    public String getReminderFrequency() { return reminderFrequency; }
    public String getRole() { return role; }
    public String getStatus() { return status; }
    public boolean isConsentAccepted() { return consentAccepted; }
    public String getConsentDate() { return consentDate; }
    public boolean isOnboardingComplete() { return onboardingComplete; }
    public int getCurrentStreak() { return currentStreak; }
    public int getLongestStreak() { return longestStreak; }
    public String getCreatedAt() { return createdAt; }
    public String getUpdatedAt() { return updatedAt; }

    // ── Setters ──────────────────────────────────────────────────────────────────

    public void setId(String id) { this.id = id; }
    public void setAuthUserId(String authUserId) { this.authUserId = authUserId; }
    public void setDisplayName(String displayName) { this.displayName = displayName; }
    public void setEmployeeId(String employeeId) { this.employeeId = employeeId; }
    public void setEmail(String email) { this.email = email; }
    public void setDepartment(String department) { this.department = department; }
    public void setTeam(String team) { this.team = team; }
    public void setHeightCm(double heightCm) { this.heightCm = heightCm; }
    public void setWeightKg(double weightKg) { this.weightKg = weightKg; }
    public void setBmi(double bmi) { this.bmi = bmi; }
    public void setBloodGroup(String bloodGroup) { this.bloodGroup = bloodGroup; }
    public void setShiftType(String shiftType) { this.shiftType = shiftType; }
    public void setShiftStartTime(String shiftStartTime) { this.shiftStartTime = shiftStartTime; }
    public void setShiftEndTime(String shiftEndTime) { this.shiftEndTime = shiftEndTime; }
    public void setReminderWindow1(String reminderWindow1) { this.reminderWindow1 = reminderWindow1; }
    public void setReminderWindow2(String reminderWindow2) { this.reminderWindow2 = reminderWindow2; }
    public void setReminderFrequency(String reminderFrequency) { this.reminderFrequency = reminderFrequency; }
    public void setRole(String role) { this.role = role; }
    public void setStatus(String status) { this.status = status; }
    public void setConsentAccepted(boolean consentAccepted) { this.consentAccepted = consentAccepted; }
    public void setConsentDate(String consentDate) { this.consentDate = consentDate; }
    public void setOnboardingComplete(boolean onboardingComplete) { this.onboardingComplete = onboardingComplete; }
    public void setCurrentStreak(int currentStreak) { this.currentStreak = currentStreak; }
    public void setLongestStreak(int longestStreak) { this.longestStreak = longestStreak; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }

    /**
     * Computes BMI from stored height and weight if not already set by server.
     */
    public double computeBmi() {
        if (heightCm > 0 && weightKg > 0) {
            double heightM = heightCm / 100.0;
            return weightKg / (heightM * heightM);
        }
        return 0;
    }
}
