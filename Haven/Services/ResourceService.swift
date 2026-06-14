import Foundation
import CoreLocation

class ResourceService {
    static let shared = ResourceService()

    private var cache: [Resource] = []
    private var cacheTimestamp: Date?

    private init() {}

    func fetchNearbyResources(coordinate: CLLocationCoordinate2D?, radiusMeters: Double = 0) async throws -> [Resource] {
        if let ts = cacheTimestamp,
           Date().timeIntervalSince(ts) < Constants.Cache.expiryHours * 3600,
           !cache.isEmpty {
            return sorted(cache, near: coordinate)
        }

        let all = try await FirebaseService.shared.fetchResources()
        cache = all
        cacheTimestamp = Date()
        persist(all)

        return sorted(all, near: coordinate)
    }

    func cachedResources() -> [Resource] {
        if !cache.isEmpty { return cache }
        return loadPersisted()
    }

    // Returns ALL resources, sorted by proximity when a coordinate is available.
    private func sorted(_ resources: [Resource], near coordinate: CLLocationCoordinate2D?) -> [Resource] {
        guard let coordinate else { return resources }
        let center = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return resources.sorted { a, b in
            CLLocation(latitude: a.latitude, longitude: a.longitude).distance(from: center)
            < CLLocation(latitude: b.latitude, longitude: b.longitude).distance(from: center)
        }
    }

    private func persist(_ resources: [Resource]) {
        guard let data = try? JSONEncoder().encode(resources) else { return }
        try? data.write(to: cacheFileURL())
    }

    private func loadPersisted() -> [Resource] {
        guard let data = try? Data(contentsOf: cacheFileURL()),
              let resources = try? JSONDecoder().decode([Resource].self, from: data) else { return [] }
        return resources
    }

    private func cacheFileURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(Constants.Cache.resourcesFileName)
    }
}
