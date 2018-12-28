/*
 * Copyright (c) 2018 Takuma Watanabe.
 */

import Foundation

/**
 ProxyHelper entry point class.
 */
class Main {
    
    private static let console = Console()
    private static let proxyHelper = ProxyHelper()
    
    /**
     Main function.
     
     - parameters:
       - arguments: Command line arguments.
     - returns:
     Exit status code.
     */
    public func main(_ arguments: [String]) -> Int32 {
        
        var shellStyle: ShellStyle = .BourneShell
        
        if (arguments.count == 1) {
            if let shellEnv: String = ProcessInfo.processInfo.environment["SHELL"] {
                if shellEnv.hasSuffix("csh") {
                    shellStyle = .CShell
                } else {
                    shellStyle = .BourneShell
                }
            } else {
                shellStyle = .BourneShell
            }
        } else {
            if (arguments[1] == "-c") {
                shellStyle = .CShell
            } else if (arguments[1] == "-s") {
                shellStyle = .BourneShell
            } else {
                shellStyle = .BourneShell
            }
        }
        
        Main.proxyHelper.printProxySettings(shellStyle: shellStyle)
        
        return 0
    }
    
}

exit(Main().main(CommandLine.arguments))
