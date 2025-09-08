import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/app_config.dart';

/// Centralized notification service for the app
class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();
  
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Android initialization settings
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS initialization settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();
    
    _initialized = true;
  }

  /// Handle notification tap events
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      // Handle navigation based on payload
      _handleNotificationPayload(payload);
    }
  }

  /// Handle notification payload for navigation
  void _handleNotificationPayload(String payload) {
    // Parse payload and navigate accordingly
    // This would integrate with your router
    print('Notification tapped with payload: $payload');
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    for (final config in AppConfig.notificationConfigs.entries) {
      final channelConfig = config.value;
      
      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            AndroidNotificationChannel(
              channelConfig.channelId,
              channelConfig.channelName,
              importance: _mapImportance(channelConfig.importance),
            ),
          );
    }
  }

  Importance _mapImportance(NotificationImportance importance) {
    switch (importance) {
      case NotificationImportance.low:
        return Importance.low;
      case NotificationImportance.medium:
        return Importance.defaultImportance;
      case NotificationImportance.high:
        return Importance.high;
      case NotificationImportance.max:
        return Importance.max;
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  // =====================================
  // Insight Notifications
  // =====================================

  /// Show new insight notification
  Future<void> showInsightNotification({
    required String title,
    required String body,
    required String insightId,
    String? personName,
  }) async {
    if (!await areNotificationsEnabled()) return;

    const channelId = 'insights';
    final id = insightId.hashCode;

    await _notifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          AppConfig.notificationConfigs[channelId]!.channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF6366F1), // Primary color
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'insight:$insightId',
    );
  }

  /// Show relationship health alert
  Future<void> showRelationshipHealthAlert({
    required String personName,
    required int healthScore,
    required String advice,
  }) async {
    if (!await areNotificationsEnabled()) return;

    const channelId = 'insights';
    final title = 'Relationship Update: $personName';
    String body;
    
    if (healthScore < 40) {
      body = 'Your relationship health score has dropped to $healthScore. $advice';
    } else if (healthScore > 80) {
      body = 'Great news! Your relationship health score is $healthScore. $advice';
    } else {
      body = 'Relationship health score: $healthScore. $advice';
    }

    await _notifications.show(
      personName.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'Relationship Insights',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'health_alert:$personName',
    );
  }

  // =====================================
  // Task & Reminder Notifications
  // =====================================

  /// Schedule task reminder
  Future<void> scheduleTaskReminder({
    required String taskId,
    required String title,
    required String description,
    required DateTime scheduledTime,
    String? personName,
  }) async {
    if (!await areNotificationsEnabled()) return;

    const channelId = 'reminders';
    final id = taskId.hashCode;

    await _notifications.zonedSchedule(
      id,
      title,
      description,
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          AppConfig.notificationConfigs[channelId]!.channelName,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'task:$taskId',
    );
  }

  /// Schedule relationship check-in reminder
  Future<void> scheduleCheckInReminder({
    required String personName,
    required DateTime scheduledTime,
  }) async {
    if (!await areNotificationsEnabled()) return;

    const channelId = 'reminders';
    final title = 'Check in with $personName';
    const body = 'It\'s been a while since you connected. Consider reaching out.';

    await _notifications.zonedSchedule(
      personName.hashCode,
      title,
      body,
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'Reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'checkin:$personName',
    );
  }

  // =====================================
  // Assessment Notifications
  // =====================================

  /// Notify when assessment needs retaking
  Future<void> showAssessmentRetakeNotification({
    required String assessmentName,
    required String personName,
  }) async {
    if (!await areNotificationsEnabled()) return;

    const channelId = 'reminders';
    final title = 'Assessment Update Available';
    final body = 'Consider retaking the $assessmentName for $personName to get updated insights.';

    await _notifications.show(
      '$assessmentName$personName'.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'Reminders',
          importance: Importance.low,
          priority: Priority.low,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'assessment_retake:$assessmentName:$personName',
    );
  }

  // =====================================
  // Daily Summary Notifications
  // =====================================

  /// Schedule daily summary notification
  Future<void> scheduleDailySummary({
    required int hour,
    required int minute,
  }) async {
    if (!await areNotificationsEnabled()) return;

    const channelId = 'daily_summary';
    
    // Cancel existing daily summary
    await _notifications.cancel(9999);

    // Schedule new daily summary
    await _notifications.zonedSchedule(
      9999, // Fixed ID for daily summary
      'Daily Relationship Summary',
      'Check your relationship insights and pending tasks.',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'Daily Summary',
          importance: Importance.low,
          priority: Priority.low,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: false,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_summary',
    );
  }

  DateTime _nextInstanceOfTime(int hour, int minute) {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  // =====================================
  // Notification Management
  // =====================================

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel notifications by tag/type
  Future<void> cancelNotificationsByTag(String tag) async {
    // This would need to be implemented based on payload patterns
    // For now, we'll cancel all notifications
    await _notifications.cancelAll();
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Get active notifications (Android only)
  Future<List<ActiveNotification>> getActiveNotifications() async {
    final plugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await plugin?.getActiveNotifications() ?? [];
  }

  // =====================================
  // Notification Settings
  // =====================================

  /// Check if specific notification type is enabled
  Future<bool> isNotificationTypeEnabled(String type) async {
    // This would be stored in user preferences
    return true; // Simplified for now
  }

  /// Enable/disable specific notification type
  Future<void> setNotificationTypeEnabled(String type, bool enabled) async {
    // This would update user preferences
    // Implementation depends on your storage system
  }

  /// Get notification settings
  Map<String, bool> getNotificationSettings() {
    // Return current notification settings
    return {
      'insights': true,
      'reminders': true,
      'daily_summary': true,
      'assessment_updates': true,
    };
  }

  /// Update notification settings
  Future<void> updateNotificationSettings(Map<String, bool> settings) async {
    // Update user preferences and reschedule notifications as needed
    for (final entry in settings.entries) {
      await setNotificationTypeEnabled(entry.key, entry.value);
    }
  }

  /// Test notification (for debugging)
  Future<void> showTestNotification() async {
    await _notifications.show(
      0,
      'Test Notification',
      'This is a test notification from Relationship Navigator.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test',
          'Test Notifications',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
