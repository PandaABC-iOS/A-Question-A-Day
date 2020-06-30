//
//  BaseModel.swift
//  Coin2Coin
//
//  Created by Albert on 2017/12/21.
//  Copyright © 2017年 Albert. All rights reserved.
//

import Foundation
@_exported import HandyJSON

//用法示例
private let model1 = YHHomePageDataModel.nonNilDeserialize([String: Any]())
private let models = [YHHomePageDataModel].nonNilDeserialize([String: Any](), designatedPath: "data")

//定义结构体类型的Model
struct YHHomePageDataModel: HandyJSON {
    var topBanner = YHBannerModel()
    var banners = [YHBannerModel]()
}

struct YHBannerModel: HandyJSON {
    var id = ""
    var title = ""
    var cover = ""
    var bannerCover = ""
    var url = ""
    var season: Int = 1
    var beginTime: Double = 0
    var endTime: Double?
    var type = YHCameraType.ezviz
}

//定义枚举类型的Model,要指定 Raw 类型， String 、Int 等
enum YHCameraType: String, HandyJSONEnum {
    case ezviz
    case UAV
}

//定义对象类型的Model
class YHCommentModel: BaseModel {
    var id = ""
    var timestamp: Double = 0
    var content = ""
    var thumbupCount: Int = 0
    var thumbuped = false

    ///自定义映射规则，有需要可以实现，大部分情况不用写， Struct 类型的 Model 也可以实现
    override func mapping(mapper: HelpingMapper) {
        //自定义映射值
        mapper <<<
            id <-- "ID"

        //排除某个属性不解析
        mapper >>> thumbupCount

        //自定义转换规则 示例
        mapper <<<
            self.timestamp <-- TransformOf<Double, String>(fromJSON: { (rawString) -> Double? in
                if let str = rawString {
                    return Double(str)
                }
                return nil
            }, toJSON: { timestampNum -> String? in
                if let num = timestampNum {
                    return "\(num)"
                }
                return nil
            })

        //内置有几个转换器
//        mapper <<<
//            date <-- CustomDateFormatTransform(formatString: "yyyy-MM-dd")
//
//        mapper <<<
//            decimal <-- NSDecimalNumberTransform()
//
//        mapper <<<
//            url <-- URLTransform(shouldEncodeURLString: false)
//
//        mapper <<<
//            data <-- DataTransform()
//
//        mapper <<<
//            color <-- HexColorTransform()
    }

    ///映射完成回调，有需要可以实现，大部分情况不用写， Struct 类型的 Model 也可以实现
    override func didFinishMapping() {
        if content.isEmpty {
            content = "Hello"
        }
    }

}

/* 支持的解析类型 https://github.com/alibaba/HandyJSON#cocoapods
Supported Property Type
Int/Bool/Double/Float/String/NSNumber/NSString

RawRepresentable enum

NSArray/NSDictionary

Int8/Int16/Int32/Int64/UInt8/UInt16/UInt23/UInt64

Optional<T>/ImplicitUnwrappedOptional<T> // T is one of the above types

Array<T> // T is one of the above types

Dictionary<String, T> // T is one of the above types

Nested of aboves
*/




//=============== 分割线 以下为 BaseModel 相关代码 ===============





/// 有继承需求的 model 继承该类 ，无继承特性的 model 直接用 struct 定义，然后遵守 HandyJSON 协议就好
class BaseModel: NSObject, HandyJSON {
    required override init() { super.init() }
    func mapping(mapper: HelpingMapper) {}
    func didFinishMapping() {}
}

extension HandyJSON {
    
    /// JSON String --> Model
    public static func nonNilDeserialize(_ jsonStr: String?, designatedPath: String? = nil) -> Self {
        var model = Self()
        if let _model = Self.deserialize(from: jsonStr, designatedPath: designatedPath) {
            model = _model
        }
        return model
    }

    /// JSON --> Model
    public static func nonNilDeserialize(_ dic: [String: Any]?, designatedPath: String? = nil) -> Self {
        var model = Self()
        if let _model = Self.deserialize(from: dic, designatedPath: designatedPath) {
            model = _model
        }
        return model
    }
    
}

extension Array where Element: HandyJSON {

    /// Array --> [Model]
    public static func nonNilDeserialize(_ array: [Any]?) -> [Element] {
        var tmpArray = [Element]()
        if let items = [Element].deserialize(from: array) {
            items.forEach { (item) in
                if let _item = item {
                    tmpArray.append(_item)
                }
            }
        }
        return tmpArray
    }

    /// JSON String --> [Model]
    public static func nonNilDeserialize(_ jsonStr: String?, designatedPath: String? = nil) -> [Element] {
        var tmpArray = [Element]()
        if let items = [Element].deserialize(from: jsonStr, designatedPath: designatedPath) {
            items.forEach({ (item) in
                if let _item = item {
                    tmpArray.append(_item)
                }
            })
        }
        return tmpArray
    }

    /// Dic --> Model
    public static func nonNilDeserialize(_ dic: [String: Any]?, designatedPath: String? = nil) -> [Element] {
        var tmpArray = [Element]()

        let items = JSONDeserializer<Element>.deserializeModelArrayFrom(dic: dic, designatedPath: designatedPath)
        if let _items = items {
            _items.forEach({ (item) in
                if let _item = item {
                    tmpArray.append(_item)
                }
            })
        }
        return tmpArray
    }



}

extension JSONDeserializer where T: HandyJSON {
    public static func deserializeModelArrayFrom(dic: [String: Any]?, designatedPath: String? = nil) -> [T?]? {
        guard let _dic = dic else {
            return nil
        }
        
        if let jsonArray = getInnerObject(inside: _dic, by: designatedPath) as? [Any] {
            return jsonArray.map({ (item) -> T? in
                return self.deserializeFrom(dict: item as? [String: Any])
            })
        }
        return nil
    }
    
    private static func getInnerObject(inside object: Any?, by designatedPath: String?) -> Any? {
        var result: Any? = object
        var abort = false
        if let paths = designatedPath?.components(separatedBy: "."), paths.count > 0 {
            var next = object as? [String: Any]
            paths.forEach({ (seg) in
                if seg.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" || abort {
                    return
                }
                if let _next = next?[seg] {
                    result = _next
                    next = _next as? [String: Any]
                } else {
                    abort = true
                }
            })
        }
        return abort ? nil : result
    }
    
}
