package ai.bluepond.wellness;

import android.content.Intent;
import android.os.Bundle;
import android.view.MenuItem;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.navigation.NavController;
import androidx.navigation.fragment.NavHostFragment;
import androidx.navigation.ui.AppBarConfiguration;
import androidx.navigation.ui.NavigationUI;

import com.google.android.material.bottomnavigation.BottomNavigationView;

import ai.bluepond.wellness.auth.LoginActivity;
import ai.bluepond.wellness.utils.SessionManager;

public class MainActivity extends AppCompatActivity {

    private NavController navController;
    private SessionManager sessionManager;

    // Top-level destination fragment IDs (back press exits app from these)
    private AppBarConfiguration appBarConfiguration;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Check authentication before inflating any UI
        sessionManager = ((WellnessApp) getApplication()).getSessionManager();
        if (!sessionManager.isLoggedIn()) {
            redirectToLogin();
            return;
        }

        setContentView(R.layout.activity_main);

        setupNavigation();
    }

    private void setupNavigation() {
        NavHostFragment navHostFragment = (NavHostFragment)
                getSupportFragmentManager().findFragmentById(R.id.nav_host_fragment);

        if (navHostFragment == null) return;

        navController = navHostFragment.getNavController();

        BottomNavigationView bottomNav = findViewById(R.id.bottomNavigationView);
        if (bottomNav == null) return;

        // Define top-level destinations for proper back-stack behavior
        appBarConfiguration = new AppBarConfiguration.Builder(
                R.id.homeFragment,
                R.id.logFragment,
                R.id.progressFragment,
                R.id.leaderboardFragment,
                R.id.profileFragment)
                .build();

        NavigationUI.setupWithNavController(bottomNav, navController);

        // "More" overflow item navigates to InfoFragment
        bottomNav.setOnItemSelectedListener(item -> {
            int itemId = item.getItemId();
            if (itemId == R.id.nav_info) {
                navController.navigate(R.id.infoFragment);
                return true;
            }
            return NavigationUI.onNavDestinationSelected(item, navController)
                    || onNavItemSelected(item);
        });
    }

    private boolean onNavItemSelected(MenuItem item) {
        return NavigationUI.onNavDestinationSelected(item, navController);
    }

    @Override
    public void onBackPressed() {
        // On root fragments, show exit confirmation dialog
        if (isAtRootDestination()) {
            showExitConfirmationDialog();
        } else {
            super.onBackPressed();
        }
    }

    private boolean isAtRootDestination() {
        if (navController == null) return false;
        int currentDestId = navController.getCurrentDestination() != null
                ? navController.getCurrentDestination().getId() : -1;
        return currentDestId == R.id.homeFragment
                || currentDestId == R.id.logFragment
                || currentDestId == R.id.progressFragment
                || currentDestId == R.id.leaderboardFragment
                || currentDestId == R.id.profileFragment;
    }

    private void showExitConfirmationDialog() {
        new AlertDialog.Builder(this)
                .setTitle("Exit BluePond Wellness")
                .setMessage("Are you sure you want to exit the app?")
                .setPositiveButton("Exit", (dialog, which) -> finishAffinity())
                .setNegativeButton("Cancel", null)
                .show();
    }

    private void redirectToLogin() {
        Intent intent = new Intent(this, LoginActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);
        finish();
    }

    @Override
    public boolean onSupportNavigateUp() {
        return NavigationUI.navigateUp(navController, appBarConfiguration)
                || super.onSupportNavigateUp();
    }
}
