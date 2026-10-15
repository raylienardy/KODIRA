-- KODIRA — Migration 3: Enable RLS & Policies
-- Date: 2026-10-16

-- ============================================
-- ENABLE RLS ON ALL TABLES
-- ============================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_mastery ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_streaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_hints ENABLE ROW LEVEL SECURITY;

-- ============================================
-- READ-ONLY CONTENT TABLES (semua authenticated bisa baca)
-- ============================================

CREATE POLICY select_levels ON levels
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY select_materials ON materials
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY select_exercises ON exercises
  FOR SELECT USING (auth.role() = 'authenticated');

-- ============================================
-- USER-SCOPED TABLES
-- ============================================

-- users
CREATE POLICY select_own_user ON users
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY update_own_user ON users
  FOR UPDATE USING (auth.uid() = id);

-- user_settings
CREATE POLICY select_own_settings ON user_settings
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY insert_own_settings ON user_settings
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY update_own_settings ON user_settings
  FOR UPDATE USING (auth.uid() = user_id);

-- user_progress
CREATE POLICY select_own_progress ON user_progress
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY insert_own_progress ON user_progress
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY update_own_progress ON user_progress
  FOR UPDATE USING (auth.uid() = user_id);

-- user_mastery
CREATE POLICY select_own_mastery ON user_mastery
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY insert_own_mastery ON user_mastery
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY update_own_mastery ON user_mastery
  FOR UPDATE USING (auth.uid() = user_id);

-- user_answers
CREATE POLICY select_own_answers ON user_answers
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY insert_own_answers ON user_answers
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ai_hints
CREATE POLICY select_own_hints ON ai_hints
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY insert_own_hints ON ai_hints
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================
-- GAMIFICATION TABLES (read-only user, insert via service_role)
-- ============================================

-- user_badges
CREATE POLICY select_own_badges ON user_badges
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY insert_service_badges ON user_badges
  FOR INSERT WITH CHECK (auth.role() = 'service_role');

-- user_streaks
CREATE POLICY select_own_streaks ON user_streaks
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY insert_service_streaks ON user_streaks
  FOR INSERT WITH CHECK (auth.role() = 'service_role');
CREATE POLICY update_service_streaks ON user_streaks
  FOR UPDATE USING (auth.role() = 'service_role');

-- user_achievements
CREATE POLICY select_own_achievements ON user_achievements
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY insert_service_achievements ON user_achievements
  FOR INSERT WITH CHECK (auth.role() = 'service_role');