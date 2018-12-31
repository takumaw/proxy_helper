/*
 * Copyright (c) 2018 Takuma Watanabe.
 */

import Foundation

/**
 ProxyHelper application entry point class.
 */
class Main {
    
    // MARK:- Dependencies
    
    private let cfNetworkHelper: CFNetworkHelper
    private let consoleHelper: ConsoleHelper
    private let consoleWrapper: ConsoleWrapper
    private let proxyHelper: ProxyHelper
    private let proxyHelperCore: ProxyHelperCore
    
    // MARK:- Initializer
    
    /**
     Initializer.
     
     Inject dependencies of the entire application.
     */
    init() {
        self.cfNetworkHelper = CFNetworkHelper()
        self.consoleWrapper = ConsoleWrapper()
        self.consoleHelper = ConsoleHelper(consoleWrapper: consoleWrapper)
        self.proxyHelperCore = ProxyHelperCore(cfNetworkHelper: cfNetworkHelper)
        self.proxyHelper = ProxyHelper(consoleHelper: consoleHelper, proxyHelperCore: proxyHelperCore)
    }
    
    // MARK:- Instance methods
    
    /**
     Main function.
     
     Invoke controller class's main entry point.
     
     - parameters:
       - arguments: Command line arguments.
     - returns:
     Exit status code.
     */
    public func main(_ arguments: [String]) -> Int32 {
        return proxyHelper.main(arguments)
    }
    
}

/// Entry point invocation.
exit(Main().main(CommandLine.arguments))
