import XCTest
@testable import MovieQuiz

final class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
        // Given
        let array = [1, 1, 1, 2, 4]
        // When
        let value = array[safe: 2]
        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 1)
    }
    
    func testGetValueOutOfRange() throws {
        // Given
        let array = [1, 1, 1, 2, 4]
        // When
        let value = array[safe: 10]
        // Then
        XCTAssertNil(value)
    }
}
