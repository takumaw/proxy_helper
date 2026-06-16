/*
 * Copyright (c) 2018-2026 Takuma Watanabe.
 */

import Foundation

/**
 ProxyHelper controller class.
 */
class ProxyHelper {
    
    // MARK:- Dependencies
    
    private let consoleHelper: ConsoleHelper
    private let proxyHelperCore: ProxyHelperCore
    
    // MARK:- Initializer
    
    /**
     Initializer.
     
     Inject depencendies.
     */
    init(consoleHelper: ConsoleHelper,
         proxyHelperCore: ProxyHelperCore) {
        self.consoleHelper = consoleHelper
        self.proxyHelperCore = proxyHelperCore
    }
    
    // MARK:- Instance Methods
    
    // MARK: Entry point
    
    /**
     Main entry point.
     
     - parameters:
     - arguments: Command line arguments.
     - returns:
     Exit status code.
     */
    public func main(_ arguments: [String]) -> Int32 {
        var shellStyle: ShellStyle?
        var enablePAC = false
        var targetURLString: String?
        
        var i = 1
        while i < arguments.count {
            let arg = arguments[i]
            switch arg {
            case "-c":
                shellStyle = .cShell
            case "-s":
                shellStyle = .bourneShell
            case "-p", "--pac":
                enablePAC = true
            case "-u", "--url":
                if i + 1 < arguments.count {
                    targetURLString = arguments[i + 1]
                    i += 1
                } else {
                    return 1
                }
            default:
                break
            }
            i += 1
        }
        
        // If unable to determine shell style by option,
        // Then determine one using SHELL ennvironment variable.
        if shellStyle == nil {
            if let shellEnv: String = ProcessInfo.processInfo.environment["SHELL"] {
                if shellEnv.hasSuffix("csh") {
                    shellStyle = .cShell
                } else {
                    shellStyle = .bourneShell
                }
            }
        }
        
        // Fallbacks to Bourne Shell style.
        if shellStyle == nil {
            shellStyle = .bourneShell
        }
        
        if enablePAC {
            let defaultURL = URL(string: "https://www.google.com")!
            var targetURL = defaultURL
            if let targetURLString = targetURLString {
                if let url = URL(string: targetURLString) {
                    targetURL = url
                } else {
                    return 1
                }
            }
            self.printPACProxySettings(targetURL: targetURL, shellStyle: shellStyle!)
        } else {
            self.printProxySettings(shellStyle: shellStyle!)
        }
        
        return 0
    }
    
    // MARK: Commands
    
    /**
     Print proxy environment variables.
     
     - parameters:
     - shellStyle: Shell style in which script is generated.
     */
    public func printProxySettings(shellStyle: ShellStyle) {
        let proxyEnnvironmentVariables: [String: String] = self.proxyHelperCore.getAllProxyEnvironmentVariables()
        
        if proxyEnnvironmentVariables.keys.count > 0 {
            self.consoleHelper.printEnvironmentVariables(proxyEnnvironmentVariables, shellStyle: shellStyle)
        }
    }
    
    /**
     Print proxy environment variables determined by PAC.
     
     - parameters:
       - targetURL: Target URL to resolve proxy for.
       - shellStyle: Shell style in which script is generated.
     */
    public func printPACProxySettings(targetURL: URL, shellStyle: ShellStyle) {
        let proxyEnvironmentVariables = self.proxyHelperCore.getPACProxyEnvironmentVariables(targetURL: targetURL)
        
        if proxyEnvironmentVariables.keys.count > 0 {
            self.consoleHelper.printEnvironmentVariables(proxyEnvironmentVariables, shellStyle: shellStyle)
        }
    }
    
    /**
     Print proxy environment variable determined with given URL.
     
     - parameters:
     - url: URL using which to determine proxy address.
     - shellStyle: Shell style in which script is generated.
     */
    public func printProxyForURL(_ url: URL, shellStyle: ShellStyle) {
        let proxyEnnvironmentVariables: [String: String] = self.proxyHelperCore.getProxyEnvironmentVariableForURL(url)
        
        if proxyEnnvironmentVariables.keys.count > 0 {
            self.consoleHelper.printEnvironmentVariables(proxyEnnvironmentVariables, shellStyle: shellStyle)
        }
    }
    
}

