package ai.bluepond.wellness.auth;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import ai.bluepond.wellness.R;

/**
 * Single page in the onboarding flow.
 * Receives its page index as an argument and shows the appropriate
 * title, body, and illustration.
 */
public class OnboardingPageFragment extends Fragment {

    private static final String ARG_PAGE = "page";

    private static final int[][] PAGE_CONTENT = {
        // {titleRes, bodyRes, imageRes}
        {R.string.onboarding_title_1, R.string.onboarding_body_1, R.drawable.ic_onboarding_challenge},
        {R.string.onboarding_title_2, R.string.onboarding_body_2, R.drawable.ic_onboarding_scoring},
        {R.string.onboarding_title_3, R.string.onboarding_body_3, R.drawable.ic_onboarding_shift},
    };

    public static OnboardingPageFragment newInstance(int page) {
        OnboardingPageFragment fragment = new OnboardingPageFragment();
        Bundle args = new Bundle();
        args.putInt(ARG_PAGE, page);
        fragment.setArguments(args);
        return fragment;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_onboarding_page, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        int page = requireArguments().getInt(ARG_PAGE, 0);

        ((ImageView) view.findViewById(R.id.imgOnboarding)).setImageResource(PAGE_CONTENT[page][2]);
        ((TextView)  view.findViewById(R.id.tvOnboardingTitle)).setText(PAGE_CONTENT[page][0]);
        ((TextView)  view.findViewById(R.id.tvOnboardingBody)).setText(PAGE_CONTENT[page][1]);
    }
}
