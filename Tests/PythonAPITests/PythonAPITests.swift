import XCTest
@testable import PythonAPI

class PythonAPITests: XCTestCase {
    func testExample() {
      let p = PyObject()
      print(p)
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
