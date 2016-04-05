// RUN: mkdir -p %{built_tests_dir}/AppleXCTest.xctest/Contents/MacOS
// RUN: %{swiftc2} %s -o %{built_tests_dir}/AppleXCTest.xctest/Contents/MacOS/AppleXCTest
// RUN: xcrun xctest %{built_tests_dir}/AppleXCTest.xctest 2> %t || true
// RUN: %{xctest_checker} %t %s

import XCTest

// CHECK: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'SingleFailingTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class SingleFailingTestCase: XCTestCase {
    static var allTests: [(String, SingleFailingTestCase -> () throws -> Void)] {
        return [
                   ("test_fails", test_fails)
        ]
    }

// CHECK: Test Case '-\[AppleXCTest.SingleFailingTestCase test_fails\]' started.
// CHECK: .*/AppleXCTest/main.swift:23: error: -\[AppleXCTest.SingleFailingTestCase test_fails\] : XCTAssertTrue failed -
// CHECK: Test Case '-\[AppleXCTest.SingleFailingTestCase test_fails\]' failed \(\d+\.\d+ seconds\).
    func test_fails() {
        XCTAssert(false)
    }
}
// CHECK: Test Suite 'SingleFailingTestCase' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+.
// CHECK: \t Executed 1 test, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

// CHECK: Test Suite '.*\.xctest' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+.
// CHECK: \t Executed 1 test, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+.
// CHECK: \t Executed 1 test, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
