// Assessment scoring algorithms and utilities
import { AssessmentScores, AssessmentScoringMethod } from './supabase_config';

// Big Five Assessment Scoring
export interface BigFiveResponses {
  [questionId: string]: number; // 1-5 scale responses
}

export interface BigFiveScores {
  openness: number;
  conscientiousness: number; 
  extraversion: number;
  agreeableness: number;
  neuroticism: number;
  percentiles: {
    openness: number;
    conscientiousness: number;
    extraversion: number;
    agreeableness: number;
    neuroticism: number;
  };
}

export class BigFiveScorer {
  // Question mapping - which questions belong to which dimension
  private static readonly DIMENSION_QUESTIONS = {
    extraversion: ['q1', 'q6', 'q11', 'q16', 'q21', 'q26', 'q31', 'q36', 'q41', 'q46'],
    agreeableness: ['q2', 'q7', 'q12', 'q17', 'q22', 'q27', 'q32', 'q37', 'q42', 'q47'],
    conscientiousness: ['q3', 'q8', 'q13', 'q18', 'q23', 'q28', 'q33', 'q38', 'q43', 'q48'],
    neuroticism: ['q4', 'q9', 'q14', 'q19', 'q24', 'q29', 'q34', 'q39', 'q44', 'q49'],
    openness: ['q5', 'q10', 'q15', 'q20', 'q25', 'q30', 'q35', 'q40', 'q45', 'q50']
  };

  // Questions that need reverse scoring (1->5, 2->4, 3->3, 4->2, 5->1)
  private static readonly REVERSE_SCORED = [
    'q2', 'q6', 'q8', 'q9', 'q10', 'q12', 'q16', 'q18', 'q19', 'q20',
    'q22', 'q26', 'q28', 'q30', 'q32', 'q36', 'q38', 'q46'
  ];

  // Normative data for percentile calculation (based on large sample studies)
  private static readonly NORMATIVE_MEANS = {
    openness: 3.4,
    conscientiousness: 3.6,
    extraversion: 3.3,
    agreeableness: 3.7,
    neuroticism: 2.9
  };

  private static readonly NORMATIVE_STANDARD_DEVIATIONS = {
    openness: 0.7,
    conscientiousness: 0.8,
    extraversion: 0.9,
    agreeableness: 0.7,
    neuroticism: 0.8
  };

  static scoreBigFive(responses: BigFiveResponses): BigFiveScores {
    // Apply reverse scoring where needed
    const adjustedResponses: { [key: string]: number } = {};
    
    for (const [questionId, response] of Object.entries(responses)) {
      if (this.REVERSE_SCORED.includes(questionId)) {
        adjustedResponses[questionId] = 6 - response; // Reverse score (1->5, 2->4, etc.)
      } else {
        adjustedResponses[questionId] = response;
      }
    }

    // Calculate dimension scores
    const scores: BigFiveScores = {
      openness: this.calculateDimensionScore('openness', adjustedResponses),
      conscientiousness: this.calculateDimensionScore('conscientiousness', adjustedResponses),
      extraversion: this.calculateDimensionScore('extraversion', adjustedResponses),
      agreeableness: this.calculateDimensionScore('agreeableness', adjustedResponses),
      neuroticism: this.calculateDimensionScore('neuroticism', adjustedResponses),
      percentiles: {
        openness: 0,
        conscientiousness: 0,
        extraversion: 0,
        agreeableness: 0,
        neuroticism: 0
      }
    };

    // Calculate percentiles
    scores.percentiles = {
      openness: this.calculatePercentile('openness', scores.openness),
      conscientiousness: this.calculatePercentile('conscientiousness', scores.conscientiousness),
      extraversion: this.calculatePercentile('extraversion', scores.extraversion),
      agreeableness: this.calculatePercentile('agreeableness', scores.agreeableness),
      neuroticism: this.calculatePercentile('neuroticism', scores.neuroticism)
    };

    return scores;
  }

  private static calculateDimensionScore(
    dimension: keyof typeof this.DIMENSION_QUESTIONS,
    responses: { [key: string]: number }
  ): number {
    const questionIds = this.DIMENSION_QUESTIONS[dimension];
    const sum = questionIds.reduce((total, questionId) => {
      return total + (responses[questionId] || 0);
    }, 0);
    
    // Return average score (1-5 scale)
    return sum / questionIds.length;
  }

  private static calculatePercentile(
    dimension: keyof typeof this.NORMATIVE_MEANS,
    score: number
  ): number {
    const mean = this.NORMATIVE_MEANS[dimension];
    const sd = this.NORMATIVE_STANDARD_DEVIATIONS[dimension];
    
    // Calculate z-score
    const zScore = (score - mean) / sd;
    
    // Convert z-score to percentile using normal distribution approximation
    return Math.round(this.normalCDF(zScore) * 100);
  }

  // Normal cumulative distribution function approximation
  private static normalCDF(x: number): number {
    return 0.5 * (1 + this.erf(x / Math.sqrt(2)));
  }

  // Error function approximation
  private static erf(x: number): number {
    const a1 = 0.254829592;
    const a2 = -0.284496736;
    const a3 = 1.421413741;
    const a4 = -1.453152027;
    const a5 = 1.061405429;
    const p = 0.3275911;
    
    const sign = x >= 0 ? 1 : -1;
    x = Math.abs(x);
    
    const t = 1.0 / (1.0 + p * x);
    const y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * Math.exp(-x * x);
    
    return sign * y;
  }

  // Generate interpretation text
  static interpretBigFive(scores: BigFiveScores): {
    [dimension: string]: {
      score: number;
      percentile: number;
      level: 'very_low' | 'low' | 'average' | 'high' | 'very_high';
      description: string;
    };
  } {
    const interpretations: any = {};
    
    const dimensions = ['openness', 'conscientiousness', 'extraversion', 'agreeableness', 'neuroticism'] as const;
    
    for (const dimension of dimensions) {
      const score = scores[dimension];
      const percentile = scores.percentiles[dimension];
      
      let level: 'very_low' | 'low' | 'average' | 'high' | 'very_high';
      if (score < 2.0) level = 'very_low';
      else if (score < 2.8) level = 'low';
      else if (score < 3.7) level = 'average';
      else if (score < 4.5) level = 'high';
      else level = 'very_high';
      
      interpretations[dimension] = {
        score,
        percentile,
        level,
        description: this.getDimensionDescription(dimension, level)
      };
    }
    
    return interpretations;
  }

  private static getDimensionDescription(
    dimension: string,
    level: 'very_low' | 'low' | 'average' | 'high' | 'very_high'
  ): string {
    const descriptions: { [key: string]: { [level: string]: string } } = {
      openness: {
        very_low: "Very practical and conventional. Prefers familiar experiences and traditional approaches.",
        low: "Generally practical with some openness to new experiences when necessary.",
        average: "Balanced between practical and creative approaches. Open to some new experiences.",
        high: "Creative and curious. Enjoys exploring new ideas and experiences.",
        very_high: "Highly imaginative and intellectually curious. Constantly seeks novel experiences and abstract ideas."
      },
      conscientiousness: {
        very_low: "Very spontaneous and flexible. May struggle with organization and follow-through.",
        low: "Somewhat disorganized but adaptable. Prefers flexibility over rigid planning.",
        average: "Generally organized with some flexibility. Balances planning with spontaneity.",
        high: "Well-organized and reliable. Good at following through on commitments.",
        very_high: "Extremely organized and disciplined. May be seen as perfectionist or rigid."
      },
      extraversion: {
        very_low: "Very introverted. Strongly prefers solitude and quiet environments.",
        low: "Generally quiet and reserved. Comfortable in small groups or alone.",
        average: "Balanced between social and solitary activities. Comfortable in various social settings.",
        high: "Outgoing and energetic. Enjoys social interaction and group activities.",
        very_high: "Extremely sociable and assertive. Thrives on social interaction and attention."
      },
      agreeableness: {
        very_low: "Very competitive and skeptical. May appear blunt or unsympathetic.",
        low: "Somewhat competitive. Values honesty over harmony in interactions.",
        average: "Generally cooperative with some assertiveness when needed.",
        high: "Cooperative and trusting. Values harmony and helping others.",
        very_high: "Extremely cooperative and empathetic. May have difficulty asserting own needs."
      },
      neuroticism: {
        very_low: "Exceptionally calm and emotionally stable. Rarely experiences stress or negative emotions.",
        low: "Generally calm and resilient. Handles stress well most of the time.",
        average: "Experiences normal range of emotions. Generally stable with occasional stress.",
        high: "Somewhat prone to worry and emotional reactions. May need stress management strategies.",
        very_high: "Highly sensitive to stress and prone to anxiety. May benefit from emotional support strategies."
      }
    };
    
    return descriptions[dimension]?.[level] || "No description available";
  }
}

// Attachment Styles Assessment Scoring
export interface AttachmentResponses {
  [questionId: string]: number; // 1-7 scale responses
}

export interface AttachmentScores {
  secure: number;
  anxious_preoccupied: number;
  dismissive_avoidant: number;
  fearful_avoidant: number;
  primary_style: 'secure' | 'anxious_preoccupied' | 'dismissive_avoidant' | 'fearful_avoidant';
  style_confidence: number;
}

export class AttachmentScorer {
  // Question mapping for attachment styles
  private static readonly STYLE_QUESTIONS = {
    secure: ['q1', 'q5', 'q9', 'q13', 'q17', 'q21', 'q25', 'q29'],
    anxious_preoccupied: ['q2', 'q6', 'q10', 'q14', 'q18', 'q22', 'q26', 'q30'],
    dismissive_avoidant: ['q3', 'q7', 'q11', 'q15', 'q19', 'q23', 'q27'],
    fearful_avoidant: ['q4', 'q8', 'q12', 'q16', 'q20', 'q24', 'q28']
  };

  static scoreAttachment(responses: AttachmentResponses): AttachmentScores {
    const scores: AttachmentScores = {
      secure: this.calculateStyleScore('secure', responses),
      anxious_preoccupied: this.calculateStyleScore('anxious_preoccupied', responses),
      dismissive_avoidant: this.calculateStyleScore('dismissive_avoidant', responses),
      fearful_avoidant: this.calculateStyleScore('fearful_avoidant', responses),
      primary_style: 'secure',
      style_confidence: 0
    };

    // Determine primary attachment style
    const styleScores = [
      { style: 'secure' as const, score: scores.secure },
      { style: 'anxious_preoccupied' as const, score: scores.anxious_preoccupied },
      { style: 'dismissive_avoidant' as const, score: scores.dismissive_avoidant },
      { style: 'fearful_avoidant' as const, score: scores.fearful_avoidant }
    ];

    styleScores.sort((a, b) => b.score - a.score);
    scores.primary_style = styleScores[0].style;
    
    // Calculate confidence as difference between top two scores
    const topScore = styleScores[0].score;
    const secondScore = styleScores[1].score;
    scores.style_confidence = Math.min((topScore - secondScore) / 7, 1); // Normalize to 0-1

    return scores;
  }

  private static calculateStyleScore(
    style: keyof typeof this.STYLE_QUESTIONS,
    responses: AttachmentResponses
  ): number {
    const questionIds = this.STYLE_QUESTIONS[style];
    const sum = questionIds.reduce((total, questionId) => {
      return total + (responses[questionId] || 0);
    }, 0);
    
    return sum / questionIds.length; // Return average (1-7 scale)
  }

  // Generate relationship compatibility score between two attachment styles
  static calculateCompatibility(
    style1: string,
    style2: string
  ): {
    score: number; // 0-100
    description: string;
    challenges: string[];
    advice: string[];
  } {
    const compatibilityMatrix: {
      [key: string]: {
        [key: string]: {
          score: number;
          description: string;
          challenges: string[];
          advice: string[];
        };
      };
    } = {
      secure: {
        secure: {
          score: 95,
          description: "Excellent compatibility. Both partners are emotionally stable and supportive.",
          challenges: ["May become complacent", "Could benefit from more growth challenges"],
          advice: ["Continue open communication", "Support individual growth", "Maintain appreciation"]
        },
        anxious_preoccupied: {
          score: 80,
          description: "Good compatibility. Secure partner provides stability for anxious partner's growth.",
          challenges: ["Anxious partner may test the relationship", "Different needs for reassurance"],
          advice: ["Consistent reassurance from secure partner", "Anxious partner should develop self-soothing", "Patient understanding"]
        },
        dismissive_avoidant: {
          score: 70,
          description: "Moderate compatibility. Secure partner can help avoidant partner open up gradually.",
          challenges: ["Avoidant partner may withdraw under pressure", "Different comfort levels with intimacy"],
          advice: ["Respect need for independence", "Gradual intimacy building", "Don't take withdrawal personally"]
        },
        fearful_avoidant: {
          score: 75,
          description: "Good potential with patience. Secure partner provides safe space for healing.",
          challenges: ["Fearful partner's push-pull dynamic", "Need for consistent safety"],
          advice: ["Consistent, non-threatening presence", "Professional support helpful", "Celebrate small steps"]
        }
      },
      anxious_preoccupied: {
        anxious_preoccupied: {
          score: 60,
          description: "Moderate compatibility. High emotional intensity - can be very supportive or volatile.",
          challenges: ["Emotional flooding", "Codependent patterns", "High drama potential"],
          advice: ["Individual emotional regulation work", "Maintain separate identities", "Set boundaries"]
        },
        dismissive_avoidant: {
          score: 40,
          description: "Challenging compatibility. Classic pursuer-distancer dynamic.",
          challenges: ["Anxious pursues, avoidant withdraws", "Escalating conflict cycles", "Mismatched needs"],
          advice: ["Both need individual therapy", "Understand each other's triggers", "Professional couples support"]
        },
        fearful_avoidant: {
          score: 55,
          description: "Complex compatibility. Both partners have relationship anxiety but different expressions.",
          challenges: ["Double anxiety patterns", "Unpredictable dynamics", "Trust issues"],
          advice: ["Focus on individual healing first", "Trauma-informed support", "Go slowly with commitment"]
        }
      },
      dismissive_avoidant: {
        dismissive_avoidant: {
          score: 65,
          description: "Moderate compatibility. Low conflict but potentially low intimacy.",
          challenges: ["Emotional distance", "Lack of deep connection", "Parallel rather than intimate lives"],
          advice: ["Intentional intimacy practices", "Schedule relationship check-ins", "Vulnerability exercises"]
        },
        fearful_avoidant: {
          score: 50,
          description: "Complex compatibility. Both avoid intimacy but for different reasons.",
          challenges: ["Double avoidance patterns", "Mixed signals", "Difficulty building trust"],
          advice: ["Individual attachment work", "Very gradual trust building", "Professional guidance recommended"]
        }
      },
      fearful_avoidant: {
        fearful_avoidant: {
          score: 45,
          description: "Challenging compatibility. Both partners struggle with approach-avoidance conflicts.",
          challenges: ["Double push-pull dynamics", "Triggered reactions", "Inconsistent behavior"],
          advice: ["Individual trauma work essential", "External support system", "Clear communication agreements"]
        }
      }
    };

    // Make lookup symmetric
    return compatibilityMatrix[style1]?.[style2] || 
           compatibilityMatrix[style2]?.[style1] || {
             score: 50,
             description: "Compatibility depends on individual growth and communication.",
             challenges: ["Unknown compatibility pattern"],
             advice: ["Focus on healthy communication", "Individual self-awareness work"]
           };
  }
}

// Generic assessment utility functions
export class AssessmentUtils {
  // Calculate confidence interval for assessment scores
  static calculateConfidenceInterval(
    score: number,
    sampleSize: number,
    confidenceLevel: number = 0.95
  ): { lower: number; upper: number } {
    const zScore = confidenceLevel === 0.95 ? 1.96 : 1.645; // 95% or 90%
    const standardError = Math.sqrt((score * (1 - score)) / sampleSize);
    const margin = zScore * standardError;
    
    return {
      lower: Math.max(0, score - margin),
      upper: Math.min(1, score + margin)
    };
  }

  // Check if assessment results are outdated and need retaking
  static isAssessmentOutdated(
    completedDate: string,
    assessmentType: string
  ): boolean {
    const completed = new Date(completedDate);
    const now = new Date();
    const daysDifference = (now.getTime() - completed.getTime()) / (1000 * 3600 * 24);
    
    const expirationDays: { [key: string]: number } = {
      'big_five': 365,     // 1 year
      'attachment': 180,   // 6 months
      'mbti': 730,         // 2 years
      'enneagram': 365,    // 1 year
      'disc': 180,         // 6 months
      'emotional_intelligence': 365 // 1 year
    };
    
    return daysDifference > (expirationDays[assessmentType] || 365);
  }

  // Validate assessment responses for completeness and consistency
  static validateResponses(
    responses: { [key: string]: number },
    expectedQuestions: string[],
    scaleRange: [number, number]
  ): { isValid: boolean; errors: string[] } {
    const errors: string[] = [];
    
    // Check completeness
    const missingQuestions = expectedQuestions.filter(q => !(q in responses));
    if (missingQuestions.length > 0) {
      errors.push(`Missing responses for questions: ${missingQuestions.join(', ')}`);
    }
    
    // Check scale validity
    for (const [questionId, response] of Object.entries(responses)) {
      if (response < scaleRange[0] || response > scaleRange[1]) {
        errors.push(`Invalid response for ${questionId}: ${response} (expected ${scaleRange[0]}-${scaleRange[1]})`);
      }
    }
    
    // Check for response patterns (e.g., all same answer)
    const uniqueResponses = new Set(Object.values(responses));
    if (uniqueResponses.size === 1 && Object.keys(responses).length > 10) {
      errors.push("All responses are identical - please answer more thoughtfully");
    }
    
    return {
      isValid: errors.length === 0,
      errors
    };
  }

  // Generate personalized relationship advice based on assessment scores
  static generateRelationshipAdvice(
    userScores: AssessmentScores,
    partnerScores: AssessmentScores | null,
    relationshipType: string
  ): {
    communication_style: string;
    conflict_approach: string;
    intimacy_preferences: string;
    growth_areas: string[];
    strengths: string[];
  } {
    // This would be a complex algorithm that considers multiple factors
    // For now, returning a basic structure that would be fully implemented
    return {
      communication_style: "Direct and empathetic communication works best for your personality combination.",
      conflict_approach: "Address conflicts early with a focus on understanding rather than winning.",
      intimacy_preferences: "Balance individual space with quality time together.",
      growth_areas: ["Active listening skills", "Emotional regulation", "Boundary setting"],
      strengths: ["Complementary personality traits", "Shared values", "Mutual respect"]
    };
  }
}
