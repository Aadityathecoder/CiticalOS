import Foundation

struct DataLoader {
    func loadSampleReports() -> [CivicReport] {
        guard let url = Bundle.main.url(forResource: "SampleReports", withExtension: "json") else { return [] }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([CivicReport].self, from: data)
        } catch {
            print("Failed to load sample reports: \(error)")
            return []
        }
    }
}
