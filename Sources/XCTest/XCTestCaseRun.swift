// This source file is part of the Swift.org open source project
//
// Copyright (c) 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCTestCaseRun.swift
//  A test run for an `XCTestCase`.
//

/// A test run for an `XCTestCase`.
public class XCTestCaseRun: XCTestRun {
    public override func start() {
        super.start()
        XCTestObservationCenter.shared().testCaseWillStart(testCase)
    }

    public override func stop() {
        super.stop()
        XCTestObservationCenter.shared().testCaseDidFinish(testCase)
    }

    public override func recordFailureWithDescription(description: String, inFile filePath: String, atLine lineNumber: UInt, expected: Bool) {
        super.recordFailureWithDescription(
            description,
            inFile: filePath,
            atLine: lineNumber,
            expected: expected)
        XCTestObservationCenter.shared().testCase(
            testCase,
            didFailWithDescription: description,
            inFile: filePath,
            atLine: lineNumber)
    }

    private var testCase: XCTestCase {
        return test as! XCTestCase
    }
}