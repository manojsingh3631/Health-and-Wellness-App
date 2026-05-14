package ai.bluepond.wellness.data.repository;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import ai.bluepond.wellness.data.api.SupabaseService;
import ai.bluepond.wellness.data.model.AuthResponse;
import ai.bluepond.wellness.data.model.Participant;
import ai.bluepond.wellness.utils.SessionManager;
import retrofit2.Response;

public class AuthRepository {

    private static final String TAG = "AuthRepository";

    private final SupabaseService service;
    private final SessionManager sessionManager;
    private final ExecutorService executor;

    public AuthRepository(SupabaseService service, SessionManager sessionManager) {
        this.service = service;
        this.sessionManager = sessionManager;
        this.executor = Executors.newSingleThreadExecutor();
    }

    /**
     * Performs email/password login against Supabase Auth.
     * On success: saves tokens, fetches the matching Participant row, caches it.
     * Posts Result.loading() immediately, then success or error.
     */
    public LiveData<Result<Participant>> login(String email, String password) {
        MutableLiveData<Result<Participant>> liveData = new MutableLiveData<>();
        liveData.postValue(Result.loading());

        executor.execute(() -> {
            try {
                SupabaseService.LoginRequest loginRequest =
                        new SupabaseService.LoginRequest(email, password);

                Response<AuthResponse> authResp = service
                        .login("password", loginRequest)
                        .execute();

                if (!authResp.isSuccessful() || authResp.body() == null) {
                    String errMsg = parseErrorBody(authResp.errorBody());
                    liveData.postValue(Result.error(
                            errMsg != null ? errMsg : "Login failed. Please check your credentials."));
                    return;
                }

                AuthResponse authResponse = authResp.body();
                String authUserId = (authResponse.getUser() != null)
                        ? authResponse.getUser().getId() : null;

                if (authUserId == null) {
                    liveData.postValue(Result.error("Authentication error: user ID missing."));
                    return;
                }

                // Save tokens first so the next call uses them
                sessionManager.saveSession(authResponse, null);

                // Fetch participant profile
                Response<List<Participant>> participantResp = service
                        .getParticipantByAuthId("eq." + authUserId, "*")
                        .execute();

                if (!participantResp.isSuccessful() || participantResp.body() == null
                        || participantResp.body().isEmpty()) {
                    // Auth succeeded but no participant record
                    sessionManager.clearSession();
                    liveData.postValue(Result.error(
                            "Account not registered as a wellness participant. Contact HR."));
                    return;
                }

                Participant participant = participantResp.body().get(0);

                // Check participant status
                if ("inactive".equalsIgnoreCase(participant.getStatus())
                        || "suspended".equalsIgnoreCase(participant.getStatus())) {
                    sessionManager.clearSession();
                    liveData.postValue(Result.error(
                            "Your account is currently inactive. Contact your administrator."));
                    return;
                }

                sessionManager.saveSession(authResponse, participant);
                liveData.postValue(Result.success(participant));

            } catch (Exception e) {
                liveData.postValue(Result.error(
                        "Network error. Please check your connection.", e));
            }
        });

        return liveData;
    }

    /**
     * Logs out the current user. Calls Supabase logout endpoint and clears local session.
     */
    public LiveData<Result<Boolean>> logout() {
        MutableLiveData<Result<Boolean>> liveData = new MutableLiveData<>();
        liveData.postValue(Result.loading());

        executor.execute(() -> {
            try {
                // Best-effort server logout — always clear local session
                service.logout().execute();
            } catch (Exception ignored) {
                // Ignore network errors on logout
            } finally {
                sessionManager.clearSession();
                liveData.postValue(Result.success(true));
            }
        });

        return liveData;
    }

    public boolean isLoggedIn() {
        return sessionManager.isLoggedIn();
    }

    public Participant getCurrentParticipant() {
        return sessionManager.getCurrentParticipant();
    }

    // ── Helpers ───────────────────────────────────────────────────────────────────

    private String parseErrorBody(okhttp3.ResponseBody errorBody) {
        if (errorBody == null) return null;
        try {
            return errorBody.string();
        } catch (Exception e) {
            return null;
        }
    }
}
