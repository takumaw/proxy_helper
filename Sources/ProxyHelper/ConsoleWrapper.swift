/*
 * Copyright (c) 2018-2026 Takuma Watanabe.
 */

import Foundation

/**
 A wrapper class for handling console output operations.
 */
class ConsoleWrapper {

    // MARK: - Initializer

    /**
     Initializer.
     */
    init() {
    }

    // MARK: - Instance Methods

    /**
     Prints a message to the given file handle.
     
     - parameters:
       - message: The message to print.
       - end: The message terminator.
       - file: The FileHandle to write the message to.
     */
    func print(_ message: String, end: String = "\n", file: FileHandle) {
        guard let messageData: Data = message.data(using: String.Encoding.utf8) else {
            return
        }
        guard let endData: Data = end.data(using: String.Encoding.utf8) else {
            return
        }

        file.write(messageData)
        file.write(endData)
    }

    /**
     Prints a message to standard output.
     
     - parameters:
       - message: The message to print.
       - end: The message terminator.
     */
    func out(_ message: String, end: String = "\n") {
        self.print(message, end: end, file: FileHandle.standardOutput)
    }

    /**
     Prints a message to standard error.
     
     - parameters:
       - message: The message to print.
       - end: The message terminator.
     */
    func err(_ message: String, end: String = "\n") {
        self.print(message, end: end, file: FileHandle.standardError)
    }

}
