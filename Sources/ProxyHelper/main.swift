/*
 * Copyright (c) 2018 Takuma Watanabe.
 */

import Foundation

import Basic
import Utility

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
        
        let parser = ArgumentParser(commandName: "proxy_helper",
                                    usage: "[-c | -s]",
                                    overview: "Helper for constructing *_PROXY environment variable",
                                    seeAlso: "path_helper(8)")
        
        let cShellEnabledOption = parser.add(option: "-c", kind: Bool.self,
                                             usage: "Generate C-shell commands on stdout.  This is the default if SHELL ends with \"csh\".")
        let bourneShellEnabledOption = parser.add(option: "-s", kind: Bool.self,
                                                  usage: "Generate Bourne shell commands on stdout.  This is the default if SHELL does not end with \"csh\".")
        
        do {
            let parsedResult: ArgumentParser.Result = try parser.parse(Array(arguments.dropFirst()))
            
            var shellStyle: ShellStyle = .BourneShell
            
            if let _: Bool = parsedResult.get(bourneShellEnabledOption) {
                shellStyle = .BourneShell
            } else if let _: Bool = parsedResult.get(cShellEnabledOption) {
                shellStyle = .CShell
            } else if let shellEnv: String = ProcessInfo.processInfo.environment["SHELL"] {
                if shellEnv.hasSuffix("csh") {
                    shellStyle = .CShell
                } else {
                    shellStyle = .BourneShell
                }
            } else {
                shellStyle = .BourneShell
            }
            
            Main.proxyHelper.printProxySettings(shellStyle: shellStyle)
            
            return 0
        } catch let error as ArgumentParserError {
            Main.console.err(error.description)
            parser.printUsage(on: stderrStream)
            
            return EINVAL
        } catch let error {
            Main.console.err(error.localizedDescription)
            
            return EINVAL
        }
    }
    
}

exit(Main().main(CommandLine.arguments))
