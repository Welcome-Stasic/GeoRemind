import Foundation
import CoreLocation

struct Reminder: Identifiable, Codable {
    let id: UUID
    var title: String
    var latitude: Double
    var longitude: Double
    var address: String
    var isActive: Bool
    
    var creatorID: String?
    var creatorName: String?
    var observerEmail: String?
    var observerName: String?
    var radius: Double?
    var createdAt: Date?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(id: UUID = UUID(),
         title: String,
         latitude: Double,
         longitude: Double,
         address: String,
         isActive: Bool = true,
         creatorID: String? = nil,
         creatorName: String? = nil,
         observerEmail: String? = nil,
         observerName: String? = nil,
         radius: Double? = nil,
         createdAt: Date? = nil) {
        self.id = id
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.isActive = isActive
        self.creatorID = creatorID
        self.creatorName = creatorName
        self.observerEmail = observerEmail
        self.observerName = observerName
        self.radius = radius
        self.createdAt = createdAt
    }
}
