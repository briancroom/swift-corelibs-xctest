// RUN: %{swiftc} %s -o %{built_tests_dir}/SelectedTest
// RUN: %{built_tests_dir}/SelectedTest SelectedTest.ExecutedTestCase/test_foo > %t || true
// RUN: %{built_tests_dir}/SelectedTest SelectedTest.ExecutedTestCase >> %t || true
// RUN: %{xctest_checker} %t %s
//// Output from the first invocation (running a single test method)
// CHECK: Test Case 'ExecutedTestCase.test_foo' started.
// CHECK: Test Case 'ExecutedTestCase.test_foo' passed \(\d+\.\d+ seconds\).
// CHECK: Executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Total executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
//// Output from the second invocation (running one entire test case)
// CHECK: Test Case 'ExecutedTestCase.test_bar' started.
// CHECK: Test Case 'ExecutedTestCase.test_bar' passed \(\d+\.\d+ seconds\).
// CHECK: Test Case 'ExecutedTestCase.test_foo' started.
// CHECK: Test Case 'ExecutedTestCase.test_foo' passed \(\d+\.\d+ seconds\).
// CHECK: Executed 2 tests, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Total executed 2 tests, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

#if os(Linux) || os(FreeBSD)
    import XCTest
#else
    import SwiftXCTest
#endif

class ExecutedTestCase: XCTestCase {
    static var allTests: [(String, ExecutedTestCase -> () throws -> Void)] {
        return [
            ("test_bar", test_bar),
            ("test_foo", test_foo),
        ]
    }

    func test_bar() {}
    func test_foo() {}
}

class SkippedTestCase: XCTestCase {
    static var allTests: [(String, SkippedTestCase -> () throws -> Void)] {
        return [("test_skipped", test_skipped)]
    }

    func test_skipped() {
        XCTFail()
    }
}

XCTMain([
    testCase(ExecutedTestCase.allTests),
    testCase(SkippedTestCase.allTests),
])
