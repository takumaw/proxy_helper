/*
 * Copyright (c) 2018-2026 Takuma Watanabe.
 */

import Foundation

/**
 The entry point class for the ProxyHelper application.
 */
class Main {

    // MARK: - Dependencies

    private let cfNetworkHelper: CFNetworkHelper
    private let consoleHelper: ConsoleHelper
    private let consoleWrapper: ConsoleWrapper
    private let proxyHelper: ProxyHelper
    private let proxyHelperCore: ProxyHelperCore

    // MARK: - Initializer

    /**
     Initializer.
     
     Injects dependencies for the entire application.
     */
    init() {
        self.cfNetworkHelper = CFNetworkHelper()
        self.consoleWrapper = ConsoleWrapper()
        self.consoleHelper = ConsoleHelper(consoleWrapper: consoleWrapper)
        self.proxyHelperCore = ProxyHelperCore(cfNetworkHelper: cfNetworkHelper)
        self.proxyHelper = ProxyHelper(consoleHelper: consoleHelper, proxyHelperCore: proxyHelperCore)
    }

    // MARK: - Instance Methods

    /**
     Main function.
     
     Invokes the controller class's main entry point.
     
     - parameters:
       - arguments: Command line arguments.
     - returns:
     The exit status code.
     */
    public func main(_ arguments: [String]) -> Int32 {
        return proxyHelper.main(arguments)
    }

}

/// Entry point invocation.
exit(Main().main(CommandLine.arguments))
