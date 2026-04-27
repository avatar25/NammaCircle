import Foundation

enum DataMode: String {
    case mock
    case supabase
}

enum AppConfiguration {
    static var dataMode: DataMode {
        let configuredValue = stringValue(for: "NAMMA_DATA_MODE")?.lowercased()
        return DataMode(rawValue: configuredValue ?? "") ?? .mock
    }

    static var isMockMode: Bool {
        dataMode == .mock
    }

    static var supabaseURL: URL? {
        guard let value = stringValue(for: "SUPABASE_URL") ?? stringValue(for: "NEXT_PUBLIC_SUPABASE_URL") else {
            return nil
        }

        return URL(string: value)
    }

    static var supabaseAnonKey: String? {
        stringValue(for: "SUPABASE_ANON_KEY") ?? stringValue(for: "NEXT_PUBLIC_SUPABASE_ANON_KEY")
    }

    private static func stringValue(for key: String) -> String? {
        if let environmentValue = ProcessInfo.processInfo.environment[key], !environmentValue.isEmpty {
            return environmentValue
        }

        if let bundleValue = Bundle.main.object(forInfoDictionaryKey: key) as? String, !bundleValue.isEmpty {
            return bundleValue
        }

        return nil
    }
}
