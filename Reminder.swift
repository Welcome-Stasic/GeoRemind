import Foundation
import CoreLocation

struct Reminder: Identifiable, Codable {
    let id: UUID
    var title: String
    var latitude: Double
    var longitude: Double
    var address: String
    var isActive: Bool
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(id: UUID = UUID(), title: String, latitude: Double, longitude: Double, address: String, isActive: Bool = true) {
        self.id = id
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.isActive = isActive
    }
}
