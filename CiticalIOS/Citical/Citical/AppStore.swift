import Foundation
import Combine

@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var reports: [ScoredReport] = []
    @Published var selectedCategory: IssueCategory? = nil
    @Published var selectedNeighborhood: String? = nil
    @Published var minimumScore: Double = 0.45
    @Published var weights = PriorityWeights()

    let partner = PartnerProfile(
        city: "Philadelphia Pilot",
        pilotNeighborhoods: ["Kensington", "West Philly", "North Central"],
        partnerName: "Neighborhood Action Collaborative",
        partnerType: "Community partner"
    )

    private let loader = DataLoader()

    init() {
        refresh()
    }

    func refresh() {
        let loaded = loader.loadSampleReports()
        reports = loaded
            .map { CivicPipeline.score(report: $0, weights: weights, now: Date()) }
            .sorted { lhs, rhs in
                if lhs.score == rhs.score {
                    return lhs.report.createdAt > rhs.report.createdAt
                }
                return lhs.score > rhs.score
            }
    }

    var filteredReports: [ScoredReport] {
        reports.filter { item in
            let scoreMatch = item.score >= minimumScore
            let categoryMatch = selectedCategory == nil || item.category == selectedCategory
            let neighborhoodMatch = selectedNeighborhood == nil || item.report.neighborhood == selectedNeighborhood
            return scoreMatch && categoryMatch && neighborhoodMatch
        }
    }

    var neighborhoods: [String] {
        Array(Set(reports.map(\.report.neighborhood))).sorted()
    }

    var metrics: [DashboardMetric] {
        let items = filteredReports.isEmpty ? reports : filteredReports
        let criticalCount = items.filter { $0.band == .critical }.count
        let averageScore = items.isEmpty ? 0 : items.map(\.score).reduce(0, +) / Double(items.count)
        let openCount = items.filter { $0.report.status != .closed }.count
        let topNeighborhood = Dictionary(grouping: items, by: \.report.neighborhood)
            .max { $0.value.count < $1.value.count }?
            .key ?? "N/A"

        return [
            DashboardMetric(title: "Needs attention", value: "\(criticalCount)", detail: "Most urgent issues right now"),
            DashboardMetric(title: "Average priority", value: "\(Int((averageScore * 100).rounded()))%", detail: "Overall urgency across the list"),
            DashboardMetric(title: "Not fixed yet", value: "\(openCount)", detail: "Reports still open or pending"),
            DashboardMetric(title: "Most active area", value: topNeighborhood, detail: "Neighborhood with the most reports")
        ]
    }

    var exportPreview: String {
        let lines = filteredReports.prefix(5).enumerated().map { index, item in
            "\(index + 1). \(item.report.title) | \(item.band.rawValue) | \(Int((item.score * 100).rounded()))% | \(item.report.neighborhood)"
        }
        return lines.joined(separator: "\n")
    }
}
