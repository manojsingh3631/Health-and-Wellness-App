-- ============================================================
-- BluePond Wellness – Seed Data
-- Migration 003: Default config and FAQ content
-- ============================================================

-- Default app config
INSERT INTO app_config (config_key, config_value, description) VALUES
('active_challenge_id',     '',       'UUID of the currently active challenge'),
('leaderboard_refresh_hour','01',     'UTC hour for daily leaderboard refresh (0-23)'),
('default_reminder_freq',   'Standard','Default reminder frequency for new participants'),
('submission_edit_allowed', 'true',   'Whether participants can edit a submitted log once'),
('max_edits_per_day',       '1',      'Maximum edits per activity log per day'),
('streak_bonus_7_day',      '5',      'Bonus points for a 7-day streak'),
('streak_bonus_30_day',     '15',     'Bonus points for a 30-day streak'),
('support_email',           'wellness@bluepond.ai', 'Support contact email shown in app'),
('privacy_notice_version',  'v1.0',   'Current privacy notice version'),
('app_version',             '1.0.0',  'Current app version'),
('leaderboard_week_start',  'Monday', 'Start day for weekly leaderboard'),
('max_steps_manual_entry',  '50000',  'Upper validation bound for manual step entry');

-- Default notification templates
INSERT INTO notification_templates (template_name, activity_type, message_body, tone_tag) VALUES
('hydration_standard',      'Water',    'A gentle reminder to stay hydrated today. Log your water intake in BluePond Wellness when ready.',       'Supportive'),
('movement_standard',       'Steps',    'Take a few minutes to move. Even a short walk supports your energy and focus.',                           'Supportive'),
('log_submission_reminder', 'General',  'Don''t forget to log today''s wellness activities before the deadline.',                                  'Informational'),
('yoga_reminder',           'Yoga',     'A few minutes of mindfulness can make a real difference. Ready to log your session?',                     'Supportive'),
('streak_7_day',            'General',  'Great consistency. You have maintained a 7-day wellness streak — keep going!',                            'Motivational'),
('streak_30_day',           'General',  'Outstanding dedication. You''ve reached a 30-day streak. Your wellbeing matters and it shows.',           'Motivational'),
('weekly_recognition',      'General',  'Well done this week. Your commitment to your wellbeing is making a difference.',                          'Motivational');

-- Default FAQs
INSERT INTO faqs (question, answer, category, display_order, is_published) VALUES
('How are my points calculated?',
 'Points are calculated at submission based on scoring rules set by your Wellness Coordinator. Each activity has a per-unit score, a daily maximum, and optional bonus thresholds. For example, steps earn 1 point per 1,000 steps with a daily maximum of 10 points.',
 'Challenge', 1, TRUE),

('Can I edit an activity log after submitting?',
 'Yes. You are allowed one edit per day before the challenge submission deadline. After the deadline passes, the entry is locked for that day.',
 'Challenge', 2, TRUE),

('How does the streak count work for night shift employees?',
 'Your streak is calculated based on your configured shift window, not the standard calendar midnight. Night-shift employees logging at 3:00 AM are logging for their current shift day — your streak stays intact as long as you log within your active window.',
 'Challenge', 3, TRUE),

('Who can see my health data?',
 'Only you and authorised Wellness Coordinators and Super Admins can see your detailed health metrics (height, weight, BMI, blood group). The leaderboard displays only your first name and last initial.',
 'Privacy', 4, TRUE),

('Is the medical report upload mandatory?',
 'No. Medical report uploads are completely optional and have no impact on your participation or scoring.',
 'Medical', 5, TRUE),

('How do I change my reminder times?',
 'Go to Profile → Notifications to toggle reminders and adjust timing. You can also update your shift window in Profile → Shift Settings to automatically recalculate your reminder defaults.',
 'Technical', 6, TRUE),

('Can I turn off all notifications?',
 'Yes. You can set your reminder frequency to Minimal in Profile → Notifications, which limits reminders to one activity-log submission nudge per day. You can also toggle individual reminder types off completely.',
 'Technical', 7, TRUE),

('How is my leaderboard rank calculated?',
 'Your rank is based on total points earned during the current challenge period. The leaderboard is refreshed daily. In the case of a tie, both participants receive the same rank.',
 'Challenge', 8, TRUE);

-- Default scoring config for a sample challenge (will be linked once first challenge is created)
-- Admins create challenges and scoring config through the admin panel
