//
//  ViewController.swift
//  infiniteScroll
//
//  Created by songzhou on 2020/5/8.
//  Copyright © 2020 songzhou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func loadView() {
        let view = UIView()
    
        view.addSubview(infiniteView)
        
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        infiniteView.scrollView.contentInsetAdjustmentBehavior = .never
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        infiniteView.frame = view.bounds
    }

    lazy var infiniteView: InfiniteView = {
        return InfiniteView(frame: .zero, initialPosition: .bottom)
    }()
}
