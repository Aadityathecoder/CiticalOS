import SwiftUI

struct AboutView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        hero
                        card(
                            title: "What this app is for",
                            body: "This app helps community groups and local leaders quickly spot the biggest neighborhood problems, like broken streetlights, trash, potholes, and service gaps."
                        )
                        card(
                            title: "How it starts",
                            body: "Pick one city or neighborhood, collect public reports, clean the data, and label a starter set of examples so the system can learn what matters."
                        )
                        card(
                            title: "How it decides",
                            body: "The app looks for the type of problem, how urgent it seems, who may be affected, and whether the report is still open. It then ranks the issues in plain language."
                        )
                        card(
                            title: "First pilot",
                            body: "Test it with one local partner for a few weeks, ask whether the ranking is useful, and improve the app based on what they say."
                        )
                        card(
                            title: "Privacy note",
                            body: "Remove names, phone numbers, and email addresses before sharing data. Only use public or approved sources."
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
            Text("\(store.partner.city) pilot with \(store.partner.partnerName)")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)

            Text("Scope: \(store.partner.pilotNeighborhoods.joined(separator: ", "))")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.orangeDark)
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
