import SwiftUI
import MapKit

struct RootView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "list.bullet.rectangle") }

            MapScreenView()
                .tabItem { Label("Map", systemImage: "map") }

            AdminView()
                .tabItem { Label("Pilot", systemImage: "slider.horizontal.3") }

            AboutView()
                .tabItem { Label("Project", systemImage: "info.circle") }
        }
        .tint(Theme.orange)
        .onAppear {
            store.refresh()
        }
    }
}

struct DashboardView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        dashboardHero
                        metricsGrid
                        filterPanel
                        prioritizedList
                    }
                    .padding(16)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: ScoredReport.self) { item in
                ReportDetailView(item: item)
            }
        }
    }

    private var dashboardHero: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(store.partner.city)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.orangeDark)
            Text("Neighborhood problems, sorted by urgency.")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.slate)
            Text("This list combines public reports and community posts to help people see what likely needs attention first.")
                .foregroundStyle(Theme.textSecondary)

            HStack(spacing: 10) {
                Label(store.partner.partnerName, systemImage: "person.2.fill")
                Label("\(store.filteredReports.count) issues shown", systemImage: "exclamationmark.bubble.fill")
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Theme.orangeDark)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Theme.orangeSoft, Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(store.metrics) { metric in
                VStack(alignment: .leading, spacing: 6) {
                    Text(metric.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary)
                    Text(metric.value)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.slate)
                    Text(metric.detail)
                        .font(.footnote)
                        .foregroundStyle(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Theme.card)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Theme.border, lineWidth: 1)
                )
            }
        }
    }

    private var filterPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose what to show")
                .font(.headline)
                .foregroundStyle(Theme.slate)

            HStack {
                filterMenu(
                    title: "Category",
                    currentValue: store.selectedCategory?.rawValue ?? "All"
                ) {
                    Button("All") { store.selectedCategory = nil }
                    ForEach(IssueCategory.allCases, id: \.self) { category in
                        Button(category.rawValue) {
                            store.selectedCategory = category
                        }
                    }
                }

                filterMenu(
                    title: "Neighborhood",
                    currentValue: store.selectedNeighborhood ?? "All"
                ) {
                    Button("All") { store.selectedNeighborhood = nil }
                    ForEach(store.neighborhoods, id: \.self) { name in
                        Button(name) {
                            store.selectedNeighborhood = name
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Minimum priority")
                    Spacer()
                    Text("\(Int((store.minimumScore * 100).rounded()))%")
                        .monospacedDigit()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)

                Slider(value: $store.minimumScore, in: 0...1, step: 0.05)
                    .tint(Theme.orange)
            }
        }
        .padding(16)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
    }

    private func filterMenu<Content: View>(title: String, currentValue: String, @ViewBuilder content: () -> Content) -> some View {
        Menu {
            content()
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary)
                Text(currentValue)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.slate)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.cardTint)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var prioritizedList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Issue list")
                    .font(.headline)
                Spacer()
                Button {
                    store.refresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.headline)
                        .foregroundStyle(Theme.orangeDark)
                }
            }
            .foregroundStyle(Theme.slate)

            ForEach(store.filteredReports) { item in
                NavigationLink(value: item) {
                    ReportCard(item: item)
                }
                .buttonStyle(.plain)
            }

            if store.filteredReports.isEmpty {
                ContentUnavailableView(
                    "No issues match this view",
                    systemImage: "line.3.horizontal.decrease.circle",
                    description: Text("Try lowering the minimum priority or choosing a different neighborhood.")
                )
                .padding(.top, 24)
            }
        }
    }
}

struct ReportCard: View {
    let item: ScoredReport

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.report.title)
                        .font(.headline)
                        .foregroundStyle(Theme.slate)
                    Text(item.report.neighborhood)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.orangeDark)
                }
                Spacer()
                bandBadge
            }

            Text(item.explanation)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.leading)

            HStack {
                statPill(label: item.category.rawValue, value: "\(Int((item.score * 100).rounded()))%")
                statPill(label: item.report.source.rawValue, value: item.report.status.rawValue)
                statPill(label: "Why it matters", value: item.report.partnerImpact)
            }
        }
        .padding(16)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
    }

    private var bandBadge: some View {
        Text(item.band.rawValue)
            .font(.footnote.weight(.bold))
            .foregroundStyle(.white)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(badgeColor.gradient)
            .clipShape(Capsule())
    }

    private var badgeColor: Color {
        switch item.band {
        case .critical:
            return Theme.danger
        case .high:
            return Theme.warning
        case .medium:
            return Theme.orangeDark
        case .watch:
            return Theme.success
        }
    }

    private func statPill(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2.weight(.semibold))
            Text(value)
                .font(.caption.weight(.bold))
        }
        .foregroundStyle(Theme.textSecondary)
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(Theme.cardTint)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct ReportDetailView: View {
    let item: ScoredReport

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(item.report.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.slate)

                HStack(spacing: 12) {
                    Label(item.report.source.rawValue, systemImage: "tray.full")
                    Label(item.report.status.rawValue, systemImage: "flag")
                    Text(item.report.createdAt, style: .date)
                }
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)

                detailCard(title: "AI explanation") {
                    Text("Why this was ranked highly")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.orangeDark)
                    Text(item.explanation)
                        .foregroundStyle(Theme.textSecondary)
                }

                detailCard(title: "What the app saw") {
                    VStack(alignment: .leading, spacing: 8) {
                        DetailRow(label: "Type of issue", value: item.category.rawValue)
                        DetailRow(label: "Urgency", value: "\(Int((item.urgency * 100).rounded()))%")
                        DetailRow(label: "Confidence", value: "\(Int((item.confidence * 100).rounded()))%")
                        DetailRow(label: "Community impact", value: "\(Int((item.equityScore * 100).rounded()))%")
                        DetailRow(label: "Address", value: item.report.address)
                        DetailRow(label: "Who may be affected", value: item.report.affectedPopulation ?? "General public")
                    }
                }

                detailCard(title: "Words that stood out") {
                    Text(item.evidence.isEmpty ? "No strong keywords stood out yet, so this item may need manual review." : item.evidence.joined(separator: ", "))
                        .foregroundStyle(Theme.textSecondary)
                }

                detailCard(title: "Original report") {
                    Text(item.report.body)
                        .foregroundStyle(Theme.slate)
                }
            }
            .padding(16)
        }
        .background(Theme.background)
        .navigationTitle("Report details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Theme.slate)
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(Theme.slate)
        }
        .font(.subheadline)
    }
}

struct MapScreenView: View {
    @EnvironmentObject private var store: AppStore
    @State private var selection: ScoredReport?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Issue map")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.slate)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                    Map(initialPosition: defaultCamera) {
                        ForEach(store.filteredReports) { item in
                            if let coordinate = item.coordinate {
                                Annotation(item.report.title, coordinate: coordinate) {
                                    Button {
                                        selection = item
                                    } label: {
                                        Circle()
                                            .fill(annotationColor(for: item.band))
                                            .frame(width: 18, height: 18)
                                            .overlay(Circle().stroke(.white, lineWidth: 2))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .padding(.horizontal, 16)
                    .frame(maxHeight: .infinity)

                    if let selection {
                        NavigationLink(value: selection) {
                            ReportCard(item: selection)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text("Tap a marker to read the report for that location.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                    }
                }
            }
            .navigationDestination(for: ScoredReport.self) { item in
                ReportDetailView(item: item)
            }
        }
    }

    private var defaultCamera: MapCameraPosition {
        .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 39.9765, longitude: -75.1551),
                span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
            )
        )
    }

    private func annotationColor(for band: PriorityBand) -> Color {
        switch band {
        case .critical:
            return Theme.danger
        case .high:
            return Theme.warning
        case .medium:
            return Theme.orange
        case .watch:
            return Theme.success
        }
    }
}

struct AdminView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        panel(title: "Pilot controls", subtitle: "Tune the transparent formula before you hand this to a community partner.") {
                            WeightSliders()
                        }

                        panel(title: "Data sources", subtitle: "Public information you can use for an early test.") {
                            VStack(alignment: .leading, spacing: 10) {
                                SourceRow(name: "311 service requests", detail: "Daily CSV/API export, public records")
                                SourceRow(name: "Public forums", detail: "Neighborhood Reddit or public boards only")
                                SourceRow(name: "Meeting minutes", detail: "Council, advisory board, or public hearing notes")
                            }
                        }

                        panel(title: "Export preview", subtitle: "A simple summary you could send to a partner or local office.") {
                            Text(store.exportPreview)
                                .font(.system(.footnote, design: .monospaced))
                                .foregroundStyle(Theme.slate)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        panel(title: "Before you pilot", subtitle: "A short checklist before testing this with real people.") {
                            VStack(alignment: .leading, spacing: 8) {
                                checklistRow("Partner feedback meeting booked")
                                checklistRow("Labeling guide written")
                                checklistRow("Privacy note reviewed")
                                checklistRow("Thresholds tuned for urgent recall")
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Pilot setup")
        }
        .onChange(of: store.weights) { _, _ in
            store.refresh()
        }
    }

    private func panel<Content: View>(title: String, subtitle: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Theme.slate)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
            content()
        }
        .padding(16)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
    }

    private func checklistRow(_ text: String) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Theme.success)
            Text(text)
                .foregroundStyle(Theme.slate)
        }
    }
}

struct WeightSliders: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sliderRow(title: "Urgency", value: $store.weights.urgency)
            sliderRow(title: "Recency", value: $store.weights.recency)
            sliderRow(title: "Status", value: $store.weights.status)
            sliderRow(title: "Equity", value: $store.weights.equity)
            sliderRow(title: "Confidence", value: $store.weights.confidence)
        }
    }

    private func sliderRow(title: String, value: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .foregroundStyle(Theme.slate)
                Spacer()
                Text(String(format: "%.2f", value.wrappedValue))
                    .monospacedDigit()
                    .foregroundStyle(Theme.textSecondary)
            }
            Slider(value: value, in: 0...1, step: 0.01)
                .tint(Theme.orange)
        }
    }
}

struct SourceRow: View {
    let name: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.slate)
            Text(detail)
                .font(.footnote)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Theme.cardTint)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
