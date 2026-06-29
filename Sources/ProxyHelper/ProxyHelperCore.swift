/*
 * Copyright (c) 2018-2026 Takuma Watanabe.
 */

import Foundation
import CFNetwork

/**
 The core business logic class for the ProxyHelper utility.
 */
class ProxyHelperCore {

    // MARK: - Dependencies

    private let cfNetworkHelper: CFNetworkHelper

    // MARK: - Initializer

    init(cfNetworkHelper: CFNetworkHelper) {
        self.cfNetworkHelper = cfNetworkHelper
    }

    // MARK: - Instance Methods

    /**
     Returns the HTTP proxy URL.
     
     - Returns: The HTTP proxy URL, or `nil` if not configured.
     */
    public func getHTTPProxyURL() throws -> String? {
        let proxySettingsDictionary: [String: Any] = try self.cfNetworkHelper.getProxySettingsAsDictionary()

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
     Returns the HTTPS proxy URL.
     
     - Returns: The HTTPS proxy URL, or `nil` if not configured.
     */
    public func getHTTPSProxyURL() throws -> String? {
        let proxySettingsDictionary: [String: Any] = try self.cfNetworkHelper.getProxySettingsAsDictionary()

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
     Returns the FTP proxy URL.
     
     - Returns: The FTP proxy URL, or `nil` if not configured.
     */
    public func getFTPProxyURL() throws -> String? {
        let proxySettingsDictionary: [String: Any] = try self.cfNetworkHelper.getProxySettingsAsDictionary()

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
     Returns the list of domains to bypass proxies for (no_proxy).
     
     - Returns: The comma-separated list of bypass domains, or `nil` if not configured.
     */
    public func getNoProxyDomains() throws -> String? {
        var noProxyDomains: [String] = []

        guard let hostNameRegex: NSRegularExpression = try? NSRegularExpression(pattern: "\\*\\.([^*]+)$") else {
            return nil
        }

        let proxySettings = try self.cfNetworkHelper.getProxySettingsAsDictionary()
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
     Checks if the given string is a valid IPv4 address.
     
     - Parameters:
       - ipString: The string to validate.
     - Returns: `true` if the string is a valid IPv4 address; otherwise, `false`.
     */
    private func isIPv4Address(_ ipString: String) -> Bool {
        var addr = in_addr()
        return inet_pton(AF_INET, ipString, &addr) == 1
    }

    /// Checks if the given string is a valid IPv6 address.
    private func isIPv6Address(_ ipString: String) -> Bool {
        var addr = in6_addr()
        return inet_pton(AF_INET6, ipString, &addr) == 1
    }

    /**
     Validates if the given string is a valid IP address or CIDR subnet (IPv4/IPv6).
     
     This method also cleans the input string by stripping square brackets from the IP part if present.
     
     - Parameters:
       - rawString: The raw string representing an IP address or CIDR subnet.
     - Returns: A tuple containing:
       - `isValid`: A boolean indicating whether the input is a valid IP address or CIDR subnet.
       - `cleanedString`: The cleaned IP/CIDR string (without square brackets) if valid; otherwise, an empty string.
     */
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
     Returns the dedicated proxy URL for a specified URL.
     
     - Parameters:
       - url: The URL used to determine the proxy URL.
     - Returns: The dedicated proxy URL for the specified URL, or `nil` if not resolved.
     */
    public func getProxyURLForURL(_ url: URL) throws -> String? {
        let proxies: [[String: Any]] = try self.cfNetworkHelper.getProxiesForURLAsArray(url)

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
            guard let proxyType = proxy[kCFProxyTypeKey as String] as? String else {
                return nil
            }

            var proxyScheme: String

            if proxyType == (kCFProxyTypeHTTP as String) {
                proxyScheme = "http"
            } else if proxyType == (kCFProxyTypeHTTPS as String) {
                proxyScheme = "https"
            } else if proxyType == (kCFProxyTypeFTP as String) {
                proxyScheme = "ftp"
            } else if proxyType == (kCFProxyTypeSOCKS as String) {
                proxyScheme = "socks"
            } else {
                return nil
            }

            return "\(proxyScheme)://\(proxyHostName):\(proxyPortNumber)"
        }
    }

    /**
     Returns all proxy environment variables.
     
     - Returns: A dictionary of proxy environment variables.
     */
    public func getAllProxyEnvironmentVariables() throws -> [String: String] {
        var proxyEnvironmentVariables: [String: String] = [:]

        if let httpProxyURL: String = try self.getHTTPProxyURL() {
            proxyEnvironmentVariables["http_proxy"] = httpProxyURL
        }

        if let httpsProxyURL: String = try self.getHTTPSProxyURL() {
            proxyEnvironmentVariables["https_proxy"] = httpsProxyURL
        }

        if let ftpProxyURL: String = try self.getFTPProxyURL() {
            proxyEnvironmentVariables["ftp_proxy"] = ftpProxyURL
        }

        if let noProxyDomains: String = try self.getNoProxyDomains() {
            proxyEnvironmentVariables["no_proxy"] = noProxyDomains
        }

        return proxyEnvironmentVariables
    }

    /**
     Returns the proxy environment variables determined for a given URL.
     
     - Parameters:
       - url: The URL used to determine the proxy address.
     - Returns: A dictionary containing the proxy environment variable for the given URL.
     */
    public func getProxyEnvironmentVariableForURL(_ url: URL) throws -> [String: String] {
        var proxyEnvironmentVariables: [String: String] = [:]

        guard let urlScheme: String = url.scheme else {
            return proxyEnvironmentVariables
        }
        let proxyIdentifier = "\(urlScheme)_proxy"

        guard let proxyURL: String = try self.getProxyURLForURL(url) else {
            return proxyEnvironmentVariables
        }

        proxyEnvironmentVariables[proxyIdentifier] = proxyURL

        return proxyEnvironmentVariables
    }

    /**
     Returns the system PAC (Proxy Auto-Configuration) URL if enabled.
     
     - Returns: The system PAC URL, or `nil` if PAC is disabled or not configured.
     */
    public func getSystemPACURL() throws -> URL? {
        let proxySettingsDictionary = try self.cfNetworkHelper.getProxySettingsAsDictionary()

        guard let enablePAC = proxySettingsDictionary[kCFNetworkProxiesProxyAutoConfigEnable as String] as? Int, enablePAC == 1 else {
            return nil
        }
        guard let pacURLString = proxySettingsDictionary[kCFNetworkProxiesProxyAutoConfigURLString as String] as? String else {
            return nil
        }
        return URL(string: pacURLString)
    }

    /**
     Returns proxy environment variables by evaluating the PAC script for a specified URL.
     
     - Parameters:
       - targetURL: The target URL to evaluate against the PAC.
     - Returns: A dictionary of proxy environment variables resolved via PAC.
     */
    public func getPACProxyEnvironmentVariables(targetURL: URL) throws -> [String: String] {
        guard let pacURL = try self.getSystemPACURL() else {
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
     Maps a single proxy dictionary to environment variables.
     
     - Parameters:
       - proxy: The proxy dictionary from CFNetwork.
     - Returns: A dictionary of mapped proxy environment variables.
     */
    private func mapProxyToEnvironmentVariables(_ proxy: [String: Any]) -> [String: String] {
        var proxyEnvironmentVariables: [String: String] = [:]

        guard let proxyTypeAny = proxy[kCFProxyTypeKey as String] else {
            return proxyEnvironmentVariables
        }
        guard let proxyType = proxyTypeAny as? String else {
            return proxyEnvironmentVariables
        }

        if proxyType == (kCFProxyTypeNone as String) {
            return proxyEnvironmentVariables
        }

        guard let proxyHost = proxy[kCFProxyHostNameKey as String] as? String,
              let proxyPort = proxy[kCFProxyPortNumberKey as String] as? Int else {
            return proxyEnvironmentVariables
        }

        var proxyScheme: String
        if proxyType == (kCFProxyTypeHTTP as String) {
            proxyScheme = "http"
        } else if proxyType == (kCFProxyTypeHTTPS as String) {
            proxyScheme = "https"
        } else if proxyType == (kCFProxyTypeFTP as String) {
            proxyScheme = "ftp"
        } else if proxyType == (kCFProxyTypeSOCKS as String) {
            proxyScheme = "socks"
        } else {
            return proxyEnvironmentVariables
        }

        let proxyURL = "\(proxyScheme)://\(proxyHost):\(proxyPort)"

        if proxyType == (kCFProxyTypeHTTP as String) || proxyType == (kCFProxyTypeHTTPS as String) || proxyType == (kCFProxyTypeSOCKS as String) {
            proxyEnvironmentVariables["http_proxy"] = proxyURL
            proxyEnvironmentVariables["https_proxy"] = proxyURL
        } else if proxyType == (kCFProxyTypeFTP as String) {
            proxyEnvironmentVariables["ftp_proxy"] = proxyURL
        }

        return proxyEnvironmentVariables
    }

}
