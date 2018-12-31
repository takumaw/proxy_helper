/*
 * Copyright (c) 2018 Takuma Watanabe.
 */

import Foundation
import CFNetwork

/**
 ProxyHelper logic class.
 */
class ProxyHelperCore {
    
    // MARK:- Dependencies
    
    private let cfNetworkHelper: CFNetworkHelper
    
    // MARK:- Initializer
    
    /**
     Initializer.
     
     Inject depencendies.
     */
    init(cfNetworkHelper: CFNetworkHelper) {
        self.cfNetworkHelper = cfNetworkHelper
    }
    
    // MARK:- Instance methods
    
    /**
     Get HTTP proxy URL.
     
     - returns:
     HTTP proxy URL.
     */
    public func getHTTPProxyURL() -> String? {
        let proxySettingsDictionary: [String: Any] = self.cfNetworkHelper.getProxySettingsAsDictionary()
        
        guard let _: Int = proxySettingsDictionary[kCFNetworkProxiesHTTPEnable as String] as? Int else {
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
        
        guard let _: Int = proxySettingsDictionary[kCFNetworkProxiesHTTPSEnable as String] as? Int else {
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
        
        guard let _: Int = proxySettingsDictionary[kCFNetworkProxiesFTPEnable as String] as? Int else {
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
        guard let hostAddressRegex: NSRegularExpression = try? NSRegularExpression(pattern: "^([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+)$") else {
            return nil
        }
        
        guard let proxiesExceptionsList: [String] = self.cfNetworkHelper.getProxySettingsAsDictionary()[kCFNetworkProxiesExceptionsList as String] as? [String] else {
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
            
            matchedResult = hostAddressRegex.matches(in: proxiesException,
                                                     range: NSRange(location: 0, length: proxiesException.count))
            if matchedResult.count > 0 {
                matchedDomain = String(proxiesException[Range(matchedResult[0].range(at: 1), in: proxiesException)!])
                noProxyDomains.append(matchedDomain)
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
            // swiftlint:disable force_cast
            let proxyType: CFString = proxy[kCFProxyTypeKey as String] as! CFString
            
            var proxyScheme: String
            
            switch proxyType {
            case kCFProxyTypeHTTP:
                proxyScheme = "http"
            case kCFProxyTypeHTTPS :
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
        var proxyEnnvironmentVariables: [String: String] = [:]
        
        if let httpProxyURL: String = self.getHTTPProxyURL() {
            proxyEnnvironmentVariables["http_proxy"] = httpProxyURL
        }
        
        if let httpsProxyURL: String = self.getHTTPSProxyURL() {
            proxyEnnvironmentVariables["https_proxy"] = httpsProxyURL
        }
        
        if let ftpProxyURL: String = self.getFTPProxyURL() {
            proxyEnnvironmentVariables["ftp_proxy"] = ftpProxyURL
        }
        
        if let noProxyDomains: String = self.getNoProxyDomains() {
            proxyEnnvironmentVariables["no_proxy"] = noProxyDomains
        }
        
        return proxyEnnvironmentVariables
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
        var proxyEnnvironmentVariables: [String: String] = [:]
        
        guard let urlScheme: String = url.scheme else {
            return proxyEnnvironmentVariables
        }
        let proxyIdentifier = "\(urlScheme)_proxy"
        
        guard let proxyURL: String = self.getProxyURLForURL(url) else {
            return proxyEnnvironmentVariables
        }
        
        proxyEnnvironmentVariables[proxyIdentifier] = proxyURL
        
        return proxyEnnvironmentVariables
    }
    
}
