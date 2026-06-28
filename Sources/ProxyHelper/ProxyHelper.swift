/*
 * Copyright (c) 2018-2026 Takuma Watanabe.
 */

import Foundation

/**
 The controller class for the ProxyHelper utility.
 */
class ProxyHelper {

    // MARK: - Dependencies

    private let consoleHelper: ConsoleHelper
    private let proxyHelperCore: ProxyHelperCore

    // MARK: - Initializer

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
     The main entry point of the utility.
     
     - Parameters:
       - arguments: Command line arguments.
     - Returns: The exit status code.
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
     Parses command line arguments.
     
     - Parameters:
       - arguments: The command line arguments to parse.
     - Returns: The parsed options, or `nil` if the arguments are invalid.
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
            case "-f", "--fish":
                options.shellStyle = .fish
            case "-w", "--powershell":
                options.shellStyle = .powerShell
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
     Determines the shell style based on options and environment variables.
     
     - Parameters:
       - shellStyle: The specified shell style option, if any.
     - Returns: The determined shell style.
     */
    private func determineShellStyle(_ shellStyle: ShellStyle?) -> ShellStyle {
        if let shellStyle = shellStyle {
            return shellStyle
        }

        if let shellEnv: String = ProcessInfo.processInfo.environment["SHELL"] {
            if shellEnv.hasSuffix("csh") {
                return .cShell
            } else if shellEnv.hasSuffix("fish") {
                return .fish
            } else if shellEnv.hasSuffix("pwsh") || shellEnv.hasSuffix("powershell") {
                return .powerShell
            }
        }

        return .bourneShell
    }

    // MARK: - Commands

    /**
     Prints the proxy environment variables.
     
     - Parameters:
       - shellStyle: The shell style in which the script is generated.
     */
    public func printProxySettings(shellStyle: ShellStyle) {
        let proxyEnvironmentVariables: [String: String] = self.proxyHelperCore.getAllProxyEnvironmentVariables()

        if proxyEnvironmentVariables.keys.count > 0 {
            self.consoleHelper.printEnvironmentVariables(proxyEnvironmentVariables, shellStyle: shellStyle)
        }
    }

    /**
     Prints the proxy environment variables determined by the PAC script.
     
     - Parameters:
       - targetURL: The target URL to resolve the proxy for.
       - shellStyle: The shell style in which the script is generated.
     */
    public func printPACProxySettings(targetURL: URL, shellStyle: ShellStyle) {
        let proxyEnvironmentVariables = self.proxyHelperCore.getPACProxyEnvironmentVariables(targetURL: targetURL)

        if proxyEnvironmentVariables.keys.count > 0 {
            self.consoleHelper.printEnvironmentVariables(proxyEnvironmentVariables, shellStyle: shellStyle)
        }
    }

    /**
     Prints the proxy environment variables determined for a given URL.
     
     - Parameters:
       - url: The URL used to determine the proxy address.
       - shellStyle: The shell style in which the script is generated.
     */
    public func printProxyForURL(_ url: URL, shellStyle: ShellStyle) {
        let proxyEnvironmentVariables: [String: String] = self.proxyHelperCore.getProxyEnvironmentVariableForURL(url)

        if proxyEnvironmentVariables.keys.count > 0 {
            self.consoleHelper.printEnvironmentVariables(proxyEnvironmentVariables, shellStyle: shellStyle)
        }
    }

}
