package ai.bluepond.wellness.data.model;

import com.google.gson.annotations.SerializedName;

public class AppConfig {

    @SerializedName("id")
    private String id;

    @SerializedName("config_key")
    private String configKey;

    @SerializedName("config_value")
    private String configValue;

    @SerializedName("description")
    private String description;

    public AppConfig() {}

    // ── Getters ──────────────────────────────────────────────────────────────────

    public String getId() { return id; }
    public String getConfigKey() { return configKey; }
    public String getConfigValue() { return configValue; }
    public String getDescription() { return description; }

    // ── Setters ──────────────────────────────────────────────────────────────────

    public void setId(String id) { this.id = id; }
    public void setConfigKey(String configKey) { this.configKey = configKey; }
    public void setConfigValue(String configValue) { this.configValue = configValue; }
    public void setDescription(String description) { this.description = description; }
}
