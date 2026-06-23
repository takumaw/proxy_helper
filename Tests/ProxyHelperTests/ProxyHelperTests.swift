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
}
