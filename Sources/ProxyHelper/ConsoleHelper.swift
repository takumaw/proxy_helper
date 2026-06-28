/*
 * Copyright (c) 2018-2026 Takuma Watanabe.
 */

import Foundation

// MARK: - Constants and Variables

/**
 An enumeration of supported shell styles.
 */
enum ShellStyle {
    case bourneShell
    case cShell
    case fish
    case powerShell
}

// MARK: - Class

/**
 A collection of helper functions for console manipulation.
 */
class ConsoleHelper {

    // MARK: - Dependencies

    private let consoleWrapper: ConsoleWrapper

    // MARK: - Initializer

    /**
     Initializer.
     
     Injects dependencies.
     */
    init(consoleWrapper: ConsoleWrapper) {
        self.consoleWrapper = consoleWrapper
    }

    // MARK: - Instance Methods

    /**
     Prints a single-line script to define an environment variable.
     
     - parameters:
       - name: The environment variable name.
       - value: The environment variable value.
       - shellStyle: The shell style in which the script is generated.
     */
    func printEnvironmentVariable(_ name: String, _ value: String, shellStyle: ShellStyle = .bourneShell) {
        let variables: [String: String] = [
            name: value,
        ]

        self.printEnvironmentVariables(variables, shellStyle: shellStyle)
    }

    /**
     Prints a single-line script to define multiple environment variables.
     
     - parameters:
       - variables: The environment variables in `[name: value]` format.
       - shellStyle: The shell style in which the script is generated.
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
            case .fish:
                messages.append("set -gx \(name) \"\(value)\";")
            case .powerShell:
                messages.append("$env:\(name) = \"\(value)\";")
            }
        }

        let joinedMessages: String = messages.joined(separator: " ")
        self.consoleWrapper.out(joinedMessages)
    }

}
