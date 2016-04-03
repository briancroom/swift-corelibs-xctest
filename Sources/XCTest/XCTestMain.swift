// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2015 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCTestMain.swift
//  This is the main file for the framework. It provides the entry point function
//  for running tests and some infrastructure for running them.
//

#if os(Linux) || os(FreeBSD)
    import Glibc
    import Foundation
#else
    import Darwin
    import SwiftFoundation
#endif

/// Starts a test run for the specified test cases.
///
/// This function will not return. If the test cases pass, then it will call `exit(0)`. If there is a failure, then it will call `exit(1)`.
/// Example usage:
///
///     class TestFoo: XCTestCase {
///         static var allTests : [(String, TestFoo -> () throws -> Void)] {
///             return [
///                 ("test_foo", test_foo),
///                 ("test_bar", test_bar),
///             ]
///         }
///
///         func test_foo() {
///             // Test things...
///         }
///
///         // etc...
///     }
///
///     XCTMain([ testCase(TestFoo.allTests) ])
///
/// Command line arguments can be used to select a particular test or test case to execute. For example:
///
///     ./FooTests FooTestCase/testFoo  # Run a single test method
///     ./FooTests FooTestCase          # Run all the tests in FooTestCase
///
/// - Parameter testCases: An array of test cases run, each produced by a call to the `testCase` function
/// - seealso: `testCase`
@noreturn public func XCTMain(testCases: [XCTestCaseEntry]) {
    // Add a test observer that prints test progress to stdout.
    let observationCenter = XCTestObservationCenter.shared()
    observationCenter.addTestObserver(PrintObserver())

    // Announce that the test bundle will start executing.
    let testBundle = NSBundle.mainBundle()
    observationCenter.testBundleWillStart(testBundle)

    // Apple XCTest behaves differently if tests have been filtered:
    // - The root `XCTestSuite` is named "Selected tests" instead of
    //   "All tests".
    // - An `XCTestSuite` representing the .xctest test bundle is not included.
    let selectedTestName = ArgumentParser().selectedTestName
    let rootTestSuite: XCTestSuite
    let currentTestSuite: XCTestSuite
    if selectedTestName == nil {
        rootTestSuite = XCTestSuite(name: "All tests")
        currentTestSuite = XCTestSuite(name: "\(testBundle.bundlePath.lastPathComponent).xctest")
        rootTestSuite.addTest(currentTestSuite)
    } else {
        rootTestSuite = XCTestSuite(name: "Selected tests")
        currentTestSuite = rootTestSuite
    }

    let filter = TestFiltering(selectedTestName: selectedTestName)
    for (testCaseType, tests) in TestFiltering.filterTests(testCases, filter: filter.selectedTestFilter) {
        let dummyTestCase = testCaseType.init(name: "None") { _ in }
        let testCaseSuite = XCTestSuite(name: "\(dummyTestCase.dynamicType)")
        for (testName, testClosure) in tests {
            let testCase = testCaseType.init(name: testName, testClosure: testClosure)
            testCaseSuite.addTest(testCase)
        }
        currentTestSuite.addTest(testCaseSuite)
    }

    rootTestSuite.runTest()

    observationCenter.testBundleDidFinish(testBundle)
    exit(rootTestSuite.testRun!.totalFailureCount == 0 ? 0 : 1)
}
