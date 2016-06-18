import XCTest
@testable import GapBuffer

class GapBufferTests: XCTestCase {
  
  func testEmptyInitialization() {
    
    let buffer = GapBuffer("", cursorPosition: 0)
    
  }
  
  
  static var allTests : [(String, (GapBufferTests) -> () throws -> Void)] {
    return [
      ("testEmptyInitialization", testEmptyInitialization),
    ]
  }
}
