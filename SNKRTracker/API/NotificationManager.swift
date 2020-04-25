import UserNotifications
import UIKit
protocol NotificationManagerProtocol: class {
    func requestNotificationAuthorizationIfNeeded()
    func sendNotification(with title: String, body: String)
    func sendNotification(for runs: [RunningWorkout])
}

final class NotificationManager {
    private let notificationCenter: UNUserNotificationCenter
    
    init(notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()) {
        self.notificationCenter = notificationCenter
        
//        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    private func requestPermissions() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { didAllow, error in
            guard didAllow else {
                print("User has declined notifications do something about it")
                return
            }
        }
    }

    private func authorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }
}

extension NotificationManager: NotificationManagerProtocol {
    func requestNotificationAuthorizationIfNeeded() {
        authorizationStatus { [weak self] status in
            if case .notDetermined = status {
                self?.requestPermissions()
            }
        }
    }
    
    func sendNotification(with title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        notificationCenter.add(request)
    }
    
    func sendNotification(for runs: [RunningWorkout]) {
        var message: String
        if runs.count == 1 {
            message = "Amazing \(runs.first?.distance?.distanceString ?? "") km run. In what sneakers did you make this workot?"
        } else {
            message = "You are insane"
        }
        
        sendNotification(with: "Wow", body: message)
    }
}
