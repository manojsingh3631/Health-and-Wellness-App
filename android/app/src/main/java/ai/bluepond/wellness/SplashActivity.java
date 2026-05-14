package ai.bluepond.wellness;

import android.content.Intent;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.view.WindowManager;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.AnimationSet;
import android.view.animation.ScaleAnimation;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import ai.bluepond.wellness.auth.LoginActivity;
import ai.bluepond.wellness.utils.SessionManager;

public class SplashActivity extends AppCompatActivity {

    private static final long SPLASH_DURATION_MS = 1500;
    private static final int COLOR_DEEP_NAVY = 0xFF00172C;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Full-screen Deep Navy background
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            getWindow().setStatusBarColor(COLOR_DEEP_NAVY);
            getWindow().setNavigationBarColor(COLOR_DEEP_NAVY);
        }

        // Hide system UI for immersive splash
        View decorView = getWindow().getDecorView();
        decorView.setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_FULLSCREEN
                        | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                        | View.SYSTEM_UI_FLAG_IMMERSIVE);

        setContentView(R.layout.activity_splash);

        // Animate logo
        animateLogo();

        // Navigate after delay
        new Handler(Looper.getMainLooper()).postDelayed(
                this::navigateToNextScreen, SPLASH_DURATION_MS);
    }

    private void animateLogo() {
        ImageView ivLogo = findViewById(R.id.ivSplashLogo);
        TextView tvTagline = findViewById(R.id.tvSplashTagline);

        if (ivLogo != null) {
            // Fade-in + scale-up animation for logo
            AlphaAnimation fadeIn = new AlphaAnimation(0f, 1f);
            fadeIn.setDuration(800);
            fadeIn.setFillAfter(true);

            ScaleAnimation scaleUp = new ScaleAnimation(
                    0.8f, 1f, 0.8f, 1f,
                    Animation.RELATIVE_TO_SELF, 0.5f,
                    Animation.RELATIVE_TO_SELF, 0.5f);
            scaleUp.setDuration(800);
            scaleUp.setFillAfter(true);

            AnimationSet animSet = new AnimationSet(true);
            animSet.addAnimation(fadeIn);
            animSet.addAnimation(scaleUp);
            ivLogo.startAnimation(animSet);
        }

        if (tvTagline != null) {
            AlphaAnimation fadeInText = new AlphaAnimation(0f, 1f);
            fadeInText.setDuration(600);
            fadeInText.setStartOffset(500);
            fadeInText.setFillAfter(true);
            tvTagline.startAnimation(fadeInText);
        }
    }

    private void navigateToNextScreen() {
        if (isFinishing() || isDestroyed()) return;

        SessionManager sessionManager = ((WellnessApp) getApplication()).getSessionManager();

        Class<?> targetActivity = sessionManager.isLoggedIn()
                ? MainActivity.class
                : LoginActivity.class;

        Intent intent = new Intent(this, targetActivity);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);
        finish();
    }
}
