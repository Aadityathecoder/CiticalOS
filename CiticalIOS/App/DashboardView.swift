import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                VStack(spacing: 14) {
                    header
                    filters
                    list
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .navigationBarHidden(true)
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Citical")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                Text("Neighborhood needs, prioritized with explanations.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            Button {
                store.refresh()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.headline)
                    .foregroundStyle(Theme.orangeDeep)
                    .padding(10)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Theme.border, lineWidth: 1)
                    )
            }
            .accessibilityLabel("Refresh")
        }
    }

    private var filters: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Category")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Picker("Category", selection: $store.selectedCategory) {
                    Text("All").tag(IssueCategory?.none)
                    ForEach(IssueCategory.allCases, id: \.self) { c in
                        Text(c.rawValue).tag(IssueCategory?.some(c))
                    }
                }
                .pickerStyle(.menu)
                .tint(Theme.orangeDeep)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Minimum priority")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text("\(Int(store.minScore * 100))%")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(Theme.textSecondary)
                }
                Slider(value: $store.minScore, in: 0...1, step: 0.05)
                    .tint(Theme.orange)
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

    private var list: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(store.filteredReports) { item in
                    NavigationLink(value: item) {
                        ReportCardView(item: item)
                    }
                    .buttonStyle(.plain)
                }

                if store.filteredReports.isEmpty {
                    ContentUnavailableView(
                        "No items match filters",
                        systemImage: "line.3.horizontal.decrease.circle",
                        description: Text("Try lowering the minimum priority or selecting “All”.")
                    )
                    .padding(.top, 28)
                }
            }
            .padding(.vertical, 4)
        }
        .navigationDestination(for: ScoredReport.self) { item in
            ReportDetailView(item: item)
        }
    }
}

