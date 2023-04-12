import XCTest
@testable import networking

final class networkingTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(networking().text, "Hello, World!")
    }
}
