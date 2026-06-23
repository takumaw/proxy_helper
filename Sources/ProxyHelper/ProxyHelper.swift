/*
 * Copyright (c) 2018-2026 Takuma Watanabe.
 */

import Foundation

/**
 ProxyHelper controller class.
 */
class ProxyHelper {

    // MARK: - Dependencies

    private let consoleHelper: ConsoleHelper
    private let proxyHelperCore: ProxyHelperCore

    // MARK: - Initializer

    /**
     Initializer.
     
     Inject depencendies.
     */
    init(consoleHelper: ConsoleHelper,
         proxyHelperCore: ProxyHelperCore) {
        self.consoleHelper = consoleHelper
        self.proxyHelperCore = proxyHelperCore
    }

    private struct Options {
        var shellStyle: ShellStyle?
        var enablePAC = false
        var targetURLString: String?
    }

    // MARK: - Entry point

    /**
     Main entry point.
     
     - parameters:
     - arguments: Command line arguments.
     - returns:
     Exit status code.
     */
    public func main(_ arguments: [String]) -> Int32 {
        guard let options = self.parseArguments(arguments) else {
            return 1
        }

        let shellStyle = self.determineShellStyle(options.shellStyle)

        if options.enablePAC {
            let defaultURL = URL(string: "https://www.google.com")!
            var targetURL = defaultURL
            if let targetURLString = options.targetURLString {
                if let url = URL(string: targetURLString) {
                    targetURL = url
                } else {
                    return 1
                }
            }
            self.printPACProxySettings(targetURL: targetURL, shellStyle: shellStyle)
        } else {
            self.printProxySettings(shellStyle: shellStyle)
        }

        return 0
    }

    /**
     Parse command line arguments.
     
     - parameters:
       - arguments: Command line arguments.
     - returns:
       Parsed options or nil if arguments are invalid.
     */
    private func parseArguments(_ arguments: [String]) -> Options? {
        var options = Options()
        var i = 1
        while i < arguments.count {
            let arg = arguments[i]
            switch arg {
            case "-c":
                options.shellStyle = .cShell
            case "-s":
                options.shellStyle = .bourneShell
            case "-p", "--pac":
                options.enablePAC = true
            case "-u", "--url":
                if i + 1 < arguments.count {
                    options.targetURLString = arguments[i + 1]
                    i += 1
                } else {
                    return nil
                }
            default:
                break
            }
            i += 1
        }
        return options
    }

    /**
     Determine shell style based on options and environment variables.
     
     - parameters:
       - shellStyle: Shell style option if specified.
     - returns:
       Determined shell style.
     */
    private func determineShellStyle(_ shellStyle: ShellStyle?) -> ShellStyle {
        if let shellStyle = shellStyle {
            return shellStyle
        }

        if let shellEnv: String = ProcessInfo.processInfo.environment["SHELL"] {
            if shellEnv.hasSuffix("csh") {
                return .cShell
            }
        }

        return .bourneShell
    }

    // MARK: - Commands

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
