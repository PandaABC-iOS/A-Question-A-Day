//
//  SZJSONSerializationTests.swift
//  SZJSONSerializationTests
//
//  Created by songzhou on 2020/6/11.
//  Copyright © 2020 songzhou. All rights reserved.
//

import XCTest
@testable import SZJSONSerialization

class SZJSONSerializationTests: XCTestCase {
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    private func jsonObjectWithString(str: String, options: JSONSerialization.ReadingOptions = []) -> Any? {
        return try? JSONSerialization.jsonObject(with: str.data(using: .utf8)!, options: options)
    }
    
    private func dictEqual(a: [String: Any], b: [String: Any]) -> Bool {
        return (a as NSDictionary).isEqual(to: b)
    }
    
    func testExample() throws {
        let json = """
        {
            "key": "value",
            "array": [
                1,
                {"key": 42},
                [11]
            ],
            "dict": {
                "key2": 0.1
            }
        }
        """
        
        let jsonObject = jsonObjectWithString(str: json) as! [String: Any]
        
        let str =  SZJSONSerialization.string(withJSONObject: jsonObject)!
        
        let result = jsonObjectWithString(str: str) as! [String: Any]
        
        XCTAssert(dictEqual(a: jsonObject, b: result))
    }
    
     
    /**
     测试单个元素
     
     object
     array
     string
     number
     "true"
     "false"
     "null"
     */
    func testSingleElement() throws {
        let obj = jsonObjectWithString(str: "{}")!
        XCTAssert("{}" == SZJSONSerialization.string(withJSONObject: obj)!)
        
        let array = jsonObjectWithString(str: "[]")!
        XCTAssert("[]" == SZJSONSerialization.string(withJSONObject: array)!)
        
        let str = jsonObjectWithString(str: "\"string\"", options: [.fragmentsAllowed])!
        XCTAssert("\"string\"" == SZJSONSerialization.string(withJSONObject: str)!)
        
        let numberObj = jsonObjectWithString(str: "1", options: [.fragmentsAllowed])!
        XCTAssert("1" == SZJSONSerialization.string(withJSONObject: numberObj)!)
        
        let t = true
        XCTAssert("true" == SZJSONSerialization.string(withJSONObject: t))
        let f = false
        XCTAssert("false" == SZJSONSerialization.string(withJSONObject: f))
        
        let nullO = jsonObjectWithString(str: "null", options: [.fragmentsAllowed])!

        XCTAssert("null" == SZJSONSerialization.string(withJSONObject: nullO))
    }
    
    /// 测试嵌套情况
    func testNested() throws {
        let array = """
        [[[[[1]]]]]
        """
        
        let arrayO = jsonObjectWithString(str: array)!
        
        let arrayR = SZJSONSerialization.string(withJSONObject: arrayO)!
        
        XCTAssert(arrayR == array)
        
        let obj = """
        {"k":{"k2":{"k3":"v"}}}
        """
        
        let objO = jsonObjectWithString(str: obj)!
        let objR = SZJSONSerialization.string(withJSONObject: objO)!
        
        XCTAssert(objR == obj)
    }
    
    /// 测试数字类型
    func testNumber() throws {
        let i1 = jsonObjectWithString(str: "1", options: [.fragmentsAllowed])!
      
        XCTAssert(i1 is Int)
        XCTAssert(i1 is NSNumber)
        XCTAssert(i1 is UInt)
        XCTAssert(SZJSONSerialization.string(withJSONObject: i1)! == "1")
        
        let _i1 = jsonObjectWithString(str: "-1", options: [.fragmentsAllowed])!
        XCTAssert(_i1 is Int)
        XCTAssert(_i1 is NSNumber)
        XCTAssertFalse(_i1 is UInt)
        XCTAssert(SZJSONSerialization.string(withJSONObject: _i1)! == "-1")
        
        let i1_ = jsonObjectWithString(str: "0.1", options: [.fragmentsAllowed])!

        XCTAssertFalse(i1_ is Float)
        XCTAssert(i1_ is Double)
        XCTAssert(i1_ is NSNumber)
        XCTAssert(SZJSONSerialization.string(withJSONObject: i1_)! == "0.1")
    }
    
    func testNumbersInSwift() throws {
        let a8: Int8 = 8
        let a16: Int16 = 16
        let a32: Int32 = 32
        let a64: Int64 = 64
        let a: Int = 64
        let a_ = -64
        
        let b: UInt = 2
        
        let c: Float = 0.1
        let c_: Float = -0.1
        let d: Double = 0.1
        let d_: Double = -0.1
        
        let n1 = NSNumber(value: 1)
        let nd = NSNumber(value: 0.1)
        let n_1 = NSNumber(value: -1)
        let nd_ = NSNumber(value: -0.1)
        
        let array: [Any] = [a8,a16,a32,a64,a,a_,b,c,c_,d,d_,n1,nd,n_1,nd_]
        
        for e in array {
            print("[\(type(of: e))]: " + String(describing: e))
            switch e {
            case is Int, is Int8, is Int16, is Int32, is Int64:
                print("Int:\(e)")
            case is UInt, is UInt8, is UInt16, is UInt32, is UInt64:
                print("Uint: \(e)")
            case is Float:
                print("Float: \(e)")
            case is Double:
                print("Double: \(e)")
            case is NSNumber:
                XCTAssertFalse(true)
            default:
                XCTAssertFalse(true)
                break
            }
        }
    }

    /*
     All Unicode characters may be placed within the
     quotation marks, except for the characters that must be escaped:
     quotation mark, reverse solidus, and the control characters (U+0000
     through U+001F).
     
     
     必须转义：
     " 0x22
     \ 0x5c

     JSON 规范没有要求 / 必须转义，但是 JSONSerialization 转义了
     
     Alternatively, there are two-character sequence escape
     representations of some popular characters.  So, for example, a
     string containing only a single reverse solidus character may be
     represented more compactly as "\\".

     对于一些流行的字符，可以加上 "\" 字符表示转义，否则用 unicode 编码 "\uxxxx" 的形式
     */
    func testEscapeWithBackSlash() throws {
        /// \/"a
        let json = """
        \\/"a
        """

        /// "\\\/\"a"
        let escapedJSON = """
        "\\\\\\/\\"a"
        """
        
        let data = try! JSONSerialization.data(withJSONObject: json, options: [.fragmentsAllowed])
        // "\\\/\"a"
        let str = String(data: data, encoding: .utf8)!
        
        XCTAssert(str == escapedJSON)

        /// 不转义 '/'
        // "\\/\"a"
        let escapedJSON2 = """
        "\\\\/\\"a"
        """
        let sz = SZJSONSerialization.string(withJSONObject: json)!
        XCTAssert(sz == escapedJSON2)
        XCTAssert(sz != escapedJSON)

    }

    /**
     打印 JSONSerialization 序列化控制字符

     00: "\u0000"
     01: "\u0001"
     02: "\u0002"
     03: "\u0003"
     04: "\u0004"
     05: "\u0005"
     06: "\u0006"
     07: "\u0007"
     08: "\b"
     09: "\t"
     0a: "\n"
     0b: "\u000b"
     0c: "\f"
     0d: "\r"
     0e: "\u000e"
     0f: "\u000f"
     10: "\u0010"
     11: "\u0011"
     12: "\u0012"
     13: "\u0013"
     14: "\u0014"
     15: "\u0015"
     16: "\u0016"
     17: "\u0017"
     18: "\u0018"
     19: "\u0019"
     1a: "\u001a"
     1b: "\u001b"
     1c: "\u001c"
     1d: "\u001d"
     1e: "\u001e"
     1f: "\u001f"
     */
    func testPrintEscapeControlCharacters() throws {
        /// JSON 规范需要转义的控制字符范围
        let jsonControlRange = 0x00...0x1f
        
        for i in jsonControlRange {
            let c = Character(Unicode.Scalar(i)!)
            let json = String(c)
            XCTAssert(json.count == 1)
            
            let data = try! JSONSerialization.data(withJSONObject: json, options: [.fragmentsAllowed])
            let str = String(data: data, encoding: .utf8)!
           
            print(String(format: "%02x", i) + ": \(str)")
        }
    }
    
    /// 测试转义
    /// '\' 转义
    /// "\u{xxxx}" 转义
    func testStingWithControlCharacter() throws {
        // app\nle
        let json = "app\u{0a}le"
        
        let data = try! JSONSerialization.data(withJSONObject: json, options: [.fragmentsAllowed])
        let nl = String(data: data, encoding: .utf8)!
        // "app\nle"
        XCTAssert(nl == "\"app\\nle\"")
        XCTAssert(nl == SZJSONSerialization.string(withJSONObject: json)!)
        
        // app\u0000le
        let json2 = "app\u{0}le"
        let data2 = try! JSONSerialization.data(withJSONObject: json2, options: [.fragmentsAllowed])
        
        // "app\u0000le"
        let str2 = String(data: data2, encoding: .utf8)!
        
        XCTAssert(str2 == "\"app\\u0000le\"")
        XCTAssert(str2 == SZJSONSerialization.string(withJSONObject: json2)!)
    }
    
    /// 测试中文
    func testChinese() throws {
        let json = "中"
        
        let data = try! JSONSerialization.data(withJSONObject: json, options: [.fragmentsAllowed])

        let str = String(data: data, encoding: .utf8)!
        
        let sz = SZJSONSerialization.string(withJSONObject: json)!
        
        XCTAssert(sz == str)
    }
    
    func testWriteToFile() throws {
        // a\n中\u0000
        let json = "a\u{0a}中\u{0}"
        
        // "a\n中\u0000"
        let data = try! JSONSerialization.data(withJSONObject: json, options: [.fragmentsAllowed])
        
        
        let dir = try! FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let url = dir.appendingPathComponent("test.json")
        
        let sz = SZJSONSerialization.string(withJSONObject: json)!

        XCTAssert(sz == String(data: data, encoding: .utf8))
        
        do {
            /**
             "a\n中\u0000"
             22615C6E E4B8AD5C 75303030 3022
             
             22 61 5C6E E4B8AD 5C7530303030 22
             "    a   \n       中           \u0000               "
             */
            try data.write(to: url)
            
            try sz.write(to: dir.appendingPathComponent("sz.json"), atomically: true, encoding: .utf8)
        }
    }
    
    /// 测试 '/' 支持的所有转义字符
    func testEscapeString() throws {
        /**
         0x22: \"
         0x5c: \\
         0x08: \b
         0x09: \t
         0x0a: \n
         0x0c: \f
         0x0d: \r
         */
        let backSlashEscapedInput = "\u{22}\u{5c}\u{08}\u{09}\u{0a}\u{0c}\u{0d}"
        
        /// "\"\\\b\t\n\f\r"
        /// 225c225c5c5c625c745c6e5c665c7222
        let backSlashResult = String(data: try! JSONSerialization.data(withJSONObject: backSlashEscapedInput, options: [.fragmentsAllowed]), encoding: .utf8)!
 
        let customEscape = escapeString(val: backSlashEscapedInput)
        XCTAssert(backSlashResult == "\""+customEscape+"\"")
    }
    
    private func escapeString(val: String) -> String {
        var result = [UInt8]()

        for unit in val.utf8 {
            switch unit {
            case 0x00...0x07, 0x0b, 0x0e...0x1f: // \u0000...\u0007, \u000b, \u000e...\u001f
                let str = String(format: "\\u00%02x", unit)
                result.append(contentsOf: Array(str.utf8))
            case 0x22:
                result.append(contentsOf: [0x5c, 0x22])
            case 0x5c:
                result.append(contentsOf: [0x5c, 0x5c])
            case 0x08:
                result.append(contentsOf: [0x5c, 0x62])
            case 0x09:
                result.append(contentsOf: [0x5c, 0x74])
            case 0x0a:
                result.append(contentsOf: [0x5c, 0x6e])
            case 0x0c:
                result.append(contentsOf: [0x5c, 0x66])
            case 0x0d:
                result.append(contentsOf: [0x5c, 0x72])
            default:
                result.append(unit)
            }
        }

        return String(bytes: result, encoding: .utf8)!
    }

}
