import XCTest
@testable import PythonAPI
import Foundation

class PythonAPITests: XCTestCase {

  override func setUp() {
    Py_Initialize()
  }
  func testExample() {
    let p = PyObject()
    print(p)
  }

  func testVersion() {
    var versionString = strdup("version")
    defer { free(versionString) }
    if let module = PyImport_ImportModule("sys"),
      let sys = PyModule_GetDict(module),
      let verObj = PyMapping_GetItemString(sys, versionString),
      let verstr = PyString_AsString(verObj),
      let _ = strstr(verstr, "2.7") {
      print(String(cString: verstr))
    } else {
      XCTFail("library import failed")
    }
  }
  static var allTests = [
    ("testExample", testExample),
    ("testVersion", testVersion)
    ]
}
