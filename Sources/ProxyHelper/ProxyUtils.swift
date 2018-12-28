/*
 * Copyright (c) 2018 Takuma Watanabe.
 */

import Foundation
import CFNetwork

/**
 Collections of utility functions for manipulating the proxy configurations in the System Preference.
 */
class ProxyUtils {
    
    private var proxySettings: CFDictionary? = nil
    
    /**
     Get System Proxy Settings.
     
     Result is cached and reused on other calls.
     
     - returns:
     System Proxy Settings.
     */
    public func getProxySettings() -> CFDictionary {
        if proxySettings == nil {
            guard let unmanagedProxySettings: Unmanaged<CFDictionary> = CFNetworkCopySystemProxySettings() else {
                fatalError("Failed to load CFNetworkCopySystemProxySettings.")
            }
            proxySettings = unmanagedProxySettings.takeRetainedValue()
        }
        
        return proxySettings!
    }
    
    /**
     Get System Proxy Settings.
     
     - returns: System Proxy Settings.
     */
    public func getProxySettingsAsDictionary() -> [String: Any] {
        return self.getProxySettings() as! [String: Any]
    }
    
    /**
     Get proxies for specified URL.
     
     - parameters:
       - url: URL using which to determine proxy addresses.
     - returns:
       Proxies.
     */
    public func getProxiesForURL(_ url: URL) -> CFArray {
        let unmanagedProxies: Unmanaged<CFArray> = CFNetworkCopyProxiesForURL(url as CFURL, self.getProxySettings())
        return unmanagedProxies.takeRetainedValue()
    }
    
    /**
     Get proxies for specified URL.
     
     - parameters:
       - url: URL using which to determine proxy addresses.
     - returns:
     Proxies.
     */
    public func getProxiesForURLAsArray(_ url: URL) -> [[String: Any]] {
        return self.getProxiesForURL(url) as! [[String: Any]]
    }
    
    /**
     Get proxy URL for HTTP.
     
     - returns:
     HTTP proxy URL.
     */
    public func getHTTPProxyURL() -> String? {
        let proxySettingsDictionary: [String: Any] = self.getProxySettingsAsDictionary()
        
        guard let _: Int = proxySettingsDictionary[kCFNetworkProxiesHTTPEnable as String] as! Int? else {
            return nil
        }
        
        let httpProxy: String = proxySettingsDictionary[kCFNetworkProxiesHTTPProxy as String] as! String
        let httpPort: Int = proxySettingsDictionary[kCFNetworkProxiesHTTPPort as String] as! Int
        let httpProxyURL: String = "http://\(httpProxy):\(httpPort)"
        
        return httpProxyURL
    }
    
    /**
     Get proxy URL for HTTPS.
     
     - returns:
     HTTPS proxy URL.
     */
    public func getHTTPSProxyURL() -> String? {
        let proxySettingsDictionary: [String: Any] = self.getProxySettingsAsDictionary()
        
        guard let _: Int = proxySettingsDictionary[kCFNetworkProxiesHTTPSEnable as String] as! Int? else {
            return nil
        }
        
        let httpsProxy: String = proxySettingsDictionary[kCFNetworkProxiesHTTPSProxy as String] as! String
        let httpsPort: Int = proxySettingsDictionary[kCFNetworkProxiesHTTPSPort as String] as! Int
        let httpsProxyURL: String = "http://\(httpsProxy):\(httpsPort)"
        
        return httpsProxyURL
    }
    
    /**
     Get proxy URL for FTP.
     
     - returns:
     FTP proxy URL.
     */
    public func getFTPProxyURL() -> String? {
        let proxySettingsDictionary: [String: Any] = self.getProxySettingsAsDictionary()
        
        guard let _: Int = proxySettingsDictionary[kCFNetworkProxiesFTPEnable as String] as! Int? else {
            return nil
        }
        
        let ftpProxy: String = proxySettingsDictionary[kCFNetworkProxiesFTPProxy as String] as! String
        let ftpPort: Int = proxySettingsDictionary[kCFNetworkProxiesFTPPort as String] as! Int
        let ftpProxyURL: String = "http://\(ftpProxy):\(ftpPort)"
        
        return ftpProxyURL
    }
    
    /**
     Get no proxy domains.
     
     - returns:
     No proxy domains.
     */
    public func getNoProxyDomains() -> String? {
        var noProxyDomains: [String] = []
        
        guard let hostNameRegex: NSRegularExpression = try? NSRegularExpression(pattern: "\\*\\.([^*]+)$") else {
            return nil
        }
        guard let hostAddressRegex: NSRegularExpression = try? NSRegularExpression(pattern: "^([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+)$") else {
            return nil
        }
        
        guard let proxiesExceptionsList: [String] = self.getProxySettingsAsDictionary()[kCFNetworkProxiesExceptionsList as String] as? [String] else {
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
     Get proxy URL for accessing specified URL.
     
     - parameters:
       - url: URL using which to determine proxy URL.
     - returns:
     Proxy URL.
     */
    public func getProxyURLForURL(_ url: URL) -> String? {
        let proxies: [[String: Any]] = self.getProxiesForURLAsArray(url)
        
        if proxies.count == 0 {
            return nil
        } else {
            let proxy: [String: Any] = proxies[0]
            
            let proxyHostName: String = proxy[kCFProxyHostNameKey as String] as! String
            let proxyPortNumber: Int = proxy[kCFProxyPortNumberKey as String] as! Int
            var proxyScheme: String
            
            let proxyType: CFString = proxy[kCFProxyTypeKey as String] as! CFString
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
}
