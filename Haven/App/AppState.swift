import Foundation
import Combine
import CoreLocation

class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: HavenUser?
    @Published var showEmergencyOverlay = false
    @Published var preferredLanguage: HavenUser.Language = .english
    @Published var isOfflineMode = false

    // Profile fields
    @Published var profileName: String = ""
    @Published var profilePhone: String = ""
    @Published var profileEmail: String = ""
    @Published var profileOccupation: String = ""
    @Published var profileHomeStatus: String = ""
    @Published var profilePrimaryCity: String = ""

    // Geocoded home location for 20-mile radius filtering
    @Published var primaryLocation: CLLocation?

    static let shared = AppState()

    static let occupationOptions = [
        "Student", "Employed (Full-time)", "Employed (Part-time)",
        "Self-employed", "Unemployed", "Retired", "Unable to work", "N/A"
    ]

    static let homeStatusOptions = [
        "Stably Housed", "At Risk of Losing Housing", "Staying with Others",
        "In a Shelter", "Living Outdoors or in Vehicle",
        "In Transitional Housing", "Other"
    ]

    var userId: String {
        if let uid = currentUser?.uid { return uid }
        if let saved = UserDefaults.standard.string(forKey: "guestUserId") { return saved }
        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: "guestUserId")
        return newId
    }

    init() {
        if let code = UserDefaults.standard.string(forKey: "preferredLanguage"),
           let lang = HavenUser.Language(rawValue: code) {
            preferredLanguage = lang
        }
        profileName       = UserDefaults.standard.string(forKey: "profileName")       ?? ""
        profilePhone      = UserDefaults.standard.string(forKey: "profilePhone")      ?? ""
        profileEmail      = UserDefaults.standard.string(forKey: "profileEmail")      ?? ""
        profileOccupation = UserDefaults.standard.string(forKey: "profileOccupation") ?? ""
        profileHomeStatus = UserDefaults.standard.string(forKey: "profileHomeStatus") ?? ""
        profilePrimaryCity = UserDefaults.standard.string(forKey: "profilePrimaryCity") ?? ""
        isAuthenticated   = UserDefaults.standard.bool(forKey: "isLoggedIn")

        if isAuthenticated {
            currentUser = HavenUser(
                uid: userId,
                displayName: profileName,
                preferredLanguage: preferredLanguage,
                createdAt: Date(),
                lastActiveAt: Date()
            )
            if !profilePrimaryCity.isEmpty {
                Task { await geocodePrimaryCity(profilePrimaryCity) }
            }
        }
    }

    func signIn(
        name: String, phone: String, email: String,
        occupation: String, homeStatus: String, primaryCity: String
    ) {
        profileName        = name
        profilePhone       = phone
        profileEmail       = email
        profileOccupation  = occupation
        profileHomeStatus  = homeStatus
        profilePrimaryCity = primaryCity

        UserDefaults.standard.set(name,       forKey: "profileName")
        UserDefaults.standard.set(phone,      forKey: "profilePhone")
        UserDefaults.standard.set(email,      forKey: "profileEmail")
        UserDefaults.standard.set(occupation, forKey: "profileOccupation")
        UserDefaults.standard.set(homeStatus, forKey: "profileHomeStatus")
        UserDefaults.standard.set(primaryCity, forKey: "profilePrimaryCity")
        UserDefaults.standard.set(true,       forKey: "isLoggedIn")

        currentUser = HavenUser(
            uid: userId,
            displayName: name,
            preferredLanguage: preferredLanguage,
            createdAt: Date(),
            lastActiveAt: Date()
        )
        isAuthenticated = true

        if !primaryCity.isEmpty {
            Task { await geocodePrimaryCity(primaryCity) }
        }
    }

    func signOut() {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        currentUser = nil
        primaryLocation = nil
        isAuthenticated = false
    }

    func setLanguage(_ language: HavenUser.Language) {
        preferredLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "preferredLanguage")
    }

    @MainActor
    func geocodePrimaryCity(_ cityOrZip: String) async {
        let geocoder = CLGeocoder()
        guard let placemarks = try? await geocoder.geocodeAddressString(cityOrZip),
              let location = placemarks.first?.location else { return }
        primaryLocation = location
    }
}
