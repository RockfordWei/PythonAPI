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

  func testFunctionCall() {
    let program = "def mydouble(num):\n\treturn num * 2;\n\nstringVar = 'Hello, world'\nlistVar = ['rocky', 505, 2.23, 'wei', 70.2]\n"
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
      if let strObj = PyObject_GetAttrString(module, "stringVar"),
        let pstr = PyString_AsString(strObj) {
        let strvar = String(cString: pstr)
        print(strvar)
      } else {
        XCTFail("string variable failed")
      }
      if let listObj = PyObject_GetAttrString(module, "listVar") {
        let size = PyList_Size(listObj)
        for i in 0 ..< size {
          if let item = PyList_GetItem(listObj, i) {
            let j = item.pointee
            let tpName = String(cString: j.ob_type.pointee.tp_name)
            let v: Any?
            switch tpName {
            case "str":
              v = String(cString: PyString_AsString(item))
              break
            case "int":
              v = PyInt_AsLong(item)
            case "float":
              v = PyFloat_AsDouble(item)
            default:
              v = nil
            }
            print(i, tpName, v)
          }
        }
      } else {
        XCTFail("list variable failed")
      }
    } else {
      XCTFail("library import failed")
    }
    unlink(path)
  }

  static var allTests = [
    ("testExample", testExample),
    ("testVersion", testVersion),
    ("testFunctionCall", testFunctionCall)
    ]
}
