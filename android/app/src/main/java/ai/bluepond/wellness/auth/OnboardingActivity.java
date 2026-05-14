package ai.bluepond.wellness.auth;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import androidx.appcompat.app.AppCompatActivity;
import androidx.viewpager2.widget.ViewPager2;

import com.google.android.material.button.MaterialButton;
import com.google.android.material.tabs.TabLayout;
import com.google.android.material.tabs.TabLayoutMediator;

import ai.bluepond.wellness.MainActivity;
import ai.bluepond.wellness.R;
import ai.bluepond.wellness.utils.SessionManager;

/**
 * First-run onboarding shown after the participant's initial login.
 * Presents a 3-page ViewPager2 explaining the challenge, scoring, and
 * shift-aware logging. On completion, sets the onboarding-seen flag and
 * navigates to MainActivity.
 */
public class OnboardingActivity extends AppCompatActivity {

    private ViewPager2 viewPager;
    private MaterialButton btnNext;
    private MaterialButton btnSkip;
    private TabLayout tabIndicator;

    private static final int PAGE_COUNT = 3;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_onboarding);

        viewPager    = findViewById(R.id.viewPagerOnboarding);
        btnNext      = findViewById(R.id.btnOnboardingNext);
        btnSkip      = findViewById(R.id.btnOnboardingSkip);
        tabIndicator = findViewById(R.id.tabOnboardingIndicator);

        viewPager.setAdapter(new OnboardingPagerAdapter(this));

        new TabLayoutMediator(tabIndicator, viewPager, (tab, position) -> { }).attach();

        viewPager.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
            @Override
            public void onPageSelected(int position) {
                if (position == PAGE_COUNT - 1) {
                    btnNext.setText(R.string.onboarding_get_started);
                    btnSkip.setVisibility(View.GONE);
                } else {
                    btnNext.setText(R.string.onboarding_next);
                    btnSkip.setVisibility(View.VISIBLE);
                }
            }
        });

        btnNext.setOnClickListener(v -> {
            int current = viewPager.getCurrentItem();
            if (current < PAGE_COUNT - 1) {
                viewPager.setCurrentItem(current + 1);
            } else {
                finishOnboarding();
            }
        });

        btnSkip.setOnClickListener(v -> finishOnboarding());
    }

    private void finishOnboarding() {
        SessionManager.getInstance(this).setOnboardingSeen(true);
        startActivity(new Intent(this, MainActivity.class));
        finish();
    }
}
