/*
 * Copyright (c) 2018 Takuma Watanabe.
 */

import Foundation
import CFNetwork

/**
 ProxyHelper main logic class.
 */
class ProxyHelper {
    
    private static let consoleUtils: ConsoleUtils = ConsoleUtils()
    private static let proxyUtils: ProxyUtils = ProxyUtils()
    
    /**
     Print proxy environmental variables.
     
     - parameters:
       - shellStyle: Shell style in which script is generated.
     */
    public func printProxySettings(shellStyle: ShellStyle) -> Void {
        var proxyVariables: [String: String] = [:]
        
        if let httpProxyURL: String = ProxyHelper.proxyUtils.getHTTPProxyURL() {
            proxyVariables["http_proxy"] = httpProxyURL
        }
        
        if let httpsProxyURL: String = ProxyHelper.proxyUtils.getHTTPSProxyURL() {
            proxyVariables["https_proxy"] = httpsProxyURL
        }
        
        if let ftpProxyURL: String = ProxyHelper.proxyUtils.getFTPProxyURL() {
            proxyVariables["ftp_proxy"] = ftpProxyURL
        }
        
        if let noProxyDomains: String = ProxyHelper.proxyUtils.getNoProxyDomains() {
            proxyVariables["no_proxy"] = noProxyDomains
        }
        
        if proxyVariables.keys.count > 0 {
            ProxyHelper.consoleUtils.printEnvironmentalVariables(proxyVariables, shellStyle: shellStyle)
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
        
        guard let proxyURL: String = ProxyHelper.proxyUtils.getProxyURLForURL(url) else {
            return
        }
        
        ProxyHelper.consoleUtils.printEnvironmentalVariable(proxyIdentifier, proxyURL, shellStyle: shellStyle)
    }
    
}
