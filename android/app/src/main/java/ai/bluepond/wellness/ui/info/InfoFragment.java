package ai.bluepond.wellness.ui.info;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.tabs.TabLayout;

import java.util.ArrayList;
import java.util.List;

import ai.bluepond.wellness.R;
import ai.bluepond.wellness.WellnessApp;
import ai.bluepond.wellness.data.model.Faq;
import ai.bluepond.wellness.data.model.Participant;
import ai.bluepond.wellness.data.repository.WellnessRepository;

public class InfoFragment extends Fragment {

    private WellnessRepository repository;

    private TabLayout tabLayout;
    private View tabFaqs;
    private View tabRules;
    private View tabPrivacy;
    private View tabConsent;

    private RecyclerView rvFaqs;
    private FaqAdapter faqAdapter;
    private ProgressBar progressBar;

    // Consent section
    private TextView tvConsentStatus;
    private TextView tvConsentDate;
    private TextView tvConsentEmail;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_info, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        WellnessApp app = (WellnessApp) requireActivity().getApplication();
        repository = new WellnessRepository(
                app.getSupabaseClient().getApiService(), app.getSessionManager());

        bindViews(view);
        setupTabs();
        loadFaqs();
        loadConsentData();
    }

    private void bindViews(View view) {
        tabLayout     = view.findViewById(R.id.tabLayout);
        tabFaqs       = view.findViewById(R.id.tabContentFaqs);
        tabRules      = view.findViewById(R.id.tabContentRules);
        tabPrivacy    = view.findViewById(R.id.tabContentPrivacy);
        tabConsent    = view.findViewById(R.id.tabContentConsent);
        rvFaqs        = view.findViewById(R.id.rvFaqs);
        progressBar   = view.findViewById(R.id.progressBar);
        tvConsentStatus = view.findViewById(R.id.tvConsentStatus);
        tvConsentDate   = view.findViewById(R.id.tvConsentDate);
        tvConsentEmail  = view.findViewById(R.id.tvConsentEmail);
    }

    private void setupTabs() {
        if (tabLayout == null) return;

        String[] tabTitles = {"FAQs", "Challenge Rules", "Privacy", "Consent"};
        for (String title : tabTitles) {
            tabLayout.addTab(tabLayout.newTab().setText(title));
        }

        showTab(0);

        tabLayout.addOnTabSelectedListener(new TabLayout.OnTabSelectedListener() {
            @Override
            public void onTabSelected(TabLayout.Tab tab) {
                showTab(tab.getPosition());
            }
            @Override public void onTabUnselected(TabLayout.Tab tab) {}
            @Override public void onTabReselected(TabLayout.Tab tab) {}
        });

        // Setup RecyclerView for FAQs
        faqAdapter = new FaqAdapter(new ArrayList<>());
        if (rvFaqs != null) {
            rvFaqs.setLayoutManager(new LinearLayoutManager(requireContext()));
            rvFaqs.setAdapter(faqAdapter);
        }
    }

    private void showTab(int position) {
        setTabVisible(tabFaqs,    position == 0);
        setTabVisible(tabRules,   position == 1);
        setTabVisible(tabPrivacy, position == 2);
        setTabVisible(tabConsent, position == 3);
    }

    private void setTabVisible(View tab, boolean visible) {
        if (tab != null) tab.setVisibility(visible ? View.VISIBLE : View.GONE);
    }

    private void loadFaqs() {
        if (progressBar != null) progressBar.setVisibility(View.VISIBLE);

        repository.getFaqs().observe(getViewLifecycleOwner(), result -> {
            if (progressBar != null) progressBar.setVisibility(View.GONE);
            if (result != null && result.isSuccess() && result.getData() != null) {
                faqAdapter.updateData(result.getData());
            }
        });
    }

    private void loadConsentData() {
        repository.getMyProfile().observe(getViewLifecycleOwner(), result -> {
            if (result != null && result.isSuccess() && result.getData() != null) {
                Participant p = result.getData();
                if (tvConsentStatus != null) {
                    tvConsentStatus.setText(p.isConsentAccepted()
                            ? "Consent Accepted" : "Consent Not Provided");
                    tvConsentStatus.setTextColor(p.isConsentAccepted()
                            ? 0xFF4CAF50 : 0xFFF44336);
                }
                if (tvConsentDate != null) {
                    tvConsentDate.setText(p.getConsentDate() != null
                            ? "Date: " + p.getConsentDate() : "Date: N/A");
                }
                if (tvConsentEmail != null) {
                    tvConsentEmail.setText(p.getEmail() != null ? p.getEmail() : "");
                }
            }
        });
    }

    // ── FAQ Adapter (Accordion/Expandable) ────────────────────────────────────────

    static class FaqAdapter extends RecyclerView.Adapter<FaqAdapter.VH> {
        private List<Faq> data;
        private final List<Boolean> expanded;

        FaqAdapter(List<Faq> data) {
            this.data = data;
            this.expanded = new ArrayList<>();
        }

        void updateData(List<Faq> newData) {
            this.data = newData;
            this.expanded.clear();
            for (int i = 0; i < newData.size(); i++) this.expanded.add(false);
            notifyDataSetChanged();
        }

        @NonNull
        @Override
        public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View v = LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.item_faq, parent, false);
            return new VH(v);
        }

        @Override
        public void onBindViewHolder(@NonNull VH holder, int position) {
            Faq faq = data.get(position);
            boolean isExpanded = expanded.get(position);

            holder.tvQuestion.setText(faq.getQuestion() != null ? faq.getQuestion() : "");
            holder.tvAnswer.setText(faq.getAnswer() != null ? faq.getAnswer() : "");
            holder.tvAnswer.setVisibility(isExpanded ? View.VISIBLE : View.GONE);
            holder.tvIndicator.setText(isExpanded ? "▲" : "▼");

            holder.itemView.setOnClickListener(v -> {
                int pos = holder.getAdapterPosition();
                if (pos == RecyclerView.NO_ID) return;
                boolean nowExpanded = !expanded.get(pos);
                expanded.set(pos, nowExpanded);
                notifyItemChanged(pos);
            });
        }

        @Override
        public int getItemCount() { return data == null ? 0 : data.size(); }

        static class VH extends RecyclerView.ViewHolder {
            final TextView tvQuestion;
            final TextView tvAnswer;
            final TextView tvIndicator;

            VH(View itemView) {
                super(itemView);
                tvQuestion  = itemView.findViewById(R.id.tvQuestion);
                tvAnswer    = itemView.findViewById(R.id.tvAnswer);
                tvIndicator = itemView.findViewById(R.id.tvIndicator);
            }
        }
    }
}
