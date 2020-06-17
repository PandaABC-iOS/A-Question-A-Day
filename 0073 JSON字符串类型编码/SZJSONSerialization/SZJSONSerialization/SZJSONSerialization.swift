//
//  SZJSONSerialization.swift
//  SZJSONSerialization
//
//  Created by songzhou on 2020/6/11.
//  Copyright © 2020 songzhou. All rights reserved.
//

import Foundation

typealias JSONDictionary = [String: Any]
typealias JSONArray = [Any]

struct SZJSONSerialization {
    static func string(withJSONObject obj: Any) -> String? {
        let serializer = JSONSerializer()
        
        return serializer.string(withJSONObject: obj)
    }
}

private struct JSONSerializer {
    func string(withJSONObject obj: Any) -> String? {
        return ELEMENT(obj)
    }
    
    /**
     '{' ws '}'
     '{' members '}'
     */
    func OBJECT(dict: JSONDictionary) -> String {
        var ret = Token.LCurlyBracket.rawValue
        
        for (index, key) in dict.keys.enumerated() {
            let value = dict[key]
            
            ret += MEMBER(key: key, value: value)
            
            if index != dict.keys.count - 1 {
                ret += Token.COMMA.rawValue
            }
        }
        
        ret += Token.RCurlyBracket.rawValue
        return ret
    }
    
    /**
     object
     array
     string
     number
     "true"
     "false"
     "null"
     */
    func VALUE(_ val: Any?) -> String {
        guard let v = val else { return Token.NULL.rawValue }
        
        let valStr: String
        switch v {
        case let o as JSONDictionary:
            valStr = OBJECT(dict: o)
        case let o as JSONArray:
            valStr = ARRAY(array: o)
        case let o as String:
            valStr = STRING(val: o)
        case let o where isNumber(val: v):
            valStr = NUMBER(number: o)
        case let o as Bool:
            valStr = BOOL(val: o)
        case _ as NSNull:
            valStr = Token.NULL.rawValue
        default:
            valStr = Token.NULL.rawValue
            break
        }
        
        return valStr
    }
    

    /**
     element
     element ',' elements
     */
    func ELEMENTS(_ val: [Any]) -> String {
        var ret = ""
        for (index, v) in val.enumerated() {
            ret += ELEMENT(v)
            
            if index != val.count - 1 {
                ret += Token.COMMA.rawValue
            }
        }
        
        return ret
    }
    
    /// ws value ws
    func ELEMENT(_ val: Any?) -> String {
        return VALUE(val)
    }

    /// ws string ws ':' element
    func MEMBER(key: String, value: Any?) -> String {
        return STRING(val: key) + Token.COLON.rawValue + ELEMENT(value)
    }
    
    /**
     '[' ws ']'
     '[' elements ']'
     */
    func ARRAY(array: JSONArray) -> String {
        var ret = Token.LSquareBracket.rawValue
        
        ret += ELEMENTS(array)
        
        ret += Token.RSquareBracket.rawValue
        return ret
    }
    
    func STRING(val: String) -> String {
        return Token.QUOTE.rawValue + escapeString(val: val) + Token.QUOTE.rawValue
    }
    
    func NUMBER(number: Any) -> String {
        return String(describing: number)
    }

    func BOOL(val: Bool) -> String {
        return (val ? Token.TRUE : Token.FALSE).rawValue
    }
    
    func isNumber(val: Any) -> Bool {
        switch val {
        case is Int, is Int8, is Int16, is Int32, is Int64:
            return true
        case is UInt, is UInt8, is UInt16, is UInt32, is UInt64:
            return true
        case is Float, is Double:
            return true
        default:
            return false
        }
    }
    
    /// 添加转义字符
    ///
    ///  00: "\u0000"
    ///  01: "\u0001"
    ///  02: "\u0002"
    ///  03: "\u0003"
    ///  04: "\u0004"
    ///  05: "\u0005"
    ///  06: "\u0006"
    ///  07: "\u0007"
    ///  08: "\b"
    ///  09: "\t"
    ///  0a: "\n"
    ///  0b: "\u000b"
    ///  0c: "\f"
    ///  0d: "\r"
    ///  0e: "\u000e"
    ///  0f: "\u000f"
    ///  10: "\u0010"
    ///  11: "\u0011"
    ///  12: "\u0012"
    ///  13: "\u0013"
    ///  14: "\u0014"
    ///  15: "\u0015"
    ///  16: "\u0016"
    ///  17: "\u0017"
    ///  18: "\u0018"
    ///  19: "\u0019"
    ///  1a: "\u001a"
    ///  1b: "\u001b"
    ///  1c: "\u001c"
    ///  1d: "\u001d"
    ///  1e: "\u001e"
    ///  1f: "\u001f"
    /// - Parameter val: 需要转义的字符串，UTF-8 编码
    /// - Returns: 转义后的字符串，UTF-8 编码
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

enum Token: String {
    case LCurlyBracket = "{"
    case RCurlyBracket = "}"
    case LSquareBracket = "["
    case RSquareBracket = "]"
    case COMMA = ","
    case QUOTE = "\""
    case COLON = ":"
    case NULL = "null"
    case TRUE = "true"
    case FALSE = "false"
}
