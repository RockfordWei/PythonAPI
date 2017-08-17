import XCTest
@testable import PythonAPI

class PythonAPITests: XCTestCase {

  override func setUp() {
    Py_Initialize()
  }

  override func tearDown() {
    Py_Finalize()
  }

  func testExample() {
    let p = PyObject()
    print(p)
  }

  func testVersion() {
    if let module = PyImport_ImportModule("sys"),
      let sys = PyModule_GetDict(module),
      let verObj = PyMapping_GetItemString(sys, UnsafeMutablePointer<Int8>(mutating: "version")),
      let verstr = PyString_AsString(verObj),
      let _ = strstr(verstr, "2.7") {
      print(String(cString: verstr))
    } else {
      XCTFail("version checking failed")
    }
  }

  func testHello() {
    let program = "def mydouble(num):\n\treturn num * 2;\n"
    let path = "/tmp/helloworld.py"
    let f = fopen(path, "w")
    _ = program.withCString { pstr -> Int in
      return fwrite(pstr, 1, program.characters.count, f)
    }
    fclose(f)
    PySys_SetPath(UnsafeMutablePointer<Int8>(mutating: "/tmp"))
    if let module = PyImport_ImportModule("helloworld"),
      let function = PyObject_GetAttrString(module, "mydouble"),
      let num = PyInt_FromLong(2),
      let args = PyTuple_New(1),
      PyTuple_SetItem(args, 0, num) == 0,
      let res = PyObject_CallObject(function, args) {
      let four = PyInt_AsLong(res)
      XCTAssertEqual(four, 4)
    } else {
      XCTFail("library import failed")
    }
    unlink(path)
  }

  static var allTests = [
    ("testExample", testExample),
    ("testVersion", testVersion),
    ("testHello", testHello)
    ]
}
