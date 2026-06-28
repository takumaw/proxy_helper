/*
 * Copyright (c) 2018-2026 Takuma Watanabe.
 */

import XCTest
import class Foundation.Bundle

final class ProxyHelperTests: XCTestCase {

    static var allTests = [
        ("testQuitsCorrectly", testQuitsCorrectly),
        ("testShellOptionBourne", testShellOptionBourne),
        ("testShellOptionCShell", testShellOptionCShell),
        ("testPACWithoutSettings", testPACWithoutSettings),
        ("testInvalidArguments", testInvalidArguments),
        ("testNoProxyDomainsWithIPv6AndCIDR", testNoProxyDomainsWithIPv6AndCIDR),
        ("testShellOptionFish", testShellOptionFish),
        ("testShellOptionPowerShell", testShellOptionPowerShell),
    ]

    func testQuitsCorrectly() throws {
        // Some of the APIs that we use below are available in macOS 10.13 and above.
        guard #available(macOS 10.13, *) else {
            return
        }

        let fooBinary = productsDirectory.appendingPathComponent("proxy_helper")

        let process = Process()
        process.executableURL = fooBinary

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)

        print(output as Any)

        XCTAssertEqual(process.terminationStatus, 0)
    }

    func testShellOptionBourne() throws {
        guard #available(macOS 10.13, *) else {
            return
        }

        let fooBinary = productsDirectory.appendingPathComponent("proxy_helper")

        let process = Process()
        process.executableURL = fooBinary
        process.arguments = ["-s"]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        if !output.isEmpty {
            XCTAssertTrue(output.contains("export"))
            XCTAssertFalse(output.contains("setenv"))
        }

        XCTAssertEqual(process.terminationStatus, 0)
    }

    func testShellOptionCShell() throws {
        guard #available(macOS 10.13, *) else {
            return
        }

        let fooBinary = productsDirectory.appendingPathComponent("proxy_helper")

        let process = Process()
        process.executableURL = fooBinary
        process.arguments = ["-c"]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        if !output.isEmpty {
            XCTAssertTrue(output.contains("setenv"))
            XCTAssertFalse(output.contains("export"))
        }

        XCTAssertEqual(process.terminationStatus, 0)
    }

    func testPACWithoutSettings() throws {
        guard #available(macOS 10.13, *) else {
            return
        }

        let fooBinary = productsDirectory.appendingPathComponent("proxy_helper")

        let process = Process()
        process.executableURL = fooBinary
        process.arguments = ["-p"]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        XCTAssertEqual(process.terminationStatus, 0)
    }

    func testInvalidArguments() throws {
        guard #available(macOS 10.13, *) else {
            return
        }

        let fooBinary = productsDirectory.appendingPathComponent("proxy_helper")

        let process = Process()
        process.executableURL = fooBinary
        process.arguments = ["-p", "-u"]

        try process.run()
        process.waitUntilExit()

        XCTAssertEqual(process.terminationStatus, 1)
    }

    func testShellOptionFish() throws {
        guard #available(macOS 10.13, *) else {
            return
        }

        let fooBinary = productsDirectory.appendingPathComponent("proxy_helper")

        let process = Process()
        process.executableURL = fooBinary
        process.arguments = ["-f"]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        if !output.isEmpty {
            XCTAssertTrue(output.contains("set -gx"))
            XCTAssertFalse(output.contains("export"))
            XCTAssertFalse(output.contains("setenv"))
        }

        XCTAssertEqual(process.terminationStatus, 0)
    }

    func testShellOptionPowerShell() throws {
        guard #available(macOS 10.13, *) else {
            return
        }

        let fooBinary = productsDirectory.appendingPathComponent("proxy_helper")

        let process = Process()
        process.executableURL = fooBinary
        process.arguments = ["-w"]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        if !output.isEmpty {
            XCTAssertTrue(output.contains("$env:"))
            XCTAssertFalse(output.contains("export"))
            XCTAssertFalse(output.contains("setenv"))
        }

        XCTAssertEqual(process.terminationStatus, 0)
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }

    func testNoProxyDomainsWithIPv6AndCIDR() throws {
        let mockCFNetworkHelper = MockCFNetworkHelper()
        mockCFNetworkHelper.mockProxySettings = [
            kCFNetworkProxiesExceptionsList as String: [
                "*.example.com",
                "192.168.1.1",
                "192.168.2.0/24",
                "fe80::1",
                "[fe80::2]",
                "fe80::/64",
                "[fe80::]/64",
                "invalid_ip/999",
                "1.1.1.1/33",
                "fe80::1/129",
                "example.com",
            ],
        ]

        let core = ProxyHelperCore(cfNetworkHelper: mockCFNetworkHelper)
        let result = core.getNoProxyDomains()

        XCTAssertNotNil(result)
        let domains = result?.components(separatedBy: ",") ?? []

        XCTAssertEqual(domains.count, 7)
        XCTAssertTrue(domains.contains("example.com"))
        XCTAssertTrue(domains.contains("192.168.1.1"))
        XCTAssertTrue(domains.contains("192.168.2.0/24"))
        XCTAssertTrue(domains.contains("fe80::1"))
        XCTAssertTrue(domains.contains("fe80::2"))
        XCTAssertTrue(domains.contains("fe80::/64"))
    }
}

class MockCFNetworkHelper: CFNetworkHelper {
    var mockProxySettings: [String: Any] = [:]

    override func getProxySettingsAsDictionary() -> [String: Any] {
        return self.mockProxySettings
    }
}
