package ai.bluepond.wellness.ui.log;

import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.fragment.NavHostFragment;

import com.google.android.material.snackbar.Snackbar;

import ai.bluepond.wellness.R;
import ai.bluepond.wellness.data.model.ActivityLog;
import ai.bluepond.wellness.data.model.Challenge;

public class LogFragment extends Fragment {

    private LogViewModel viewModel;

    private EditText etSteps;
    private EditText etWater;
    private EditText etYoga;
    private EditText etWorkout;
    private Button btnSugarYes;
    private Button btnSugarNo;
    private TextView tvEstimatedPoints;
    private TextView tvEditWarning;
    private Button btnSubmit;
    private ProgressBar progressBar;
    private View rootView;
    private TextView tvDate;

    private boolean sugarFree = false;
    private boolean isEditMode = false;
    private ActivityLog existingLog = null;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_log, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        rootView = view;
        viewModel = new ViewModelProvider(this).get(LogViewModel.class);

        bindViews(view);
        setupSugarToggle();
        setupTextWatchers();
        observeViewModel();

        viewModel.loadData();
    }

    private void bindViews(View view) {
        etSteps           = view.findViewById(R.id.etSteps);
        etWater           = view.findViewById(R.id.etWater);
        etYoga            = view.findViewById(R.id.etYoga);
        etWorkout         = view.findViewById(R.id.etWorkout);
        btnSugarYes       = view.findViewById(R.id.btnSugarYes);
        btnSugarNo        = view.findViewById(R.id.btnSugarNo);
        tvEstimatedPoints = view.findViewById(R.id.tvEstimatedPoints);
        tvEditWarning     = view.findViewById(R.id.tvEditWarning);
        btnSubmit         = view.findViewById(R.id.btnSubmit);
        progressBar       = view.findViewById(R.id.progressBar);
        tvDate            = view.findViewById(R.id.tvDate);

        btnSubmit.setOnClickListener(v -> handleSubmit());
    }

    private void setupSugarToggle() {
        if (btnSugarYes == null || btnSugarNo == null) return;

        btnSugarNo.setSelected(true); // default: no sugar-free
        setSugarFree(false);

        btnSugarYes.setOnClickListener(v -> setSugarFree(true));
        btnSugarNo.setOnClickListener(v -> setSugarFree(false));
    }

    private void setSugarFree(boolean value) {
        sugarFree = value;
        if (btnSugarYes != null) btnSugarYes.setSelected(value);
        if (btnSugarNo != null)  btnSugarNo.setSelected(!value);
        triggerPointsRecalculation();
    }

    private void setupTextWatchers() {
        TextWatcher watcher = new TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int i, int i1, int i2) {}
            @Override public void onTextChanged(CharSequence s, int i, int i1, int i2) {
                triggerPointsRecalculation();
            }
            @Override public void afterTextChanged(Editable s) {}
        };

        if (etSteps != null)   etSteps.addTextChangedListener(watcher);
        if (etWater != null)   etWater.addTextChangedListener(watcher);
        if (etYoga != null)    etYoga.addTextChangedListener(watcher);
        if (etWorkout != null) etWorkout.addTextChangedListener(watcher);
    }

    private void triggerPointsRecalculation() {
        viewModel.recalculateEstimatedPoints(
                safeParseInt(etSteps, 0),
                safeParseDouble(etWater, 0.0),
                safeParseInt(etYoga, 0),
                safeParseInt(etWorkout, 0),
                sugarFree
        );
    }

    private void observeViewModel() {
        viewModel.getExistingLog().observe(getViewLifecycleOwner(), result -> {
            if (result != null && result.isSuccess()) {
                existingLog = result.getData();
                if (existingLog != null) {
                    populateExistingLog(existingLog);
                }
            }
        });

        viewModel.getActiveChallenge().observe(getViewLifecycleOwner(), result -> {
            if (result != null && result.isSuccess() && result.getData() != null) {
                Challenge challenge = result.getData();
                toggleActivityFields(challenge);
            }
        });

        viewModel.getEstimatedPoints().observe(getViewLifecycleOwner(), points -> {
            if (tvEstimatedPoints != null) {
                tvEstimatedPoints.setText(String.format("Estimated: %.1f pts", points));
            }
        });

        viewModel.getSubmitResult().observe(getViewLifecycleOwner(), result -> {
            if (result == null) return;
            setLoadingState(false);
            if (result.isLoading()) {
                setLoadingState(true);
            } else if (result.isSuccess() && result.getData() != null) {
                double pts = result.getData().getPointsEarned();
                showSnackbar(String.format("Log submitted +%.1f pts", pts));
                NavHostFragment.findNavController(this)
                        .navigate(R.id.action_logFragment_to_homeFragment);
            } else if (result.isError()) {
                showSnackbar(result.getErrorMessage());
            }
        });
    }

    private void populateExistingLog(ActivityLog log) {
        isEditMode = true;

        if (etSteps != null)   etSteps.setText(String.valueOf(log.getStepsCount()));
        if (etWater != null)   etWater.setText(String.valueOf(log.getWaterIntakeLiters()));
        if (etYoga != null)    etYoga.setText(String.valueOf(log.getYogaMinutes()));
        if (etWorkout != null) etWorkout.setText(String.valueOf(log.getWorkoutMinutes()));
        setSugarFree(log.isNoAddedSugarDay());

        if (log.getEditCount() >= 1) {
            // Edit limit reached
            if (tvEditWarning != null) {
                tvEditWarning.setVisibility(View.VISIBLE);
                tvEditWarning.setText("1 edit used — cannot resubmit today");
            }
            setInputsEnabled(false);
            if (btnSubmit != null) btnSubmit.setEnabled(false);
        } else if (log.getEditCount() == 0) {
            // Can still edit once
            if (tvEditWarning != null) {
                tvEditWarning.setVisibility(View.VISIBLE);
                tvEditWarning.setText("You have 1 edit remaining for today");
            }
            if (btnSubmit != null) btnSubmit.setText("Update Log");
        }
    }

    private void toggleActivityFields(Challenge challenge) {
        setFieldVisible(etSteps,   challenge.isIncludeSteps());
        setFieldVisible(etWater,   challenge.isIncludeWater());
        setFieldVisible(etYoga,    challenge.isIncludeYoga());
        setFieldVisible(etWorkout, challenge.isIncludeWorkout());
        View sugarRow = rootView.findViewById(R.id.rowSugarFree);
        if (sugarRow != null) {
            sugarRow.setVisibility(challenge.isIncludeSugarFree() ? View.VISIBLE : View.GONE);
        }
    }

    private void setFieldVisible(View field, boolean visible) {
        if (field != null) {
            View parent = (View) field.getParent();
            if (parent != null) parent.setVisibility(visible ? View.VISIBLE : View.GONE);
            else field.setVisibility(visible ? View.VISIBLE : View.GONE);
        }
    }

    private void handleSubmit() {
        if (!validateInputs()) return;

        ActivityLog log = new ActivityLog();
        log.setStepsCount(safeParseInt(etSteps, 0));
        log.setWaterIntakeLiters(safeParseDouble(etWater, 0.0));
        log.setYogaMinutes(safeParseInt(etYoga, 0));
        log.setWorkoutMinutes(safeParseInt(etWorkout, 0));
        log.setNoAddedSugarDay(sugarFree);

        if (isEditMode && existingLog != null) {
            log.setId(existingLog.getId());
            log.setParticipantId(existingLog.getParticipantId());
            log.setChallengeId(existingLog.getChallengeId());
            log.setActivityDate(existingLog.getActivityDate());
            log.setEditCount(existingLog.getEditCount());
            viewModel.updateLog(log);
        } else {
            viewModel.submitLog(log);
        }
    }

    private boolean validateInputs() {
        int steps = safeParseInt(etSteps, -1);
        if (steps > 50000) {
            showSnackbar("Steps cannot exceed 50,000");
            return false;
        }
        double water = safeParseDouble(etWater, -1);
        if (water > 10.0) {
            showSnackbar("Water intake cannot exceed 10 litres");
            return false;
        }
        return true;
    }

    private void setLoadingState(boolean loading) {
        if (progressBar != null) progressBar.setVisibility(loading ? View.VISIBLE : View.GONE);
        if (btnSubmit != null)   btnSubmit.setEnabled(!loading);
    }

    private void setInputsEnabled(boolean enabled) {
        if (etSteps != null)   etSteps.setEnabled(enabled);
        if (etWater != null)   etWater.setEnabled(enabled);
        if (etYoga != null)    etYoga.setEnabled(enabled);
        if (etWorkout != null) etWorkout.setEnabled(enabled);
        if (btnSugarYes != null) btnSugarYes.setEnabled(enabled);
        if (btnSugarNo != null)  btnSugarNo.setEnabled(enabled);
    }

    private void showSnackbar(String message) {
        Snackbar.make(rootView, message != null ? message : "An error occurred.",
                Snackbar.LENGTH_LONG).show();
    }

    private int safeParseInt(EditText et, int fallback) {
        if (et == null || et.getText() == null || et.getText().toString().trim().isEmpty())
            return fallback;
        try { return Integer.parseInt(et.getText().toString().trim()); }
        catch (NumberFormatException e) { return fallback; }
    }

    private double safeParseDouble(EditText et, double fallback) {
        if (et == null || et.getText() == null || et.getText().toString().trim().isEmpty())
            return fallback;
        try { return Double.parseDouble(et.getText().toString().trim()); }
        catch (NumberFormatException e) { return fallback; }
    }
}
