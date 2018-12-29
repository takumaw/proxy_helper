/*
 * Copyright (c) 2018 Takuma Watanabe.
 */

import Foundation

/**
 Shell style enumeration.
 */
enum ShellStyle {
    case bourneShell
    case cShell
}

/**
 Collections of helper function for console manipuration.
 */
class ConsoleHelper {
    
    // Dependencies.
    private let consoleWrapper: ConsoleWrapper
    
    /**
     Initializer.
     
     Inject dependencies.
     */
    init(consoleWrapper: ConsoleWrapper) {
        self.consoleWrapper = consoleWrapper
    }
    
    /**
     Print single-line script to define an environment variable.
     
     - parameters:
       - name: Environment variable name.
       - value: Environment variable value.
       - shellStyle: Shell style in which script is generated.
     */
    func printEnvironmentVariable(_ name: String, _ value: String, shellStyle: ShellStyle = .bourneShell) {
        let variables: [String: String] = [
            name: value,
        ]
        
        self.printEnvironmentVariables(variables, shellStyle: shellStyle)
    }
    
    /**
     Print single-line script to define multiple environment variables.
     
     - parameters:
       - variables: Environment variables in [name: value] style.
       - shellStyle: Shell style in which script is generated.
     */
    func printEnvironmentVariables(_ variables: [String: String], shellStyle: ShellStyle = .bourneShell) {
        var messages: [String] = []
        
        for (name, value) in variables {
            switch shellStyle {
            case .bourneShell:
                messages.append("\(name)=\"\(value)\";")
                messages.append("export \(name);")
            case .cShell:
                messages.append("setenv \(name) \"\(value)\";")
            }
        }
        
        let joinedMessages: String = messages.joined(separator: " ")
        self.consoleWrapper.out(joinedMessages)
    }
    
}
