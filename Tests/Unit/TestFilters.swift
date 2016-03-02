// This source file is part of the Swift.org open source project
//
// Copyright (c) 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

class TestArgumentParser: XCTestCase {
    static var allTests: [(String, TestArgumentParser -> () throws -> Void)] {
        return [
            ("test_parsesSelectedTestNameFromFirstArgument", test_parsesSelectedTestNameFromFirstArgument),
            ("test_parsesNoSelectedTestNameWhenNoArgumentIsNotPresent", test_parsesNoSelectedTestNameWhenNoArgumentIsNotPresent),
        ]
    }

    func test_parsesSelectedTestNameFromFirstArgument() {
        let args = ["UnitTests", "filter/string"]
        XCTAssertEqual(ArgumentParser(arguments: args).selectedTestName, "filter/string")
    }

    func test_parsesNoSelectedTestNameWhenNoArgumentIsNotPresent() {
        XCTAssertNil(ArgumentParser(arguments: ["Tests"]).selectedTestName)
    }
}

class TestFilters: XCTestCase {
    static var allTests: [(String, TestFilters -> () throws -> Void)] {
        return [
            ("test_selectedTestFilterMatchesClassNameAndTestName", test_selectedTestFilterMatchesClassNameAndTestName),
            ("test_selectedTestFilterMatchesClassName", test_selectedTestFilterMatchesClassName),
            ("test_selectedTestFilterMatchesNothingForInvalidString", test_selectedTestFilterMatchesNothingForInvalidString),
            ("test_selectedTestFilterMatchesEverythingForNoSelectedTest", test_selectedTestFilterMatchesEverythingForNoSelectedTest),
            ("test_filterTestsOnlyIncludesTestsPassingTheFilter", test_filterTestsOnlyIncludesTestsPassingTheFilter),
            ("test_filterTestsExcludesEmptyTestCases", test_filterTestsExcludesEmptyTestCases),
        ]
    }

    func test_selectedTestFilterMatchesClassNameAndTestName() {
        let filter = TestFiltering(selectedTestName: "SwiftXCTestUnitTests.TestFilters/test_name").selectedTestFilter

        XCTAssertTrue(filter(TestFilters.self, "test_name"))
        XCTAssertFalse(filter(TestFilters.self, "test_other"))
        XCTAssertFalse(filter(XCTestCase.self, "test_name"))
    }

    func test_selectedTestFilterMatchesClassName() {
        let filter = TestFiltering(selectedTestName: "SwiftXCTestUnitTests.TestFilters").selectedTestFilter

        XCTAssertTrue(filter(TestFilters.self, "test_name"))
        XCTAssertTrue(filter(TestFilters.self, "test_other"))
        XCTAssertFalse(filter(XCTestCase.self, "test_name"))
    }

    func test_selectedTestFilterMatchesNothingForInvalidString() {
        XCTAssertFalse(TestFiltering(selectedTestName: "bogus").selectedTestFilter(TestFilters.self, "bogus"))
        XCTAssertFalse(TestFiltering(selectedTestName: "abc.123/hello/world").selectedTestFilter(XCTestCase.self, "world"))
    }

    func test_selectedTestFilterMatchesEverythingForNoSelectedTest() {
        XCTAssertTrue(TestFiltering(selectedTestName: nil).selectedTestFilter(TestFilters.self, "testSomeStuff"))
        XCTAssertTrue(TestFiltering(selectedTestName: nil).selectedTestFilter(XCTestCase.self, "testMoreStuff"))
    }


    func test_filterTestsOnlyIncludesTestsPassingTheFilter() {
        let entries: [XCTestCaseEntry] = [(TestFilters.self, [("test_foo", { _ in }), ("test_bar", { _ in })])]
        let filter: TestFilter = { return $0.1 == "test_bar" }
        let filtered = TestFiltering.filterTests(entries, filter: filter)

        XCTAssertEqual(filtered.count, 1)
        let (testClass, tests) = (filtered.first?.0, filtered.first?.1)

        XCTAssertTrue(testClass is TestFilters.Type)
        XCTAssertEqual(tests?.count, 1)
        XCTAssertEqual(tests?.first?.0, "test_bar")
    }

    func test_filterTestsExcludesEmptyTestCases() {
        let entries: [XCTestCaseEntry] = [(TestFilters.self, [("keep", { _ in })]), (XCTestCase.self, [("exclude", { _ in })])]
        let filter: TestFilter = { return $0.1 == "keep" }
        let filtered = TestFiltering.filterTests(entries, filter: filter)

        XCTAssertEqual(filtered.count, 1)
        XCTAssertTrue(filtered.first?.0 is TestFilters.Type)
    }
}
