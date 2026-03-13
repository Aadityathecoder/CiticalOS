import SwiftUI

struct ReportCardView: View {
    let item: ScoredReport

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                badge
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.report.title)
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(2)
                    Text(item.category.rawValue + " • " + item.report.source.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer(minLength: 8)
                scorePill
            }

            Text(item.explanation)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .lineLimit(2)

            if let hint = item.report.addressHint, !hint.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundStyle(Theme.orangeDeep)
                    Text(hint)
                        .font(.footnote)
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                }
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

    private var badge: some View {
        let color = badgeColor(for: item.category)
        return RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(color.opacity(0.16))
            .frame(width: 44, height: 44)
            .overlay(
                Image(systemName: badgeIcon(for: item.category))
                    .font(.headline)
                    .foregroundStyle(color)
            )
            .accessibilityHidden(true)
    }

    private var scorePill: some View {
        let pct = Int(round(item.score * 100))
        return Text("\(pct)%")
            .font(.subheadline.weight(.semibold).monospacedDigit())
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                LinearGradient(
                    colors: [Theme.orange, Theme.orangeDeep],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(Capsule())
            .accessibilityLabel("Priority \(pct) percent")
    }

    private func badgeIcon(for category: IssueCategory) -> String {
        switch category {
        case .pothole: return "car.fill"
        case .streetlight: return "lightbulb.fill"
        case .sanitation: return "trash.fill"
        case .graffiti: return "paintbrush.fill"
        case .housing: return "house.fill"
        case .socialServices: return "cross.case.fill"
        case .other: return "exclamationmark.bubble.fill"
        }
    }

    private func badgeColor(for category: IssueCategory) -> Color {
        switch category {
        case .pothole: return Theme.orangeDeep
        case .streetlight: return Theme.orange
        case .sanitation: return Color(red: 0.86, green: 0.35, blue: 0.16)
        case .graffiti: return Color(red: 0.82, green: 0.28, blue: 0.22)
        case .housing: return Color(red: 0.92, green: 0.42, blue: 0.14)
        case .socialServices: return Color(red: 0.80, green: 0.22, blue: 0.18)
        case .other: return Theme.orangeDeep
        }
    }
}

