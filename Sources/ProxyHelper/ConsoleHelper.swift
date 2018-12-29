/*
 * Copyright (c) 2018 Takuma Watanabe.
 */

import Foundation

/**
 Shell Style enumeration.
 */
enum ShellStyle {
    case bourneShell
    case cShell
}

/**
 Collections of helper function for console manipuration.
 */
class ConsoleHelper {
    
    private let console: Console
    
    init(console: Console) {
        self.console = console
    }
    
    /**
     Print single-line script to define an environmental variable.
     
     - parameters:
       - name: Environmental variable name.
       - value: Environmental variable value.
       - shellStyle: Shell style in which script is generated.
     */
    func printEnvironmentalVariable(_ name: String, _ value: String, shellStyle: ShellStyle = .bourneShell) {
        let variables: [String: String] = [
            name: value,
        ]
        
        self.printEnvironmentalVariables(variables, shellStyle: shellStyle)
    }
    
    /**
     Print single-line script to define multiple environmental variables.
     
     - parameters:
       - variables: Environmental variables in [name: value] style.
       - shellStyle: Shell style in which script is generated.
     */
    func printEnvironmentalVariables(_ variables: [String: String], shellStyle: ShellStyle = .bourneShell) {
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
        
        let joinedMessages = messages.joined(separator: " ")
        self.console.out(joinedMessages)
    }
    
}
