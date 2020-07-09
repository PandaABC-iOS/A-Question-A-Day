//
//  ViewController.swift
//  CustomXib
//
//  Created by songzhou on 2020/7/9.
//  Copyright © 2020 songzhou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let customView = Bundle.main.loadNibNamed("CustomView", owner: nil, options: nil)?.first as! CustomView
        customViewContainer.addSubview(customView)
        
        self.customView = customView
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.customView.frame = customViewContainer.bounds
    }

    var customView: CustomView!
    @IBOutlet weak var customViewContainer: UIView!
    
}

