//
//  PerfectPythonTests.swift
//  Perfect-Python
//
//  Created by Rockford Wei on 2017-08-18.
//  Copyright © 2017 PerfectlySoft. All rights reserved.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2017 - 2018 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//
import XCTest
@testable import PythonAPI
@testable import PerfectPython

class PerfectPythonTests: XCTestCase {

    override func setUp() {
      Py_Initialize()
    }

    override func tearDown() {
      Python.tearDown()
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

    func testClass() {
      let program = "class Person:\n\tdef __init__(self, name, age):\n\t\tself.name = name\n\t\tself.age = age\n\tdef intro(self):\n\t\treturn 'Name: ' + self.name + ', Age: ' + str(self.age)\n"
      let path = "/tmp/clstest.py"
      let f = fopen(path, "w")
      _ = program.withCString { pstr -> Int in
        return fwrite(pstr, 1, program.characters.count, f)
      }
      fclose(f)
      PySys_SetPath(UnsafeMutablePointer<Int8>(mutating: "/tmp"))
      if let module = PyImport_ImportModule("clstest"),
        let personClass = PyObject_GetAttrString(module, "Person"),
        let args = PyTuple_New(2),
        let name = PyString_FromString("Rocky"),
        let age = PyInt_FromLong(24),
        PyTuple_SetItem(args, 0, name) == 0,
        PyTuple_SetItem(args, 1, age) == 0,
        let personObj = PyInstance_New(personClass, args, nil),
        let introFunc = PyObject_GetAttrString(personObj, "intro"),
        let introRes = PyObject_CallObject(introFunc, nil),
        let intro = PyString_AsString(introRes)
      {
        print(String(cString: intro))
      } else {
        XCTFail("class variable failed")
      }
      unlink(path)
    }

    func testBasic() {
      let program = "def mydouble(num):\n\treturn num * 2;\n\nstringVar = 'Hello, world'\nlistVar = ['rocky', 505, 2.23, 'wei', 70.2]\ndictVar = {'Name': 'Rocky', 'Age': 17, 'Class': 'Top'};\n"
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
          XCTAssertEqual(String(cString: listObj.pointee.ob_type.pointee.tp_name), "list")
          let size = PyList_Size(listObj)
          XCTAssertEqual(size, 5)
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
              if let v = v {
                print(i, tpName, v)
              } else {
                print(i, tpName, "Unknown")
              }
            }
          }
        } else {
          XCTFail("list variable failed")
        }

        if let dicObj = PyObject_GetAttrString(module, "dictVar"),
          let keys = PyDict_Keys(dicObj) {
          XCTAssertEqual(String(cString: dicObj.pointee.ob_type.pointee.tp_name), "dict")
          let size = PyDict_Size(dicObj)
          XCTAssertEqual(size, 3)
          for i in 0 ..< size {
            guard let key = PyList_GetItem(keys, i),
              let item = PyDict_GetItem(dicObj, key) else {
                continue
            }
            let keyName = String(cString: PyString_AsString(key))
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
            if let v = v {
              print(keyName, tpName, v)
            } else {
              print(keyName, tpName, "Unknown")
            }

          }
        } else {
          XCTFail("dictionary variable failed")
        }

      } else {
        XCTFail("library import failed")
      }
      unlink(path)
    }

    static var allTests = [
      ("testExample", testExample),
      ("testVersion", testVersion),
      ("testBasic", testBasic),
      ("testClass", testClass)
      ]}
