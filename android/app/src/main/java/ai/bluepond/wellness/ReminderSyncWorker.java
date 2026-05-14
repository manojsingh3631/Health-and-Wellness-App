package ai.bluepond.wellness;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.work.Worker;
import androidx.work.WorkerParameters;

public class ReminderSyncWorker extends Worker {

    private static final String TAG = "ReminderSyncWorker";

    public ReminderSyncWorker(@NonNull Context context, @NonNull WorkerParameters workerParams) {
        super(context, workerParams);
    }

    @NonNull
    @Override
    public Result doWork() {
        Log.d(TAG, "ReminderSyncWorker running");
        try {
            // Sync reminders from server and schedule local notifications
            // This is triggered by WorkManager on a 15-minute interval
            return Result.success();
        } catch (Exception e) {
            Log.e(TAG, "ReminderSyncWorker failed", e);
            return Result.retry();
        }
    }
}
