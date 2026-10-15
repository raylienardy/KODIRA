-- KODIRA — Migration 2: Create Indexes
-- Date: 2026-10-16

CREATE INDEX idx_user_progress_user_level ON user_progress(user_id, level_id);
CREATE INDEX idx_user_mastery_user_topic ON user_mastery(user_id, topic);
CREATE INDEX idx_user_mastery_user_level ON user_mastery(user_id, level_id);
CREATE INDEX idx_user_answers_user_exercise ON user_answers(user_id, exercise_id);
CREATE INDEX idx_user_answers_created ON user_answers(created_at);
CREATE INDEX idx_ai_hints_user_level ON ai_hints(user_id, level_id);
CREATE INDEX idx_levels_number ON levels(level_number);
CREATE INDEX idx_exercises_level ON exercises(level_id);
CREATE INDEX idx_materials_level ON materials(level_id);