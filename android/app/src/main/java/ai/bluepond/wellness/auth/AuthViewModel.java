package ai.bluepond.wellness.auth;

import android.app.Application;

import androidx.annotation.NonNull;
import androidx.lifecycle.AndroidViewModel;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import ai.bluepond.wellness.WellnessApp;
import ai.bluepond.wellness.data.repository.AuthRepository;
import ai.bluepond.wellness.data.repository.Result;
import ai.bluepond.wellness.data.model.Participant;

public class AuthViewModel extends AndroidViewModel {

    private final AuthRepository authRepository;

    private final MutableLiveData<Result<Participant>> loginResult = new MutableLiveData<>();
    private final MutableLiveData<Result<Boolean>> logoutResult = new MutableLiveData<>();

    public AuthViewModel(@NonNull Application application) {
        super(application);
        WellnessApp app = (WellnessApp) application;
        authRepository = new AuthRepository(
                app.getSupabaseClient().getApiService(),
                app.getSessionManager());
    }

    public LiveData<Result<Participant>> getLoginResult() {
        return loginResult;
    }

    public LiveData<Result<Boolean>> getLogoutResult() {
        return logoutResult;
    }

    public void login(String email, String password) {
        authRepository.login(email, password).observeForever(result -> {
            loginResult.postValue(result);
        });
    }

    public void logout() {
        authRepository.logout().observeForever(result -> {
            logoutResult.postValue(result);
        });
    }

    public boolean isLoggedIn() {
        return authRepository.isLoggedIn();
    }

    public Participant getCurrentParticipant() {
        return authRepository.getCurrentParticipant();
    }
}
