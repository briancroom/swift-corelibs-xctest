// This source file is part of the Swift.org open source project
//
// Copyright (c) 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  PrintObserver.swift
//  Prints test progress to stdout.
//

#if os(Linux) || os(FreeBSD)
    import Foundation
#else
    import SwiftFoundation
#endif

/// Prints textual representations of each XCTestObservation event to stdout.
/// Mirrors the Apple XCTest output exactly.
internal class PrintObserver: XCTestObservation {
    func testBundleWillStart(testBundle: NSBundle) {}

    func testSuiteWillStart(testSuite: XCTestSuite) {
        printAndFlush("Test Suite '\(testSuite.name)' started at \(dateFormatter.stringFromDate(testSuite.testRun!.startDate!))")
    }

    func testCaseWillStart(testCase: XCTestCase) {
        printAndFlush("Test Case '\(testCase.name)' started at \(dateFormatter.stringFromDate(testCase.testRun!.startDate!))")
    }

    func testCase(testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt) {
        let file = filePath ?? "<unknown>"
        printAndFlush("\(file):\(lineNumber): error: \(description)")
    }

    func testCaseDidFinish(testCase: XCTestCase) {
        let testRun = testCase.testRun!
        let verb = testRun.hasSucceeded ? "passed" : "failed"
        // FIXME: Apple XCTest does not print a period after "(N seconds)".
        //        The trailing period here should be removed and the functional
        //        test suite should be updated.
        printAndFlush("Test Case '\(testCase.name)' \(verb) (\(formatTimeInterval(testRun.totalDuration)) seconds).")
    }

    func testSuiteDidFinish(testSuite: XCTestSuite) {
        let testRun = testSuite.testRun!
        let verb = testRun.hasSucceeded ? "passed" : "failed"
        printAndFlush("Test Suite '\(testSuite.name)' \(verb) at \(dateFormatter.stringFromDate(testRun.stopDate!))")

        let tests = testRun.executionCount == 1 ? "test" : "tests"
        let failures = testRun.totalFailureCount == 1 ? "failure" : "failures"
        printAndFlush(
            "\t Executed \(testRun.executionCount) \(tests), " +
            "with \(testRun.totalFailureCount) \(failures) (\(testRun.unexpectedExceptionCount) unexpected) " +
            "in \(formatTimeInterval(testRun.testDuration)) (\(formatTimeInterval(testRun.totalDuration))) seconds"
        )
    }

    func testBundleDidFinish(testBundle: NSBundle) {}

    private lazy var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()

    private func printAndFlush(message: String) {
        print(message)
        fflush(stdout)
    }

    private func formatTimeInterval(timeInterval: NSTimeInterval) -> String {
        return String(round(timeInterval * 1000.0) / 1000.0)
    }
}
