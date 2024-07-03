class NotificationService {
  static int unreadNotificationsCount = 0;
  static List<Map<String, dynamic>> notifications = [];

  static void incrementNotificationCount() {
    unreadNotificationsCount++;
  }
static void decrementNotificationCount() {
    if (unreadNotificationsCount > 0) {
      unreadNotificationsCount--;
    }
  }

  static void clearNotifications() {
    unreadNotificationsCount = 0;
  }

  static void addNotification(String title, String message) {
    notifications.add({
      'title': title,
      'message': message,
    });
    incrementNotificationCount();
  }

  static void clearAllNotifications() {
    notifications.clear();
    clearNotifications();
  }
}
