//
//  ViewController.swift
//  imageDownsample
//
//  Created by songzhou on 2020/6/23.
//  Copyright © 2020 songzhou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        /// 图片原始大小
        /// 750*3248*4/1024/1024:  9.30M
//        let path = Bundle.main.path(forResource: "CourseList_bg@2x", ofType: "png")!
        
        /// 1. 直接从 bundle 读取：
        /// 13.5M -> 23.3M = 9.8
//        let image = UIImage(contentsOfFile: path)
        
        /// 2. 从 asset 里读取，保留一份 decode 结果
        /// 13.5M -> 34.9 M = 21.4
        let imageAsset = UIImage(named: "CourseList_bg")!
        imageView.image = imageAsset
        
        view.addSubview(imageView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /// 3. 降采样
        /// 13.5M -> 14M = 0.5
//        let url = Bundle.main.url(forResource: "CourseList_bg@2x", withExtension: "png")!
//        let downsampledImage = downsample(imageAt: url, to: CGSize(width: view.bounds.width, height: view.bounds.height), scale: 2)
//        imageView.image = downsampledImage
        
        imageView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
    }
    
    private lazy var imageView: UIImageView = {
       let o = UIImageView()
        return o
    }()

    private func downsample(imageAt imageURL: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage {
        /// kCGImageSourceShouldCache: false，先不解码
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions)!
        
        /// 需要的尺寸
        let maxDimentionInPixels = max(pointSize.width, pointSize.height) * scale
        
        let downsampledOptions = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                  kCGImageSourceShouldCacheImmediately: true,
                                  kCGImageSourceCreateThumbnailWithTransform: true,
                                  kCGImageSourceThumbnailMaxPixelSize: maxDimentionInPixels] as CFDictionary
        
        let downsampledImage =  CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampledOptions)!
        
        return UIImage(cgImage: downsampledImage)
    }
}

