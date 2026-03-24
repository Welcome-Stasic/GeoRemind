import SwiftUI
import CoreLocation

struct AddReminderView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var remindersViewModel: RemindersViewModel
    let currentUser: UserProfile
    let availableUsers: [UserProfile]
    
    @State private var title = ""
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var selectedAddress = ""
    @State private var selectedObserver: UserProfile?
    @State private var radius: Double = 100
    @State private var showingAddressSearch = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Что нужно сделать?") {
                    TextField("Например: купить молоко", text: $title)
                }
                
                Section("Кому?") {
                    Picker("Выберите наблюдателя", selection: $selectedObserver) {
                        Text("Выберите человека").tag(nil as UserProfile?)
                        ForEach(availableUsers, id: \.self) { user in
                            Text(user.name)
                                .tag(user as UserProfile?)
                        }
                    }
                }
                
                Section("Где?") {
                    if let location = selectedLocation {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(selectedAddress)
                                .font(.subheadline)
                            Text("\(String(format: "%.4f", location.latitude)), \(String(format: "%.4f", location.longitude))")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        Button("Выбрать другое место") {
                            showingAddressSearch = true
                        }
                        .font(.caption)
                    } else {
                        Button("Выбрать место") {
                            showingAddressSearch = true
                        }
                    }
                }
                
                Section("Радиус срабатывания (\(Int(radius)) м)") {
                    Slider(value: $radius, in: 50...500, step: 50)
                    .tint(.blue)
                    
                    HStack {
                        Text("50 м")
                        Spacer()
                        Text("500 м")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
            }
            .navigationTitle("Новая метка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        saveReminder()
                    }
                    .disabled(title.isEmpty || selectedLocation == nil || selectedObserver == nil)
                }
            }
            .sheet(isPresented: $showingAddressSearch) {
                AddressSearchView(
                    selectedLocation: $selectedLocation,
                    selectedAddress: $selectedAddress
                )
            }
        }
    }
    
    private func saveReminder() {
        guard let location = selectedLocation,
              let observer = selectedObserver else { return }
        
        remindersViewModel.addReminder(
            title: title,
            at: location,
            address: selectedAddress,
            observerEmail: observer.email,
            observerName: observer.name,
            radius: radius
        )
        dismiss()
    }
}

#Preview {
    AddReminderView(
        remindersViewModel: RemindersViewModel(currentUser: nil),
        currentUser: UserProfile(id: "1", email: "me@test.com", name: "Я"),
        availableUsers: [
            UserProfile(id: "1", email: "me@test.com", name: "Я"),
            UserProfile(id: "2", email: "pavel@com.com", name: "Павел"),
            UserProfile(id: "3", email: "anatoliy@com.com", name: "Анатолий")
        ]
    )
}
