/*
 * Copyright (c) 2018 Takuma Watanabe.
 */

import Foundation
import CFNetwork

/**
 Collections of helper functions for manipulating the proxy configurations from CFNetwork.
 */
class CFNetworkHelper {
    
    /**
     Initializer.
     
     Inject dependencies.
     */
    init() {
    }
    
    private var proxySettings: CFDictionary?
    
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
        guard let proxySettingsAsDictionary: [String: Any] = self.getProxySettings() as? [String: Any] else {
            fatalError("Failed to load CFNetworkCopySystemProxySettings as a Swift Dictionary.")
        }
        return proxySettingsAsDictionary
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
        guard let proxiesForURLAsArray = self.getProxiesForURL(url) as? [[String: Any]] else {
            fatalError("Failed to load CFNetworkCopyProxiesForURL as a Swift Array.")
        }
        return proxiesForURLAsArray
    }
    
}
