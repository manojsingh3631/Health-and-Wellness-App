-- ============================================================
-- BluePond Wellness – Row Level Security Policies
-- Migration 002: RLS
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE participants          ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_logs         ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenges            ENABLE ROW LEVEL SECURITY;
ALTER TABLE scoring_config        ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboard_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE reminders             ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE faqs                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE consent_records       ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_config            ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log             ENABLE ROW LEVEL SECURITY;
ALTER TABLE medical_documents     ENABLE ROW LEVEL SECURITY;

-- Helper: get current participant row
CREATE OR REPLACE FUNCTION current_participant_id()
RETURNS UUID AS $$
    SELECT id FROM participants WHERE auth_user_id = auth.uid()
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Helper: get current role
CREATE OR REPLACE FUNCTION current_role_level()
RETURNS TEXT AS $$
    SELECT role FROM participants WHERE auth_user_id = auth.uid()
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- ──────────────────────────────────────────
-- participants
-- ──────────────────────────────────────────
-- Everyone can read their own row; admins can read all
CREATE POLICY "participants_select_own"
    ON participants FOR SELECT
    USING (auth_user_id = auth.uid()
        OR current_role_level() IN ('Wellness Coordinator','Org Admin','Super Admin'));

-- Only the participant can update their own non-sensitive fields; admins can update all
CREATE POLICY "participants_update_own"
    ON participants FOR UPDATE
    USING (auth_user_id = auth.uid()
        OR current_role_level() IN ('Org Admin','Super Admin'));

-- Only admins can insert (bulk import)
CREATE POLICY "participants_insert_admin"
    ON participants FOR INSERT
    WITH CHECK (current_role_level() IN ('Org Admin','Super Admin'));

-- ──────────────────────────────────────────
-- activity_logs
-- ──────────────────────────────────────────
CREATE POLICY "actlogs_select"
    ON activity_logs FOR SELECT
    USING (participant_id = current_participant_id()
        OR current_role_level() IN ('Wellness Coordinator','Org Admin','Super Admin'));

CREATE POLICY "actlogs_insert_own"
    ON activity_logs FOR INSERT
    WITH CHECK (participant_id = current_participant_id());

CREATE POLICY "actlogs_update_own"
    ON activity_logs FOR UPDATE
    USING (participant_id = current_participant_id() AND edit_count < 1 AND is_voided = FALSE
        OR current_role_level() IN ('Org Admin','Super Admin'));

-- ──────────────────────────────────────────
-- challenges (read all; write admin only)
-- ──────────────────────────────────────────
CREATE POLICY "challenges_select_all"
    ON challenges FOR SELECT USING (TRUE);

CREATE POLICY "challenges_write_admin"
    ON challenges FOR ALL
    USING (current_role_level() IN ('Org Admin','Super Admin'))
    WITH CHECK (current_role_level() IN ('Org Admin','Super Admin'));

-- ──────────────────────────────────────────
-- scoring_config (read all; write admin only)
-- ──────────────────────────────────────────
CREATE POLICY "scoring_select_all"   ON scoring_config FOR SELECT USING (TRUE);
CREATE POLICY "scoring_write_admin"  ON scoring_config FOR ALL
    USING (current_role_level() IN ('Org Admin','Super Admin'))
    WITH CHECK (current_role_level() IN ('Org Admin','Super Admin'));

-- ──────────────────────────────────────────
-- leaderboard_snapshots (read filtered; write via server only)
-- ──────────────────────────────────────────
CREATE POLICY "lb_select_all"
    ON leaderboard_snapshots FOR SELECT USING (TRUE);

CREATE POLICY "lb_write_admin"
    ON leaderboard_snapshots FOR ALL
    USING (current_role_level() IN ('Org Admin','Super Admin'));

-- ──────────────────────────────────────────
-- reminders (own row only; admins all)
-- ──────────────────────────────────────────
CREATE POLICY "reminders_own"
    ON reminders FOR ALL
    USING (participant_id = current_participant_id()
        OR current_role_level() IN ('Wellness Coordinator','Org Admin','Super Admin'));

-- ──────────────────────────────────────────
-- notification_templates (admin only)
-- ──────────────────────────────────────────
CREATE POLICY "notif_admin_only"
    ON notification_templates FOR ALL
    USING (current_role_level() IN ('Wellness Coordinator','Org Admin','Super Admin'));

-- ──────────────────────────────────────────
-- faqs (read published; write admin)
-- ──────────────────────────────────────────
CREATE POLICY "faqs_read_published"
    ON faqs FOR SELECT
    USING (is_published = TRUE
        OR current_role_level() IN ('Wellness Coordinator','Org Admin','Super Admin'));

CREATE POLICY "faqs_write_admin"
    ON faqs FOR ALL
    USING (current_role_level() IN ('Wellness Coordinator','Org Admin','Super Admin'))
    WITH CHECK (current_role_level() IN ('Wellness Coordinator','Org Admin','Super Admin'));

-- ──────────────────────────────────────────
-- consent_records (read own; no update/delete)
-- ──────────────────────────────────────────
CREATE POLICY "consent_read_own"
    ON consent_records FOR SELECT
    USING (participant_id = current_participant_id()
        OR current_role_level() IN ('Org Admin','Super Admin'));

CREATE POLICY "consent_insert_own"
    ON consent_records FOR INSERT
    WITH CHECK (participant_id = current_participant_id());

-- ──────────────────────────────────────────
-- app_config (read all; write super admin)
-- ──────────────────────────────────────────
CREATE POLICY "appconfig_read_all"   ON app_config FOR SELECT USING (TRUE);
CREATE POLICY "appconfig_write_super" ON app_config FOR ALL
    USING (current_role_level() = 'Super Admin')
    WITH CHECK (current_role_level() = 'Super Admin');

-- ──────────────────────────────────────────
-- audit_log (super admin read; insert only via functions)
-- ──────────────────────────────────────────
CREATE POLICY "audit_read_super"
    ON audit_log FOR SELECT
    USING (current_role_level() = 'Super Admin');

CREATE POLICY "audit_insert_any"
    ON audit_log FOR INSERT WITH CHECK (TRUE);

-- ──────────────────────────────────────────
-- medical_documents
-- ──────────────────────────────────────────
CREATE POLICY "medical_own"
    ON medical_documents FOR SELECT
    USING (participant_id = current_participant_id()
        OR current_role_level() IN ('Wellness Coordinator','Super Admin'));

CREATE POLICY "medical_insert_own"
    ON medical_documents FOR INSERT
    WITH CHECK (participant_id = current_participant_id());
