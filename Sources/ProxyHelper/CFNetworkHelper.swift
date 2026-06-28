/*
 * Copyright (c) 2018-2026 Takuma Watanabe.
 */

import Foundation
import CFNetwork

/**
 A collection of helper functions for manipulating proxy configurations from CFNetwork.
 */
class CFNetworkHelper {

    // MARK: - Instance Variables

    private var proxySettings: CFDictionary?

    // MARK: - Initializer

    /**
     Initializer.
     */
    init() {
    }

    // MARK: - Instance Methods

    /**
     Returns the system proxy settings.
     
     The result is cached and reused for subsequent calls.
     
     - returns:
     The system proxy settings.
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
     Returns the system proxy settings as a Swift dictionary.
     
     - returns: The system proxy settings.
     */
    public func getProxySettingsAsDictionary() -> [String: Any] {
        guard let proxySettingsAsDictionary: [String: Any] = self.getProxySettings() as? [String: Any] else {
            fatalError("Failed to load CFNetworkCopySystemProxySettings as a Swift Dictionary.")
        }
        return proxySettingsAsDictionary
    }

    /**
     Returns the proxies configured for a specified URL.
     
     - parameters:
       - url: The URL used to determine proxy addresses.
     - returns:
       The proxies.
     */
    public func getProxiesForURL(_ url: URL) -> CFArray {
        let unmanagedProxies: Unmanaged<CFArray> = CFNetworkCopyProxiesForURL(url as CFURL, self.getProxySettings())
        return unmanagedProxies.takeRetainedValue()
    }

    /**
     Returns the proxies configured for a specified URL as a Swift array.
     
     - parameters:
       - url: The URL used to determine proxy addresses.
     - returns:
     The proxies.
     */
    public func getProxiesForURLAsArray(_ url: URL) -> [[String: Any]] {
        guard let proxiesForURLAsArray = self.getProxiesForURL(url) as? [[String: Any]] else {
            fatalError("Failed to load CFNetworkCopyProxiesForURL as a Swift Array.")
        }
        return proxiesForURLAsArray
    }

    /**
     Executes PAC (Proxy Auto-Configuration) script evaluation to resolve proxies for a specified URL.
     
     - parameters:
       - pacURL: The URL of the PAC script.
       - targetURL: The URL used to determine proxy addresses.
       - timeout: The timeout in seconds for resolution.
     - returns:
       The resolved proxies.
     */
    public func executePAC(pacURL: URL, targetURL: URL, timeout: TimeInterval = 0.2) -> [[String: Any]]? {
        class PACContext {
            var result: CFArray?
            var error: CFError?
            var isDone = false
        }

        let context = PACContext()
        let contextPointer = Unmanaged.passRetained(context).toOpaque()

        var streamContext = CFStreamClientContext(
            version: 0,
            info: contextPointer,
            retain: nil,
            release: nil,
            copyDescription: nil
        )

        let callback: CFProxyAutoConfigurationResultCallback = { (clientInfo, proxies, error) in
            let context = Unmanaged<PACContext>.fromOpaque(clientInfo).takeUnretainedValue()

            context.result = proxies
            context.error = error
            context.isDone = true

            CFRunLoopStop(CFRunLoopGetCurrent())
        }

        let runLoop = CFRunLoopGetCurrent()
        let runLoopSource = CFNetworkExecuteProxyAutoConfigurationURL(
            pacURL as CFURL,
            targetURL as CFURL,
            callback,
            &streamContext
        )

        let mode = CFRunLoopMode.defaultMode

        CFRunLoopAddSource(runLoop, runLoopSource, mode)

        _ = CFRunLoopRunInMode(mode, timeout, false)

        CFRunLoopRemoveSource(runLoop, runLoopSource, mode)
        Unmanaged<PACContext>.fromOpaque(contextPointer).release()

        if context.isDone {
            if let resolvedProxies = context.result as? [[String: Any]] {
                return resolvedProxies
            }
        }

        return nil
    }

}
