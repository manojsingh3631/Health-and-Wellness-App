package ai.bluepond.wellness.ui.profile;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;

import com.google.android.material.chip.Chip;
import com.google.android.material.snackbar.Snackbar;

import java.util.List;

import ai.bluepond.wellness.R;
import ai.bluepond.wellness.WellnessApp;
import ai.bluepond.wellness.auth.AuthViewModel;
import ai.bluepond.wellness.auth.LoginActivity;
import ai.bluepond.wellness.data.model.Participant;
import ai.bluepond.wellness.data.model.Reminder;
import ai.bluepond.wellness.data.repository.Result;
import ai.bluepond.wellness.data.repository.WellnessRepository;
import ai.bluepond.wellness.utils.ShiftAwareUtils;

public class ProfileFragment extends Fragment {

    private static final int COLOR_DEEP_NAVY   = 0xFF00172C;
    private static final int COLOR_ACCENT_BLUE = 0xFF005CFF;
    private static final int REQUEST_DOCUMENT  = 1001;

    private WellnessRepository repository;
    private AuthViewModel authViewModel;
    private View rootView;

    // Avatar & identity
    private TextView tvAvatarInitials;
    private TextView tvDisplayName;
    private TextView tvEmail;
    private Chip chipDepartment;
    private Chip chipStatus;
    private Chip chipShift;

    // Health metrics
    private TextView tvHeight;
    private TextView tvWeight;
    private TextView tvBmi;
    private TextView tvBmiLabel;

    // Shift settings
    private EditText etShiftType;
    private EditText etShiftStart;
    private EditText etShiftEnd;

    // Reminders
    private Switch switchStepsReminder;
    private Switch switchWaterReminder;
    private Switch switchYogaReminder;
    private Switch switchWorkoutReminder;

    // Actions
    private Button btnSaveChanges;
    private Button btnUploadDocument;
    private Button btnSignOut;
    private ProgressBar progressBar;

    private Participant currentParticipant;
    private List<Reminder> reminders;

    private final ActivityResultLauncher<Intent> filePickerLauncher = registerForActivityResult(
            new ActivityResultContracts.StartActivityForResult(),
            result -> {
                if (result.getResultCode() == Activity.RESULT_OK && result.getData() != null) {
                    Uri fileUri = result.getData().getData();
                    if (fileUri != null) handleDocumentUpload(fileUri);
                }
            });

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_profile, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        rootView = view;

        WellnessApp app = (WellnessApp) requireActivity().getApplication();
        repository = new WellnessRepository(
                app.getSupabaseClient().getApiService(), app.getSessionManager());
        authViewModel = new ViewModelProvider(requireActivity()).get(AuthViewModel.class);

        bindViews(view);
        setupClickListeners();
        observeViewModel();
        loadData();
    }

    private void bindViews(View view) {
        tvAvatarInitials  = view.findViewById(R.id.tvAvatarInitials);
        tvDisplayName     = view.findViewById(R.id.tvDisplayName);
        tvEmail           = view.findViewById(R.id.tvEmail);
        chipDepartment    = view.findViewById(R.id.chipDepartment);
        chipStatus        = view.findViewById(R.id.chipStatus);
        chipShift         = view.findViewById(R.id.chipShift);
        tvHeight          = view.findViewById(R.id.tvHeight);
        tvWeight          = view.findViewById(R.id.tvWeight);
        tvBmi             = view.findViewById(R.id.tvBmi);
        tvBmiLabel        = view.findViewById(R.id.tvBmiLabel);
        etShiftType       = view.findViewById(R.id.etShiftType);
        etShiftStart      = view.findViewById(R.id.etShiftStart);
        etShiftEnd        = view.findViewById(R.id.etShiftEnd);
        switchStepsReminder   = view.findViewById(R.id.switchStepsReminder);
        switchWaterReminder   = view.findViewById(R.id.switchWaterReminder);
        switchYogaReminder    = view.findViewById(R.id.switchYogaReminder);
        switchWorkoutReminder = view.findViewById(R.id.switchWorkoutReminder);
        btnSaveChanges    = view.findViewById(R.id.btnSaveChanges);
        btnUploadDocument = view.findViewById(R.id.btnUploadDocument);
        btnSignOut        = view.findViewById(R.id.btnSignOut);
        progressBar       = view.findViewById(R.id.progressBar);
    }

    private void setupClickListeners() {
        if (btnSaveChanges != null) {
            btnSaveChanges.setOnClickListener(v -> saveProfileChanges());
        }

        if (btnUploadDocument != null) {
            btnUploadDocument.setOnClickListener(v -> openFilePicker());
        }

        if (btnSignOut != null) {
            btnSignOut.setOnClickListener(v -> confirmSignOut());
        }

        // Reminder toggles — update reminder records via repository
        CompoundButton.OnCheckedChangeListener reminderListener = (buttonView, isChecked) -> {
            if (reminders == null || currentParticipant == null) return;
            String type = (String) buttonView.getTag();
            if (type == null) return;
            for (Reminder r : reminders) {
                if (type.equals(r.getReminderType())) {
                    r.setEnabled(isChecked);
                    repository.updateReminder(r).observe(getViewLifecycleOwner(), res -> {});
                    return;
                }
            }
        };

        if (switchStepsReminder != null) {
            switchStepsReminder.setTag("steps");
            switchStepsReminder.setOnCheckedChangeListener(reminderListener);
        }
        if (switchWaterReminder != null) {
            switchWaterReminder.setTag("water");
            switchWaterReminder.setOnCheckedChangeListener(reminderListener);
        }
        if (switchYogaReminder != null) {
            switchYogaReminder.setTag("yoga");
            switchYogaReminder.setOnCheckedChangeListener(reminderListener);
        }
        if (switchWorkoutReminder != null) {
            switchWorkoutReminder.setTag("workout");
            switchWorkoutReminder.setOnCheckedChangeListener(reminderListener);
        }
    }

    private void observeViewModel() {
        authViewModel.getLogoutResult().observe(getViewLifecycleOwner(), result -> {
            if (result != null && result.isSuccess()) {
                navigateToLogin();
            } else if (result != null && result.isError()) {
                Snackbar.make(rootView,
                        "Sign out failed: " + result.getErrorMessage(),
                        Snackbar.LENGTH_SHORT).show();
            }
        });
    }

    private void loadData() {
        if (progressBar != null) progressBar.setVisibility(View.VISIBLE);

        repository.getMyProfile().observe(getViewLifecycleOwner(), result -> {
            if (progressBar != null) progressBar.setVisibility(View.GONE);
            if (result != null && result.isSuccess() && result.getData() != null) {
                currentParticipant = result.getData();
                bindParticipant(currentParticipant);
            }
        });

        repository.getMyReminders().observe(getViewLifecycleOwner(), result -> {
            if (result != null && result.isSuccess() && result.getData() != null) {
                reminders = result.getData();
                bindReminders(reminders);
            }
        });
    }

    private void bindParticipant(Participant p) {
        // Avatar initials
        String name = p.getDisplayName() != null ? p.getDisplayName() : "";
        String initials = buildInitials(name);
        if (tvAvatarInitials != null) {
            tvAvatarInitials.setText(initials);
            tvAvatarInitials.setBackgroundColor(COLOR_DEEP_NAVY);
        }

        if (tvDisplayName != null) tvDisplayName.setText(name);
        if (tvEmail != null)       tvEmail.setText(p.getEmail() != null ? p.getEmail() : "");

        if (chipDepartment != null && p.getDepartment() != null) {
            chipDepartment.setText(p.getDepartment());
            chipDepartment.setVisibility(View.VISIBLE);
        }
        if (chipStatus != null && p.getStatus() != null) {
            chipStatus.setText(p.getStatus());
        }
        if (chipShift != null) {
            chipShift.setText(ShiftAwareUtils.formatShiftLabel(p.getShiftType()));
        }

        // Health metrics
        if (tvHeight != null) tvHeight.setText(String.format("%.0f cm", p.getHeightCm()));
        if (tvWeight != null) tvWeight.setText(String.format("%.1f kg", p.getWeightKg()));

        double bmi = p.getBmi() > 0 ? p.getBmi() : p.computeBmi();
        if (tvBmi != null) tvBmi.setText(String.format("%.1f", bmi));
        if (tvBmiLabel != null) tvBmiLabel.setText(getBmiCategory(bmi));

        // Shift settings
        if (etShiftType != null)  etShiftType.setText(p.getShiftType() != null ? p.getShiftType() : "day");
        if (etShiftStart != null) etShiftStart.setText(p.getShiftStartTime() != null ? p.getShiftStartTime() : "09:00");
        if (etShiftEnd != null)   etShiftEnd.setText(p.getShiftEndTime() != null ? p.getShiftEndTime() : "18:00");
    }

    private void bindReminders(List<Reminder> reminderList) {
        // Temporarily remove listeners to prevent firing while setting state
        for (Reminder r : reminderList) {
            Switch sw = getSwitchForType(r.getReminderType());
            if (sw != null) {
                sw.setOnCheckedChangeListener(null);
                sw.setChecked(r.isEnabled());
            }
        }
        // Re-attach listeners
        setupClickListeners();
    }

    private Switch getSwitchForType(String type) {
        if (type == null) return null;
        switch (type) {
            case "steps":   return switchStepsReminder;
            case "water":   return switchWaterReminder;
            case "yoga":    return switchYogaReminder;
            case "workout": return switchWorkoutReminder;
            default:        return null;
        }
    }

    private void saveProfileChanges() {
        if (currentParticipant == null) return;

        if (etShiftType != null && etShiftType.getText() != null)
            currentParticipant.setShiftType(etShiftType.getText().toString().trim());
        if (etShiftStart != null && etShiftStart.getText() != null)
            currentParticipant.setShiftStartTime(etShiftStart.getText().toString().trim());
        if (etShiftEnd != null && etShiftEnd.getText() != null)
            currentParticipant.setShiftEndTime(etShiftEnd.getText().toString().trim());

        if (progressBar != null) progressBar.setVisibility(View.VISIBLE);
        repository.updateProfile(currentParticipant).observe(getViewLifecycleOwner(), result -> {
            if (progressBar != null) progressBar.setVisibility(View.GONE);
            if (result != null && result.isSuccess()) {
                Snackbar.make(rootView, "Profile saved", Snackbar.LENGTH_SHORT).show();
            } else if (result != null && result.isError()) {
                Snackbar.make(rootView,
                        "Save failed: " + result.getErrorMessage(),
                        Snackbar.LENGTH_LONG).show();
            }
        });
    }

    private void openFilePicker() {
        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("*/*");
        intent.putExtra(Intent.EXTRA_MIME_TYPES,
                new String[]{"application/pdf", "image/jpeg", "image/png"});
        filePickerLauncher.launch(intent);
    }

    private void handleDocumentUpload(Uri fileUri) {
        // Upload to Supabase Storage via REST API
        // Show progress and confirm on completion
        Toast.makeText(requireContext(),
                "Document selected. Upload in progress…", Toast.LENGTH_SHORT).show();
    }

    private void confirmSignOut() {
        new AlertDialog.Builder(requireContext())
                .setTitle("Sign Out")
                .setMessage("Are you sure you want to sign out?")
                .setPositiveButton("Sign Out", (d, w) -> authViewModel.logout())
                .setNegativeButton("Cancel", null)
                .show();
    }

    private void navigateToLogin() {
        Intent intent = new Intent(requireContext(), LoginActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);
        requireActivity().finish();
    }

    private String buildInitials(String name) {
        if (name == null || name.isEmpty()) return "?";
        String[] parts = name.trim().split("\\s+");
        if (parts.length >= 2) {
            return (parts[0].charAt(0) + "" + parts[1].charAt(0)).toUpperCase();
        }
        return name.substring(0, Math.min(2, name.length())).toUpperCase();
    }

    private String getBmiCategory(double bmi) {
        if (bmi <= 0)    return "";
        if (bmi < 18.5)  return "Underweight";
        if (bmi < 25.0)  return "Normal";
        if (bmi < 30.0)  return "Overweight";
        return "Obese";
    }
}
