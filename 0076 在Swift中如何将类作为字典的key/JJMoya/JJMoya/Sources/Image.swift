//
//  Image.swift
//  JJMoya
//
//  Created by 张津铭 on 2020/6/19.
//  Copyright © 2020 iOS. All rights reserved.
//

import Foundation

#if canImport(UIKit)
    import UIKit.UIImage
    public typealias ImageType = UIImage
#elseif canImport(AppKit)
    import AppKit.NSImage
    public typealias ImageType = NSImage
#endif

/// An alias for the SDK's image type.
public typealias Image = ImageType
