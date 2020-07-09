//
//  CustomView.swift
//  CustomXib
//
//  Created by songzhou on 2020/7/9.
//  Copyright © 2020 songzhou. All rights reserved.
//

import UIKit

@IBDesignable class CustomView: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = .black {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBOutlet weak var switcher: UISwitch!
    
}
