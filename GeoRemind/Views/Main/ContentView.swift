import SwiftUI
import CoreLocation
import UserNotifications

struct ContentView: View {
    let user: UserProfile
    @StateObject private var remindersViewModel: RemindersViewModel
    @StateObject private var locationManager = LocationManager()
    @State private var showingAddReminder = false
    @State private var selectedTab = 0
    @State private var showingProfile = false
    
    init(user: UserProfile) {
        self.user = user
        _remindersViewModel = StateObject(wrappedValue: RemindersViewModel(currentUser: user))
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                List {
                    if remindersViewModel.myReminders.isEmpty {
                        ContentUnavailableView(
                            "Нет отправленных меток",
                            systemImage: "paperplane",
                            description: Text("Когда вы отправите метку другому человеку, она появится здесь")
                        )
                    } else {
                        ForEach(remindersViewModel.myReminders) { reminder in
                            reminderRow(reminder, isMyReminder: true)
                        }
                    }
                }
                .navigationTitle("Отправленные")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showingProfile = true
                        } label: {
                            Image(systemName: "person.circle")
                                .font(.title2)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingAddReminder = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .tabItem {
                Label("Отправленные", systemImage: "paperplane")
            }
            .tag(0)
            
            NavigationStack {
                List {
                    if remindersViewModel.remindersForMe.isEmpty {
                        ContentUnavailableView(
                            "Нет полученных меток",
                            systemImage: "bell",
                            description: Text("Когда кто-то отправит вам метку, она появится здесь")
                        )
                    } else {
                        ForEach(remindersViewModel.remindersForMe) { reminder in
                            reminderRow(reminder, isMyReminder: false)
                        }
                    }
                }
                .navigationTitle("Для меня")
            }
            .tabItem {
                Label("Для меня", systemImage: "bell.fill")
            }
            .tag(1)
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView(user: user)
        }
        .sheet(isPresented: $showingAddReminder) {
            AddReminderView(
                remindersViewModel: remindersViewModel,
                locationManager: locationManager,
                currentUser: user,
                availableUsers: remindersViewModel.allUsers
            )
        }
        .onAppear {
            Task {
                await remindersViewModel.loadData(for: user)
            }
            requestNotificationPermission()
            locationManager.requestPermission()
        }
        .refreshable {
            Task {
                await remindersViewModel.loadData(for: user)
            }
        }
    }
    
    @ViewBuilder
    private func reminderRow(_ reminder: Reminder, isMyReminder: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: reminder.isActive ? "location.fill" : "location.slash")
                    .foregroundColor(reminder.isActive ? .blue : .gray)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(reminder.title)
                        .font(.headline)
                        .strikethrough(!reminder.isActive)
                        .foregroundColor(reminder.isActive ? .primary : .secondary)
                    
                    Text(reminder.address)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 12) {
                        if let radius = reminder.radius {
                            Label("\(Int(radius)) м", systemImage: "circle.dotted")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        
                        if isMyReminder, let observerName = reminder.observerName {
                            Label("Отправлено: \(observerName)", systemImage: "paperplane")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                        
                        if !isMyReminder, let creatorName = reminder.creatorName {
                            Label("От: \(creatorName)", systemImage: "person.fill")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Spacer()
                
                if reminder.isActive {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            .padding(.vertical, 4)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                remindersViewModel.toggleReminder(reminder)
            } label: {
                Label(
                    reminder.isActive ? "Выключить" : "Включить",
                    systemImage: reminder.isActive ? "bell.slash" : "bell"
                )
            }
            .tint(reminder.isActive ? .orange : .green)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                remindersViewModel.deleteReminder(reminder, isMyReminder: isMyReminder)
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Разрешение на уведомления получено")
            } else if let error = error {
                print("Ошибка: \(error)")
            }
        }
    }
}

#Preview {
    ContentView(user: UserProfile(id: "preview", email: "preview@example.com", name: "Станислав"))
}
