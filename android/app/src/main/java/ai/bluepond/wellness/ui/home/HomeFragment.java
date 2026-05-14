package ai.bluepond.wellness.ui.home;

import android.graphics.Color;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.cardview.widget.CardView;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.fragment.NavHostFragment;

import com.github.mikephil.charting.charts.BarChart;
import com.github.mikephil.charting.components.XAxis;
import com.github.mikephil.charting.data.BarData;
import com.github.mikephil.charting.data.BarDataSet;
import com.github.mikephil.charting.data.BarEntry;
import com.github.mikephil.charting.formatter.IndexAxisValueFormatter;

import java.util.ArrayList;
import java.util.List;

import ai.bluepond.wellness.R;
import ai.bluepond.wellness.data.model.ActivityLog;
import ai.bluepond.wellness.data.model.Challenge;
import ai.bluepond.wellness.data.model.LeaderboardEntry;
import ai.bluepond.wellness.data.model.Participant;
import ai.bluepond.wellness.data.repository.Result;

public class HomeFragment extends Fragment {

    private static final int COLOR_DEEP_NAVY   = 0xFF00172C;
    private static final int COLOR_ACCENT_BLUE = 0xFF005CFF;

    private HomeViewModel viewModel;

    // Header
    private TextView tvGreeting;
    private TextView tvParticipantName;

    // Challenge card
    private CardView cardChallenge;
    private TextView tvChallengeName;
    private TextView tvChallengeDaysLeft;
    private ProgressBar pbChallengeProgress;
    private TextView tvTotalPoints;

    // Activity summary tiles
    private TextView tvStepsValue;
    private TextView tvWaterValue;
    private TextView tvYogaValue;
    private TextView tvWorkoutValue;
    private TextView tvSugarFreeValue;
    private CardView cardSteps;
    private CardView cardWater;
    private CardView cardYoga;
    private CardView cardWorkout;
    private CardView cardSugarFree;

    // Streak
    private TextView tvStreakCount;
    private TextView tvStreakLabel;

    // Leaderboard rank
    private TextView tvMyRank;
    private TextView tvBtnViewBoard;

    // Chart
    private BarChart barChart;

    // Empty state
    private TextView tvNoChallenge;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_home, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        viewModel = new ViewModelProvider(this).get(HomeViewModel.class);

        bindViews(view);
        setupChart();
        setupActivityCardClicks();
        observeViewModel();

        viewModel.refreshAll();
    }

    private void bindViews(View view) {
        tvGreeting         = view.findViewById(R.id.tvGreeting);
        tvParticipantName  = view.findViewById(R.id.tvParticipantName);
        cardChallenge      = view.findViewById(R.id.cardChallenge);
        tvChallengeName    = view.findViewById(R.id.tvChallengeName);
        tvChallengeDaysLeft = view.findViewById(R.id.tvChallengeDaysLeft);
        pbChallengeProgress = view.findViewById(R.id.pbChallengeProgress);
        tvTotalPoints      = view.findViewById(R.id.tvTotalPoints);
        tvStepsValue       = view.findViewById(R.id.tvStepsValue);
        tvWaterValue       = view.findViewById(R.id.tvWaterValue);
        tvYogaValue        = view.findViewById(R.id.tvYogaValue);
        tvWorkoutValue     = view.findViewById(R.id.tvWorkoutValue);
        tvSugarFreeValue   = view.findViewById(R.id.tvSugarFreeValue);
        cardSteps          = view.findViewById(R.id.cardSteps);
        cardWater          = view.findViewById(R.id.cardWater);
        cardYoga           = view.findViewById(R.id.cardYoga);
        cardWorkout        = view.findViewById(R.id.cardWorkout);
        cardSugarFree      = view.findViewById(R.id.cardSugarFree);
        tvStreakCount      = view.findViewById(R.id.tvStreakCount);
        tvStreakLabel      = view.findViewById(R.id.tvStreakLabel);
        tvMyRank           = view.findViewById(R.id.tvMyRank);
        tvBtnViewBoard     = view.findViewById(R.id.tvBtnViewBoard);
        barChart           = view.findViewById(R.id.barChart);
        tvNoChallenge      = view.findViewById(R.id.tvNoChallenge);
    }

    private void setupActivityCardClicks() {
        View.OnClickListener openLog = v ->
                NavHostFragment.findNavController(this)
                        .navigate(R.id.action_homeFragment_to_logFragment);

        if (cardSteps != null)     cardSteps.setOnClickListener(openLog);
        if (cardWater != null)     cardWater.setOnClickListener(openLog);
        if (cardYoga != null)      cardYoga.setOnClickListener(openLog);
        if (cardWorkout != null)   cardWorkout.setOnClickListener(openLog);
        if (cardSugarFree != null) cardSugarFree.setOnClickListener(openLog);

        if (tvBtnViewBoard != null) {
            tvBtnViewBoard.setOnClickListener(v ->
                    NavHostFragment.findNavController(this)
                            .navigate(R.id.action_homeFragment_to_leaderboardFragment));
        }
    }

    private void observeViewModel() {
        viewModel.getMyProfile().observe(getViewLifecycleOwner(), result -> {
            if (result != null && result.isSuccess() && result.getData() != null) {
                bindProfile(result.getData());
            }
        });

        viewModel.getActiveChallenge().observe(getViewLifecycleOwner(), result -> {
            if (result == null) return;
            if (result.isSuccess() && result.getData() != null) {
                bindChallenge(result.getData());
                if (tvNoChallenge != null) tvNoChallenge.setVisibility(View.GONE);
                if (cardChallenge != null) cardChallenge.setVisibility(View.VISIBLE);
            } else if (result.isError()) {
                if (tvNoChallenge != null) {
                    tvNoChallenge.setVisibility(View.VISIBLE);
                    tvNoChallenge.setText("No active challenge at the moment.");
                }
                if (cardChallenge != null) cardChallenge.setVisibility(View.GONE);
            }
        });

        viewModel.getTodayLog().observe(getViewLifecycleOwner(), result -> {
            if (result != null && result.isSuccess()) {
                bindTodayLog(result.getData()); // may be null = not logged
            } else {
                resetActivityTiles();
            }
        });

        viewModel.getLeaderboard().observe(getViewLifecycleOwner(), result -> {
            if (result != null && result.isSuccess() && result.getData() != null) {
                int rank = viewModel.getMyRank(result.getData());
                if (tvMyRank != null) {
                    tvMyRank.setText(rank > 0 ? "#" + rank : "–");
                }
            }
        });

        viewModel.getRecentLogs().observe(getViewLifecycleOwner(), result -> {
            if (result != null && result.isSuccess() && result.getData() != null) {
                updateWeeklyChart(result.getData());
            }
        });
    }

    private void bindProfile(Participant participant) {
        String greeting = viewModel.getShiftAwareGreeting(participant);
        String name = participant.getDisplayName() != null
                ? participant.getDisplayName() : "there";

        if (tvGreeting != null)        tvGreeting.setText(greeting + ",");
        if (tvParticipantName != null) tvParticipantName.setText(name);
        if (tvStreakCount != null)     tvStreakCount.setText(String.valueOf(participant.getCurrentStreak()));
        if (tvStreakLabel != null) {
            int streak = participant.getCurrentStreak();
            tvStreakLabel.setText(streak == 1 ? "day streak" : "day streak");
        }
    }

    private void bindChallenge(Challenge challenge) {
        if (tvChallengeName != null)    tvChallengeName.setText(challenge.getTitle());
        int daysLeft = viewModel.getDaysRemaining(challenge);
        if (tvChallengeDaysLeft != null) {
            tvChallengeDaysLeft.setText(daysLeft + (daysLeft == 1 ? " day left" : " days left"));
        }

        // Progress bar: days elapsed / total days
        if (pbChallengeProgress != null && challenge.getStartDate() != null
                && challenge.getEndDate() != null) {
            try {
                java.time.LocalDate start = java.time.LocalDate.parse(challenge.getStartDate());
                java.time.LocalDate end   = java.time.LocalDate.parse(challenge.getEndDate());
                java.time.LocalDate today = java.time.LocalDate.now();
                long total   = java.time.temporal.ChronoUnit.DAYS.between(start, end);
                long elapsed = java.time.temporal.ChronoUnit.DAYS.between(start, today);
                if (total > 0) {
                    int progress = (int) Math.min(100, Math.max(0, (elapsed * 100) / total));
                    pbChallengeProgress.setMax(100);
                    pbChallengeProgress.setProgress(progress);
                }
            } catch (Exception ignored) {}
        }
    }

    private void bindTodayLog(@Nullable ActivityLog log) {
        if (log == null) {
            resetActivityTiles();
            return;
        }

        if (tvStepsValue != null)    tvStepsValue.setText(String.valueOf(log.getStepsCount()));
        if (tvWaterValue != null)    tvWaterValue.setText(String.format("%.1fL", log.getWaterIntakeLiters()));
        if (tvYogaValue != null)     tvYogaValue.setText(log.getYogaMinutes() + " min");
        if (tvWorkoutValue != null)  tvWorkoutValue.setText(log.getWorkoutMinutes() + " min");
        if (tvSugarFreeValue != null) tvSugarFreeValue.setText(log.isNoAddedSugarDay() ? "Yes" : "No");
        if (tvTotalPoints != null)   tvTotalPoints.setText(String.format("%.1f pts", log.getPointsEarned()));
    }

    private void resetActivityTiles() {
        if (tvStepsValue != null)    tvStepsValue.setText("Log");
        if (tvWaterValue != null)    tvWaterValue.setText("Log");
        if (tvYogaValue != null)     tvYogaValue.setText("Log");
        if (tvWorkoutValue != null)  tvWorkoutValue.setText("Log");
        if (tvSugarFreeValue != null) tvSugarFreeValue.setText("Log");
        if (tvTotalPoints != null)   tvTotalPoints.setText("0 pts");
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
        barChart.setNoDataText("Log activities to see your weekly chart");
        barChart.setNoDataTextColor(Color.LTGRAY);
    }

    private void updateWeeklyChart(List<ActivityLog> logs) {
        if (barChart == null) return;

        // Build last 7 days of data
        java.time.LocalDate today = java.time.LocalDate.now();
        String[] labels = new String[7];
        float[] points  = new float[7];

        for (int i = 6; i >= 0; i--) {
            java.time.LocalDate day = today.minusDays(i);
            labels[6 - i] = day.getDayOfWeek().getDisplayName(
                    java.time.format.TextStyle.SHORT, java.util.Locale.getDefault());
            String dateStr = day.format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            for (ActivityLog log : logs) {
                if (dateStr.equals(log.getActivityDate()) && !log.isVoided()) {
                    points[6 - i] = (float) log.getPointsEarned();
                    break;
                }
            }
        }

        List<BarEntry> entries = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            entries.add(new BarEntry(i, points[i]));
        }

        BarDataSet dataSet = new BarDataSet(entries, "Points");
        dataSet.setColor(COLOR_ACCENT_BLUE);
        dataSet.setValueTextColor(Color.WHITE);

        BarData barData = new BarData(dataSet);
        barData.setBarWidth(0.7f);

        barChart.getXAxis().setValueFormatter(new IndexAxisValueFormatter(labels));
        barChart.getXAxis().setGranularity(1f);
        barChart.setData(barData);
        barChart.invalidate();
    }
}
