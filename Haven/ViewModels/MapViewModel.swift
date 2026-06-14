import Foundation
import MapKit
import Combine
import SwiftUI
import CoreLocation

@MainActor
class MapViewModel: ObservableObject {
    @Published var resources: [Resource] = []
    @Published var filteredResources: [Resource] = []
    @Published var selectedCategories: Set<ResourceCategory> = []
    @Published var selectedResource: Resource?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showList = false
    @Published var searchQuery = ""
    @Published private(set) var focusCoordinate: CLLocationCoordinate2D?

    // Used for sorting resources by proximity (not for filtering)
    var primaryLocation: CLLocation?

    private let resourceService = ResourceService.shared
    private let finderService = ResourceFinderService.shared
    private let locationService = LocationService.shared
    private var cancellables = Set<AnyCancellable>()

    var userLocation: CLLocation? { locationService.currentLocation }

    init() {
        locationService.$currentLocation
            .compactMap { $0 }
            .removeDuplicates { $0.coordinate.latitude == $1.coordinate.latitude && $0.coordinate.longitude == $1.coordinate.longitude }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loc in
                Task { @MainActor in
                    self?.focusCoordinate = loc.coordinate
                }
            }
            .store(in: &cancellables)

        Task { await loadResources() }
    }

    func loadResources() async {
        isLoading = true
        defer { isLoading = false }

        let fetchCoordinate = primaryLocation?.coordinate
            ?? locationService.currentLocation?.coordinate

        do {
            // No radius cap — all resources are returned, sorted by proximity
            resources = try await resourceService.fetchNearbyResources(coordinate: fetchCoordinate)
        } catch {
            errorMessage = "Could not load resources. Showing cached data."
            resources = resourceService.cachedResources()
        }
        applyFilters()
    }

    func toggleCategory(_ category: ResourceCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
        applyFilters()
    }

    func clearFilters() {
        selectedCategories.removeAll()
        searchQuery = ""
        applyFilters()
    }

    func applySearchFilter() {
        applyFilters()
    }

    func selectResource(_ resource: Resource) {
        selectedResource = resource
        focusCoordinate = resource.coordinate
    }

    func navigateTo(_ resource: Resource) {
        locationService.openInMaps(
            name: resource.name,
            address: resource.address,
            coordinate: resource.coordinate
        )
    }

    func requestLocation() {
        locationService.requestLocation()
    }

    func formattedResults(for query: String) -> String {
        finderService.formattedResults(
            for: query,
            resources: filteredResources,
            near: userLocation
        )
    }

    private func applyFilters() {
        var result = resources

        if !selectedCategories.isEmpty {
            result = result.filter { selectedCategories.contains($0.category) }
        }
        if !searchQuery.isEmpty {
            result = finderService.filter(query: searchQuery, resources: result)
        }
        filteredResources = result
    }
}
