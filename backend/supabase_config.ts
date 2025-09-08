// Supabase configuration and type definitions
// This file defines the TypeScript interfaces that match our database schema

export interface Database {
  public: {
    Tables: {
      users: {
        Row: {
          id: string;
          email: string;
          full_name: string | null;
          created_at: string;
          updated_at: string;
          timezone: string;
          preferences: Record<string, any>;
          privacy_settings: PrivacySettings;
        };
        Insert: {
          id: string;
          email: string;
          full_name?: string | null;
          timezone?: string;
          preferences?: Record<string, any>;
          privacy_settings?: PrivacySettings;
        };
        Update: {
          full_name?: string | null;
          timezone?: string;
          preferences?: Record<string, any>;
          privacy_settings?: PrivacySettings;
        };
      };
      
      user_consents: {
        Row: {
          id: string;
          user_id: string;
          consent_type: ConsentType;
          granted: boolean;
          granted_at: string;
          revoked_at: string | null;
          version: string;
        };
        Insert: {
          user_id: string;
          consent_type: ConsentType;
          granted: boolean;
          version: string;
        };
        Update: {
          granted?: boolean;
          revoked_at?: string | null;
        };
      };
      
      person_profiles: {
        Row: {
          id: string;
          user_id: string;
          name: string;
          nickname: string | null;
          relationship_type: RelationshipType | null;
          is_self: boolean;
          birth_date: string | null;
          birth_time: string | null;
          birth_location: string | null;
          contact_info: Record<string, any>;
          notes: string | null;
          created_at: string;
          updated_at: string;
          archived_at: string | null;
        };
        Insert: {
          user_id: string;
          name: string;
          nickname?: string | null;
          relationship_type?: RelationshipType | null;
          is_self?: boolean;
          birth_date?: string | null;
          birth_time?: string | null;
          birth_location?: string | null;
          contact_info?: Record<string, any>;
          notes?: string | null;
        };
        Update: {
          name?: string;
          nickname?: string | null;
          relationship_type?: RelationshipType | null;
          birth_date?: string | null;
          birth_time?: string | null;
          birth_location?: string | null;
          contact_info?: Record<string, any>;
          notes?: string | null;
          archived_at?: string | null;
        };
      };
      
      daily_relationship_scores: {
        Row: {
          id: string;
          user_id: string;
          person_id: string;
          score_date: string;
          relationship_health: number | null;
          approachability: number | null;
          availability: number | null;
          notes: string | null;
          created_at: string;
        };
        Insert: {
          user_id: string;
          person_id: string;
          score_date: string;
          relationship_health?: number | null;
          approachability?: number | null;
          availability?: number | null;
          notes?: string | null;
        };
        Update: {
          relationship_health?: number | null;
          approachability?: number | null;
          availability?: number | null;
          notes?: string | null;
        };
      };
      
      assessment_definitions: {
        Row: {
          id: string;
          name: string;
          category: AssessmentCategory;
          version: string;
          description: string | null;
          scoring_method: AssessmentScoringMethod;
          question_set: AssessmentQuestionSet;
          created_at: string;
          is_active: boolean;
        };
        Insert: {
          name: string;
          category: AssessmentCategory;
          version: string;
          description?: string | null;
          scoring_method: AssessmentScoringMethod;
          question_set: AssessmentQuestionSet;
          is_active?: boolean;
        };
        Update: {
          description?: string | null;
          scoring_method?: AssessmentScoringMethod;
          question_set?: AssessmentQuestionSet;
          is_active?: boolean;
        };
      };
      
      person_assessment_results: {
        Row: {
          id: string;
          person_id: string;
          assessment_id: string;
          raw_responses: Record<string, any>;
          calculated_scores: AssessmentScores;
          confidence_level: number;
          completed_at: string;
          expires_at: string | null;
          notes: string | null;
        };
        Insert: {
          person_id: string;
          assessment_id: string;
          raw_responses: Record<string, any>;
          calculated_scores: AssessmentScores;
          confidence_level?: number;
          expires_at?: string | null;
          notes?: string | null;
        };
        Update: {
          calculated_scores?: AssessmentScores;
          confidence_level?: number;
          notes?: string | null;
        };
      };
      
      astrology_profiles: {
        Row: {
          id: string;
          person_id: string;
          sun_sign: string | null;
          moon_sign: string | null;
          rising_sign: string | null;
          birth_chart_data: Record<string, any> | null;
          compatibility_factors: Record<string, any> | null;
          daily_influences: Record<string, any> | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          person_id: string;
          sun_sign?: string | null;
          moon_sign?: string | null;
          rising_sign?: string | null;
          birth_chart_data?: Record<string, any> | null;
          compatibility_factors?: Record<string, any> | null;
          daily_influences?: Record<string, any> | null;
        };
        Update: {
          sun_sign?: string | null;
          moon_sign?: string | null;
          rising_sign?: string | null;
          birth_chart_data?: Record<string, any> | null;
          compatibility_factors?: Record<string, any> | null;
          daily_influences?: Record<string, any> | null;
        };
      };
      
      interaction_logs: {
        Row: {
          id: string;
          user_id: string;
          person_id: string;
          action_type: ActionType;
          action_description: string;
          action_context: Record<string, any> | null;
          action_timestamp: string;
          reaction_description: string | null;
          reaction_sentiment: Sentiment | null;
          reaction_intensity: number | null;
          outcome_description: string | null;
          outcome_satisfaction: number | null;
          relationship_impact: RelationshipImpact | null;
          tags: string[] | null;
          mood_before: string | null;
          mood_after: string | null;
          learned_insight: string | null;
          private_notes: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          user_id: string;
          person_id: string;
          action_type: ActionType;
          action_description: string;
          action_context?: Record<string, any> | null;
          action_timestamp: string;
          reaction_description?: string | null;
          reaction_sentiment?: Sentiment | null;
          reaction_intensity?: number | null;
          outcome_description?: string | null;
          outcome_satisfaction?: number | null;
          relationship_impact?: RelationshipImpact | null;
          tags?: string[] | null;
          mood_before?: string | null;
          mood_after?: string | null;
          learned_insight?: string | null;
          private_notes?: string | null;
        };
        Update: {
          action_description?: string;
          action_context?: Record<string, any> | null;
          reaction_description?: string | null;
          reaction_sentiment?: Sentiment | null;
          reaction_intensity?: number | null;
          outcome_description?: string | null;
          outcome_satisfaction?: number | null;
          relationship_impact?: RelationshipImpact | null;
          tags?: string[] | null;
          mood_before?: string | null;
          mood_after?: string | null;
          learned_insight?: string | null;
          private_notes?: string | null;
        };
      };
      
      relationship_insights: {
        Row: {
          id: string;
          user_id: string;
          person_id: string;
          insight_type: InsightType;
          title: string;
          description: string;
          confidence_score: number | null;
          priority_level: number | null;
          category: string | null;
          source_data_types: string[] | null;
          trigger_event_id: string | null;
          generated_at: string;
          expires_at: string | null;
          dismissed_at: string | null;
          acted_upon_at: string | null;
          user_feedback: number | null;
          outcome_notes: string | null;
        };
        Insert: {
          user_id: string;
          person_id: string;
          insight_type: InsightType;
          title: string;
          description: string;
          confidence_score?: number | null;
          priority_level?: number | null;
          category?: string | null;
          source_data_types?: string[] | null;
          trigger_event_id?: string | null;
          expires_at?: string | null;
        };
        Update: {
          dismissed_at?: string | null;
          acted_upon_at?: string | null;
          user_feedback?: number | null;
          outcome_notes?: string | null;
        };
      };
      
      relationship_tasks: {
        Row: {
          id: string;
          user_id: string;
          person_id: string | null;
          insight_id: string | null;
          title: string;
          description: string | null;
          task_type: TaskType;
          priority: number | null;
          due_date: string | null;
          reminder_time: string | null;
          status: TaskStatus;
          completed_at: string | null;
          outcome_notes: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          user_id: string;
          person_id?: string | null;
          insight_id?: string | null;
          title: string;
          description?: string | null;
          task_type: TaskType;
          priority?: number | null;
          due_date?: string | null;
          reminder_time?: string | null;
          status?: TaskStatus;
        };
        Update: {
          title?: string;
          description?: string | null;
          priority?: number | null;
          due_date?: string | null;
          reminder_time?: string | null;
          status?: TaskStatus;
          completed_at?: string | null;
          outcome_notes?: string | null;
        };
      };
    };
    Views: {
      // Add any views here
    };
    Functions: {
      calculate_relationship_health: {
        Args: {
          p_user_id: string;
          p_person_id: string;
          p_days_back?: number;
        };
        Returns: number;
      };
    };
    Enums: {
      // Database enums would be defined here
    };
  };
}

// Type definitions
export type ConsentType = 
  | 'data_processing' 
  | 'message_analysis' 
  | 'astrology' 
  | 'cloud_processing'
  | 'analytics';

export type RelationshipType = 
  | 'self' 
  | 'family' 
  | 'friend' 
  | 'romantic' 
  | 'professional' 
  | 'other';

export type AssessmentCategory = 
  | 'personality' 
  | 'relational' 
  | 'emotional' 
  | 'alternative';

export type ActionType = 
  | 'conversation' 
  | 'text' 
  | 'call' 
  | 'meeting' 
  | 'conflict' 
  | 'request'
  | 'social_media'
  | 'email';

export type Sentiment = 
  | 'positive' 
  | 'negative' 
  | 'neutral' 
  | 'mixed';

export type RelationshipImpact = 
  | 'improved' 
  | 'worsened' 
  | 'neutral';

export type InsightType = 
  | 'prediction' 
  | 'advice' 
  | 'pattern' 
  | 'warning' 
  | 'opportunity';

export type TaskType = 
  | 'reminder' 
  | 'action' 
  | 'follow_up' 
  | 'reflection';

export type TaskStatus = 
  | 'pending' 
  | 'in_progress' 
  | 'completed' 
  | 'cancelled';

// Complex type definitions
export interface PrivacySettings {
  data_processing_consent: boolean;
  astrology_enabled: boolean;
  message_analysis_enabled: boolean;
  local_processing_only: boolean;
  analytics_enabled?: boolean;
  third_party_sharing?: boolean;
}

export interface AssessmentScoringMethod {
  dimensions?: string[];
  scale?: number[];
  result_type?: string;
  calculation_rules?: Record<string, any>;
}

export interface AssessmentQuestionSet {
  total_questions: number;
  questions_per_dimension?: number;
  scale_type?: string;
  question_format?: string;
  time_limit_minutes?: number;
}

export interface AssessmentScores {
  // Big Five
  openness?: number;
  conscientiousness?: number;
  extraversion?: number;
  agreeableness?: number;
  neuroticism?: number;
  
  // MBTI
  mbti_type?: string;
  e_i_score?: number;
  s_n_score?: number;
  t_f_score?: number;
  j_p_score?: number;
  
  // Enneagram
  enneagram_type?: number;
  wing?: string;
  instinct_variant?: string;
  
  // DISC
  dominance?: number;
  influence?: number;
  steadiness?: number;
  compliance?: number;
  
  // Attachment
  attachment_style?: string;
  attachment_scores?: Record<string, number>;
  
  // EQ
  self_awareness?: number;
  self_management?: number;
  social_awareness?: number;
  relationship_management?: number;
  
  // Generic scores for custom assessments
  raw_scores?: Record<string, number>;
  percentiles?: Record<string, number>;
  interpretations?: Record<string, string>;
}

// Utility types
export type Tables<T extends keyof Database['public']['Tables']> = Database['public']['Tables'][T]['Row'];
export type Inserts<T extends keyof Database['public']['Tables']> = Database['public']['Tables'][T]['Insert'];
export type Updates<T extends keyof Database['public']['Tables']> = Database['public']['Tables'][T]['Update'];

// Export specific table types for convenience
export type User = Tables<'users'>;
export type PersonProfile = Tables<'person_profiles'>;
export type InteractionLog = Tables<'interaction_logs'>;
export type RelationshipInsight = Tables<'relationship_insights'>;
export type RelationshipTask = Tables<'relationship_tasks'>;
export type AssessmentResult = Tables<'person_assessment_results'>;
export type DailyScore = Tables<'daily_relationship_scores'>;

// API Response types
export interface ApiResponse<T = any> {
  data: T | null;
  error: string | null;
  status: number;
}

export interface PaginatedResponse<T> {
  data: T[];
  count: number;
  page: number;
  per_page: number;
  total_pages: number;
}

// Assessment question types
export interface AssessmentQuestion {
  id: string;
  text: string;
  type: 'likert' | 'multiple_choice' | 'boolean' | 'ranking';
  options?: string[];
  scale?: {
    min: number;
    max: number;
    labels: string[];
  };
  dimension?: string;
  reverse_scored?: boolean;
}

// Interaction analysis types
export interface InteractionAnalysis {
  sentiment_trends: {
    date: string;
    sentiment: number;
    volume: number;
  }[];
  common_themes: string[];
  success_patterns: string[];
  risk_factors: string[];
  recommendations: string[];
}

// Prediction types
export interface Prediction {
  scenario: string;
  probability: number;
  confidence: number;
  factors: string[];
  suggested_actions: string[];
}

// Real-time advice types
export interface AdviceContext {
  current_mood?: string;
  recent_interactions?: InteractionLog[];
  relationship_status?: 'good' | 'strained' | 'conflict' | 'unknown';
  timing_factors?: {
    day_of_week: string;
    time_of_day: string;
    recent_events: string[];
  };
  personality_considerations?: {
    user_traits: AssessmentScores;
    other_traits: AssessmentScores;
    compatibility_score: number;
  };
}

export interface AdviceResponse {
  primary_advice: string;
  reasoning: string;
  confidence_level: number;
  alternative_approaches: string[];
  timing_recommendation: string;
  success_probability: number;
  risk_factors: string[];
}

// Configuration types for the app
export interface AppConfig {
  features: {
    astrology_enabled: boolean;
    message_analysis_enabled: boolean;
    advanced_predictions: boolean;
    social_media_integration: boolean;
  };
  ai_settings: {
    confidence_threshold: number;
    prediction_horizon_days: number;
    learning_rate: number;
    privacy_mode: 'strict' | 'balanced' | 'open';
  };
  notification_settings: {
    insights_enabled: boolean;
    reminders_enabled: boolean;
    daily_summary: boolean;
    prediction_alerts: boolean;
  };
}
