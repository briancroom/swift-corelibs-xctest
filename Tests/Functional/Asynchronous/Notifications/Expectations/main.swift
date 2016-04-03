// RUN: %{swiftc} %s -o %{built_tests_dir}/Asynchronous-Notifications
// RUN: %{built_tests_dir}/Asynchronous-Notifications > %t || true
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

// CHECK: Test Suite 'NotificationExpectationsTestCase' started at \d+:\d+:\d+\.\d+
class NotificationExpectationsTestCase: XCTestCase {
// CHECK: Test Case 'NotificationExpectationsTestCase.test_observeNotificationWithName_passes' started at \d+:\d+:\d+\.\d+
// CHECK: Test Case 'NotificationExpectationsTestCase.test_observeNotificationWithName_passes' passed \(\d+\.\d+ seconds\).
    func test_observeNotificationWithName_passes() {
        let notificationName = "notificationWithNameTest"
        expectationForNotification(notificationName, object:nil, handler:nil)
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: nil)
        waitForExpectationsWithTimeout(0.0, handler: nil)
    }
    
// CHECK: Test Case 'NotificationExpectationsTestCase.test_observeNotificationWithNameAndObject_passes' started at \d+:\d+:\d+\.\d+
// CHECK: Test Case 'NotificationExpectationsTestCase.test_observeNotificationWithNameAndObject_passes' passed \(\d+\.\d+ seconds\).
    func test_observeNotificationWithNameAndObject_passes() {
        let notificationName = "notificationWithNameAndObjectTest"
        let dummyObject = NSObject()
        expectationForNotification(notificationName, object:dummyObject, handler:nil)
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: dummyObject)
        waitForExpectationsWithTimeout(0.0, handler: nil)
    }
    
// CHECK: Test Case 'NotificationExpectationsTestCase.test_observeNotificationWithNameAndObject_butExpectingNoObject_passes' started at \d+:\d+:\d+\.\d+
// CHECK: Test Case 'NotificationExpectationsTestCase.test_observeNotificationWithNameAndObject_butExpectingNoObject_passes' passed \(\d+\.\d+ seconds\).
    func test_observeNotificationWithNameAndObject_butExpectingNoObject_passes() {
        let notificationName = "notificationWithNameAndObject_expectNoObjectTest"
        expectationForNotification(notificationName, object:nil, handler:nil)
        let dummyObject = NSObject()
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: dummyObject)
        waitForExpectationsWithTimeout(0.0, handler: nil)
    }
    
// CHECK: Test Case 'NotificationExpectationsTestCase.test_observeNotificationWithIncorrectName_fails' started at \d+:\d+:\d+\.\d+
// CHECK: .*/Tests/Functional/Asynchronous/Notifications/Expectations/main.swift:54: error: NotificationExpectationsTestCase.test_observeNotificationWithIncorrectName_fails : Asynchronous wait failed - Exceeded timeout of 0.1 seconds, with unfulfilled expectations: Expect notification 'expectedName' from any object
// CHECK: Test Case 'NotificationExpectationsTestCase.test_observeNotificationWithIncorrectName_fails' failed \(\d+\.\d+ seconds\).
    func test_observeNotificationWithIncorrectName_fails() {
        expectationForNotification("expectedName", object: nil, handler:nil)
        NSNotificationCenter.defaultCenter().postNotificationName("actualName", object: nil)
        waitForExpectationsWithTimeout(0.1, handler: nil)
    }
    
// CHECK: Test Case 'NotificationExpectationsTestCase.test_observeNotificationWithIncorrectObject_fails' started at \d+:\d+:\d+\.\d+
// CHECK: .*/Tests/Functional/Asynchronous/Notifications/Expectations/main.swift:66: error: NotificationExpectationsTestCase.test_observeNotificationWithIncorrectObject_fails : Asynchronous wait failed - Exceeded timeout of 0.1 seconds, with unfulfilled expectations: Expect notification 'notificationWithIncorrectObjectTest' from dummyObject
// CHECK: Test Case 'NotificationExpectationsTestCase.test_observeNotificationWithIncorrectObject_fails' failed \(\d+\.\d+ seconds\).
    func test_observeNotificationWithIncorrectObject_fails() {
        let notificationName = "notificationWithIncorrectObjectTest"
        let dummyObject: NSString = "dummyObject"
        let anotherDummyObject = NSObject()
        expectationForNotification(notificationName, object: dummyObject, handler: nil)
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object:anotherDummyObject)
        waitForExpectationsWithTimeout(0.1, handler: nil)
    }
    
    static var allTests: [(String, NotificationExpectationsTestCase -> () throws -> Void)] {
        return [
                   ("test_observeNotificationWithName_passes", test_observeNotificationWithName_passes),
                   ("test_observeNotificationWithNameAndObject_passes", test_observeNotificationWithNameAndObject_passes),
                   ("test_observeNotificationWithNameAndObject_butExpectingNoObject_passes", test_observeNotificationWithNameAndObject_butExpectingNoObject_passes),
                   ("test_observeNotificationWithIncorrectName_fails", test_observeNotificationWithIncorrectName_fails),
                   ("test_observeNotificationWithIncorrectObject_fails", test_observeNotificationWithIncorrectObject_fails),
        ]
    }
}
// CHECK: Test Suite 'NotificationExpectationsTestCase' failed at \d+:\d+:\d+\.\d+
// CHECK: \t Executed 5 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

XCTMain([testCase(NotificationExpectationsTestCase.allTests)])

// CHECK: Test Suite '.*\.xctest' failed at \d+:\d+:\d+\.\d+
// CHECK: \t Executed 5 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' failed at \d+:\d+:\d+\.\d+
// CHECK: \t Executed 5 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
