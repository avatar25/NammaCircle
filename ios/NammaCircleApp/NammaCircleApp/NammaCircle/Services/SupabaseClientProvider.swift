import Foundation

#if canImport(Supabase)
import Supabase
#endif

final class SupabaseClientProvider {
    static let shared = SupabaseClientProvider()

    let supabaseURL: URL
    let anonKey: String

    #if canImport(Supabase)
    let client: SupabaseClient
    private var anonymousSession: Session?
    #endif

    init(
        supabaseURL: URL? = AppConfiguration.supabaseURL,
        anonKey: String? = AppConfiguration.supabaseAnonKey
    ) {
        guard let supabaseURL, let anonKey else {
            self.supabaseURL = URL(string: "https://example.supabase.co")!
            self.anonKey = ""
            #if canImport(Supabase)
            self.client = SupabaseClient(supabaseURL: self.supabaseURL, supabaseKey: self.anonKey)
            #endif
            return
        }

        self.supabaseURL = supabaseURL
        self.anonKey = anonKey
        #if canImport(Supabase)
        self.client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: anonKey)
        #endif
    }

    var isConfigured: Bool {
        !anonKey.isEmpty && supabaseURL.host != "example.supabase.co"
    }

    func fetchTable<T: Decodable>(
        _ table: String,
        queryItems: [URLQueryItem] = [],
        authenticated: Bool = false
    ) async throws -> T {
        try await request(path: "/rest/v1/\(table)", queryItems: queryItems, authenticated: authenticated)
    }

    func insert<T: Encodable, Response: Decodable>(
        into table: String,
        payload: T,
        authenticated: Bool = false
    ) async throws -> Response {
        var request = try makeRequest(path: "/rest/v1/\(table)", queryItems: [
            URLQueryItem(name: "select", value: "*")
        ])
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")
        request.httpBody = try JSONEncoder.supabase.encode(payload)

        if authenticated {
            let session = try await anonymousAuthSession()
            request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        }

        return try await perform(request)
    }

    func authenticatedSessionForWrite() async throws -> SupabaseAuthSession {
        try await anonymousAuthSession()
    }

    func uploadQuestProofImage(
        data: Data,
        mimeType: String,
        fileExtension: String,
        session: SupabaseAuthSession
    ) async throws -> String {
        let objectPath = "\(session.userID.uuidString)/\(UUID().uuidString).\(fileExtension)"
        var request = try makeRequest(path: "/storage/v1/object/quest-proof/\(objectPath)")
        request.httpMethod = "POST"
        request.setValue(mimeType, forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = data

        try await perform(request)
        return "quest-proof/\(objectPath)"
    }

    func invokeFunction<RequestBody: Encodable, ResponseBody: Decodable>(
        _ name: String,
        body: RequestBody,
        authenticated: Bool = false
    ) async throws -> ResponseBody {
        var request = try makeRequest(path: "/functions/v1/\(name)")
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder.supabase.encode(body)

        if authenticated {
            let session = try await anonymousAuthSession()
            request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        }

        return try await perform(request)
    }

    private func request<T: Decodable>(
        path: String,
        queryItems: [URLQueryItem] = [],
        authenticated: Bool = false
    ) async throws -> T {
        var request = try makeRequest(path: path, queryItems: queryItems)

        if authenticated {
            let session = try await anonymousAuthSession()
            request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        }

        return try await perform(request)
    }

    private func makeRequest(path: String, queryItems: [URLQueryItem] = []) throws -> URLRequest {
        guard isConfigured else {
            throw ServicePlaceholderError.missingSupabaseConfiguration
        }

        var components = URLComponents(url: supabaseURL, resolvingAgainstBaseURL: false)
        components?.path = path
        components?.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components?.url else {
            throw ServicePlaceholderError.invalidSupabaseURL
        }

        var request = URLRequest(url: url)
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServicePlaceholderError.invalidSupabaseResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Supabase request failed."
            throw ServicePlaceholderError.supabaseRequestFailed(message)
        }

        return try JSONDecoder.supabase.decode(T.self, from: data)
    }

    private func perform(_ request: URLRequest) async throws {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServicePlaceholderError.invalidSupabaseResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Supabase request failed."
            throw ServicePlaceholderError.supabaseRequestFailed(message)
        }
    }

    private func anonymousAuthSession() async throws -> SupabaseAuthSession {
        #if canImport(Supabase)
        if let anonymousSession {
            return SupabaseAuthSession(
                accessToken: anonymousSession.accessToken,
                userID: anonymousSession.user.id
            )
        }

        let session = try await client.auth.signInAnonymously()
        anonymousSession = session
        return SupabaseAuthSession(accessToken: session.accessToken, userID: session.user.id)
        #else
        throw ServicePlaceholderError.supabaseSwiftUnavailable
        #endif
    }
}

struct SupabaseAuthSession {
    let accessToken: String
    let userID: UUID
}

extension JSONDecoder {
    static var supabase: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            let fractionalFormatter = ISO8601DateFormatter()
            fractionalFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            if let date = fractionalFormatter.date(from: value) {
                return date
            }

            if let date = ISO8601DateFormatter().date(from: value) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid ISO8601 date: \(value)"
            )
        }
        return decoder
    }
}

extension JSONEncoder {
    static var supabase: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}
