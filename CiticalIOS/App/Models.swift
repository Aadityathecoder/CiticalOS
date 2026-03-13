import Foundation
import CoreLocation

enum SourceType: String, Codable, CaseIterable {
    case city311 = "311"
    case forum = "Forum"
    case minutes = "Minutes"
}

enum IssueCategory: String, Codable, CaseIterable {
    case pothole = "Pothole"
    case streetlight = "Streetlight"
    case sanitation = "Sanitation"
    case graffiti = "Graffiti"
    case housing = "Housing"
    case socialServices = "Social Services"
    case other = "Other"
}

struct CivicReport: Identifiable, Codable, Hashable {
    let id: String
    var source: SourceType
    var createdAtISO: String
    var title: String
    var body: String
    var addressHint: String?
    var latitude: Double?
    var longitude: Double?
    var status: String?
}

struct ScoredReport: Identifiable, Hashable {
    let id: String
    let report: CivicReport
    let category: IssueCategory
    let urgency: Double     // 0...1
    let confidence: Double  // 0...1
    let score: Double
    let explanation: String
    let keywords: [String]

    var createdAt: Date? {
        ISO8601DateFormatter().date(from: report.createdAtISO)
    }

    var coordinate: CLLocationCoordinate2D? {
        guard let lat = report.latitude, let lon = report.longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

