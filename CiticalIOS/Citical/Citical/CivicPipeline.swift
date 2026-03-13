import Foundation

enum CivicPipeline {
    static func score(report: CivicReport, weights: PriorityWeights, now: Date) -> ScoredReport {
        let text = (report.title + " " + report.body).lowercased()
        let inferredCategory = report.suggestedCategory ?? classifyCategory(in: text).category
        let categorySignals = classifyCategory(in: text).signals
        let urgencySignals = detectUrgencySignals(in: text)
        let urgency = clamp(report.suggestedUrgency ?? urgencySignals.score, 0, 1)
        let confidence = clamp(report.confidenceHint ?? inferredConfidence(categorySignals: categorySignals, urgencySignals: urgencySignals.signals), 0.35, 0.95)
        let recency = recencyScore(from: report.createdAt, now: now)
        let statusBoost = statusScore(report.status)
        let equity = clamp(report.vulnerabilityIndex ?? equitySignals(in: text), 0, 1)

        let rawScore = (weights.urgency * urgency)
            + (weights.recency * recency)
            + (weights.status * statusBoost)
            + (weights.equity * equity)
            + (weights.confidence * confidence)
        let score = clamp(rawScore, 0, 1)
        let evidence = Array(Set(categorySignals + urgencySignals.signals)).sorted()
        let band = priorityBand(for: score)
        let explanation = buildExplanation(
            report: report,
            category: inferredCategory,
            urgency: urgency,
            confidence: confidence,
            equity: equity,
            score: score,
            evidence: evidence
        )

        return ScoredReport(
            report: report,
            category: inferredCategory,
            urgency: urgency,
            confidence: confidence,
            equityScore: equity,
            score: score,
            band: band,
            evidence: evidence,
            explanation: explanation
        )
    }

    private static func classifyCategory(in text: String) -> (category: IssueCategory, signals: [String]) {
        let rules: [(IssueCategory, [String])] = [
            (.pothole, ["pothole", "sinkhole", "asphalt", "crater", "road hole"]),
            (.streetlight, ["streetlight", "street light", "lamp", "dark block", "light out"]),
            (.sanitation, ["trash", "garbage", "dumping", "rats", "overflowing", "sanitation"]),
            (.safety, ["unsafe", "crosswalk", "blocked sidewalk", "crime", "danger"]),
            (.housing, ["mold", "eviction", "no heat", "unsafe building", "landlord"]),
            (.socialServices, ["shelter", "food pantry", "unhoused", "overdose", "mental health"])
        ]

        for rule in rules {
            let hits = rule.1.filter(text.contains)
            if !hits.isEmpty {
                return (rule.0, hits)
            }
        }

        return (.other, [])
    }

    private static func detectUrgencySignals(in text: String) -> (score: Double, signals: [String]) {
        let urgentSignals = ["urgent", "immediately", "children", "school", "dark", "danger", "blocked", "wheelchair", "elderly", "overnight"]
        let slowerSignals = ["ongoing", "weeks", "cosmetic", "sometime"]

        let hot = urgentSignals.filter(text.contains)
        let cool = slowerSignals.filter(text.contains)

        var urgency = 0.34
        urgency += Double(hot.count) * 0.12
        urgency -= Double(cool.count) * 0.05
        return (clamp(urgency, 0, 1), hot + cool)
    }

    private static func inferredConfidence(categorySignals: [String], urgencySignals: [String]) -> Double {
        let evidenceCount = Set(categorySignals + urgencySignals).count
        return 0.42 + (Double(evidenceCount) * 0.08)
    }

    private static func recencyScore(from date: Date, now: Date) -> Double {
        let days = max(0, now.timeIntervalSince(date) / 86_400)
        return clamp(exp(-days / 21), 0, 1)
    }

    private static func statusScore(_ status: ReportStatus) -> Double {
        switch status {
        case .open:
            return 1
        case .pending:
            return 0.75
        case .closed:
            return 0.2
        }
    }

    private static func equitySignals(in text: String) -> Double {
        let markers = ["bus stop", "wheelchair", "school", "shelter", "elderly", "public housing"]
        let hits = markers.filter(text.contains).count
        return clamp(0.3 + Double(hits) * 0.1, 0, 1)
    }

    private static func priorityBand(for score: Double) -> PriorityBand {
        switch score {
        case 0.80...:
            return .critical
        case 0.65..<0.80:
            return .high
        case 0.45..<0.65:
            return .medium
        default:
            return .watch
        }
    }

    private static func buildExplanation(
        report: CivicReport,
        category: IssueCategory,
        urgency: Double,
        confidence: Double,
        equity: Double,
        score: Double,
        evidence: [String]
    ) -> String {
        let urgencyText = Int((urgency * 100).rounded())
        let confidenceText = Int((confidence * 100).rounded())
        let equityText = Int((equity * 100).rounded())
        let priorityText = Int((score * 100).rounded())
        let evidenceText = evidence.isEmpty ? "general civic-need language" : evidence.joined(separator: ", ")

        return "\(category.rawValue) issue scored \(priorityText)% priority for \(report.neighborhood). Urgency \(urgencyText)%, confidence \(confidenceText)%, equity modifier \(equityText)% from cues like \(evidenceText)."
    }

    private static func clamp(_ value: Double, _ minimum: Double, _ maximum: Double) -> Double {
        min(max(value, minimum), maximum)
    }
}
