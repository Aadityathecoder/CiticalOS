import SwiftUI
import MapKit

struct MapScreenView: View {
    @EnvironmentObject private var store: AppStore
    @State private var selection: ScoredReport?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Map")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                    Map(position: .constant(defaultCamera)) {
                        ForEach(store.filteredReports) { item in
                            if let coord = item.coordinate {
                                Annotation("", coordinate: coord) {
                                    Button {
                                        selection = item
                                    } label: {
                                        Circle()
                                            .fill(Theme.orange)
                                            .frame(width: 14, height: 14)
                                            .overlay(Circle().stroke(.white, lineWidth: 2))
                                            .shadow(color: .black.opacity(0.18), radius: 3, x: 0, y: 2)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel(item.report.title)
                                }
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.horizontal, 16)
                    .frame(maxHeight: .infinity)

                    if let item = selection {
                        NavigationLink(value: item) {
                            ReportCardView(item: item)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text("Tap a dot to preview an item.")
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
        // Centered on sample SF-ish coords; update when you pick a real city/partner.
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
        return .region(region)
    }
}

