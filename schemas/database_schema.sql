-- Relationship Navigator App - Complete Database Schema
-- PostgreSQL with Supabase extensions

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================
-- CORE USER & AUTHENTICATION TABLES
-- =====================================

-- Users table (extends Supabase auth.users)
CREATE TABLE public.users (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    timezone VARCHAR(50) DEFAULT 'UTC',
    preferences JSONB DEFAULT '{}',
    privacy_settings JSONB DEFAULT '{
        "data_processing_consent": false,
        "astrology_enabled": false,
        "message_analysis_enabled": false,
        "local_processing_only": true
    }'
);

-- User consent tracking
CREATE TABLE public.user_consents (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    consent_type VARCHAR(50) NOT NULL, -- 'data_processing', 'message_analysis', 'astrology', etc.
    granted BOOLEAN NOT NULL,
    granted_at TIMESTAMPTZ DEFAULT NOW(),
    revoked_at TIMESTAMPTZ,
    version VARCHAR(20) NOT NULL, -- consent version for compliance
    UNIQUE(user_id, consent_type)
);

-- =====================================
-- PERSON PROFILES & RELATIONSHIPS
-- =====================================

-- Person profiles (including self and others)
CREATE TABLE public.person_profiles (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    nickname VARCHAR(100),
    relationship_type VARCHAR(50), -- 'self', 'family', 'friend', 'romantic', 'professional', 'other'
    is_self BOOLEAN DEFAULT FALSE,
    birth_date DATE,
    birth_time TIME,
    birth_location VARCHAR(255),
    contact_info JSONB DEFAULT '{}', -- phone, email, social handles
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    archived_at TIMESTAMPTZ,
    
    -- Ensure only one self profile per user
    CONSTRAINT one_self_per_user UNIQUE(user_id, is_self) WHERE is_self = TRUE
);

-- Daily relationship scores
CREATE TABLE public.daily_relationship_scores (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    person_id UUID REFERENCES public.person_profiles(id) ON DELETE CASCADE,
    score_date DATE NOT NULL,
    relationship_health INTEGER CHECK (relationship_health >= 0 AND relationship_health <= 100),
    approachability INTEGER CHECK (approachability >= 0 AND approachability <= 100),
    availability INTEGER CHECK (availability >= 0 AND availability <= 100),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id, person_id, score_date)
);

-- =====================================
-- ASSESSMENT FRAMEWORK TABLES
-- =====================================

-- Assessment definitions (static reference data)
CREATE TABLE public.assessment_definitions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(50) NOT NULL, -- 'personality', 'relational', 'emotional', 'alternative'
    version VARCHAR(20) NOT NULL,
    description TEXT,
    scoring_method JSONB NOT NULL, -- defines how to calculate scores
    question_set JSONB NOT NULL, -- questions and possible answers
    created_at TIMESTAMPTZ DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE
);

-- Insert standard assessments
INSERT INTO public.assessment_definitions (name, category, version, description, scoring_method, question_set) VALUES
('Big Five (OCEAN)', 'personality', '1.0', 'Five-factor model of personality', 
 '{"dimensions": ["openness", "conscientiousness", "extraversion", "agreeableness", "neuroticism"], "scale": [1, 5]}',
 '{"total_questions": 50, "questions_per_dimension": 10, "scale_type": "likert_5"}'),

('MBTI', 'personality', '1.0', 'Myers-Briggs Type Indicator', 
 '{"dimensions": ["E_I", "S_N", "T_F", "J_P"], "result_type": "categorical"}',
 '{"total_questions": 70, "dichotomy_questions": 17.5, "result_format": "4_letter_code"}'),

('Enneagram', 'personality', '1.0', 'Nine personality types system', 
 '{"primary_type": [1, 9], "wing_types": "adjacent", "instincts": ["self_preservation", "social", "sexual"]}',
 '{"total_questions": 45, "type_questions": 5, "instinct_questions": 15}'),

('DISC', 'personality', '1.0', 'Dominance, Influence, Steadiness, Compliance', 
 '{"dimensions": ["dominance", "influence", "steadiness", "compliance"], "scale": [1, 5]}',
 '{"total_questions": 40, "questions_per_dimension": 10, "forced_choice": false}'),

('Attachment Styles', 'relational', '1.0', 'Adult attachment patterns', 
 '{"styles": ["secure", "anxious", "avoidant", "disorganized"], "result_type": "primary_secondary"}',
 '{"total_questions": 30, "style_questions": 7.5, "scenario_based": true}'),

('Emotional Intelligence', 'emotional', '1.0', 'EQ assessment across four domains', 
 '{"domains": ["self_awareness", "self_management", "social_awareness", "relationship_management"], "scale": [1, 5]}',
 '{"total_questions": 60, "questions_per_domain": 15, "scenario_based": true}');

-- Person assessment results
CREATE TABLE public.person_assessment_results (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    person_id UUID REFERENCES public.person_profiles(id) ON DELETE CASCADE,
    assessment_id UUID REFERENCES public.assessment_definitions(id),
    raw_responses JSONB NOT NULL, -- actual answers given
    calculated_scores JSONB NOT NULL, -- computed results
    confidence_level NUMERIC(3,2) DEFAULT 0.75, -- AI confidence in results
    completed_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ, -- some assessments may need retaking
    notes TEXT,
    
    -- Allow retaking assessments
    UNIQUE(person_id, assessment_id, completed_at)
);

-- Astrology profiles (optional)
CREATE TABLE public.astrology_profiles (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    person_id UUID REFERENCES public.person_profiles(id) ON DELETE CASCADE UNIQUE,
    sun_sign VARCHAR(20),
    moon_sign VARCHAR(20),
    rising_sign VARCHAR(20),
    birth_chart_data JSONB, -- full planetary positions
    compatibility_factors JSONB, -- computed compatibility elements
    daily_influences JSONB, -- current astrological influences
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================
-- INTERACTION LOGGING SYSTEM
-- =====================================

-- Interaction logs (ARR model: Action -> Reaction -> Outcome)
CREATE TABLE public.interaction_logs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    person_id UUID REFERENCES public.person_profiles(id) ON DELETE CASCADE,
    
    -- Action phase
    action_type VARCHAR(50) NOT NULL, -- 'conversation', 'text', 'call', 'meeting', 'conflict', 'request'
    action_description TEXT NOT NULL,
    action_context JSONB, -- location, mood, circumstances
    action_timestamp TIMESTAMPTZ NOT NULL,
    
    -- Reaction phase
    reaction_description TEXT,
    reaction_sentiment VARCHAR(20), -- 'positive', 'negative', 'neutral', 'mixed'
    reaction_intensity INTEGER CHECK (reaction_intensity >= 1 AND reaction_intensity <= 10),
    
    -- Outcome phase
    outcome_description TEXT,
    outcome_satisfaction INTEGER CHECK (outcome_satisfaction >= 1 AND outcome_satisfaction <= 10),
    relationship_impact VARCHAR(20), -- 'improved', 'worsened', 'neutral'
    
    -- Metadata
    tags TEXT[], -- for categorization and search
    mood_before VARCHAR(50),
    mood_after VARCHAR(50),
    learned_insight TEXT,
    private_notes TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Message analysis (for text/communication patterns)
CREATE TABLE public.message_snippets (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    interaction_id UUID REFERENCES public.interaction_logs(id) ON DELETE CASCADE,
    person_id UUID REFERENCES public.person_profiles(id) ON DELETE CASCADE,
    
    -- Message content (encrypted for privacy)
    message_content_encrypted TEXT, -- pgp encrypted
    message_hash VARCHAR(64), -- for deduplication
    sender VARCHAR(10) CHECK (sender IN ('user', 'other')),
    
    -- NLP Analysis results
    sentiment_score NUMERIC(3,2), -- -1 to 1
    emotion_detected VARCHAR(50),
    urgency_level INTEGER CHECK (urgency_level >= 1 AND urgency_level <= 5),
    tone VARCHAR(30),
    intent_category VARCHAR(50),
    
    -- Context
    timestamp_sent TIMESTAMPTZ,
    platform VARCHAR(30), -- 'sms', 'whatsapp', 'email', 'manual_entry'
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================
-- AI PREDICTIONS & ADVICE SYSTEM
-- =====================================

-- Generated insights and predictions
CREATE TABLE public.relationship_insights (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    person_id UUID REFERENCES public.person_profiles(id) ON DELETE CASCADE,
    
    insight_type VARCHAR(50) NOT NULL, -- 'prediction', 'advice', 'pattern', 'warning', 'opportunity'
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    
    -- Prediction/advice details
    confidence_score NUMERIC(3,2), -- 0 to 1
    priority_level INTEGER CHECK (priority_level >= 1 AND priority_level <= 5),
    category VARCHAR(50), -- 'communication', 'timing', 'approach', 'conflict_resolution'
    
    -- Context that generated this insight
    source_data_types TEXT[], -- which data contributed: ['interactions', 'assessments', 'astrology']
    trigger_event_id UUID REFERENCES public.interaction_logs(id),
    
    -- Lifecycle
    generated_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    dismissed_at TIMESTAMPTZ,
    acted_upon_at TIMESTAMPTZ,
    
    -- Learning feedback
    user_feedback INTEGER CHECK (user_feedback >= 1 AND user_feedback <= 5), -- effectiveness rating
    outcome_notes TEXT
);

-- Scenario simulations
CREATE TABLE public.scenario_simulations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    person_id UUID REFERENCES public.person_profiles(id) ON DELETE CASCADE,
    
    scenario_description TEXT NOT NULL,
    proposed_actions JSONB NOT NULL, -- array of possible actions
    predicted_outcomes JSONB NOT NULL, -- predictions for each action
    
    -- Simulation parameters
    context_factors JSONB, -- mood, timing, recent interactions
    personality_weights JSONB, -- how personality traits influence outcomes
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '7 days'
);

-- Actionable tasks generated from advice
CREATE TABLE public.relationship_tasks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    person_id UUID REFERENCES public.person_profiles(id),
    insight_id UUID REFERENCES public.relationship_insights(id),
    
    title VARCHAR(255) NOT NULL,
    description TEXT,
    task_type VARCHAR(50), -- 'reminder', 'action', 'follow_up', 'reflection'
    priority INTEGER CHECK (priority >= 1 AND priority <= 5),
    
    -- Scheduling
    due_date TIMESTAMPTZ,
    reminder_time TIMESTAMPTZ,
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    completed_at TIMESTAMPTZ,
    outcome_notes TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================
-- LEARNING & ANALYTICS TABLES
-- =====================================

-- Pattern recognition cache
CREATE TABLE public.interaction_patterns (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    person_id UUID REFERENCES public.person_profiles(id) ON DELETE CASCADE,
    
    pattern_type VARCHAR(50), -- 'successful_approach', 'conflict_trigger', 'mood_correlation'
    pattern_description TEXT,
    confidence_level NUMERIC(3,2),
    
    -- Pattern data
    trigger_conditions JSONB, -- what leads to this pattern
    typical_outcomes JSONB, -- what usually happens
    success_rate NUMERIC(3,2), -- historical success rate
    
    -- Supporting evidence
    interaction_count INTEGER DEFAULT 0,
    last_occurrence TIMESTAMPTZ,
    
    discovered_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- System learning feedback
CREATE TABLE public.advice_effectiveness (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    insight_id UUID REFERENCES public.relationship_insights(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    
    -- Feedback metrics
    helpfulness_rating INTEGER CHECK (helpfulness_rating >= 1 AND helpfulness_rating <= 5),
    accuracy_rating INTEGER CHECK (accuracy_rating >= 1 AND accuracy_rating <= 5),
    followed_advice BOOLEAN,
    
    -- Outcomes
    outcome_description TEXT,
    would_recommend BOOLEAN,
    
    feedback_given_at TIMESTAMPTZ DEFAULT NOW(),
    actual_outcome_at TIMESTAMPTZ
);

-- =====================================
-- INDEXES FOR PERFORMANCE
-- =====================================

-- User-related indexes
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_person_profiles_user_id ON public.person_profiles(user_id);
CREATE INDEX idx_person_profiles_user_id_active ON public.person_profiles(user_id) WHERE archived_at IS NULL;

-- Assessment indexes
CREATE INDEX idx_assessment_results_person ON public.person_assessment_results(person_id);
CREATE INDEX idx_assessment_results_assessment ON public.person_assessment_results(assessment_id);

-- Interaction indexes
CREATE INDEX idx_interaction_logs_user_person ON public.interaction_logs(user_id, person_id);
CREATE INDEX idx_interaction_logs_timestamp ON public.interaction_logs(action_timestamp);
CREATE INDEX idx_interaction_logs_tags ON public.interaction_logs USING GIN(tags);

-- Insights and tasks indexes
CREATE INDEX idx_insights_user_person ON public.relationship_insights(user_id, person_id);
CREATE INDEX idx_insights_type_priority ON public.relationship_insights(insight_type, priority_level);
CREATE INDEX idx_tasks_user_due ON public.relationship_tasks(user_id, due_date) WHERE status != 'completed';

-- Message analysis indexes
CREATE INDEX idx_messages_person_timestamp ON public.message_snippets(person_id, timestamp_sent);
CREATE INDEX idx_messages_hash ON public.message_snippets(message_hash);

-- Daily scores indexes
CREATE INDEX idx_daily_scores_person_date ON public.daily_relationship_scores(person_id, score_date);

-- =====================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================

-- Enable RLS on all user data tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_consents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.person_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_relationship_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.person_assessment_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.astrology_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.interaction_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.message_snippets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.relationship_insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scenario_simulations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.relationship_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.interaction_patterns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.advice_effectiveness ENABLE ROW LEVEL SECURITY;

-- RLS Policies - Users can only access their own data
CREATE POLICY "Users can view own profile" ON public.users FOR ALL USING (auth.uid() = id);

CREATE POLICY "Users can manage own consents" ON public.user_consents FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own person profiles" ON public.person_profiles FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own daily scores" ON public.daily_relationship_scores FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own assessment results" ON public.person_assessment_results FOR ALL 
  USING (auth.uid() = (SELECT user_id FROM public.person_profiles WHERE id = person_id));

CREATE POLICY "Users can manage own astrology data" ON public.astrology_profiles FOR ALL 
  USING (auth.uid() = (SELECT user_id FROM public.person_profiles WHERE id = person_id));

CREATE POLICY "Users can manage own interactions" ON public.interaction_logs FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own messages" ON public.message_snippets FOR ALL 
  USING (auth.uid() = (SELECT user_id FROM public.person_profiles WHERE id = person_id));

CREATE POLICY "Users can view own insights" ON public.relationship_insights FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own simulations" ON public.scenario_simulations FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own tasks" ON public.relationship_tasks FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own patterns" ON public.interaction_patterns FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can submit own feedback" ON public.advice_effectiveness FOR ALL USING (auth.uid() = user_id);

-- Assessment definitions are public (read-only for all authenticated users)
ALTER TABLE public.assessment_definitions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Assessment definitions are public" ON public.assessment_definitions FOR SELECT USING (auth.role() = 'authenticated');

-- =====================================
-- FUNCTIONS AND TRIGGERS
-- =====================================

-- Function to update timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at columns
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_person_profiles_updated_at BEFORE UPDATE ON public.person_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_interaction_logs_updated_at BEFORE UPDATE ON public.interaction_logs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_relationship_tasks_updated_at BEFORE UPDATE ON public.relationship_tasks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_astrology_profiles_updated_at BEFORE UPDATE ON public.astrology_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_interaction_patterns_updated_at BEFORE UPDATE ON public.interaction_patterns FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to calculate relationship health scores
CREATE OR REPLACE FUNCTION calculate_relationship_health(
    p_user_id UUID,
    p_person_id UUID,
    p_days_back INTEGER DEFAULT 30
) RETURNS INTEGER AS $$
DECLARE
    avg_satisfaction NUMERIC;
    interaction_frequency INTEGER;
    positive_interactions INTEGER;
    total_interactions INTEGER;
    health_score INTEGER;
BEGIN
    -- Get interaction statistics for the period
    SELECT 
        AVG(outcome_satisfaction),
        COUNT(*),
        COUNT(*) FILTER (WHERE relationship_impact = 'improved'),
        COUNT(*)
    INTO avg_satisfaction, interaction_frequency, positive_interactions, total_interactions
    FROM public.interaction_logs
    WHERE user_id = p_user_id 
      AND person_id = p_person_id
      AND action_timestamp >= NOW() - INTERVAL '1 day' * p_days_back;
    
    -- Calculate health score (0-100)
    IF total_interactions = 0 THEN
        RETURN 50; -- neutral score for no interactions
    END IF;
    
    health_score := (
        (COALESCE(avg_satisfaction, 5) * 10) * 0.4 +  -- satisfaction weight: 40%
        (LEAST(interaction_frequency * 2, 100)) * 0.3 + -- frequency weight: 30%
        ((positive_interactions::FLOAT / total_interactions) * 100) * 0.3 -- positivity weight: 30%
    )::INTEGER;
    
    RETURN GREATEST(0, LEAST(100, health_score));
END;
$$ LANGUAGE plpgsql;

-- =====================================
-- SAMPLE DATA FUNCTIONS
-- =====================================

-- Function to create sample data for testing
CREATE OR REPLACE FUNCTION create_sample_data(p_user_id UUID)
RETURNS void AS $$
BEGIN
    -- This function would be used for testing/demo purposes
    -- Implementation would create sample profiles, interactions, etc.
    RAISE NOTICE 'Sample data creation function - to be implemented';
END;
$$ LANGUAGE plpgsql;
