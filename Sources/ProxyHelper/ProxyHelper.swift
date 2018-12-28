/*
 * Copyright (c) 2018 Takuma Watanabe.
 */

import Foundation
import CFNetwork

/**
 ProxyHelper main logic class.
 */
class ProxyHelper {
    
    private let consoleHelper: ConsoleHelper
    private let cfNetworkHelper: CFNetworkHelper
    
    init(consoleHelper: ConsoleHelper, cfNetworkHelper: CFNetworkHelper) {
        self.consoleHelper = consoleHelper
        self.cfNetworkHelper = cfNetworkHelper
    }
    
    /**
     Get proxy URL for HTTP.
     
     - returns:
     HTTP proxy URL.
     */
    public func getHTTPProxyURL() -> String? {
        let proxySettingsDictionary: [String: Any] = self.cfNetworkHelper.getProxySettingsAsDictionary()
        
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
        let proxySettingsDictionary: [String: Any] = self.cfNetworkHelper.getProxySettingsAsDictionary()
        
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
        let proxySettingsDictionary: [String: Any] = self.cfNetworkHelper.getProxySettingsAsDictionary()
        
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
     Get proxy URL for accessing specified URL.
     
     - parameters:
     - url: URL using which to determine proxy URL.
     - returns:
     Proxy URL.
     */
    public func getProxyURLForURL(_ url: URL) -> String? {
        let proxies: [[String: Any]] = self.cfNetworkHelper.getProxiesForURLAsArray(url)
        
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
    
    /**
     Print proxy environmental variables.
     
     - parameters:
       - shellStyle: Shell style in which script is generated.
     */
    public func printProxySettings(shellStyle: ShellStyle) -> Void {
        var proxyVariables: [String: String] = [:]
        
        if let httpProxyURL: String = self.getHTTPProxyURL() {
            proxyVariables["http_proxy"] = httpProxyURL
        }
        
        if let httpsProxyURL: String = self.getHTTPSProxyURL() {
            proxyVariables["https_proxy"] = httpsProxyURL
        }
        
        if let ftpProxyURL: String = self.getFTPProxyURL() {
            proxyVariables["ftp_proxy"] = ftpProxyURL
        }
        
        if let noProxyDomains: String = self.getNoProxyDomains() {
            proxyVariables["no_proxy"] = noProxyDomains
        }
        
        if proxyVariables.keys.count > 0 {
            self.consoleHelper.printEnvironmentalVariables(proxyVariables, shellStyle: shellStyle)
        }
    }
    
    /**
     Print proxy environmental variable determined with given URL.
     
     - parameters:
       - url: URL using which to determine proxy address.
       - shellStyle: Shell style in which script is generated.
     */
    public func printProxyForURL(_ url: URL, shellStyle: ShellStyle) -> Void {
        guard let urlScheme: String = url.scheme else {
            return
        }
        let proxyIdentifier = "\(urlScheme)_proxy"
        
        guard let proxyURL: String = self.getProxyURLForURL(url) else {
            return
        }
        
        self.consoleHelper.printEnvironmentalVariable(proxyIdentifier, proxyURL, shellStyle: shellStyle)
    }
    
    /**
     Main entry point.
     
     - parameters:
       - arguments: Command line arguments.
     - returns:
     Exit status code.
     */
    public func main(_ arguments: [String]) -> Int32 {
        
        var shellStyle: ShellStyle? = nil
        
        if (arguments.count >= 2) {
            switch arguments[1] {
            case "-c":
                shellStyle = .CShell
            case "-s":
                shellStyle = .BourneShell
            default:
                break
            }
        }
        
        if shellStyle == nil {
            if let shellEnv: String = ProcessInfo.processInfo.environment["SHELL"] {
                if shellEnv.hasSuffix("csh") {
                    shellStyle = .CShell
                } else {
                    shellStyle = .BourneShell
                }
            } else {
                shellStyle = .BourneShell
            }
        }
        
        self.printProxySettings(shellStyle: shellStyle!)
        
        return 0
    }
    
}
