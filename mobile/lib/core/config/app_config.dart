/// Application configuration and constants
/// Environment-specific settings and feature flags
class AppConfig {
  AppConfig._();
  
  // Environment
  static const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
  static const bool isDebug = environment == 'development';
  static const bool isProduction = environment == 'production';
  
  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'your-supabase-url-here',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-supabase-anon-key-here',
  );
  
  // Feature Flags
  static const bool enableAstrology = bool.fromEnvironment('ENABLE_ASTROLOGY', defaultValue: true);
  static const bool enableMessageAnalysis = bool.fromEnvironment('ENABLE_MESSAGE_ANALYSIS', defaultValue: true);
  static const bool enableAdvancedPredictions = bool.fromEnvironment('ENABLE_ADVANCED_PREDICTIONS', defaultValue: false);
  
  // API Endpoints
  static const String baseApiUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://your-api-endpoint.com',
  );
  
  // App Metadata
  static const String appName = 'Relationship Navigator';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // Storage Keys
  static const String userPrefsBox = 'user_prefs';
  static const String personalityDataBox = 'personality_data';
  static const String interactionCacheBox = 'interaction_cache';
  static const String insightsCacheBox = 'insights_cache';
  
  // Privacy & Security
  static const int encryptionKeyLength = 32;
  static const int maxCacheAge = 7; // days
  static const int sessionTimeoutMinutes = 60;
  
  // Assessment Configuration
  static const Map<String, AssessmentConfig> assessmentConfigs = {
    'big_five': AssessmentConfig(
      maxQuestions: 50,
      timeoutMinutes: 30,
      retakeIntervalDays: 90,
    ),
    'mbti': AssessmentConfig(
      maxQuestions: 70,
      timeoutMinutes: 45,
      retakeIntervalDays: 365,
    ),
    'enneagram': AssessmentConfig(
      maxQuestions: 45,
      timeoutMinutes: 25,
      retakeIntervalDays: 180,
    ),
    'disc': AssessmentConfig(
      maxQuestions: 40,
      timeoutMinutes: 20,
      retakeIntervalDays: 90,
    ),
    'attachment': AssessmentConfig(
      maxQuestions: 30,
      timeoutMinutes: 15,
      retakeIntervalDays: 180,
    ),
    'emotional_intelligence': AssessmentConfig(
      maxQuestions: 60,
      timeoutMinutes: 35,
      retakeIntervalDays: 120,
    ),
  };
  
  // AI & ML Configuration
  static const double defaultConfidenceThreshold = 0.75;
  static const int predictionHorizonDays = 30;
  static const int maxInteractionHistory = 1000;
  static const int minInteractionsForPrediction = 5;
  
  // UI Configuration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounceDelay = Duration(milliseconds: 500);
  static const int maxRecentProfiles = 10;
  
  // Notification Configuration
  static const Map<String, NotificationConfig> notificationConfigs = {
    'insights': NotificationConfig(
      channelId: 'insights',
      channelName: 'Relationship Insights',
      importance: NotificationImportance.high,
    ),
    'reminders': NotificationConfig(
      channelId: 'reminders',
      channelName: 'Task Reminders',
      importance: NotificationImportance.medium,
    ),
    'daily_summary': NotificationConfig(
      channelId: 'daily_summary',
      channelName: 'Daily Summary',
      importance: NotificationImportance.low,
    ),
  };
  
  // Platform-specific Configuration
  static const Map<String, dynamic> iosConfig = {
    'enableBackgroundRefresh': false,
    'shareSheetIntegration': true,
    'siriIntegration': false,
  };
  
  static const Map<String, dynamic> androidConfig = {
    'enableSMSAnalysis': true,
    'backgroundProcessing': true,
    'workManagerEnabled': true,
  };
  
  // Development/Testing Configuration
  static const bool enableDetailedLogging = isDebug;
  static const bool enableAnalytics = isProduction;
  static const bool enableCrashReporting = isProduction;
  static const bool enableTestData = isDebug;
}

class AssessmentConfig {
  final int maxQuestions;
  final int timeoutMinutes;
  final int retakeIntervalDays;
  
  const AssessmentConfig({
    required this.maxQuestions,
    required this.timeoutMinutes,
    required this.retakeIntervalDays,
  });
}

class NotificationConfig {
  final String channelId;
  final String channelName;
  final NotificationImportance importance;
  
  const NotificationConfig({
    required this.channelId,
    required this.channelName,
    required this.importance,
  });
}

enum NotificationImportance {
  low,
  medium,
  high,
  max,
}

/// Environment-specific configurations
class EnvironmentConfig {
  static Map<String, dynamic> get current {
    switch (AppConfig.environment) {
      case 'production':
        return productionConfig;
      case 'staging':
        return stagingConfig;
      case 'development':
      default:
        return developmentConfig;
    }
  }
  
  static const Map<String, dynamic> productionConfig = {
    'apiTimeout': 30000, // 30 seconds
    'retryAttempts': 3,
    'logLevel': 'error',
    'enableMockData': false,
    'cacheStrategy': 'aggressive',
  };
  
  static const Map<String, dynamic> stagingConfig = {
    'apiTimeout': 45000, // 45 seconds
    'retryAttempts': 5,
    'logLevel': 'info',
    'enableMockData': true,
    'cacheStrategy': 'normal',
  };
  
  static const Map<String, dynamic> developmentConfig = {
    'apiTimeout': 60000, // 60 seconds
    'retryAttempts': 1,
    'logLevel': 'debug',
    'enableMockData': true,
    'cacheStrategy': 'minimal',
  };
}
