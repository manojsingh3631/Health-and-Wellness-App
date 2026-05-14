package ai.bluepond.wellness.ui.leaderboard;

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
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.google.android.material.chip.Chip;
import com.google.android.material.chip.ChipGroup;

import java.util.ArrayList;
import java.util.List;

import ai.bluepond.wellness.R;
import ai.bluepond.wellness.WellnessApp;
import ai.bluepond.wellness.data.model.Challenge;
import ai.bluepond.wellness.data.model.LeaderboardEntry;
import ai.bluepond.wellness.data.repository.Result;
import ai.bluepond.wellness.data.repository.WellnessRepository;
import ai.bluepond.wellness.utils.SessionManager;

public class LeaderboardFragment extends Fragment {

    private static final int COLOR_ACCENT_BLUE = 0xFF005CFF;
    private static final int COLOR_GOLD        = 0xFFFFD700;
    private static final int COLOR_SILVER      = 0xFFC0C0C0;
    private static final int COLOR_BRONZE      = 0xFFCD7F32;

    private static final String TYPE_OVERALL = "overall";
    private static final String TYPE_WEEKLY  = "weekly";
    private static final String TYPE_TEAM    = "team";
    private static final String TYPE_PERIOD  = "period";

    private WellnessRepository repository;
    private SessionManager sessionManager;

    private RecyclerView recyclerView;
    private LeaderboardAdapter adapter;
    private ProgressBar progressBar;
    private TextView tvEmpty;
    private TextView tvMyRankPinned;
    private SwipeRefreshLayout swipeRefresh;
    private ChipGroup chipGroup;

    private String currentType = TYPE_OVERALL;
    private String currentChallengeId = null;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_leaderboard, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        WellnessApp app = (WellnessApp) requireActivity().getApplication();
        repository = new WellnessRepository(
                app.getSupabaseClient().getApiService(), app.getSessionManager());
        sessionManager = app.getSessionManager();

        bindViews(view);
        setupRecyclerView();
        setupChips();
        loadChallengeThenLeaderboard();
    }

    private void bindViews(View view) {
        recyclerView   = view.findViewById(R.id.recyclerLeaderboard);
        progressBar    = view.findViewById(R.id.progressBar);
        tvEmpty        = view.findViewById(R.id.tvEmpty);
        tvMyRankPinned = view.findViewById(R.id.tvMyRankPinned);
        swipeRefresh   = view.findViewById(R.id.swipeRefresh);
        chipGroup      = view.findViewById(R.id.chipGroupType);

        if (swipeRefresh != null) {
            swipeRefresh.setColorSchemeColors(COLOR_ACCENT_BLUE);
            swipeRefresh.setOnRefreshListener(() -> {
                if (currentChallengeId != null) loadLeaderboard(currentChallengeId, currentType);
            });
        }
    }

    private void setupRecyclerView() {
        adapter = new LeaderboardAdapter(new ArrayList<>(), sessionManager.getParticipantId());
        if (recyclerView != null) {
            recyclerView.setLayoutManager(new LinearLayoutManager(requireContext()));
            recyclerView.setAdapter(adapter);
            recyclerView.addItemDecoration(
                    new DividerItemDecoration(requireContext(), DividerItemDecoration.VERTICAL));
        }
    }

    private void setupChips() {
        if (chipGroup == null) return;

        String[] types  = {TYPE_OVERALL, TYPE_WEEKLY, TYPE_PERIOD, TYPE_TEAM};
        String[] labels = {"Overall", "Weekly", "Period", "Team"};

        for (int i = 0; i < types.length; i++) {
            Chip chip = new Chip(requireContext());
            chip.setText(labels[i]);
            chip.setCheckable(true);
            chip.setChecked(i == 0);
            final String type = types[i];
            chip.setOnClickListener(v -> {
                currentType = type;
                if (currentChallengeId != null) loadLeaderboard(currentChallengeId, type);
            });
            chipGroup.addView(chip);
        }
    }

    private void loadChallengeThenLeaderboard() {
        repository.getActiveChallenge().observe(getViewLifecycleOwner(), result -> {
            if (result != null && result.isSuccess() && result.getData() != null) {
                currentChallengeId = result.getData().getId();
                loadLeaderboard(currentChallengeId, currentType);
            } else if (result != null && result.isError()) {
                showEmpty("No active challenge found.");
            }
        });
    }

    private void loadLeaderboard(String challengeId, String type) {
        if (progressBar != null) progressBar.setVisibility(View.VISIBLE);
        if (tvEmpty != null)     tvEmpty.setVisibility(View.GONE);

        repository.getLeaderboard(challengeId, type).observe(getViewLifecycleOwner(), result -> {
            if (progressBar != null) progressBar.setVisibility(View.GONE);
            if (swipeRefresh != null) swipeRefresh.setRefreshing(false);

            if (result != null && result.isSuccess() && result.getData() != null) {
                List<LeaderboardEntry> entries = result.getData();
                adapter.updateData(entries);

                // Pin my rank if outside top 10
                String myId = sessionManager.getParticipantId();
                LeaderboardEntry myEntry = null;
                for (LeaderboardEntry e : entries) {
                    if (myId != null && myId.equals(e.getParticipantId())) {
                        myEntry = e;
                        break;
                    }
                }
                if (myEntry != null && myEntry.getRank() > 10 && tvMyRankPinned != null) {
                    tvMyRankPinned.setVisibility(View.VISIBLE);
                    tvMyRankPinned.setText(String.format(
                            "Your rank: #%d  •  %.1f pts",
                            myEntry.getRank(), myEntry.getTotalPoints()));
                } else if (tvMyRankPinned != null) {
                    tvMyRankPinned.setVisibility(View.GONE);
                }

                if (entries.isEmpty()) showEmpty("No leaderboard data yet.");
            } else if (result != null && result.isError()) {
                showEmpty(result.getErrorMessage());
            }
        });
    }

    private void showEmpty(String msg) {
        if (tvEmpty != null) {
            tvEmpty.setVisibility(View.VISIBLE);
            tvEmpty.setText(msg);
        }
        adapter.updateData(new ArrayList<>());
    }

    // ── Adapter ───────────────────────────────────────────────────────────────────

    static class LeaderboardAdapter extends RecyclerView.Adapter<LeaderboardAdapter.VH> {

        private List<LeaderboardEntry> data;
        private final String myParticipantId;

        LeaderboardAdapter(List<LeaderboardEntry> data, String myParticipantId) {
            this.data = data;
            this.myParticipantId = myParticipantId;
        }

        void updateData(List<LeaderboardEntry> newData) {
            this.data = newData;
            notifyDataSetChanged();
        }

        @NonNull
        @Override
        public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.item_leaderboard, parent, false);
            return new VH(view);
        }

        @Override
        public void onBindViewHolder(@NonNull VH holder, int position) {
            LeaderboardEntry entry = data.get(position);
            boolean isMe = myParticipantId != null
                    && myParticipantId.equals(entry.getParticipantId());

            // Rank badge color
            int rankColor;
            switch (entry.getRank()) {
                case 1: rankColor = COLOR_GOLD;   break;
                case 2: rankColor = COLOR_SILVER; break;
                case 3: rankColor = COLOR_BRONZE; break;
                default: rankColor = Color.GRAY;  break;
            }

            holder.tvRank.setText(String.valueOf(entry.getRank()));
            holder.tvRank.setTextColor(rankColor);

            holder.tvName.setText(entry.getDisplayName() != null
                    ? entry.getDisplayName() : "–");
            holder.tvPoints.setText(String.format("%.1f pts", entry.getTotalPoints()));

            if (entry.getDepartment() != null && !entry.getDepartment().isEmpty()) {
                holder.tvDept.setVisibility(View.VISIBLE);
                holder.tvDept.setText(entry.getDepartment());
            } else {
                holder.tvDept.setVisibility(View.GONE);
            }

            if (entry.isTied()) {
                holder.tvRank.setText("=" + entry.getRank());
            }

            // Highlight my own row
            holder.itemView.setBackgroundColor(
                    isMe ? 0x33005CFF : Color.TRANSPARENT); // semi-transparent accent blue
        }

        @Override
        public int getItemCount() { return data == null ? 0 : data.size(); }

        static class VH extends RecyclerView.ViewHolder {
            final TextView tvRank;
            final TextView tvName;
            final TextView tvPoints;
            final TextView tvDept;

            VH(View itemView) {
                super(itemView);
                tvRank   = itemView.findViewById(R.id.tvRank);
                tvName   = itemView.findViewById(R.id.tvName);
                tvPoints = itemView.findViewById(R.id.tvPoints);
                tvDept   = itemView.findViewById(R.id.tvDept);
            }
        }
    }
}
