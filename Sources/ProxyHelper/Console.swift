/*
 * Copyright (c) 2018 Takuma Watanabe.
 */

import Foundation

/**
 Simple wrapper class for console manipulation.
 */
class Console {
    
    /**
     Print message to given filehandle.
     
     - parameters:
       - message: Message to print.
       - end: Message terminator.
       - file: FileHandle to print message to.
    */
    func print(_ message: String, end: String = "\n", file: FileHandle) -> Void {
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
     Print message to the standard output.
     
     - parameters:
       - message: Message to print.
       - end: Message terminator.
     */
    func out(_ message: String, end: String = "\n") -> Void {
        self.print(message, end: end, file: FileHandle.standardOutput)
    }
    
    /**
     Print message to the standard error.
     
     - parameters:
       - message: Message to print.
       - end: Message terminator.
     */
    func err(_ message: String, end: String = "\n") -> Void {
        self.print(message, end: end, file: FileHandle.standardError)
    }
    
}
