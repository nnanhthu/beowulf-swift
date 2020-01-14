import BeowulfIntegrationTests
import BeowulfTests
import XCTest

var tests = [XCTestCaseEntry]()
tests += BeowulfTests.__allTests()
tests += BeowulfIntegrationTests.__allTests()

XCTMain(tests)
