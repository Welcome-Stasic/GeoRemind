//
//  AddressSearchView.swift
//  AddressSearchView
//
//  Created by Stanislav on 24/03/2026.
//

import SwiftUI
import MapKit

struct AddressSearchView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @Binding var selectedAddress: String
    
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Введите адрес", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onSubmit {
                        searchAddress()
                    }
                
                List(searchResults, id: \.self) { item in
                    Button {
                        selectedLocation = item.placemark.coordinate
                        selectedAddress = item.name ?? item.placemark.title ?? "Выбранное место"
                        dismiss()
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name ?? "Неизвестно")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(item.placemark.title ?? "")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Поиск места")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func searchAddress() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.resultTypes = .address
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let items = response?.mapItems {
                searchResults = items
            } else if let error = error {
                print("Ошибка поиска: \(error.localizedDescription)")
                searchResults = []
            }
        }
    }
}
