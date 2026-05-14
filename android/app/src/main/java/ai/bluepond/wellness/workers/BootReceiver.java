package ai.bluepond.wellness.workers;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import androidx.work.ExistingPeriodicWorkPolicy;
import androidx.work.PeriodicWorkRequest;
import androidx.work.WorkManager;

import java.util.concurrent.TimeUnit;

/**
 * Re-schedules the periodic reminder sync after device reboot.
 * WorkManager's PeriodicWorkRequest is normally persisted across reboots
 * automatically from API 23+, but an explicit BootReceiver ensures
 * the work is re-enqueued even after a force-stop or clear-data event.
 */
public class BootReceiver extends BroadcastReceiver {

    private static final String WORK_TAG = "reminder_sync";

    @Override
    public void onReceive(Context context, Intent intent) {
        if (!Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) return;

        PeriodicWorkRequest syncRequest =
                new PeriodicWorkRequest.Builder(ReminderSyncWorker.class, 15, TimeUnit.MINUTES)
                        .addTag(WORK_TAG)
                        .build();

        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                WORK_TAG,
                ExistingPeriodicWorkPolicy.KEEP,
                syncRequest
        );
    }
}
