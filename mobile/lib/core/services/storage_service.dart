import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

/// Centralized storage service for local data persistence
class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  
  StorageService._();

  late Box<dynamic> _userPrefsBox;
  late Box<Map<dynamic, dynamic>> _personalityDataBox;
  late Box<Map<dynamic, dynamic>> _interactionCacheBox;
  late Box<Map<dynamic, dynamic>> _insightsCacheBox;
  late SharedPreferences _sharedPrefs;

  /// Initialize all storage systems
  Future<void> initialize() async {
    // Initialize SharedPreferences for simple key-value storage
    _sharedPrefs = await SharedPreferences.getInstance();
    
    // Initialize Hive boxes for structured data
    _userPrefsBox = await Hive.openBox(AppConfig.userPrefsBox);
    _personalityDataBox = await Hive.openBox<Map<dynamic, dynamic>>(AppConfig.personalityDataBox);
    _interactionCacheBox = await Hive.openBox<Map<dynamic, dynamic>>(AppConfig.interactionCacheBox);
    _insightsCacheBox = await Hive.openBox<Map<dynamic, dynamic>>(AppConfig.insightsCacheBox);
  }

  /// Clear all local storage (for logout/reset)
  Future<void> clearAll() async {
    await _userPrefsBox.clear();
    await _personalityDataBox.clear();
    await _interactionCacheBox.clear();
    await _insightsCacheBox.clear();
    await _sharedPrefs.clear();
  }

  // =====================================
  // User Preferences
  // =====================================

  /// Get user preference
  T? getUserPref<T>(String key, {T? defaultValue}) {
    return _userPrefsBox.get(key, defaultValue: defaultValue) as T?;
  }

  /// Set user preference
  Future<void> setUserPref<T>(String key, T value) async {
    await _userPrefsBox.put(key, value);
  }

  /// Remove user preference
  Future<void> removeUserPref(String key) async {
    await _userPrefsBox.delete(key);
  }

  // =====================================
  // Assessment & Personality Data
  // =====================================

  /// Store assessment result
  Future<void> storeAssessmentResult(String resultId, Map<String, dynamic> result) async {
    await _personalityDataBox.put(resultId, result);
  }

  /// Get assessment result
  Map<String, dynamic>? getAssessmentResult(String resultId) {
    final result = _personalityDataBox.get(resultId);
    return result?.cast<String, dynamic>();
  }

  /// Get all assessment results for a person
  List<Map<String, dynamic>> getAssessmentResultsForPerson(String personId) {
    final results = <Map<String, dynamic>>[];
    
    for (final key in _personalityDataBox.keys) {
      final result = _personalityDataBox.get(key)?.cast<String, dynamic>();
      if (result != null && result['person_id'] == personId) {
        results.add(result);
      }
    }
    
    return results;
  }

  /// Remove assessment result
  Future<void> removeAssessmentResult(String resultId) async {
    await _personalityDataBox.delete(resultId);
  }

  // =====================================
  // Interaction Cache
  // =====================================

  /// Cache interaction data
  Future<void> cacheInteraction(String interactionId, Map<String, dynamic> interaction) async {
    final timestamped = Map<String, dynamic>.from(interaction);
    timestamped['cached_at'] = DateTime.now().toIso8601String();
    await _interactionCacheBox.put(interactionId, timestamped);
  }

  /// Get cached interaction
  Map<String, dynamic>? getCachedInteraction(String interactionId) {
    final interaction = _interactionCacheBox.get(interactionId);
    return interaction?.cast<String, dynamic>();
  }

  /// Get cached interactions for a person
  List<Map<String, dynamic>> getCachedInteractionsForPerson(String personId) {
    final interactions = <Map<String, dynamic>>[];
    
    for (final key in _interactionCacheBox.keys) {
      final interaction = _interactionCacheBox.get(key)?.cast<String, dynamic>();
      if (interaction != null && interaction['person_id'] == personId) {
        interactions.add(interaction);
      }
    }
    
    // Sort by timestamp, most recent first
    interactions.sort((a, b) {
      final aTime = DateTime.tryParse(a['action_timestamp'] ?? '');
      final bTime = DateTime.tryParse(b['action_timestamp'] ?? '');
      if (aTime == null || bTime == null) return 0;
      return bTime.compareTo(aTime);
    });
    
    return interactions;
  }

  /// Remove expired cached interactions
  Future<void> cleanupExpiredInteractions() async {
    final cutoff = DateTime.now().subtract(Duration(days: AppConfig.maxCacheAge));
    final keysToDelete = <dynamic>[];
    
    for (final key in _interactionCacheBox.keys) {
      final interaction = _interactionCacheBox.get(key);
      if (interaction != null) {
        final cachedAt = DateTime.tryParse(interaction['cached_at'] ?? '');
        if (cachedAt != null && cachedAt.isBefore(cutoff)) {
          keysToDelete.add(key);
        }
      }
    }
    
    for (final key in keysToDelete) {
      await _interactionCacheBox.delete(key);
    }
  }

  // =====================================
  // Insights Cache
  // =====================================

  /// Cache insight data
  Future<void> cacheInsight(String insightId, Map<String, dynamic> insight) async {
    final timestamped = Map<String, dynamic>.from(insight);
    timestamped['cached_at'] = DateTime.now().toIso8601String();
    await _insightsCacheBox.put(insightId, timestamped);
  }

  /// Get cached insight
  Map<String, dynamic>? getCachedInsight(String insightId) {
    final insight = _insightsCacheBox.get(insightId);
    return insight?.cast<String, dynamic>();
  }

  /// Get cached insights for a person
  List<Map<String, dynamic>> getCachedInsightsForPerson(String personId) {
    final insights = <Map<String, dynamic>>[];
    
    for (final key in _insightsCacheBox.keys) {
      final insight = _insightsCacheBox.get(key)?.cast<String, dynamic>();
      if (insight != null && insight['person_id'] == personId) {
        insights.add(insight);
      }
    }
    
    // Sort by priority and recency
    insights.sort((a, b) {
      final aPriority = a['priority_level'] ?? 0;
      final bPriority = b['priority_level'] ?? 0;
      if (aPriority != bPriority) {
        return bPriority.compareTo(aPriority); // Higher priority first
      }
      
      final aTime = DateTime.tryParse(a['generated_at'] ?? '');
      final bTime = DateTime.tryParse(b['generated_at'] ?? '');
      if (aTime == null || bTime == null) return 0;
      return bTime.compareTo(aTime); // More recent first
    });
    
    return insights;
  }

  /// Remove expired insights
  Future<void> cleanupExpiredInsights() async {
    final cutoff = DateTime.now().subtract(Duration(days: AppConfig.maxCacheAge));
    final keysToDelete = <dynamic>[];
    
    for (final key in _insightsCacheBox.keys) {
      final insight = _insightsCacheBox.get(key);
      if (insight != null) {
        // Check if insight has explicit expiry
        final expiresAt = DateTime.tryParse(insight['expires_at'] ?? '');
        if (expiresAt != null && expiresAt.isBefore(DateTime.now())) {
          keysToDelete.add(key);
          continue;
        }
        
        // Check cache age
        final cachedAt = DateTime.tryParse(insight['cached_at'] ?? '');
        if (cachedAt != null && cachedAt.isBefore(cutoff)) {
          keysToDelete.add(key);
        }
      }
    }
    
    for (final key in keysToDelete) {
      await _insightsCacheBox.delete(key);
    }
  }

  // =====================================
  // SharedPreferences Helpers
  // =====================================

  /// Get string from SharedPreferences
  String? getString(String key, {String? defaultValue}) {
    return _sharedPrefs.getString(key) ?? defaultValue;
  }

  /// Set string in SharedPreferences
  Future<bool> setString(String key, String value) {
    return _sharedPrefs.setString(key, value);
  }

  /// Get bool from SharedPreferences
  bool getBool(String key, {bool defaultValue = false}) {
    return _sharedPrefs.getBool(key) ?? defaultValue;
  }

  /// Set bool in SharedPreferences
  Future<bool> setBool(String key, bool value) {
    return _sharedPrefs.setBool(key, value);
  }

  /// Get int from SharedPreferences
  int getInt(String key, {int defaultValue = 0}) {
    return _sharedPrefs.getInt(key) ?? defaultValue;
  }

  /// Set int in SharedPreferences
  Future<bool> setInt(String key, int value) {
    return _sharedPrefs.setInt(key, value);
  }

  /// Get double from SharedPreferences
  double getDouble(String key, {double defaultValue = 0.0}) {
    return _sharedPrefs.getDouble(key) ?? defaultValue;
  }

  /// Set double in SharedPreferences
  Future<bool> setDouble(String key, double value) {
    return _sharedPrefs.setDouble(key, value);
  }

  /// Get string list from SharedPreferences
  List<String> getStringList(String key, {List<String>? defaultValue}) {
    return _sharedPrefs.getStringList(key) ?? defaultValue ?? [];
  }

  /// Set string list in SharedPreferences
  Future<bool> setStringList(String key, List<String> value) {
    return _sharedPrefs.setStringList(key, value);
  }

  /// Remove key from SharedPreferences
  Future<bool> remove(String key) {
    return _sharedPrefs.remove(key);
  }

  // =====================================
  // JSON Helpers
  // =====================================

  /// Store JSON data
  Future<void> storeJson(String boxName, String key, Map<String, dynamic> data) async {
    final box = await Hive.openBox<Map<dynamic, dynamic>>(boxName);
    await box.put(key, data);
  }

  /// Get JSON data
  Future<Map<String, dynamic>?> getJson(String boxName, String key) async {
    final box = await Hive.openBox<Map<dynamic, dynamic>>(boxName);
    final data = box.get(key);
    return data?.cast<String, dynamic>();
  }

  /// Store JSON string in SharedPreferences
  Future<bool> setJsonString(String key, Map<String, dynamic> data) {
    final jsonString = jsonEncode(data);
    return setString(key, jsonString);
  }

  /// Get JSON from SharedPreferences
  Map<String, dynamic>? getJsonString(String key) {
    final jsonString = getString(key);
    if (jsonString == null) return null;
    
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // =====================================
  // Utility Methods
  // =====================================

  /// Get storage statistics
  Map<String, dynamic> getStorageStats() {
    return {
      'user_prefs_count': _userPrefsBox.length,
      'personality_data_count': _personalityDataBox.length,
      'interaction_cache_count': _interactionCacheBox.length,
      'insights_cache_count': _insightsCacheBox.length,
      'shared_prefs_keys': _sharedPrefs.getKeys().length,
    };
  }

  /// Check if storage is healthy
  bool isHealthy() {
    try {
      // Basic health checks
      final _ = _userPrefsBox.isOpen;
      final __ = _personalityDataBox.isOpen;
      final ___ = _interactionCacheBox.isOpen;
      final ____ = _insightsCacheBox.isOpen;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Compact all boxes to optimize storage
  Future<void> compact() async {
    await _userPrefsBox.compact();
    await _personalityDataBox.compact();
    await _interactionCacheBox.compact();
    await _insightsCacheBox.compact();
  }

  /// Close all storage systems
  Future<void> close() async {
    await _userPrefsBox.close();
    await _personalityDataBox.close();
    await _interactionCacheBox.close();
    await _insightsCacheBox.close();
  }
}

/// Storage service extensions for specific data types
extension PersonalityStorageExtension on StorageService {
  /// Store Big Five scores
  Future<void> storeBigFiveScores(String personId, Map<String, double> scores) async {
    final key = 'big_five_$personId';
    await storeAssessmentResult(key, {
      'person_id': personId,
      'assessment_type': 'big_five',
      'scores': scores,
      'completed_at': DateTime.now().toIso8601String(),
    });
  }

  /// Get Big Five scores
  Map<String, double>? getBigFiveScores(String personId) {
    final key = 'big_five_$personId';
    final result = getAssessmentResult(key);
    if (result == null) return null;
    
    final scores = result['scores'] as Map<String, dynamic>?;
    return scores?.cast<String, double>();
  }

  /// Store attachment style
  Future<void> storeAttachmentStyle(String personId, String style, Map<String, double> scores) async {
    final key = 'attachment_$personId';
    await storeAssessmentResult(key, {
      'person_id': personId,
      'assessment_type': 'attachment',
      'primary_style': style,
      'scores': scores,
      'completed_at': DateTime.now().toIso8601String(),
    });
  }

  /// Get attachment style
  String? getAttachmentStyle(String personId) {
    final key = 'attachment_$personId';
    final result = getAssessmentResult(key);
    return result?['primary_style'] as String?;
  }
}
