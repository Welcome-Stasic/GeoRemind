import Foundation
import CoreLocation
import UserNotifications

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var remindersForMe: [Reminder] = []
    private var monitoredRegions: Set<String> = []
    
    var onNotification: ((Reminder) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        requestPermission()
    }
    
    func requestPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func updateReminders(_ reminders: [Reminder]) {
        self.remindersForMe = reminders.filter { $0.isActive }
        
        for regionId in monitoredRegions {
            let region = CLCircularRegion(center: CLLocationCoordinate2D(), radius: 0, identifier: regionId)
            locationManager.stopMonitoring(for: region)
        }
        monitoredRegions.removeAll()
        
        for reminder in self.remindersForMe {
            let region = CLCircularRegion(
                center: reminder.coordinate,
                radius: reminder.radius ?? 100,
                identifier: reminder.id.uuidString
            )
            region.notifyOnEntry = true
            locationManager.startMonitoring(for: region)
            monitoredRegions.insert(reminder.id.uuidString)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let reminder = remindersForMe.first(where: { $0.id.uuidString == region.identifier }) else {
            return
        }
        sendNotification(for: reminder)
        onNotification?(reminder)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Получены координаты: \(locations.first?.coordinate ?? CLLocationCoordinate2D())")
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    private func sendNotification(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        let senderName = reminder.creatorName ?? "Кто-то"
        content.title = "\(senderName) в зоне"
        content.body = reminder.title
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: reminder.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    func requestLocation(completion: @escaping (CLLocationCoordinate2D, String) -> Void) {
        self.locationManager.requestLocation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            
            if let location = self.locationManager.location {
                CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
                    let address = placemarks?.first?.name ?? "\(location.coordinate.latitude), \(location.coordinate.longitude)"
                    completion(location.coordinate, address)
                }
            } else {
                print("Не удалось получить местоположение")
            }
        }
    }
}
