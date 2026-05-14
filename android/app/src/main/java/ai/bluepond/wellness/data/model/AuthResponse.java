package ai.bluepond.wellness.data.model;

import com.google.gson.annotations.SerializedName;

public class AuthResponse {

    @SerializedName("access_token")
    private String accessToken;

    @SerializedName("token_type")
    private String tokenType;

    @SerializedName("expires_in")
    private int expiresIn;

    @SerializedName("refresh_token")
    private String refreshToken;

    @SerializedName("user")
    private User user;

    public AuthResponse() {}

    // ── Getters ──────────────────────────────────────────────────────────────────

    public String getAccessToken() { return accessToken; }
    public String getTokenType() { return tokenType; }
    public int getExpiresIn() { return expiresIn; }
    public String getRefreshToken() { return refreshToken; }
    public User getUser() { return user; }

    // ── Setters ──────────────────────────────────────────────────────────────────

    public void setAccessToken(String accessToken) { this.accessToken = accessToken; }
    public void setTokenType(String tokenType) { this.tokenType = tokenType; }
    public void setExpiresIn(int expiresIn) { this.expiresIn = expiresIn; }
    public void setRefreshToken(String refreshToken) { this.refreshToken = refreshToken; }
    public void setUser(User user) { this.user = user; }

    // ── Inner User class ──────────────────────────────────────────────────────────

    public static class User {

        @SerializedName("id")
        private String id;

        @SerializedName("email")
        private String email;

        @SerializedName("created_at")
        private String createdAt;

        public User() {}

        public String getId() { return id; }
        public String getEmail() { return email; }
        public String getCreatedAt() { return createdAt; }

        public void setId(String id) { this.id = id; }
        public void setEmail(String email) { this.email = email; }
        public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    }
}
