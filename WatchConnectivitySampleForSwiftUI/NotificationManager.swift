import UserNotifications

class NotificationManager {
    static let instance = NotificationManager()

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Permission granted!") // ✅ Debug log
            } else if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "It's time to check your app!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false) // ⏳ 5 seconds delay
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)") // 🛑 Debug log
            } else {
                print("Notification Scheduled!") // ✅ Debug log
            }
        }
    }
}
