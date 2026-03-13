import Foundation

final class SampleDataLoader {
    func loadSampleReports() -> [CivicReport] {
        guard
            let url = Bundle.main.url(forResource: "SampleReports", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode([CivicReport].self, from: data)
        else {
            return []
        }
        return decoded
    }
}

