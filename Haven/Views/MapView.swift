import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = MapViewModel()
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
    )

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.showList {
                    resourceList
                } else {
                    resourceMap
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchQuery, prompt: L10n.t(.searchPlaceholder))
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Haven")
                        .font(.custom("Snell Roundhand", size: 28).bold())
                        .foregroundStyle(
                            LinearGradient(colors: [.blue, Color(red: 0.2, green: 0.5, blue: 1.0)],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                }
            }
            .havenSOS()
            .safeAreaInset(edge: .top, spacing: 0) {
                categoryChips
            }
            .onChange(of: viewModel.searchQuery) { _, _ in
                Task { @MainActor in viewModel.applySearchFilter() }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation { viewModel.showList.toggle() }
                    } label: {
                        Image(systemName: viewModel.showList ? "map.fill" : "list.bullet")
                    }
                }
            }
            .sheet(item: $viewModel.selectedResource) { resource in
                ResourceDetailSheet(resource: resource, viewModel: viewModel)
                    .presentationDetents([.medium, .large])
            }
            .onChange(of: viewModel.focusCoordinate?.latitude) { _, _ in
                guard let coord = viewModel.focusCoordinate else { return }
                Task { @MainActor in
                    withAnimation {
                        cameraPosition = .region(MKCoordinateRegion(
                            center: coord,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        ))
                    }
                }
            }
            .task {
                viewModel.requestLocation()
                viewModel.primaryLocation = appState.primaryLocation
                await viewModel.loadResources()
            }
            .onChange(of: appState.primaryLocation) { _, loc in
                viewModel.primaryLocation = loc
                Task { await viewModel.loadResources() }
            }
        }
    }

    // MARK: - Category Chips (under search bar)

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if !viewModel.selectedCategories.isEmpty {
                    Button {
                        viewModel.clearFilters()
                    } label: {
                        Label("Clear", systemImage: "xmark.circle.fill")
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(Color.red.opacity(0.12))
                            .foregroundColor(.red)
                            .clipShape(Capsule())
                    }
                }

                ForEach(ResourceCategory.allCases, id: \.self) { cat in
                    CategoryBubble(
                        category: cat,
                        isSelected: viewModel.selectedCategories.contains(cat),
                        action: { viewModel.toggleCategory(cat) }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(.ultraThinMaterial)
    }

    // MARK: - Map

    private var resourceMap: some View {
        ZStack(alignment: .bottom) {
            Map(position: $cameraPosition) {
                // User's current GPS location
                UserAnnotation()

                // Resource pins
                ForEach(viewModel.filteredResources) { resource in
                    Annotation(resource.name, coordinate: resource.coordinate, anchor: .bottom) {
                        ResourceMapPin(resource: resource, isSelected: viewModel.selectedResource?.id == resource.id)
                            .onTapGesture { viewModel.selectResource(resource) }
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }

    // MARK: - List

    private var resourceList: some View {
        List(viewModel.filteredResources) { resource in
            ResourceCard(resource: resource, userLocation: viewModel.userLocation)
                .onTapGesture { viewModel.selectedResource = resource }
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
    }
}

// MARK: - Category Bubble (icon + label, rounded)

struct CategoryBubble: View {
    let category: ResourceCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color(hex: category.colorHex) : Color(hex: category.colorHex).opacity(0.15))
                        .frame(width: 58, height: 58)
                    Image(systemName: category.icon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? .white : Color(hex: category.colorHex))
                }
                Text(category.rawValue)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(isSelected ? Color(hex: category.colorHex) : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .frame(width: 64)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Map Pin

struct ResourceMapPin: View {
    let resource: Resource
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(Color(hex: resource.category.colorHex))
                    .frame(width: isSelected ? 48 : 36, height: isSelected ? 48 : 36)
                    .shadow(color: Color(hex: resource.category.colorHex).opacity(0.5), radius: isSelected ? 8 : 3)

                Image(systemName: resource.category.icon)
                    .font(.system(size: isSelected ? 20 : 15))
                    .foregroundColor(.white)
            }

            Triangle()
                .fill(Color(hex: resource.category.colorHex))
                .frame(width: 12, height: 7)
        }
        .animation(.spring(duration: 0.2), value: isSelected)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.closeSubpath()
        return p
    }
}

// MARK: - Resource Detail Sheet

struct ResourceDetailSheet: View {
    let resource: Resource
    @ObservedObject var viewModel: MapViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var aiExplanation: String?
    @State private var isExplaining = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color(hex: resource.category.colorHex).opacity(0.15))
                        .frame(width: 56, height: 56)
                    Image(systemName: resource.category.icon)
                        .font(.title2)
                        .foregroundColor(Color(hex: resource.category.colorHex))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(resource.name).font(.headline)
                    Text(resource.category.rawValue)
                        .font(.caption)
                        .foregroundColor(Color(hex: resource.category.colorHex))
                        .fontWeight(.semibold)
                }
                Spacer()
                if resource.isVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(icon: "mappin.circle.fill", text: resource.address)
                    if let phone = resource.phone {
                        DetailRow(icon: "phone.circle.fill", text: phone)
                    }
                    if let hours = resource.hours {
                        DetailRow(icon: "clock.fill", text: hours)
                    }
                    if let distance = resource.distanceDisplay(from: viewModel.userLocation) {
                        DetailRow(icon: "location.fill", text: distance)
                    }
                    DetailRow(icon: "text.alignleft", text: resource.description)

                    if !resource.requiresID {
                        HStack {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                            Text("No ID required").font(.subheadline).foregroundColor(.green)
                        }
                    }

                    if !resource.languages.isEmpty {
                        HStack {
                            Image(systemName: "globe").foregroundColor(.secondary)
                            Text("Languages: \(resource.languages.joined(separator: ", "))")
                                .font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }

            if let explanation = aiExplanation {
                VStack(alignment: .leading, spacing: 8) {
                    Label("What is this place?", systemImage: "sparkles")
                        .font(.caption.bold())
                        .foregroundColor(.blue)
                    Text(explanation).font(.caption).foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            } else if isExplaining {
                HStack(spacing: 8) {
                    ProgressView().scaleEffect(0.8)
                    Text("Explaining this resource…").font(.caption).foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }

            VStack(spacing: 10) {
                Button {
                    Task { await explain() }
                } label: {
                    Label(aiExplanation == nil ? L10n.t(.whatIsThis) : L10n.t(.reExplain),
                          systemImage: "questionmark.circle.fill")
                        .frame(maxWidth: .infinity)
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(isExplaining)

                Button { viewModel.navigateTo(resource) } label: {
                    Label(L10n.t(.getDirections), systemImage: "arrow.triangle.turn.up.right.circle.fill")
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                if let phone = resource.phone {
                    Button {
                        guard let url = URL(string: "tel://\(phone.filter(\.isNumber))") else { return }
                        UIApplication.shared.open(url)
                    } label: {
                        Label("Call \(phone)", systemImage: "phone.fill")
                            .frame(maxWidth: .infinity)
                            .font(.headline)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
            }
            .padding()
        }
    }

    private func explain() async {
        isExplaining = true
        aiExplanation = try? await ClaudeService.shared.explainResource(resource)
        isExplaining = false
    }
}

struct DetailRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            Text(text).font(.subheadline)
        }
    }
}

// MARK: - Resource Card (List)

struct ResourceCard: View {
    let resource: Resource
    let userLocation: CLLocation?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                ZStack {
                    Circle()
                        .fill(Color(hex: resource.category.colorHex).opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: resource.category.icon)
                        .foregroundColor(Color(hex: resource.category.colorHex))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(resource.name).font(.subheadline.bold())
                    Text(resource.category.rawValue)
                        .font(.caption)
                        .foregroundColor(Color(hex: resource.category.colorHex))
                }

                Spacer()

                if let distance = resource.distanceDisplay(from: userLocation) {
                    Text(distance).font(.caption.bold()).foregroundColor(.secondary)
                }
            }

            Text(resource.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            HStack(spacing: 12) {
                if let hours = resource.hours {
                    Label(hours, systemImage: "clock")
                        .font(.caption2).foregroundColor(.secondary)
                }
                if !resource.requiresID {
                    Label("No ID", systemImage: "checkmark.circle.fill")
                        .font(.caption2).foregroundColor(.green)
                }
            }
        }
        .padding(12)
        .havenCard()
    }
}
