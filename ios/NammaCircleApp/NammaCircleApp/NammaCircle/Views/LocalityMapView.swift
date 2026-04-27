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
        ZStack {
            Map(position: $camera) {
                ForEach(viewModel.localities) { locality in
                    Annotation(locality.name, coordinate: locality.coordinate) {
                        NavigationLink {
                            LocalityDetailView(locality: locality)
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(FitColor.color(for: locality.recommendation.fit))
                                    .frame(width: 38, height: 38)
                                    .overlay(Circle().stroke(NammaColor.cream, lineWidth: 3))
                                    .shadow(color: NammaColor.deepGreen.opacity(0.22), radius: 8, x: 0, y: 4)
                                Text("\(locality.recommendation.score)")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.white)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))

            VStack {
                SectionCard {
                    HStack(spacing: 12) {
                        Image(systemName: "map.fill")
                            .foregroundStyle(NammaColor.deepGreen)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Bengaluru locality map")
                                .font(.headline)
                                .foregroundStyle(NammaColor.ink)
                            Text("Tap a score marker to inspect fit and risks.")
                                .font(.caption)
                                .foregroundStyle(NammaColor.muted)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                Spacer()
            }

            if viewModel.isLoading {
                LoadingStateView(message: "Loading localities")
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding()
            } else if viewModel.localities.isEmpty {
                EmptyStateView(title: "No localities", message: "No locality rows were returned from the active data source.")
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding()
            }

            if let errorMessage = viewModel.errorMessage {
                VStack {
                    ErrorBanner(message: errorMessage)
                    Spacer()
                }
                .padding()
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !viewModel.localities.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.localities) { locality in
                            NavigationLink {
                                LocalityDetailView(locality: locality)
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(locality.name)
                                            .font(.headline)
                                            .foregroundStyle(NammaColor.ink)
                                        Spacer()
                                        Text("\(locality.recommendation.score)")
                                            .font(.headline)
                                            .foregroundStyle(FitColor.color(for: locality.recommendation.fit))
                                    }
                                    Text(locality.recommendation.fit.title)
                                        .font(.caption)
                                        .foregroundStyle(NammaColor.muted)
                                }
                                .padding()
                                .frame(width: 170, alignment: .leading)
                                .background(NammaColor.card.opacity(0.92))
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(NammaColor.line.opacity(0.22), lineWidth: 1)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.inline)
        .tint(NammaColor.deepGreen)
        .task {
            viewModel.load()
        }
    }
}
