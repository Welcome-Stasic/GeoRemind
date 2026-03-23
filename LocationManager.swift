import Foundation
import CoreLocation
import UserNotifications

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var reminders: [Reminder] = []
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        loadReminders()
    }
    
    func requestPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func addReminder(title: String, at location: CLLocationCoordinate2D, address: String) {
        let reminder = Reminder(
            title: title,
            latitude: location.latitude,
            longitude: location.longitude,
            address: address
        )
        reminders.append(reminder)
        saveReminders()
        startMonitoring(reminder: reminder)
    }
    
    func removeReminder(_ reminder: Reminder) {
        stopMonitoring(reminder: reminder)
        reminders.removeAll { $0.id == reminder.id }
        saveReminders()
    }
    
    func toggleReminder(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index].isActive.toggle()
            if reminders[index].isActive {
                startMonitoring(reminder: reminders[index])
            } else {
                stopMonitoring(reminder: reminders[index])
            }
            saveReminders()
        }
    }
    
    private func startMonitoring(reminder: Reminder) {
        let region = CLCircularRegion(
            center: reminder.coordinate,
            radius: 100,
            identifier: reminder.id.uuidString
        )
        region.notifyOnEntry = true
        region.notifyOnExit = false
        locationManager.startMonitoring(for: region)
        print("Начинаем следить за: \(reminder.title) по координатам \(reminder.latitude), \(reminder.longitude)")
    }
    
    private func stopMonitoring(reminder: Reminder) {
        let region = CLCircularRegion(
            center: reminder.coordinate,
            radius: 100,
            identifier: reminder.id.uuidString
        )
        locationManager.stopMonitoring(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("ВОШЛИ В РЕГИОН: \(region.identifier)")
        guard let reminder = reminders.first(where: { $0.id.uuidString == region.identifier }) else { return }
        sendNotification(for: reminder)
    }
    
    private func sendNotification(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        
        content.title = "Вы на месте!"
        content.body = "\(reminder.title)"
        content.sound = .default
        content.badge = 1
        
        content.categoryIdentifier = "REMINDER_CATEGORY"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: reminder.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        let category = UNNotificationCategory(
            identifier: "REMINDER_CATEGORY",
            actions: [],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Ошибка: \(error)")
            } else {
                print("Уведомление отправлено")
            }
        }
    }
    
    private func saveReminders() {
        if let encoded = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(encoded, forKey: "reminders")
        }
    }
    
    private func loadReminders() {
        guard let data = UserDefaults.standard.data(forKey: "reminders"),
              let decoded = try? JSONDecoder().decode([Reminder].self, from: data) else { return }
        reminders = decoded
        for reminder in reminders where reminder.isActive {
            startMonitoring(reminder: reminder)
        }
    }
}
