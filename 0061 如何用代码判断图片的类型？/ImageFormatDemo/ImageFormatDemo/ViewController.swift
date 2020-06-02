//
//  ViewController.swift
//  ImageFormatDemo
//
//  Created by 张津铭 on 2020/6/2.
//  Copyright © 2020 iOS. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func testImage1Format(_ sender: Any) {
        let path = Bundle.main.path(forResource: "IMG_1", ofType: "AA")!
        let url = URL(fileURLWithPath: path)
        
        do {
            let data = try Data(contentsOf: url)
            print("虽然图片后缀被人为改成了AA，但打印出来的图片类型依然是：\(data.imageFormat)")
        } catch let error {
            print("\(error)")
        }
    }
    
    @IBAction func testImage2Format(_ sender: Any) {
        let path = Bundle.main.path(forResource: "IMG_2", ofType: "PNG")!
        let url = URL(fileURLWithPath: path)
        
        do {
            let data = try Data(contentsOf: url)
            print("图片类型是：\(data.imageFormat)")
        } catch let error {
            print("\(error)")
        }
    }
    
    @IBAction func testImage3Format(_ sender: Any) {
        let path = Bundle.main.path(forResource: "IMG_3", ofType: "GIF")!
        let url = URL(fileURLWithPath: path)
        
        do {
            let data = try Data(contentsOf: url)
            print("图片类型是：\(data.imageFormat)")
        } catch let error {
            print("\(error)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}



