//
//  main.swift
//  fontSubstitute
//
//  Created by songzhou on 2020/3/16.
//  Copyright © 2020 songzhou. All rights reserved.
//

import Foundation

struct XibTag {
    let elementName: String
    let attributeDict: [String : String]
    let selfClosingTag: Bool
    let lineNumber: Int
}

class XibParser: NSObject, XMLParserDelegate {
    init?(filePath: String, targetElement: String, completion: @escaping (_ parser: XibParser, _ tags: [XibTag]) -> ()) {
        self.filePath = filePath
        guard let parser = XMLParser(contentsOf: URL(fileURLWithPath: filePath)) else {
            return nil
        }

        self.xmlParser = parser
        self.targetElement = targetElement
        self.completion = completion
        tags = []
        
        super.init()
        self.xmlParser.delegate = self
    }
    
    let filePath: String
    let xmlParser: XMLParser
    let targetElement: String
    var tags: [XibTag]
    let completion: ((_ parser: XibParser, _ tags: [XibTag]) -> ())?
    
    func parserDidStartDocument(_ parser: XMLParser) {
        print("start parse \(filePath)")
    }
    
    func parser(_ parser: XMLParser, foundUnparsedEntityDeclarationWithName name: String, publicID: String?, systemID: String?, notationName: String?) {
        print(name)
    }

    func parser(_ parser: XMLParser, foundElementDeclarationWithName elementName: String, model: String) {
        print(elementName)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == self.targetElement {
            let tag = XibTag(elementName: elementName, attributeDict: attributeDict, selfClosingTag: true, lineNumber: parser.lineNumber)
            tags.append(tag)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        print("end parse \(filePath)")
        self.completion?(self, self.tags)
    }
    
    func parse() {
        xmlParser.parse()
    }
}

struct XibSerializer {
    func makeTagString(elementName: String, attributeDict: [String : String], selfClosing: Bool) -> String {
        guard selfClosing == true else {return ""}
        
        let attributes =
        attributeDict.reduce("") { (result, e) -> String in
            let (key, value) = e

            return result + " \(key)=\"\(value)\""
        }
        
        return "<\(elementName)\(attributes)/>"
    }
    
    func output() -> String {
        let contents = try! String(contentsOfFile: filePath)
        let lines = contents.split(separator: "\n")

        var dict = [Int: XibTag]()
        tags.forEach { (tag) in
            dict[tag.lineNumber] = tag
        }

        var newContens = ""
        for (index, line) in lines.enumerated() {
            let linNum = index+1

            if let tag = dict[linNum] {
                let newAttributes = self.attributesModifier(tag)
                if newAttributes.1 == true {
                    let newLine = makeTagString(elementName: tag.elementName, attributeDict: newAttributes.0, selfClosing: tag.selfClosingTag)
                    print("change line:\(tag.lineNumber) \(line) \n -> \(newLine)")
                    newContens.append(contentsOf: newLine + "\n")
                    continue
                }
            }
            
            newContens.append(contentsOf: line + "\n")
        }
        
        return newContens
    }
    
    let filePath: String
    let tags: [XibTag]
    let attributesModifier: (_ tag: XibTag) -> ([String: String], Bool)
}

/// 替换后的字体，目前只有两个字重，name，family 和 xib 中的 tag 中的属性是对应的
let font = [
    "regular": [
        "name": "FZLANTY_JW--GB1-0",
        "family": "FZLanTingYuanS-R-GB",
    ],
    "bold": [
        "name": "FZLANTY_CUJW--GB1-0",
        "family": "FZLanTingYuanS-B-GB",
    ],
]

let pingfangRegular = "PingFangSC-Regular"
let pingfangBold = "PingFangSC-Medium"

let pingfangFonts = [
    "PingFangSC-Ultralight",
    "PingFangSC-Light",
    "PingFangSC-Thin",
    "PingFangSC-Regular",
    "PingFangSC-Medium",
    "PingFangSC-Semibold",
]

let pingfangRegularIdx = pingfangFonts.firstIndex(of: "PingFangSC-Regular")!

func parserWithPath(filePath: String) -> XibParser? {
    let parser = XibParser(filePath: filePath, targetElement: "fontDescription") { parser, tags in
        let serializer = XibSerializer(filePath: parser.filePath, tags: tags) { tag in
            var dict = tag.attributeDict
            
            var needReplace = false
            /// 支持替换的字体
            if let name = dict["name"], let idx = pingfangFonts.firstIndex(of: name) {
                needReplace = true
                let targetFont: [String: String]
                if idx <= pingfangRegularIdx { // 小于等于 regular 字重
                    targetFont = font["regular"]!
                } else  { // 大于等于 bold 自重
                    targetFont = font["bold"]!
                }
                
                targetFont.forEach { key, value in
                    dict[key] = value
                }
            }
            
            return (dict, needReplace)
        }
        
        print("start Serialize \(filePath)")
        let output = serializer.output()
        
        let url = URL(fileURLWithPath: filePath)
        do {
            try output.write(to: url, atomically: false, encoding: .utf8)
        } catch {
            print(error)
        }
        print("end Serialize \(filePath)")
    }
    
    parser?.parse()
    
    return parser
}

func generateWithPath(path: String, recursive: Bool) {
    let fileUrl = URL(fileURLWithPath: path)
    var parsers = [XibParser?]()
    if fileUrl.hasDirectoryPath {
        
        let closure: (String) -> () = { file in
            let fullPath = fileUrl.appendingPathComponent(file)
            
            guard fullPath.hasDirectoryPath == false,
                fullPath.pathExtension == "xib" else { return }
            
            parsers.append(parserWithPath(filePath: fullPath.path))
        }
        
        let files: [String]
        if recursive {
            files = try! FileManager.default.subpathsOfDirectory(atPath: path)
        } else {
            files = try! FileManager.default.contentsOfDirectory(atPath: path)
        }
    
        for file in files {
            closure(file)
        }
    } else {
        parsers.append(parserWithPath(filePath: fileUrl.path))
    }
}

let help = """
使用：fontSubstitute [-Options...] 文件/文件夹路径

Options:
-h      帮助信息

-r      递归搜索
"""

func main() {
    guard CommandLine.arguments.count >= 2 else {
        print(help)
        return
    }
    
    let arg1 = CommandLine.arguments[1]
    if arg1[arg1.startIndex] == "-" {
        let option = arg1[arg1.index(after: arg1.startIndex)]

        switch option {
        case "r":
            guard CommandLine.arguments.count == 3 else {
                print(help)
                return
            }
            
            generateWithPath(path: CommandLine.arguments[2], recursive: true)
        default:
            print(help)
            return
        }
    } else {
         generateWithPath(path: arg1, recursive: false)
    }
}

main()
