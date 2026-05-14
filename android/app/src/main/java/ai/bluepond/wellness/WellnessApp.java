package ai.bluepond.wellness;

import android.app.Application;
import android.util.Log;

import androidx.work.Constraints;
import androidx.work.ExistingPeriodicWorkPolicy;
import androidx.work.NetworkType;
import androidx.work.PeriodicWorkRequest;
import androidx.work.WorkManager;

import java.util.concurrent.TimeUnit;

import ai.bluepond.wellness.data.api.SupabaseClient;
import ai.bluepond.wellness.utils.SessionManager;

public class WellnessApp extends Application {

    private static final String TAG = "WellnessApp";
    private static WellnessApp instance;

    private SupabaseClient supabaseClient;
    private SessionManager sessionManager;

    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;
        Log.d(TAG, "WellnessApp initializing");

        sessionManager = new SessionManager(this);
        supabaseClient = SupabaseClient.getInstance(this);

        initWorkManager();
    }

    private void initWorkManager() {
        try {
            Constraints constraints = new Constraints.Builder()
                    .setRequiredNetworkType(NetworkType.CONNECTED)
                    .build();

            PeriodicWorkRequest reminderSyncWork = new PeriodicWorkRequest.Builder(
                    ReminderSyncWorker.class,
                    15, TimeUnit.MINUTES)
                    .setConstraints(constraints)
                    .addTag("reminder_sync")
                    .build();

            WorkManager.getInstance(this).enqueueUniquePeriodicWork(
                    "reminder_sync",
                    ExistingPeriodicWorkPolicy.KEEP,
                    reminderSyncWork);

            Log.d(TAG, "WorkManager initialized for reminders");
        } catch (Exception e) {
            Log.e(TAG, "WorkManager initialization failed", e);
        }
    }

    public static WellnessApp getInstance() {
        return instance;
    }

    public SupabaseClient getSupabaseClient() {
        return supabaseClient;
    }

    public SessionManager getSessionManager() {
        return sessionManager;
    }
}
