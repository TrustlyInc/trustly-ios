import Foundation

enum TrustlyEnvironment {
    case production
    case dynamic(env: String)
    case local(address: String)
    case subDomains(env: String)

    var isLocal: Bool {
        switch self {
        case .local:
            return true
        default:
            return false
        }
    }
    
    var baseURL: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        
        switch self {
        case .production:
            components.host = Constants.baseDomain
            return components

        case .local(let address):
            let trimmedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
            let lowercasedAddress = trimmedAddress.lowercased()
            let localDomain = (lowercasedAddress == "local" || lowercasedAddress == "localhost") ? "localhost" : trimmedAddress

            components.scheme = "http"
            components.host = localDomain
            return components

        case .dynamic(let env):
            components.host = "\(env).int.\(Constants.baseDomain)"
            return components

        case .subDomains(let env):
            components.host = "\(env).\(Constants.baseDomain)"
            return components
        }
    }

    init(env: String?) {
        let rawValue = env?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let lowercaseValue = rawValue.lowercased()

        if rawValue.isEmpty || lowercaseValue == "prod" || lowercaseValue == "production" {
            self = .production
            return
        }

        let ipv4Pattern = "^(?:25[0-5]|2[0-4]\\d|1?\\d?\\d)(?:\\.(?:25[0-5]|2[0-4]\\d|1?\\d?\\d)){3}$"
        let isIPv4 = (try? NSRegularExpression(pattern: ipv4Pattern, options: .caseInsensitive))?
            .firstMatch(in: rawValue, options: [], range: NSRange(location: 0, length: rawValue.utf16.count)) != nil

        if lowercaseValue == "local" || lowercaseValue == "localhost" || isIPv4 {
            self = .local(address: rawValue)
            return
        }

        if lowercaseValue.hasPrefix("dev-") {
            self = .dynamic(env: rawValue)
            return
        }

        self = .subDomains(env: rawValue)
    }
}
