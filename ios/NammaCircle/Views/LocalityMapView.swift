import SwiftUI
import MapKit

struct LocalityMapView: View {
    @StateObject private var viewModel = LocalityViewModel()
    @State private var camera = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 12.95, longitude: 77.64),
            span: MKCoordinateSpan(latitudeDelta: 0.22, longitudeDelta: 0.22)
        )
    )

    var body: some View {
        Map(position: $camera) {
            ForEach(viewModel.localities) { locality in
                Annotation(locality.name, coordinate: locality.coordinate) {
                    NavigationLink {
                        LocalityDetailView(locality: locality)
                    } label: {
                        Circle()
                            .fill(FitColor.color(for: locality.recommendation.fit))
                            .frame(width: 18, height: 18)
                            .overlay(Circle().stroke(.white, lineWidth: 3))
                            .shadow(radius: 4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.localities) { locality in
                        NavigationLink {
                            LocalityDetailView(locality: locality)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(locality.name).font(.headline)
                                Text("\(locality.recommendation.score) / \(locality.recommendation.fit.title)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Locality Map")
        .task {
            viewModel.load()
        }
    }
}
