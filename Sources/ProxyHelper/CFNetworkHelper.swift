/*
 * Copyright (c) 2018-2026 Takuma Watanabe.
 */

import Foundation
import CFNetwork

public enum ProxyError: Error, LocalizedError {
    case cfNetworkSettingsLoadFailure
    case cfNetworkProxiesForURLFailure

    public var errorDescription: String? {
        switch self {
        case .cfNetworkSettingsLoadFailure:
            return "Failed to load system proxy settings via CFNetwork."
        case .cfNetworkProxiesForURLFailure:
            return "Failed to resolve proxies for the specified URL."
        }
    }
}

/**
 A collection of helper functions for manipulating proxy configurations from CFNetwork.
 */
class CFNetworkHelper {

    // MARK: - Instance Variables

    private var proxySettings: CFDictionary?

    // MARK: - Initializer

    init() {
    }

    // MARK: - Instance Methods

    /**
     Returns the system proxy settings.
     
     The result is cached and reused for subsequent calls.
     
     - Returns: The system proxy settings.
     */
    public func getProxySettings() throws -> CFDictionary {
        if proxySettings == nil {
            guard let unmanagedProxySettings: Unmanaged<CFDictionary> = CFNetworkCopySystemProxySettings() else {
                throw ProxyError.cfNetworkSettingsLoadFailure
            }
            proxySettings = unmanagedProxySettings.takeRetainedValue()
        }

        return proxySettings!
    }

    /**
     Returns the system proxy settings as a Swift dictionary.
     
     - Returns: The system proxy settings as a dictionary.
     */
    public func getProxySettingsAsDictionary() throws -> [String: Any] {
        guard let proxySettingsAsDictionary: [String: Any] = try self.getProxySettings() as? [String: Any] else {
            throw ProxyError.cfNetworkSettingsLoadFailure
        }
        return proxySettingsAsDictionary
    }

    /**
     Returns the proxies configured for a specified URL.
     
     - Parameters:
       - url: The URL used to determine proxy addresses.
     - Returns: The CFArray of proxies.
     */
    public func getProxiesForURL(_ url: URL) throws -> CFArray {
        let unmanagedProxies: Unmanaged<CFArray> = CFNetworkCopyProxiesForURL(url as CFURL, try self.getProxySettings())
        return unmanagedProxies.takeRetainedValue()
    }

    /**
     Returns the proxies configured for a specified URL as a Swift array.
     
     - Parameters:
       - url: The URL used to determine proxy addresses.
     - Returns: The array of proxy dictionaries.
     */
    public func getProxiesForURLAsArray(_ url: URL) throws -> [[String: Any]] {
        guard let proxiesForURLAsArray = try self.getProxiesForURL(url) as? [[String: Any]] else {
            throw ProxyError.cfNetworkProxiesForURLFailure
        }
        return proxiesForURLAsArray
    }

    /**
     Executes PAC (Proxy Auto-Configuration) script evaluation to resolve proxies for a specified URL.
     
     - Parameters:
       - pacURL: The URL of the PAC script.
       - targetURL: The URL used to determine proxy addresses.
       - timeout: The timeout in seconds for resolution.
     - Returns: The array of resolved proxy dictionaries, or `nil` if resolution failed.
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
