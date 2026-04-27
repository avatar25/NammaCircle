import Foundation

enum ServicePlaceholderError: LocalizedError {
    case notImplemented

    var errorDescription: String? {
        "Supabase service is a placeholder for now. Use mock services in the MVP skeleton."
    }
}
