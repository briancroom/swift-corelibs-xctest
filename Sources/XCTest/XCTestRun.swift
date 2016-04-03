// This source file is part of the Swift.org open source project
//
// Copyright (c) 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCTestRun.swift
//  A test run collects information about the execution of a test.
//

#if os(Linux) || os(FreeBSD)
    import Foundation
#else
    import SwiftFoundation
#endif

/// A test run collects information about the execution of a test. Failures in
/// explicit test assertions are classified as "expected", while failures from
/// unrelated or uncaught exceptions are classified as "unexpected".
public class XCTestRun {
    /// The test instance provided when the test run was initialized.
    public let test: XCTest

    /// The time at which the test run was started, or nil.
    public private(set) var startDate: NSDate?

    /// The time at which the test run was stopped, or nil.
    public private(set) var stopDate: NSDate?

    /// The number of seconds that elapsed between when the run was started and
    /// when it was stopped.
    public var totalDuration: NSTimeInterval {
        guard stopped else {
            return 0.0
        }
        return stopDate!.timeIntervalSinceDate(startDate!)
    }

    /// In an `XCTestCase` run, the number of seconds that elapsed between when
    /// the run was started and when it was stopped. In an `XCTestSuite` run,
    /// the combined `testDuration` of each test case in the suite.
    public var testDuration: NSTimeInterval {
        return totalDuration
    }

    /// The number of tests in the run.
    public var testCaseCount: UInt {
        return test.testCaseCount
    }

    /// The number of test executions recorded during the run.
    public private(set) var executionCount: UInt = 0

    /// The number of test failures recorded during the run.
    public private(set) var failureCount: UInt = 0

    /// The number of uncaught exceptions recorded during the run.
    public private(set) var unexpectedExceptionCount: UInt = 0

    /// The total number of test failures and uncaught exceptions recorded
    /// during the run.
    public var totalFailureCount: UInt {
        return failureCount + unexpectedExceptionCount
    }

    /// `true` if all tests in the run completed their execution without
    /// recording any failures, otherwise `false`.
    public var hasSucceeded: Bool {
        guard stopped else {
            return false
        }
        return totalFailureCount == 0
    }

    /// Designated initializer for the XCTestRun class.
    /// - Parameter test: An XCTest instance.
    /// - Returns: A test run for the provided test.
    public required init(test: XCTest) {
        self.test = test
    }

    /// Start a test run. Must not be called more than once.
    public func start() {
        guard !started else {
            fatalError("Invalid attempt to start a test run that has " +
                       "already been started: \(self)")
        }
        guard !stopped else {
            fatalError("Invalid attempt to start a test run that has " +
                       "already been stopped: \(self)")
        }

        startDate = NSDate()
    }

    /// Stop a test run. Must not be called unless the run has been started.
    /// Must not be called more than once.
    public func stop() {
        guard started else {
            fatalError("Invalid attempt to stop a test run that has " +
                       "not yet been started: \(self)")
        }
        guard !stopped else {
            fatalError("Invalid attempt to stop a test run that has " +
                       "already been stopped: \(self)")
        }

        executionCount += 1
        stopDate = NSDate()
    }

    /// Records a failure in the execution of the test for this test run. Must
    /// not be called unless the run has been started. Must not be called if the
    /// test run has been stopped.
    /// - Parameter description: The description of the failure being reported.
    /// - Parameter filePath: The file path to the source file where the failure
    ///   being reported was encountered or nil if unknown.
    /// - Parameter lineNumber: The line number in the source file at filePath
    ///   where the failure being reported was encountered.
    /// - Parameter expected: `true` if the failure being reported was the
    ///   result of a failed assertion, `false` if it was the result of an
    ///   uncaught exception.
    public func recordFailureWithDescription(description: String, inFile filePath: String, atLine lineNumber: UInt, expected: Bool) {
        guard started else {
            fatalError("Invalid attempt to record a failure for a test run " +
                       "that has not yet been started: \(self)")
        }
        guard !stopped else {
            fatalError("Invalid attempt to record a failure for a test run " +
                       "that has already been stopped: \(self)")
        }

        if expected {
            failureCount += 1
        } else {
            unexpectedExceptionCount += 1
        }
    }

    private var started: Bool {
        return startDate != nil
    }

    private var stopped: Bool {
        return started && stopDate != nil
    }
}
