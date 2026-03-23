import SwiftUI
import UserNotifications

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var showingAddReminder = false
    
    var body: some View {
        NavigationStack {
            List {
                if locationManager.reminders.isEmpty {
                    ContentUnavailableView(
                        "Нет напоминаний",
                        systemImage: "bell.slash",
                        description: Text("Нажмите + чтобы добавить новое напоминание")
                    )
                } else {
                    ForEach(locationManager.reminders) { reminder in
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
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "mappin.circle.fill")
                                            .font(.caption2)
                                        Text("\(String(format: "%.4f", reminder.latitude)), \(String(format: "%.4f", reminder.longitude))")
                                            .font(.caption2)
                                    }
                                    .foregroundColor(.gray)
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
                        .padding(.vertical, 4)
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                locationManager.toggleReminder(reminder)
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
                                locationManager.removeReminder(reminder)
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("ГеоНапоминания")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddReminder = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddReminder) {
                AddReminderView(locationManager: locationManager)
            }
            .onAppear {
                locationManager.requestPermission()
                requestNotificationPermission()
            }
            .navigationTitle("Мои места")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Разрешение на уведомления получено")
            } else if let error = error {
                print("Ошибка при запросе уведомлений: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
