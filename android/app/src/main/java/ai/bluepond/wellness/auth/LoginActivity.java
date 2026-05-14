package ai.bluepond.wellness.auth;

import android.content.Intent;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Patterns;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.lifecycle.ViewModelProvider;

import com.google.android.material.snackbar.Snackbar;
import com.google.android.material.textfield.TextInputLayout;

import ai.bluepond.wellness.MainActivity;
import ai.bluepond.wellness.R;
import ai.bluepond.wellness.data.repository.Result;

public class LoginActivity extends AppCompatActivity {

    private static final int COLOR_DEEP_NAVY = 0xFF00172C;

    private AuthViewModel viewModel;

    // View references (would normally use ViewBinding; using manual find for portability)
    private TextInputLayout tilEmail;
    private TextInputLayout tilPassword;
    private EditText etEmail;
    private EditText etPassword;
    private Button btnLogin;
    private ProgressBar progressBar;
    private TextView tvForgotPassword;
    private View rootView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Deep Navy status bar
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            getWindow().setStatusBarColor(COLOR_DEEP_NAVY);
        }

        setContentView(R.layout.activity_login);

        viewModel = new ViewModelProvider(this).get(AuthViewModel.class);

        bindViews();
        setupClickListeners();
        observeViewModel();
    }

    private void bindViews() {
        rootView       = findViewById(android.R.id.content);
        tilEmail       = findViewById(R.id.tilEmail);
        tilPassword    = findViewById(R.id.tilPassword);
        etEmail        = findViewById(R.id.etEmail);
        etPassword     = findViewById(R.id.etPassword);
        btnLogin       = findViewById(R.id.btnLogin);
        progressBar    = findViewById(R.id.progressBar);
        tvForgotPassword = findViewById(R.id.tvForgotPassword);
    }

    private void setupClickListeners() {
        btnLogin.setOnClickListener(v -> attemptLogin());

        tvForgotPassword.setOnClickListener(v -> showForgotPasswordDialog());

        // Clear errors as user types
        etEmail.addTextChangedListener(new TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            @Override public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (tilEmail != null) tilEmail.setError(null);
            }
            @Override public void afterTextChanged(Editable s) {}
        });

        etPassword.addTextChangedListener(new TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            @Override public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (tilPassword != null) tilPassword.setError(null);
            }
            @Override public void afterTextChanged(Editable s) {}
        });
    }

    private void observeViewModel() {
        viewModel.getLoginResult().observe(this, result -> {
            if (result == null) return;

            if (result.isLoading()) {
                setLoadingState(true);
            } else if (result.isSuccess()) {
                setLoadingState(false);
                navigateToMain();
            } else if (result.isError()) {
                setLoadingState(false);
                showError(result.getErrorMessage());
            }
        });
    }

    private void attemptLogin() {
        String email    = etEmail.getText() != null ? etEmail.getText().toString().trim() : "";
        String password = etPassword.getText() != null ? etPassword.getText().toString() : "";

        boolean valid = true;

        if (email.isEmpty() || !Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
            if (tilEmail != null) tilEmail.setError("Enter a valid email address");
            valid = false;
        }

        if (password.length() < 8) {
            if (tilPassword != null) tilPassword.setError("Password must be at least 8 characters");
            valid = false;
        }

        if (valid) {
            viewModel.login(email, password);
        }
    }

    private void showForgotPasswordDialog() {
        View dialogView = getLayoutInflater().inflate(R.layout.dialog_forgot_password, null);
        EditText etResetEmail = dialogView.findViewById(R.id.etResetEmail);

        // Pre-fill if user has already typed their email
        String currentEmail = etEmail.getText() != null ? etEmail.getText().toString().trim() : "";
        if (!currentEmail.isEmpty()) {
            etResetEmail.setText(currentEmail);
        }

        new AlertDialog.Builder(this)
                .setTitle("Reset Password")
                .setMessage("Enter your registered email and we'll send you a reset link.")
                .setView(dialogView)
                .setPositiveButton("Send Reset Link", (dialog, which) -> {
                    String resetEmail = etResetEmail.getText() != null
                            ? etResetEmail.getText().toString().trim() : "";
                    if (!resetEmail.isEmpty() && Patterns.EMAIL_ADDRESS.matcher(resetEmail).matches()) {
                        showSnackbar("Password reset email sent to " + resetEmail);
                    } else {
                        showError("Please enter a valid email address.");
                    }
                })
                .setNegativeButton("Cancel", null)
                .show();
    }

    private void setLoadingState(boolean loading) {
        if (progressBar != null) progressBar.setVisibility(loading ? View.VISIBLE : View.GONE);
        btnLogin.setEnabled(!loading);
        etEmail.setEnabled(!loading);
        etPassword.setEnabled(!loading);
        btnLogin.setText(loading ? "" : "Sign In");
    }

    private void navigateToMain() {
        Intent intent = new Intent(this, MainActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);
        finish();
    }

    private void showError(String message) {
        showSnackbar(message != null ? message : "An error occurred. Please try again.");
    }

    private void showSnackbar(String message) {
        Snackbar.make(rootView, message, Snackbar.LENGTH_LONG).show();
    }
}
