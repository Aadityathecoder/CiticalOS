import SwiftUI
import MapKit

struct ReportDetailView: View {
    let item: ScoredReport

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    titleCard
                    explanationCard
                    signalsCard
                    if let coord = item.coordinate {
                        mapCard(coord: coord)
                    }
                    rawTextCard
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var titleCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.report.title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("\(item.category.rawValue) • \(item.report.source.rawValue)")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    meter(label: "Priority", value: item.score)
                    meter(label: "Urgency", value: item.urgency)
                    meter(label: "Confidence", value: item.confidence)
                }
            }

            if let hint = item.report.addressHint, !hint.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundStyle(Theme.orangeDeep)
                    Text(hint)
                        .font(.footnote)
                        .foregroundStyle(Theme.textSecondary)
                }
            }

            if let status = item.report.status, !status.isEmpty {
                Text("Status: \(status)")
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(14)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
    }

    private var explanationCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Explanation")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)
            Text(item.explanation)
                .font(.body)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(14)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
    }

    private var signalsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Signals")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)

            if item.keywords.isEmpty {
                Text("No strong keyword signals found. This was prioritized mostly by general urgency + recency.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            } else {
                FlowTagsView(tags: item.keywords)
            }
        }
        .padding(14)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
    }

    private func mapCard(coord: CLLocationCoordinate2D) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Map")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)

            Map(initialPosition: .region(MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))) {
                Marker(item.report.title, coordinate: coord)
                    .tint(Theme.orange)
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(14)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
    }

    private var rawTextCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Original text")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)
            Text(item.report.body)
                .font(.body)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(14)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
    }

    private func meter(label: String, value: Double) -> some View {
        let pct = Int(round(value * 100))
        return HStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
            Text("\(pct)%")
                .font(.caption.monospacedDigit().weight(.semibold))
                .foregroundStyle(Theme.textPrimary)
                .frame(width: 44, alignment: .trailing)
        }
    }
}

private struct FlowTagsView: View {
    let tags: [String]

    var body: some View {
        LayoutTags(tags: tags) { tag in
            Text(tag)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.orangeDeep)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Theme.orange.opacity(0.14))
                .clipShape(Capsule())
        }
    }
}

private struct LayoutTags<TagView: View>: View {
    let tags: [String]
    let tagView: (String) -> TagView

    init(tags: [String], @ViewBuilder tagView: @escaping (String) -> TagView) {
        self.tags = tags
        self.tagView = tagView
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            var currentLine: [String] = []
            var currentWidth: CGFloat = 0

            GeometryReader { geo in
                let maxWidth = geo.size.width
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(lines(maxWidth: maxWidth), id: \.self) { line in
                        HStack(spacing: 8) {
                            ForEach(line, id: \.self) { t in
                                tagView(t)
                            }
                            Spacer(minLength: 0)
                        }
                    }
                }
            }
            .frame(minHeight: 10)

            // Dummy usage to satisfy stored vars above (no-op)
            _ = { () -> Void in
                _ = currentLine
                _ = currentWidth
            }()
        }
    }

    private func lines(maxWidth: CGFloat) -> [[String]] {
        var result: [[String]] = [[]]
        var currentLineWidth: CGFloat = 0

        func chipWidth(_ s: String) -> CGFloat {
            // Rough estimate; good enough for layout without UIKit measurement.
            CGFloat(22 + s.count * 7)
        }

        for tag in tags {
            let w = chipWidth(tag) + 8
            if currentLineWidth + w > maxWidth, !result.last!.isEmpty {
                result.append([tag])
                currentLineWidth = w
            } else {
                result[result.count - 1].append(tag)
                currentLineWidth += w
            }
        }
        return result
    }
}

