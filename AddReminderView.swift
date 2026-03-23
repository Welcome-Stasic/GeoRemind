import SwiftUI
import CoreLocation
import MapKit

struct AddReminderView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var locationManager: LocationManager
    
    @State private var title = ""
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var selectedAddress = ""
    @State private var showingAddressSearch = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Что нужно сделать?") {
                    TextField("Например: купить молоко", text: $title)
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
            }
            .navigationTitle("Новое напоминание")
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
                    .disabled(title.isEmpty || selectedLocation == nil)
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
        guard let location = selectedLocation else { return }
        locationManager.addReminder(
            title: title,
            at: location,
            address: selectedAddress
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dismiss()
        }
    }
}
