import Foundation

enum CivicPipeline {
    static func scoreAndExplain(_ report: CivicReport, now: Date = Date()) -> ScoredReport {
        let text = (report.title + " " + report.body).lowercased()
        let createdAt = ISO8601DateFormatter().date(from: report.createdAtISO) ?? now

        let (category, catSignals) = classifyCategory(text: text)
        let (urgency, urgencySignals) = estimateUrgency(text: text)
        let recency = recencyScore(createdAt: createdAt, now: now) // 0...1
        let openBoost: Double = {
            let s = (report.status ?? "").lowercased()
            if s.contains("open") || s.contains("pending") { return 0.10 }
            if s.contains("closed") || s.contains("resolved") { return -0.05 }
            return 0.0
        }()

        // Transparent scoring function (tunable)
        // - urgency drives most of the score
        // - recency matters (older = lower)
        // - open tickets get a small boost
        let score = clamp(0.60 * urgency + 0.30 * recency + openBoost, 0, 1)

        // Confidence is heuristic: more signals -> higher confidence
        let signalCount = Double(Set(catSignals + urgencySignals).count)
        let confidence = clamp(0.35 + 0.12 * signalCount, 0.40, 0.92)

        let keywords = Array(Set(catSignals + urgencySignals)).sorted()
        let urgencyPct = Int(round(urgency * 100))
        let scorePct = Int(round(score * 100))

        let explanation = """
        Prioritized as \(category.rawValue) with urgency \(urgencyPct)% (overall \(scorePct)%). \
        Triggered by \(keywords.isEmpty ? "general civic need language" : keywords.joined(separator: ", ")). \
        Reported \(relativeTimeString(from: createdAt, to: now)).
        """

        return ScoredReport(
            id: report.id,
            report: report,
            category: category,
            urgency: urgency,
            confidence: confidence,
            score: score,
            explanation: explanation,
            keywords: keywords
        )
    }

    // MARK: - Category

    private static func classifyCategory(text: String) -> (IssueCategory, [String]) {
        // Very lightweight lexicon baseline; replace with real model later.
        let rules: [(IssueCategory, [String])] = [
            (.pothole, ["pothole", "sinkhole", "road hole", "crater", "asphalt"]),
            (.streetlight, ["streetlight", "street light", "lamp", "light out", "dark street"]),
            (.sanitation, ["trash", "garbage", "dumping", "overflowing", "rats", "smell", "sanitation"]),
            (.graffiti, ["graffiti", "tagging", "vandalism"]),
            (.housing, ["eviction", "mold", "leak", "no heat", "landlord", "unsafe building"]),
            (.socialServices, ["overdose", "need shelter", "food pantry", "domestic", "mental health", "unhoused"])
        ]

        for (cat, keys) in rules {
            let hits = keys.filter { text.contains($0) }
            if !hits.isEmpty { return (cat, hits) }
        }
        return (.other, [])
    }

    // MARK: - Urgency

    private static func estimateUrgency(text: String) -> (Double, [String]) {
        let urgent = ["urgent", "asap", "immediately", "danger", "unsafe", "hazard", "emergency", "fire", "gas leak", "downed", "blocked"]
        let high = ["kids", "school", "elderly", "wheelchair", "bus stop", "crosswalk", "accident", "crime", "assault"]
        let mild = ["when you can", "sometime", "minor", "cosmetic"]

        let urgentHits = urgent.filter { text.contains($0) }
        let highHits = high.filter { text.contains($0) }
        let mildHits = mild.filter { text.contains($0) }

        var u = 0.30
        u += 0.25 * Double(urgentHits.count)
        u += 0.12 * Double(highHits.count)
        u -= 0.10 * Double(mildHits.count)
        u = clamp(u, 0, 1)

        return (u, urgentHits + highHits + mildHits)
    }

    private static func recencyScore(createdAt: Date, now: Date) -> Double {
        let days = max(0, now.timeIntervalSince(createdAt) / 86400.0)
        // 0 days -> 1.0, 30 days -> ~0.37, 90 days -> ~0.05
        let score = exp(-days / 30.0)
        return clamp(score, 0, 1)
    }

    private static func relativeTimeString(from: Date, to: Date) -> String {
        let seconds = Int(to.timeIntervalSince(from))
        if seconds < 60 { return "just now" }
        let minutes = seconds / 60
        if minutes < 60 { return "\(minutes)m ago" }
        let hours = minutes / 60
        if hours < 48 { return "\(hours)h ago" }
        let days = hours / 24
        return "\(days)d ago"
    }

    private static func clamp(_ x: Double, _ a: Double, _ b: Double) -> Double {
        min(max(x, a), b)
    }
}

