import Foundation
import SwiftUI

@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var reports: [ScoredReport] = []
    @Published var selectedCategory: IssueCategory? = nil
    @Published var minScore: Double = 0.0

    private let loader = SampleDataLoader()

    init() {
        refresh()
    }

    func refresh() {
        let raw = loader.loadSampleReports()
        let scored = raw.map { CivicPipeline.scoreAndExplain($0) }
            .sorted { $0.score > $1.score }
        reports = scored
    }

    var filteredReports: [ScoredReport] {
        reports.filter { r in
            let categoryOK = selectedCategory == nil || r.category == selectedCategory
            let scoreOK = r.score >= minScore
            return categoryOK && scoreOK
        }
    }
}

