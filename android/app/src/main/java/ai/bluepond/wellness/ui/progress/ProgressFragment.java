package ai.bluepond.wellness.ui.progress;

import android.graphics.Color;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.github.mikephil.charting.charts.BarChart;
import com.github.mikephil.charting.components.XAxis;
import com.github.mikephil.charting.data.BarData;
import com.github.mikephil.charting.data.BarDataSet;
import com.github.mikephil.charting.data.BarEntry;
import com.github.mikephil.charting.formatter.IndexAxisValueFormatter;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.TextStyle;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import ai.bluepond.wellness.R;
import ai.bluepond.wellness.WellnessApp;
import ai.bluepond.wellness.data.model.ActivityLog;
import ai.bluepond.wellness.data.model.Challenge;
import ai.bluepond.wellness.data.model.Participant;
import ai.bluepond.wellness.data.repository.Result;
import ai.bluepond.wellness.data.repository.WellnessRepository;
import ai.bluepond.wellness.utils.SessionManager;

public class ProgressFragment extends Fragment {

    private static final int COLOR_ACCENT_BLUE = 0xFF005CFF;
    private static final int COLOR_DEEP_NAVY   = 0xFF00172C;

    private WellnessRepository repository;
    private SessionManager sessionManager;

    // Points summary
    private TextView tvPointsToday;
    private TextView tvPointsWeek;
    private TextView tvPointsTotal;

    // Streak card
    private TextView tvCurrentStreak;
    private TextView tvBestStreak;

    // Activity progress bars
    private ProgressBar pbSteps;
    private ProgressBar pbWater;
    private ProgressBar pbYoga;
    private ProgressBar pbWorkout;
    private TextView tvStepsAvg;
    private TextView tvWaterAvg;
    private TextView tvYogaAvg;
    private TextView tvWorkoutAvg;

    // Chart
    private BarChart barChart;

    // Recent logs list
    private RecyclerView rvRecentLogs;
    private RecentLogsAdapter logsAdapter;

    // Loading
    private ProgressBar mainProgressBar;
    private TextView tvEmpty;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_progress, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        WellnessApp app = (WellnessApp) requireActivity().getApplication();
        repository = new WellnessRepository(
                app.getSupabaseClient().getApiService(), app.getSessionManager());
        sessionManager = app.getSessionManager();

        bindViews(view);
        setupChart();
        setupRecyclerView();
        loadData();
    }

    private void bindViews(View view) {
        tvPointsToday   = view.findViewById(R.id.tvPointsToday);
        tvPointsWeek    = view.findViewById(R.id.tvPointsWeek);
        tvPointsTotal   = view.findViewById(R.id.tvPointsTotal);
        tvCurrentStreak = view.findViewById(R.id.tvCurrentStreak);
        tvBestStreak    = view.findViewById(R.id.tvBestStreak);
        pbSteps         = view.findViewById(R.id.pbSteps);
        pbWater         = view.findViewById(R.id.pbWater);
        pbYoga          = view.findViewById(R.id.pbYoga);
        pbWorkout       = view.findViewById(R.id.pbWorkout);
        tvStepsAvg      = view.findViewById(R.id.tvStepsAvg);
        tvWaterAvg      = view.findViewById(R.id.tvWaterAvg);
        tvYogaAvg       = view.findViewById(R.id.tvYogaAvg);
        tvWorkoutAvg    = view.findViewById(R.id.tvWorkoutAvg);
        barChart        = view.findViewById(R.id.barChart);
        rvRecentLogs    = view.findViewById(R.id.rvRecentLogs);
        mainProgressBar = view.findViewById(R.id.progressBar);
        tvEmpty         = view.findViewById(R.id.tvEmpty);
    }

    private void setupChart() {
        if (barChart == null) return;
        barChart.getDescription().setEnabled(false);
        barChart.setDrawGridBackground(false);
        barChart.setFitBars(true);
        barChart.getAxisRight().setEnabled(false);
        barChart.getAxisLeft().setTextColor(Color.WHITE);
        barChart.getXAxis().setTextColor(Color.WHITE);
        barChart.getXAxis().setPosition(XAxis.XAxisPosition.BOTTOM);
        barChart.getLegend().setEnabled(false);
        barChart.setNoDataText("No activity data yet");
        barChart.setNoDataTextColor(Color.LTGRAY);
    }

    private void setupRecyclerView() {
        logsAdapter = new RecentLogsAdapter(new ArrayList<>());
        if (rvRecentLogs != null) {
            rvRecentLogs.setLayoutManager(new LinearLayoutManager(requireContext()));
            rvRecentLogs.setAdapter(logsAdapter);
            rvRecentLogs.setNestedScrollingEnabled(false);
        }
    }

    private void loadData() {
        // Load profile for streak data
        repository.getMyProfile().observe(getViewLifecycleOwner(), result -> {
            if (result != null && result.isSuccess() && result.getData() != null) {
                bindStreakCard(result.getData());
            }
        });

        // Load challenge then logs
        if (mainProgressBar != null) mainProgressBar.setVisibility(View.VISIBLE);
        repository.getActiveChallenge().observe(getViewLifecycleOwner(), result -> {
            if (result != null && result.isSuccess() && result.getData() != null) {
                loadLogs(result.getData().getId());
            } else {
                if (mainProgressBar != null) mainProgressBar.setVisibility(View.GONE);
                if (tvEmpty != null) {
                    tvEmpty.setVisibility(View.VISIBLE);
                    tvEmpty.setText("No active challenge.");
                }
            }
        });
    }

    private void loadLogs(String challengeId) {
        repository.getMyActivityLogs(challengeId).observe(getViewLifecycleOwner(), result -> {
            if (mainProgressBar != null) mainProgressBar.setVisibility(View.GONE);
            if (result != null && result.isSuccess() && result.getData() != null) {
                List<ActivityLog> logs = result.getData();
                bindPointsSummary(logs);
                bindActivityBreakdown(logs);
                updateWeeklyChart(logs);
                bindRecentLogs(logs);
            }
        });
    }

    private void bindStreakCard(Participant p) {
        if (tvCurrentStreak != null)
            tvCurrentStreak.setText(p.getCurrentStreak() + " days");
        if (tvBestStreak != null)
            tvBestStreak.setText("Best: " + p.getLongestStreak() + " days");
    }

    private void bindPointsSummary(List<ActivityLog> logs) {
        LocalDate today = LocalDate.now();
        LocalDate weekStart = today.minusDays(today.getDayOfWeek().getValue() - 1);

        double todayPts = 0, weekPts = 0, totalPts = 0;
        for (ActivityLog log : logs) {
            if (log.isVoided()) continue;
            double pts = log.getPointsEarned();
            totalPts += pts;
            try {
                LocalDate logDate = LocalDate.parse(log.getActivityDate());
                if (logDate.equals(today))                       todayPts += pts;
                if (!logDate.isBefore(weekStart))                weekPts  += pts;
            } catch (Exception ignored) {}
        }
        if (tvPointsToday != null) tvPointsToday.setText(String.format("%.1f", todayPts));
        if (tvPointsWeek != null)  tvPointsWeek.setText(String.format("%.1f", weekPts));
        if (tvPointsTotal != null) tvPointsTotal.setText(String.format("%.1f", totalPts));
    }

    private void bindActivityBreakdown(List<ActivityLog> logs) {
        if (logs.isEmpty()) return;
        long count = 0;
        double totalSteps = 0, totalWater = 0, totalYoga = 0, totalWorkout = 0;
        for (ActivityLog log : logs) {
            if (log.isVoided()) continue;
            totalSteps   += log.getStepsCount();
            totalWater   += log.getWaterIntakeLiters();
            totalYoga    += log.getYogaMinutes();
            totalWorkout += log.getWorkoutMinutes();
            count++;
        }
        if (count == 0) return;

        double avgSteps   = totalSteps   / count;
        double avgWater   = totalWater   / count;
        double avgYoga    = totalYoga    / count;
        double avgWorkout = totalWorkout / count;

        if (tvStepsAvg != null)   tvStepsAvg.setText(String.format("Avg: %.0f", avgSteps));
        if (tvWaterAvg != null)   tvWaterAvg.setText(String.format("Avg: %.1fL", avgWater));
        if (tvYogaAvg != null)    tvYogaAvg.setText(String.format("Avg: %.0f min", avgYoga));
        if (tvWorkoutAvg != null) tvWorkoutAvg.setText(String.format("Avg: %.0f min", avgWorkout));

        // Progress bars relative to common daily targets
        setProgressBar(pbSteps,   (int) Math.min(100, (avgSteps   / 10000) * 100));
        setProgressBar(pbWater,   (int) Math.min(100, (avgWater   / 3.0)   * 100));
        setProgressBar(pbYoga,    (int) Math.min(100, (avgYoga    / 30.0)  * 100));
        setProgressBar(pbWorkout, (int) Math.min(100, (avgWorkout / 45.0)  * 100));
    }

    private void setProgressBar(ProgressBar pb, int progress) {
        if (pb != null) { pb.setMax(100); pb.setProgress(progress); }
    }

    private void updateWeeklyChart(List<ActivityLog> logs) {
        if (barChart == null) return;
        LocalDate today = LocalDate.now();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        String[] labels = new String[7];
        float[] points  = new float[7];

        for (int i = 6; i >= 0; i--) {
            LocalDate day = today.minusDays(i);
            labels[6 - i] = day.getDayOfWeek()
                    .getDisplayName(TextStyle.SHORT, Locale.getDefault());
            String dateStr = day.format(fmt);
            for (ActivityLog log : logs) {
                if (dateStr.equals(log.getActivityDate()) && !log.isVoided()) {
                    points[6 - i] = (float) log.getPointsEarned();
                    break;
                }
            }
        }

        List<BarEntry> entries = new ArrayList<>();
        for (int i = 0; i < 7; i++) entries.add(new BarEntry(i, points[i]));

        BarDataSet ds = new BarDataSet(entries, "Points");
        ds.setColor(COLOR_ACCENT_BLUE);
        ds.setValueTextColor(Color.WHITE);
        BarData data = new BarData(ds);
        data.setBarWidth(0.7f);

        barChart.getXAxis().setValueFormatter(new IndexAxisValueFormatter(labels));
        barChart.getXAxis().setGranularity(1f);
        barChart.setData(data);
        barChart.invalidate();
    }

    private void bindRecentLogs(List<ActivityLog> logs) {
        // Show most recent 7 logs
        List<ActivityLog> recent = logs.size() > 7 ? logs.subList(0, 7) : logs;
        logsAdapter.updateData(recent);
    }

    // ── Recent Logs Adapter ───────────────────────────────────────────────────────

    static class RecentLogsAdapter extends RecyclerView.Adapter<RecentLogsAdapter.VH> {
        private List<ActivityLog> data;

        RecentLogsAdapter(List<ActivityLog> data) { this.data = data; }

        void updateData(List<ActivityLog> newData) {
            this.data = newData;
            notifyDataSetChanged();
        }

        @NonNull
        @Override
        public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View v = LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.item_activity_log, parent, false);
            return new VH(v);
        }

        @Override
        public void onBindViewHolder(@NonNull VH holder, int position) {
            ActivityLog log = data.get(position);
            holder.tvDate.setText(log.getActivityDate() != null ? log.getActivityDate() : "–");
            holder.tvPoints.setText(String.format("%.1f pts", log.getPointsEarned()));
            holder.tvSummary.setText(String.format(
                    "%d steps  •  %.1fL  •  %dmin yoga  •  %dmin workout",
                    log.getStepsCount(),
                    log.getWaterIntakeLiters(),
                    log.getYogaMinutes(),
                    log.getWorkoutMinutes()));
        }

        @Override
        public int getItemCount() { return data == null ? 0 : data.size(); }

        static class VH extends RecyclerView.ViewHolder {
            final TextView tvDate;
            final TextView tvPoints;
            final TextView tvSummary;

            VH(View itemView) {
                super(itemView);
                tvDate    = itemView.findViewById(R.id.tvDate);
                tvPoints  = itemView.findViewById(R.id.tvPoints);
                tvSummary = itemView.findViewById(R.id.tvSummary);
            }
        }
    }
}
