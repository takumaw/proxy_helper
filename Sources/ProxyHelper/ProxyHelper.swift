/*
 * Copyright (c) 2018 Takuma Watanabe.
 */

import Foundation

/**
 ProxyHelper controller class.
 */
class ProxyHelper {
    
    // Dependencies.
    private let consoleHelper: ConsoleHelper
    private let proxyHelperCore: ProxyHelperCore
    
    /**
     Initializer.
     
     Inject depencendies.
     */
    init(consoleHelper: ConsoleHelper,
         proxyHelperCore: ProxyHelperCore) {
        self.consoleHelper = consoleHelper
        self.proxyHelperCore = proxyHelperCore
    }
    
    /**
     Main entry point.
     
     - parameters:
     - arguments: Command line arguments.
     - returns:
     Exit status code.
     */
    public func main(_ arguments: [String]) -> Int32 {
        
        var shellStyle: ShellStyle?
        
        // Parse options when specified.
        // Ignore unknown options.
        if arguments.count >= 2 {
            switch arguments[1] {
            case "-c":
                shellStyle = .cShell
            case "-s":
                shellStyle = .bourneShell
            default:
                break
            }
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
        
        // Invoke specified command.
        self.printProxySettings(shellStyle: shellStyle!)
        
        return 0
    }
    
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
