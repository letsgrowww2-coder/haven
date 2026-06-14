import Foundation

// MARK: - Firebase Service
// Before using: add the Firebase iOS SDK via File > Add Package Dependencies
// URL: https://github.com/firebase/firebase-ios-sdk
// Add to target: FirebaseFirestore, FirebaseStorage, FirebaseAuth
// Then uncomment the Firebase imports and replace stub implementations below.

class FirebaseService {
    static let shared = FirebaseService()
    private init() {}

    // MARK: - Resources

    func fetchResources() async throws -> [Resource] {
        // TODO: Replace with Firestore
        // let snap = try await Firestore.firestore().collection(Constants.Firebase.resources).getDocuments()
        // return try snap.documents.map { try $0.data(as: Resource.self) }
        try await Task.sleep(nanoseconds: 300_000_000) // simulate network
        return Resource.sampleData
    }

    // MARK: - Documents (local storage fallback until Firebase is configured)

    func fetchDocuments(userId: String) async throws -> [HavenDocument] {
        return loadLocalMetadata(userId: userId)
    }

    func uploadDocument(
        data: Data,
        name: String,
        category: HavenDocument.DocumentCategory,
        userId: String,
        onProgress: @escaping (Double) -> Void
    ) async throws -> HavenDocument {
        let id = UUID().uuidString
        let filename = "\(id).jpg"
        let fileURL = localDocumentURL(userId: userId, filename: filename)
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: fileURL)
        onProgress(1.0)

        let doc = HavenDocument(
            id: id,
            name: name,
            category: category,
            firebaseStoragePath: fileURL.path,
            uploadedAt: Date(),
            tags: [],
            fileSize: Int64(data.count),
            mimeType: "image/jpeg"
        )
        var all = loadLocalMetadata(userId: userId)
        all.insert(doc, at: 0)
        saveLocalMetadata(all, userId: userId)
        return doc
    }

    func deleteDocument(_ document: HavenDocument, userId: String) async throws {
        let fileURL = URL(fileURLWithPath: document.firebaseStoragePath)
        try? FileManager.default.removeItem(at: fileURL)
        var all = loadLocalMetadata(userId: userId)
        all.removeAll { $0.id == document.id }
        saveLocalMetadata(all, userId: userId)
    }

    // MARK: - Local metadata helpers

    private func localDocumentURL(userId: String, filename: String) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("vault/\(userId)/\(filename)")
    }

    private func metadataURL(userId: String) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("vault/\(userId)/metadata.json")
    }

    private func loadLocalMetadata(userId: String) -> [HavenDocument] {
        guard let data = try? Data(contentsOf: metadataURL(userId: userId)),
              let docs = try? JSONDecoder().decode([HavenDocument].self, from: data)
        else { return [] }
        return docs
    }

    private func saveLocalMetadata(_ docs: [HavenDocument], userId: String) {
        guard let data = try? JSONEncoder().encode(docs) else { return }
        let url = metadataURL(userId: userId)
        try? FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(), withIntermediateDirectories: true
        )
        try? data.write(to: url)
    }

    // MARK: - Housing Steps

    func fetchHousingSteps(userId: String) async throws -> [HousingStep] {
        // TODO: Replace with Firestore
        return []
    }

    func saveHousingSteps(_ steps: [HousingStep], userId: String) async throws {
        // TODO: Encode and write to Firestore
        // let data = try Firestore.Encoder().encode(steps)
        // try await Firestore.firestore().collection(Constants.Firebase.users).document(userId)
        //     .collection(Constants.Firebase.housingSteps).document("pathway").setData(["steps": data])
    }

    // MARK: - Share Links

    func saveShareLink(_ link: HavenShareLink) async throws {
        // TODO: Write to Firestore
        throw FirebaseError.notConfigured
    }

    func revokeShareLink(_ id: String) async throws {
        // TODO: Update isRevoked field in Firestore
        throw FirebaseError.notConfigured
    }

    enum FirebaseError: LocalizedError {
        case notConfigured
        var errorDescription: String? {
            "Firebase is not yet configured. Add the Firebase package via Swift Package Manager."
        }
    }
}
