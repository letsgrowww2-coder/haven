import Foundation

nonisolated enum Constants {
    // Replace with your actual Claude API key — never commit real keys to source control
    static let claudeAPIKey = "YOUR_ANTHROPIC_API_KEY_HERE" // paste your Anthropic API key between the quotes

    static let appName = "Haven"

    enum Map {
        static let defaultSearchRadiusMeters: Double = 5000
        static let maxSearchRadiusMeters: Double = 25000
    }

    enum Vault {
        static let maxDocumentSizeMB: Int64 = 25
        static let allowedMimeTypes = ["application/pdf", "image/jpeg", "image/png", "image/heic"]
    }

    enum Sharing {
        static let defaultExpiryHours = 48
        static let maxExpiryDays = 30
    }

    enum Emergency {
        static let phone211 = "211"
        static let crisisLine = "988"
        static let crisisTextNumber = "741741"
        static let crisisTextBody = "HOME"
    }

    enum Firebase {
        static let resources = "resources"
        static let users = "users"
        static let shareLinks = "shareLinks"
        static let housingSteps = "housingSteps"
        static let documents = "documents"
    }

    enum Cache {
        static let resourcesFileName = "haven_resources_cache.json"
        static let expiryHours: Double = 24
    }
}
