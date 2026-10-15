-- KODIRA — Migration 1: Create Tables
-- Date: 2026-10-16
-- Description: Semua tabel untuk aplikasi KODIRA

-- ============================================
-- USER TABLES
-- ============================================

CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nim TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  email TEXT UNIQUE,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_login TIMESTAMPTZ
);

CREATE TABLE user_settings (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  language TEXT DEFAULT 'id',
  notifications_enabled BOOLEAN DEFAULT true,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- CONTENT TABLES
-- ============================================

CREATE TABLE levels (
  id SERIAL PRIMARY KEY,
  level_number INT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  topic TEXT,
  language TEXT CHECK (language IN ('cpp', 'java')),
  difficulty INT CHECK (difficulty BETWEEN 1 AND 5),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE materials (
  id SERIAL PRIMARY KEY,
  level_id INT REFERENCES levels(id) ON DELETE CASCADE,
  slide_order INT NOT NULL,
  title TEXT,
  content TEXT,
  code_snippet TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE exercises (
  id SERIAL PRIMARY KEY,
  level_id INT REFERENCES levels(id) ON DELETE CASCADE,
  type TEXT CHECK (type IN ('drag_drop', 'code_editor', 'quiz')),
  prompt TEXT NOT NULL,
  payload JSONB,
  difficulty INT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- PROGRESS TABLES
-- ============================================

CREATE TABLE user_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  level_id INT REFERENCES levels(id),
  status TEXT CHECK (status IN ('locked', 'active', 'completed', 'remedial')),
  mastery_score FLOAT DEFAULT 0,
  xp_earned INT DEFAULT 0,
  attempts INT DEFAULT 0,
  remedial_level_id INT REFERENCES levels(id),
  last_attempt_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  UNIQUE(user_id, level_id)
);

CREATE TABLE user_mastery (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  topic TEXT NOT NULL,
  level_id INT REFERENCES levels(id),
  mastery_score FLOAT DEFAULT 0,
  error_count INT DEFAULT 0,
  last_updated TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, topic)
);

CREATE TABLE user_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  level_id INT REFERENCES levels(id),
  exercise_id INT REFERENCES exercises(id),
  answer TEXT,
  is_correct BOOLEAN,
  error_type TEXT CHECK (error_type IN ('syntax', 'logic', 'fatal')),
  time_spent_ms INT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- GAMIFICATION TABLES
-- ============================================

CREATE TABLE user_badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  badge_code TEXT NOT NULL,
  earned_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, badge_code)
);

CREATE TABLE user_streaks (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  current_streak INT DEFAULT 0,
  longest_streak INT DEFAULT 0,
  last_active_date DATE
);

CREATE TABLE user_achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  achievement_code TEXT NOT NULL,
  earned_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, achievement_code)
);

-- ============================================
-- AI TABLES
-- ============================================

CREATE TABLE ai_hints (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  level_id INT REFERENCES levels(id),
  exercise_id INT REFERENCES exercises(id),
  hint_level INT CHECK (hint_level BETWEEN 1 AND 3),
  content TEXT,
  requested_at TIMESTAMPTZ DEFAULT NOW()
);