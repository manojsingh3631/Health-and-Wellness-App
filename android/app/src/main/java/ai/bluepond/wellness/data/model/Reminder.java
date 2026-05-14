package ai.bluepond.wellness.data.model;

import com.google.gson.annotations.SerializedName;

public class Reminder {

    @SerializedName("id")
    private String id;

    @SerializedName("participant_id")
    private String participantId;

    @SerializedName("reminder_type")
    private String reminderType;

    @SerializedName("reminder_time")
    private String reminderTime; // HH:mm format

    @SerializedName("frequency_type")
    private String frequencyType; // daily, weekly, etc.

    @SerializedName("is_enabled")
    private boolean isEnabled;

    @SerializedName("last_sent_at")
    private String lastSentAt;

    @SerializedName("created_at")
    private String createdAt;

    @SerializedName("updated_at")
    private String updatedAt;

    public Reminder() {}

    // ── Getters ──────────────────────────────────────────────────────────────────

    public String getId() { return id; }
    public String getParticipantId() { return participantId; }
    public String getReminderType() { return reminderType; }
    public String getReminderTime() { return reminderTime; }
    public String getFrequencyType() { return frequencyType; }
    public boolean isEnabled() { return isEnabled; }
    public String getLastSentAt() { return lastSentAt; }
    public String getCreatedAt() { return createdAt; }
    public String getUpdatedAt() { return updatedAt; }

    // ── Setters ──────────────────────────────────────────────────────────────────

    public void setId(String id) { this.id = id; }
    public void setParticipantId(String participantId) { this.participantId = participantId; }
    public void setReminderType(String reminderType) { this.reminderType = reminderType; }
    public void setReminderTime(String reminderTime) { this.reminderTime = reminderTime; }
    public void setFrequencyType(String frequencyType) { this.frequencyType = frequencyType; }
    public void setEnabled(boolean enabled) { isEnabled = enabled; }
    public void setLastSentAt(String lastSentAt) { this.lastSentAt = lastSentAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }
}
