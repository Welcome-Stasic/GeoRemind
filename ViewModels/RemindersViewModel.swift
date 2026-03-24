import SwiftUI
import CoreLocation

@MainActor
class RemindersViewModel: ObservableObject {
    @Published var myReminders: [Reminder] = []
    @Published var remindersForMe: [Reminder] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var allUsers: [UserProfile] = []
    
    private let locationManager = LocationManager()
    private var currentUser: UserProfile?
    
    init(currentUser: UserProfile?) {
        self.currentUser = currentUser
        if let user = currentUser {
            Task {
                await loadData(for: user)
            }
        }
        
        locationManager.onNotification = { [weak self] reminder in
            print("Уведомление получено: \(reminder.title)")
        }
    }
    
    func loadData(for user: UserProfile) async {
        isLoading = true
        
        allUsers = [
            UserProfile(id: "1", email: user.email, name: "Я (\(user.name))"),
            UserProfile(id: "2", email: "pavel@com.com", name: "Павел"),
            UserProfile(id: "3", email: "anatoliy@com.com", name: "Анатолий"),
        ]
        
        if let savedData = UserDefaults.standard.data(forKey: "myReminders_\(user.id)"),
           let savedReminders = try? JSONDecoder().decode([Reminder].self, from: savedData) {
            myReminders = savedReminders
        }
        
        if let savedData = UserDefaults.standard.data(forKey: "remindersForMe_\(user.email)"),
           let savedReminders = try? JSONDecoder().decode([Reminder].self, from: savedData) {
            remindersForMe = savedReminders
        }
        
        let allActiveReminders = (myReminders + remindersForMe).filter { $0.isActive }
        locationManager.updateReminders(allActiveReminders)
        
        isLoading = false
    }
    
    func addReminder(title: String,
                     at location: CLLocationCoordinate2D,
                     address: String,
                     observerEmail: String,
                     observerName: String,
                     radius: Double) {
        guard let user = currentUser else { return }
        
        let isForMyself = (observerEmail == user.email)
        
        let reminder = Reminder(
            title: title,
            latitude: location.latitude,
            longitude: location.longitude,
            address: address,
            isActive: true,
            creatorID: user.id,
            creatorName: user.name,
            observerEmail: observerEmail,
            observerName: observerName,
            radius: radius,
            createdAt: Date()
        )
        
        if isForMyself {
            remindersForMe.insert(reminder, at: 0)
            saveRemindersForMe()
        } else {
            myReminders.insert(reminder, at: 0)
            saveMyReminders()
        }
        
        let allActiveReminders = (myReminders + remindersForMe).filter { $0.isActive }
        locationManager.updateReminders(allActiveReminders)
    }
    
    func deleteReminder(_ reminder: Reminder, isMyReminder: Bool) {
        guard let user = currentUser else { return }
        
        if isMyReminder {
            myReminders.removeAll { $0.id == reminder.id }
            saveMyReminders()
        } else {
            remindersForMe.removeAll { $0.id == reminder.id }
            saveRemindersForMe()
        }
        
        let allActiveReminders = (myReminders + remindersForMe).filter { $0.isActive }
        locationManager.updateReminders(allActiveReminders)
    }
    
    func toggleReminder(_ reminder: Reminder) {
        if let index = myReminders.firstIndex(where: { $0.id == reminder.id }) {
            myReminders[index].isActive.toggle()
            saveMyReminders()
        } else if let index = remindersForMe.firstIndex(where: { $0.id == reminder.id }) {
            remindersForMe[index].isActive.toggle()
            saveRemindersForMe()
        }
        
        let allActiveReminders = (myReminders + remindersForMe).filter { $0.isActive }
        locationManager.updateReminders(allActiveReminders)
    }
    
    private func saveMyReminders() {
        guard let user = currentUser else { return }
        if let encoded = try? JSONEncoder().encode(myReminders) {
            UserDefaults.standard.set(encoded, forKey: "myReminders_\(user.id)")
        }
    }
    
    private func saveRemindersForMe() {
        guard let user = currentUser else { return }
        if let encoded = try? JSONEncoder().encode(remindersForMe) {
            UserDefaults.standard.set(encoded, forKey: "remindersForMe_\(user.email)")
        }
    }
}
