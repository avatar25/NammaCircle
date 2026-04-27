import Foundation

enum ServicePlaceholderError: LocalizedError {
    case notImplemented
    case missingSupabaseConfiguration
    case invalidSupabaseURL
    case invalidSupabaseResponse
    case supabaseSwiftUnavailable
    case supabaseRequestFailed(String)
    case authRequired

    var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "This service is not implemented yet."
        case .missingSupabaseConfiguration:
            return "Supabase URL or anon key is missing. Use mock mode or add Supabase configuration."
        case .invalidSupabaseURL:
            return "Supabase URL is invalid."
        case .invalidSupabaseResponse:
            return "Supabase returned an invalid response."
        case .supabaseSwiftUnavailable:
            return "Supabase Swift is not linked. Add the Supabase Swift package to the app target."
        case .supabaseRequestFailed(let message):
            return message
        case .authRequired:
            return "This action requires anonymous auth or a temporary dev user. Enable anonymous sign-in before Supabase writes."
        }
    }
}
