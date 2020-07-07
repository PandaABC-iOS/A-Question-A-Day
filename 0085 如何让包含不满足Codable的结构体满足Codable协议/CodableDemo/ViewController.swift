//
//  ViewController.swift
//  CodableDemo
//
//  Created by ZHANGJINMING on 2020/7/7.
//  Copyright © 2020 ZHANGJINMING. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        do {
            let json1: String =
            """
            [{"name":"Berlin","longitude":13.0,"latitude":52.0},{"name":"Cape Town","longitude":18.0,"latitude":-34.0}]
            """
            
            let jsonData = json1.data(using: .utf8)!
            let decoder = JSONDecoder()
            
            let decoded1 = try decoder.decode([Placemark].self, from: jsonData)
            print("方法一结果：\(decoded1)")
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            let json2: String =
            """
            [{"name":"Berlin","coordinate":{"longitude":13.0,"latitude":52.0}},{"name":"Cape Town","coordinate":{"longitude":18.0,"latitude":-34.0}}]
            """
            
            let jsonData = json2.data(using: .utf8)!
            let decoder = JSONDecoder()

            let decoded2 = try decoder.decode([Placemark2].self, from: jsonData)
            print("方法二结果：\(decoded2)")

            let decoded3 = try decoder.decode([Placemark3].self, from: jsonData)
            print("方法三结果：\(decoded3)")
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
}

// 方法一：提供自己的 Codable 实现
struct Placemark: Codable {
    var name: String = ""
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    private enum CodingKeys: String, CodingKey {
        case name
        case latitude
        case longitude
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.coordinate = CLLocationCoordinate2D(latitude: try container.decode(Double.self, forKey: .latitude), longitude: try container.decode(Double.self, forKey: .longitude))
        self.name = try container.decode(String.self, forKey: .name)
        
    }
}

// 方法二：利用嵌套容器
struct Placemark2: Codable {
    var name: String
    var coordinate: CLLocationCoordinate2D
    
    private enum CodingKeys: String, CodingKey {
        case name
        case coordinate
    }
    
    private enum CoordinateCodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        var coordinateContainer = container.nestedContainer(keyedBy: CoordinateCodingKeys.self, forKey: .coordinate)
        try coordinateContainer.encode(coordinate.latitude, forKey: .latitude)
        try coordinateContainer.encode(coordinate.longitude, forKey: .longitude)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        
        let coordinateContainer = try container.nestedContainer(keyedBy: CoordinateCodingKeys.self, forKey: .coordinate)
        self.coordinate = CLLocationCoordinate2D(latitude: try coordinateContainer.decode(Double.self, forKey: .latitude), longitude: try coordinateContainer.decode(Double.self, forKey: .longitude))

    }
}

// 方法三：使用计算属性绕开问题

struct Coordinate: Codable {
    var latitude: Double
    var longitude: Double
}

struct Placemark3: Codable {
    var name: String
    private var _coordinate: Coordinate
    
    // Codable系统会忽略计算属性
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: _coordinate.latitude, longitude: _coordinate.longitude)
        }
        set {
            _coordinate = Coordinate(latitude: newValue.latitude, longitude: newValue.longitude)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case _coordinate = "coordinate"
    }
}
