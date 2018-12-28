/*
 * Copyright (c) 2018 Takuma Watanabe.
 */

import Foundation
import CFNetwork

/**
 Collections of helper functions for manipulating the proxy configurations from CFNetwork.
 */
class CFNetworkHelper {
    
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
    
}
