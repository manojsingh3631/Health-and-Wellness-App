-- ============================================================
-- BluePond Wellness – Supabase Database Schema
-- Migration 001: Initial schema
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ──────────────────────────────────────────
-- TABLE: participants
-- ──────────────────────────────────────────
CREATE TABLE participants (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_user_id        UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name        TEXT NOT NULL,
    employee_id         TEXT UNIQUE NOT NULL,
    email               TEXT UNIQUE NOT NULL,
    department          TEXT,
    team                TEXT,
    height_cm           NUMERIC(5,1),
    weight_kg           NUMERIC(5,1),
    bmi                 NUMERIC(4,1) GENERATED ALWAYS AS (
                            CASE WHEN height_cm > 0
                            THEN ROUND((weight_kg / ((height_cm/100.0)*(height_cm/100.0)))::NUMERIC, 1)
                            ELSE NULL END
                        ) STORED,
    blood_group         TEXT CHECK (blood_group IN ('A+','A-','B+','B-','O+','O-','AB+','AB-')),
    shift_type          TEXT NOT NULL DEFAULT 'Day'
                            CHECK (shift_type IN ('Day','Night','Rotating','Custom')),
    shift_start_time    TIME,
    shift_end_time      TIME,
    reminder_window_1   TIME,
    reminder_window_2   TIME,
    reminder_frequency  TEXT NOT NULL DEFAULT 'Standard'
                            CHECK (reminder_frequency IN ('Standard','Reduced','Minimal')),
    role                TEXT NOT NULL DEFAULT 'Participant'
                            CHECK (role IN ('Participant','Wellness Coordinator','Org Admin','Super Admin')),
    status              TEXT NOT NULL DEFAULT 'Active'
                            CHECK (status IN ('Active','Inactive','Pending','Blocked')),
    consent_accepted    BOOLEAN NOT NULL DEFAULT FALSE,
    consent_date        TIMESTAMPTZ,
    onboarding_complete BOOLEAN NOT NULL DEFAULT FALSE,
    current_streak      INTEGER NOT NULL DEFAULT 0,
    longest_streak      INTEGER NOT NULL DEFAULT 0,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ──────────────────────────────────────────
-- TABLE: challenges
-- ──────────────────────────────────────────
CREATE TABLE challenges (
    id                          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title                       TEXT NOT NULL,
    description                 TEXT,
    start_date                  DATE NOT NULL,
    end_date                    DATE NOT NULL,
    submission_deadline_time    TIME NOT NULL DEFAULT '23:59:00',
    allow_one_edit              BOOLEAN NOT NULL DEFAULT TRUE,
    is_active                   BOOLEAN NOT NULL DEFAULT FALSE,
    include_steps               BOOLEAN NOT NULL DEFAULT TRUE,
    include_water               BOOLEAN NOT NULL DEFAULT TRUE,
    include_yoga                BOOLEAN NOT NULL DEFAULT TRUE,
    include_workout             BOOLEAN NOT NULL DEFAULT TRUE,
    include_sugar_free          BOOLEAN NOT NULL DEFAULT TRUE,
    leaderboard_display_field   TEXT NOT NULL DEFAULT 'FirstNameLastInitial'
                                    CHECK (leaderboard_display_field IN ('FirstNameLastInitial','FirstName','Anonymous')),
    show_department             BOOLEAN NOT NULL DEFAULT FALSE,
    team_leaderboard_enabled    BOOLEAN NOT NULL DEFAULT FALSE,
    tie_handling_rule           TEXT NOT NULL DEFAULT 'SharedRank'
                                    CHECK (tie_handling_rule IN ('SharedRank','EarliestSubmission')),
    created_by                  UUID REFERENCES participants(id),
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ──────────────────────────────────────────
-- TABLE: scoring_config
-- ──────────────────────────────────────────
CREATE TABLE scoring_config (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    challenge_id        UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
    activity_type       TEXT NOT NULL
                            CHECK (activity_type IN ('Steps','Water','Yoga','Workout','SugarFree')),
    points_per_unit     NUMERIC(5,2) NOT NULL DEFAULT 1,
    unit_description    TEXT,
    unit_threshold      NUMERIC(10,2) NOT NULL DEFAULT 1,
    daily_max_points    NUMERIC(5,2) NOT NULL DEFAULT 10,
    bonus_threshold     NUMERIC(10,2),
    bonus_points        NUMERIC(5,2) DEFAULT 0,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(challenge_id, activity_type)
);

-- ──────────────────────────────────────────
-- TABLE: activity_logs
-- ──────────────────────────────────────────
CREATE TABLE activity_logs (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    participant_id          UUID NOT NULL REFERENCES participants(id) ON DELETE CASCADE,
    challenge_id            UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
    activity_date           DATE NOT NULL,
    steps_count             INTEGER DEFAULT 0 CHECK (steps_count >= 0 AND steps_count <= 100000),
    water_intake_liters     NUMERIC(4,2) DEFAULT 0 CHECK (water_intake_liters >= 0 AND water_intake_liters <= 20),
    yoga_minutes            INTEGER DEFAULT 0 CHECK (yoga_minutes >= 0 AND yoga_minutes <= 1440),
    workout_minutes         INTEGER DEFAULT 0 CHECK (workout_minutes >= 0 AND workout_minutes <= 1440),
    no_added_sugar_day      BOOLEAN DEFAULT FALSE,
    points_earned           NUMERIC(7,2) NOT NULL DEFAULT 0,
    edit_count              INTEGER NOT NULL DEFAULT 0 CHECK (edit_count >= 0 AND edit_count <= 1),
    data_source             TEXT NOT NULL DEFAULT 'ManualEntry'
                                CHECK (data_source IN ('ManualEntry','AutoSync')),
    status                  TEXT NOT NULL DEFAULT 'Submitted'
                                CHECK (status IN ('Submitted','Edited','Voided')),
    is_voided               BOOLEAN NOT NULL DEFAULT FALSE,
    void_reason             TEXT,
    voided_by               UUID REFERENCES participants(id),
    submitted_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_modified_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(participant_id, challenge_id, activity_date)
);

-- ──────────────────────────────────────────
-- TABLE: leaderboard_snapshots
-- ──────────────────────────────────────────
CREATE TABLE leaderboard_snapshots (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    challenge_id        UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
    leaderboard_type    TEXT NOT NULL CHECK (leaderboard_type IN ('Weekly','Monthly','Period')),
    period_label        TEXT NOT NULL,
    period_start        DATE NOT NULL,
    period_end          DATE NOT NULL,
    participant_id      UUID NOT NULL REFERENCES participants(id) ON DELETE CASCADE,
    display_name        TEXT NOT NULL,
    department          TEXT,
    team_name           TEXT,
    total_points        NUMERIC(8,2) NOT NULL DEFAULT 0,
    rank                INTEGER NOT NULL,
    is_tied             BOOLEAN NOT NULL DEFAULT FALSE,
    generated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(challenge_id, leaderboard_type, period_label, participant_id)
);

-- ──────────────────────────────────────────
-- TABLE: reminders
-- ──────────────────────────────────────────
CREATE TABLE reminders (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    participant_id      UUID NOT NULL REFERENCES participants(id) ON DELETE CASCADE,
    reminder_type       TEXT NOT NULL
                            CHECK (reminder_type IN ('Water','Steps','Yoga','Workout','SugarFree','General','Broadcast')),
    reminder_time       TIME NOT NULL,
    frequency_type      TEXT NOT NULL DEFAULT 'Daily'
                            CHECK (frequency_type IN ('Daily','WeekdaysOnly','ShiftDays','Custom')),
    is_enabled          BOOLEAN NOT NULL DEFAULT TRUE,
    last_sent_at        TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ──────────────────────────────────────────
-- TABLE: notification_templates
-- ──────────────────────────────────────────
CREATE TABLE notification_templates (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    template_name   TEXT NOT NULL UNIQUE,
    activity_type   TEXT NOT NULL,
    message_body    TEXT NOT NULL,
    tone_tag        TEXT NOT NULL DEFAULT 'Supportive'
                        CHECK (tone_tag IN ('Supportive','Informational','Motivational')),
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    updated_by      UUID REFERENCES participants(id),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ──────────────────────────────────────────
-- TABLE: faqs
-- ──────────────────────────────────────────
CREATE TABLE faqs (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question        TEXT NOT NULL,
    answer          TEXT NOT NULL,
    category        TEXT NOT NULL DEFAULT 'General'
                        CHECK (category IN ('Challenge','Privacy','Technical','General','Medical')),
    display_order   INTEGER NOT NULL DEFAULT 0,
    is_published    BOOLEAN NOT NULL DEFAULT FALSE,
    updated_by      UUID REFERENCES participants(id),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ──────────────────────────────────────────
-- TABLE: consent_records (append-only)
-- ──────────────────────────────────────────
CREATE TABLE consent_records (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    participant_id      UUID NOT NULL REFERENCES participants(id) ON DELETE CASCADE,
    challenge_id        UUID REFERENCES challenges(id),
    consent_version     TEXT NOT NULL,
    consent_text        TEXT NOT NULL,
    device_info         TEXT,
    accepted_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ──────────────────────────────────────────
-- TABLE: app_config
-- ──────────────────────────────────────────
CREATE TABLE app_config (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    config_key      TEXT NOT NULL UNIQUE,
    config_value    TEXT NOT NULL,
    description     TEXT,
    updated_by      UUID REFERENCES participants(id),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ──────────────────────────────────────────
-- TABLE: audit_log
-- ──────────────────────────────────────────
CREATE TABLE audit_log (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    action_type         TEXT NOT NULL,
    performed_by        UUID REFERENCES participants(id),
    target_record_id    UUID,
    target_table        TEXT,
    action_detail       JSONB,
    performed_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ──────────────────────────────────────────
-- TABLE: medical_documents (metadata only – files stored in Supabase Storage)
-- ──────────────────────────────────────────
CREATE TABLE medical_documents (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    participant_id  UUID NOT NULL REFERENCES participants(id) ON DELETE CASCADE,
    file_name       TEXT NOT NULL,
    storage_path    TEXT NOT NULL,
    report_type     TEXT NOT NULL DEFAULT 'Other'
                        CHECK (report_type IN ('Lab Report','Prescription','Fitness Assessment','Other')),
    review_status   TEXT NOT NULL DEFAULT 'Uploaded'
                        CHECK (review_status IN ('Uploaded','Reviewed','Flagged')),
    uploaded_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reviewed_by     UUID REFERENCES participants(id),
    reviewed_at     TIMESTAMPTZ
);

-- ──────────────────────────────────────────
-- INDEXES
-- ──────────────────────────────────────────
CREATE INDEX idx_activity_logs_participant   ON activity_logs(participant_id);
CREATE INDEX idx_activity_logs_challenge     ON activity_logs(challenge_id);
CREATE INDEX idx_activity_logs_date          ON activity_logs(activity_date);
CREATE INDEX idx_leaderboard_challenge       ON leaderboard_snapshots(challenge_id, leaderboard_type);
CREATE INDEX idx_reminders_participant       ON reminders(participant_id);
CREATE INDEX idx_consent_participant         ON consent_records(participant_id);
CREATE INDEX idx_medical_docs_participant    ON medical_documents(participant_id);

-- ──────────────────────────────────────────
-- UPDATED_AT trigger
-- ──────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_participants_updated   BEFORE UPDATE ON participants          FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_challenges_updated     BEFORE UPDATE ON challenges            FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_reminders_updated      BEFORE UPDATE ON reminders             FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_app_config_updated     BEFORE UPDATE ON app_config            FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_notif_templates_updated BEFORE UPDATE ON notification_templates FOR EACH ROW EXECUTE FUNCTION update_updated_at();
