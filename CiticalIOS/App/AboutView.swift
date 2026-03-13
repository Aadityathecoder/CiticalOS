import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        hero
                        card(
                            title: "What this prototype does",
                            body: "Reads local civic-style items (sample JSON), predicts a category + urgency, computes a transparent priority score, and shows a short explanation."
                        )
                        card(
                            title: "How to pilot",
                            body: "Pick 1 city + 2–4 issue categories. Replace `SampleReports.json` with a monthly export (311 CSV→JSON or forum posts). Tune the scoring weights in `CivicPipeline` with your partner."
                        )
                        card(
                            title: "Privacy note",
                            body: "Before using real reports, remove personal identifiers (names, phone numbers, emails). Only use public/consented sources."
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Civic Needs AI")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Theme.textPrimary)
            Text("Compact, community-focused prioritization with clear explanations.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)

            Button("Replace sample data") {
                // Instructional button (no action in prototype)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(true)
            .opacity(0.7)
        }
        .padding(14)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
    }

    private func card(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)
            Text(body)
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
}

