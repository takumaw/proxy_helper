/*
 * Copyright (c) 2018 Takuma Watanabe.
 */

import Foundation

/**
 ProxyHelper entry point class.
 */
class Main {
    
    private let cfNetworkHelper: CFNetworkHelper
    private let console: Console
    private let consoleHelper: ConsoleHelper
    private let proxyHelper: ProxyHelper
    
    /**
     Initializer.
     
     Inject dependencies of the entire application.
     */
    init() {
        self.cfNetworkHelper = CFNetworkHelper()
        self.console = Console()
        self.consoleHelper = ConsoleHelper(console: console)
        self.proxyHelper = ProxyHelper(consoleHelper: consoleHelper, cfNetworkHelper: cfNetworkHelper)
    }
    
    /**
     Main function.
     
     Invoke main logic class's entry point.
     
     - parameters:
       - arguments: Command line arguments.
     - returns:
     Exit status code.
     */
    public func main(_ arguments: [String]) -> Int32 {
        return proxyHelper.main(arguments)
    }
    
}

exit(Main().main(CommandLine.arguments))
