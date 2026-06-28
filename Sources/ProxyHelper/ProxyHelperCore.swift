/*
 * Copyright (c) 2018-2026 Takuma Watanabe.
 */

import Foundation
import CFNetwork

/**
 ProxyHelper logic class.
 */
class ProxyHelperCore {

    // MARK: - Dependencies

    private let cfNetworkHelper: CFNetworkHelper

    // MARK: - Initializer

    /**
     Initializer.
     
     Inject dependencies.
     */
    init(cfNetworkHelper: CFNetworkHelper) {
        self.cfNetworkHelper = cfNetworkHelper
    }

    // MARK: - Instance Methods

    /**
     Get HTTP proxy URL.
     
     - returns:
     HTTP proxy URL.
     */
    public func getHTTPProxyURL() -> String? {
        let proxySettingsDictionary: [String: Any] = self.cfNetworkHelper.getProxySettingsAsDictionary()

        guard proxySettingsDictionary[kCFNetworkProxiesHTTPEnable as String] != nil else {
            return nil
        }
        guard let httpProxy: String = proxySettingsDictionary[kCFNetworkProxiesHTTPProxy as String] as? String else {
            return nil
        }
        guard let httpPort: Int = proxySettingsDictionary[kCFNetworkProxiesHTTPPort as String] as? Int else {
            return nil
        }
        let httpProxyURL: String = "http://\(httpProxy):\(httpPort)"

        return httpProxyURL
    }

    /**
     Get HTTPS proxy URL.
     
     - returns:
     HTTPS proxy URL.
     */
    public func getHTTPSProxyURL() -> String? {
        let proxySettingsDictionary: [String: Any] = self.cfNetworkHelper.getProxySettingsAsDictionary()

        guard proxySettingsDictionary[kCFNetworkProxiesHTTPSEnable as String] != nil else {
            return nil
        }
        guard let httpsProxy: String = proxySettingsDictionary[kCFNetworkProxiesHTTPSProxy as String] as? String else {
            return nil
        }
        guard let httpsPort: Int = proxySettingsDictionary[kCFNetworkProxiesHTTPSPort as String] as? Int else {
            return nil
        }
        let httpsProxyURL: String = "http://\(httpsProxy):\(httpsPort)"

        return httpsProxyURL
    }

    /**
     Get FTP proxy URL.
     
     - returns:
     FTP proxy URL.
     */
    public func getFTPProxyURL() -> String? {
        let proxySettingsDictionary: [String: Any] = self.cfNetworkHelper.getProxySettingsAsDictionary()

        guard proxySettingsDictionary[kCFNetworkProxiesFTPEnable as String] != nil else {
            return nil
        }
        guard let ftpProxy: String = proxySettingsDictionary[kCFNetworkProxiesFTPProxy as String] as? String else {
            return nil
        }
        guard let ftpPort: Int = proxySettingsDictionary[kCFNetworkProxiesFTPPort as String] as? Int else {
            return nil
        }
        let ftpProxyURL: String = "http://\(ftpProxy):\(ftpPort)"

        return ftpProxyURL
    }

    /**
     Get no proxy domains.
     
     - returns:
     No proxy domains. (comma-separated)
     */
    public func getNoProxyDomains() -> String? {
        var noProxyDomains: [String] = []

        guard let hostNameRegex: NSRegularExpression = try? NSRegularExpression(pattern: "\\*\\.([^*]+)$") else {
            return nil
        }

        let proxySettings = self.cfNetworkHelper.getProxySettingsAsDictionary()
        guard let proxiesExceptionsList = proxySettings[kCFNetworkProxiesExceptionsList as String] as? [String] else {
            return nil
        }

        for proxiesException: String in proxiesExceptionsList {
            var matchedResult: [NSTextCheckingResult]
            var matchedDomain: String

            matchedResult = hostNameRegex.matches(in: proxiesException,
                                                  range: NSRange(location: 0, length: proxiesException.count))
            if matchedResult.count > 0 {
                matchedDomain = String(proxiesException[Range(matchedResult[0].range(at: 1), in: proxiesException)!])
                noProxyDomains.append(matchedDomain)
                continue
            }

            let validation = self.isValidIPOrCIDR(proxiesException)
            if validation.isValid {
                noProxyDomains.append(validation.cleanedString)
                continue
            }
        }

        if noProxyDomains.count > 0 {
            return noProxyDomains.joined(separator: ",")
        } else {
            return nil
        }
    }

    /**
     Check if the given string is a valid IPv4 address.
     
     - parameters:
       - ipString: The string to validate.
     - returns:
       True if it is a valid IPv4 address, false otherwise.
     */
    private func isIPv4Address(_ ipString: String) -> Bool {
        var addr = in_addr()
        return inet_pton(AF_INET, ipString, &addr) == 1
    }

    /// Check if the given string is a valid IPv6 address.
    private func isIPv6Address(_ ipString: String) -> Bool {
        var addr = in6_addr()
        return inet_pton(AF_INET6, ipString, &addr) == 1
    }

    /// Validate if the given string is a valid IP address or CIDR subnet (IPv4/IPv6).
    /// It also strips square brackets from the IP part if present.
    private func isValidIPOrCIDR(_ rawString: String) -> (isValid: Bool, cleanedString: String) {
        let cleaned = rawString.replacingOccurrences(of: "[", with: "")
                               .replacingOccurrences(of: "]", with: "")

        if cleaned.contains("/") {
            let parts = cleaned.components(separatedBy: "/")
            guard parts.count == 2 else {
                return (false, "")
            }
            let ipPart = parts[0]
            let maskPart = parts[1]
            guard let mask = Int(maskPart) else {
                return (false, "")
            }

            if self.isIPv4Address(ipPart) {
                if mask >= 0 && mask <= 32 {
                    return (true, cleaned)
                }
            } else if self.isIPv6Address(ipPart) {
                if mask >= 0 && mask <= 128 {
                    return (true, cleaned)
                }
            }
        } else {
            if self.isIPv4Address(cleaned) || self.isIPv6Address(cleaned) {
                return (true, cleaned)
            }
        }

        return (false, "")
    }

    /**
     Get dedicated proxy URL for specified URL.
     
     - parameters:
       - url: URL using which to determine proxy URL.
     - returns:
     Dedicated proxy URL for specified URL.
     */
    public func getProxyURLForURL(_ url: URL) -> String? {
        let proxies: [[String: Any]] = self.cfNetworkHelper.getProxiesForURLAsArray(url)

        if proxies.count == 0 {
            return nil
        } else {
            let proxy: [String: Any] = proxies[0]

            guard let proxyHostName: String = proxy[kCFProxyHostNameKey as String] as? String else {
                return nil
            }
            guard let proxyPortNumber: Int = proxy[kCFProxyPortNumberKey as String] as? Int else {
                return nil
            }
            // swiftlint:disable:next force_cast
            let proxyType = proxy[kCFProxyTypeKey as String] as! CFString

            var proxyScheme: String

            switch proxyType {
            case kCFProxyTypeHTTP:
                proxyScheme = "http"
            case kCFProxyTypeHTTPS:
                proxyScheme = "https"
            case kCFProxyTypeFTP:
                proxyScheme = "ftp"
            case kCFProxyTypeSOCKS:
                proxyScheme = "socks"
            default:
                return nil
            }

            return "\(proxyScheme)://\(proxyHostName):\(proxyPortNumber)"
        }
    }

    /**
     Get all proxy environment variables.
     
     - parameters:
       - shellStyle: Shell style in which script is generated.
     - returns:
     Proxy environment variables.
     */
    public func getAllProxyEnvironmentVariables() -> [String: String] {
        var proxyEnvironmentVariables: [String: String] = [:]

        if let httpProxyURL: String = self.getHTTPProxyURL() {
            proxyEnvironmentVariables["http_proxy"] = httpProxyURL
        }

        if let httpsProxyURL: String = self.getHTTPSProxyURL() {
            proxyEnvironmentVariables["https_proxy"] = httpsProxyURL
        }

        if let ftpProxyURL: String = self.getFTPProxyURL() {
            proxyEnvironmentVariables["ftp_proxy"] = ftpProxyURL
        }

        if let noProxyDomains: String = self.getNoProxyDomains() {
            proxyEnvironmentVariables["no_proxy"] = noProxyDomains
        }

        return proxyEnvironmentVariables
    }

    /**
     Get proxy environment variables determined with given URL.
     
     - parameters:
       - url: URL using which to determine proxy address.
       - shellStyle: Shell style in which script is generated.
     - returns:
     Proxy environment variables.
     */
    public func getProxyEnvironmentVariableForURL(_ url: URL) -> [String: String] {
        var proxyEnvironmentVariables: [String: String] = [:]

        guard let urlScheme: String = url.scheme else {
            return proxyEnvironmentVariables
        }
        let proxyIdentifier = "\(urlScheme)_proxy"

        guard let proxyURL: String = self.getProxyURLForURL(url) else {
            return proxyEnvironmentVariables
        }

        proxyEnvironmentVariables[proxyIdentifier] = proxyURL

        return proxyEnvironmentVariables
    }

    /**
     Get system PAC (Proxy Auto-Configuration) URL if enabled.
     
     - returns:
       PAC URL.
     */
    public func getSystemPACURL() -> URL? {
        let proxySettingsDictionary = self.cfNetworkHelper.getProxySettingsAsDictionary()

        guard let enablePAC = proxySettingsDictionary[kCFNetworkProxiesProxyAutoConfigEnable as String] as? Int, enablePAC == 1 else {
            return nil
        }
        guard let pacURLString = proxySettingsDictionary[kCFNetworkProxiesProxyAutoConfigURLString as String] as? String else {
            return nil
        }
        return URL(string: pacURLString)
    }

    /**
     Get proxy environment variables by evaluating PAC for the specified URL.
     
     - parameters:
       - url: Target URL to evaluate against the PAC.
     - returns:
       Proxy environment variables.
     */
    public func getPACProxyEnvironmentVariables(targetURL: URL) -> [String: String] {
        guard let pacURL = self.getSystemPACURL() else {
            return [:]
        }

        guard let proxies = self.cfNetworkHelper.executePAC(pacURL: pacURL, targetURL: targetURL) else {
            return [:]
        }

        if proxies.isEmpty {
            return [:]
        }

        return self.mapProxyToEnvironmentVariables(proxies[0])
    }

    /**
     Map a single proxy dictionary to environment variables.
     
     - parameters:
       - proxy: Proxy dictionary from CFNetwork.
     - returns:
       Proxy environment variables dictionary.
     */
    private func mapProxyToEnvironmentVariables(_ proxy: [String: Any]) -> [String: String] {
        var proxyEnvironmentVariables: [String: String] = [:]

        guard let proxyTypeAny = proxy[kCFProxyTypeKey as String] else {
            return proxyEnvironmentVariables
        }
        // swiftlint:disable:next force_cast
        let proxyType = proxyTypeAny as! CFString

        if proxyType == kCFProxyTypeNone {
            return proxyEnvironmentVariables
        }

        guard let proxyHost = proxy[kCFProxyHostNameKey as String] as? String,
              let proxyPort = proxy[kCFProxyPortNumberKey as String] as? Int else {
            return proxyEnvironmentVariables
        }

        var proxyScheme: String
        switch proxyType {
        case kCFProxyTypeHTTP:
            proxyScheme = "http"
        case kCFProxyTypeHTTPS:
            proxyScheme = "https"
        case kCFProxyTypeFTP:
            proxyScheme = "ftp"
        case kCFProxyTypeSOCKS:
            proxyScheme = "socks"
        default:
            return proxyEnvironmentVariables
        }

        let proxyURL = "\(proxyScheme)://\(proxyHost):\(proxyPort)"

        if proxyType == kCFProxyTypeHTTP || proxyType == kCFProxyTypeHTTPS || proxyType == kCFProxyTypeSOCKS {
            proxyEnvironmentVariables["http_proxy"] = proxyURL
            proxyEnvironmentVariables["https_proxy"] = proxyURL
        } else if proxyType == kCFProxyTypeFTP {
            proxyEnvironmentVariables["ftp_proxy"] = proxyURL
        }

        return proxyEnvironmentVariables
    }

}
