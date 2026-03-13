import Foundation
import CoreLocation

enum SourceType: String, Codable, CaseIterable, Hashable {
    case city311 = "311"
    case publicForum = "Forum"
    case meetingMinutes = "Minutes"
}

enum IssueCategory: String, Codable, CaseIterable, Hashable {
    case pothole = "Potholes"
    case streetlight = "Streetlights"
    case sanitation = "Sanitation"
    case safety = "Safety"
    case housing = "Housing"
    case socialServices = "Social Services"
    case other = "Other"
}

enum ReportStatus: String, Codable, CaseIterable, Hashable {
    case open = "Open"
    case pending = "Pending"
    case closed = "Closed"
}

enum PriorityBand: String, Hashable {
    case critical = "Critical"
    case high = "High"
    case medium = "Medium"
    case watch = "Watch"
}

struct CivicReport: Identifiable, Codable, Hashable {
    var id: UUID
    var source: SourceType
    var title: String
    var body: String
    var createdAt: Date
    var status: ReportStatus
    var neighborhood: String
    var address: String
    var latitude: Double?
    var longitude: Double?
    var partnerImpact: String
    var sourceURL: String?
    var suggestedCategory: IssueCategory?
    var suggestedUrgency: Double?
    var confidenceHint: Double?
    var vulnerabilityIndex: Double?
    var affectedPopulation: String?

    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return .init(latitude: lat, longitude: lon)
    }
}

struct PriorityWeights: Codable, Hashable {
    var urgency: Double = 0.38
    var recency: Double = 0.16
    var status: Double = 0.10
    var equity: Double = 0.20
    var confidence: Double = 0.16
}

struct ScoredReport: Identifiable, Hashable {
    var id: UUID { report.id }
    var report: CivicReport
    var category: IssueCategory
    var urgency: Double
    var confidence: Double
    var equityScore: Double
    var score: Double
    var band: PriorityBand
    var evidence: [String]
    var explanation: String

    var coordinate: CLLocationCoordinate2D? {
        report.coordinate
    }
}

struct DashboardMetric: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var value: String
    var detail: String
}

struct PartnerProfile: Hashable {
    var city: String
    var pilotNeighborhoods: [String]
    var partnerName: String
    var partnerType: String
}
