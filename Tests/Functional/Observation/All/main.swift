// RUN: %{swiftc} %s -o %{built_tests_dir}/All
// RUN: %{built_tests_dir}/All > %t || true
// RUN: %{xctest_checker} %t %s

#if os(Linux) || os(FreeBSD)
    import XCTest
    import Foundation
#else
    import SwiftXCTest
    import SwiftFoundation
#endif

// CHECK: Test Suite 'All tests' started at \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+:\d+:\d+\.\d+

class Observer: XCTestObservation {
    var startedBundlePaths = [String]()
    var startedTestSuites = [XCTestSuite]()
    var startedTestCaseNames = [String]()
    var failureDescriptions = [String]()
    var finishedTestCaseNames = [String]()
    var finishedTestSuites = [XCTestSuite]()
    var finishedBundlePaths = [String]()

    func testBundleWillStart(testBundle: NSBundle) {
        startedBundlePaths.append(testBundle.bundlePath)
    }

    func testSuiteWillStart(testSuite: XCTestSuite) {
        startedTestSuites.append(testSuite)
    }

    func testCaseWillStart(testCase: XCTestCase) {
        startedTestCaseNames.append(testCase.name)
    }

    func testCase(testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt) {
        failureDescriptions.append(description)
    }

    func testCaseDidFinish(testCase: XCTestCase) {
        finishedTestCaseNames.append(testCase.name)
    }

    func testSuiteDidFinish(testSuite: XCTestSuite) {
        print("In \(#function): \(testSuite.name)")
    }

    func testBundleDidFinish(testBundle: NSBundle) {
        print("In \(#function)")
    }
}

let observer = Observer()
XCTestObservationCenter.shared().addTestObserver(observer)

// CHECK: Test Suite 'Observation' started at \d+:\d+:\d+\.\d+
class Observation: XCTestCase {
    static var allTests: [(String, Observation -> () throws -> Void)] {
        return [
            ("test_one", test_one),
            ("test_two", test_two),
            ("test_three", test_three),
        ]
    }

// CHECK: Test Case 'Observation.test_one' started at \d+:\d+:\d+\.\d+
// CHECK: .*/Observation/All/main.swift:\d+: error: Observation.test_one : failed - fail!
// CHECK: Test Case 'Observation.test_one' failed \(\d+\.\d+ seconds\).
    func test_one() {
        XCTAssertEqual(observer.startedBundlePaths.count, 1)
        XCTAssertEqual(
            observer.startedTestSuites.count, 3,
            "Three test suites should have started: 'All tests', 'tmp.xctest', and 'Observation'.")
        XCTAssertEqual(observer.startedTestCaseNames, ["Observation.test_one"])
        XCTAssertEqual(observer.failureDescriptions, [])
        XCTAssertEqual(observer.finishedTestCaseNames, [])
        XCTAssertEqual(observer.finishedBundlePaths.count, 0)

        XCTFail("fail!")
        XCTAssertEqual(observer.failureDescriptions, ["Observation.test_one : failed - fail!"])
    }

// CHECK: Test Case 'Observation.test_two' started at \d+:\d+:\d+\.\d+
// CHECK: Test Case 'Observation.test_two' passed \(\d+\.\d+ seconds\).
    func test_two() {
        XCTAssertEqual(observer.startedBundlePaths.count, 1)
        XCTAssertEqual(
            observer.startedTestSuites.count, 3,
            "Three test suites should have started: 'All tests', 'tmp.xctest', and 'Observation'.")
        XCTAssertEqual(observer.startedTestCaseNames, ["Observation.test_one", "Observation.test_two"])
        XCTAssertEqual(observer.finishedTestCaseNames,["Observation.test_one"])
        XCTAssertEqual(observer.finishedBundlePaths.count, 0)

        XCTestObservationCenter.shared().removeTestObserver(observer)
    }

// CHECK: Test Case 'Observation.test_three' started at \d+:\d+:\d+\.\d+
// CHECK: Test Case 'Observation.test_three' passed \(\d+\.\d+ seconds\).
    func test_three() {
        XCTAssertEqual(observer.startedBundlePaths.count, 1)
        XCTAssertEqual(observer.startedTestCaseNames, ["Observation.test_one", "Observation.test_two"])
        XCTAssertEqual(observer.finishedTestCaseNames,["Observation.test_one"])
        XCTAssertEqual(observer.finishedBundlePaths.count, 0)

        XCTestObservationCenter.shared().addTestObserver(observer)
    }
}

// There's no guarantee as to the order in which these two observers will be
// called, so we match any order here.

// CHECK: (In testSuiteDidFinish: Observation)|(Test Suite 'Observation' failed at \d+:\d+:\d+\.\d+)|(\t Executed 3 tests, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds)
// CHECK: (In testSuiteDidFinish: Observation)|(Test Suite 'Observation' failed at \d+:\d+:\d+\.\d+)|(\t Executed 3 tests, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds)
// CHECK: (In testSuiteDidFinish: Observation)|(Test Suite 'Observation' failed at \d+:\d+:\d+\.\d+)|(\t Executed 3 tests, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds)

XCTMain([testCase(Observation.allTests)])

// CHECK: (In testSuiteDidFinish: .*\.xctest)|(Test Suite '.*\.xctest' failed at \d+:\d+:\d+\.\d+)|(\t Executed 3 tests, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds)
// CHECK: (In testSuiteDidFinish: .*\.xctest)|(Test Suite '.*\.xctest' failed at \d+:\d+:\d+\.\d+)|(\t Executed 3 tests, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds)
// CHECK: (In testSuiteDidFinish: .*\.xctest)|(Test Suite '.*\.xctest' failed at \d+:\d+:\d+\.\d+)|(\t Executed 3 tests, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds)

// CHECK: (In testSuiteDidFinish: All tests)|(Test Suite 'All tests' failed at \d+:\d+:\d+\.\d+)|(\t Executed 3 tests, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds)
// CHECK: (In testSuiteDidFinish: All tests)|(Test Suite 'All tests' failed at \d+:\d+:\d+\.\d+)|(\t Executed 3 tests, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds)
// CHECK: (In testSuiteDidFinish: All tests)|(Test Suite 'All tests' failed at \d+:\d+:\d+\.\d+)|(\t Executed 3 tests, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds)

// CHECK: In testBundleDidFinish
