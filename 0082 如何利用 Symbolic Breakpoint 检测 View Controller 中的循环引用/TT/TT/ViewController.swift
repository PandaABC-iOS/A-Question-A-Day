//
//  ViewController.swift
//  TT
//
//  Created by Apple on 2019/7/3.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var testView: UIView!
    @IBOutlet weak var testView2: UIView!
    @IBOutlet weak var testView3: UIView!
    
    var closure = {}
    var closure2 = { (str: String) in }

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.layer.cornerRadius = 100
        imageView.layer.masksToBounds = true
        
        testView.layer.cornerRadius = 100
        testView.layer.masksToBounds = true
        testView.backgroundColor = UIColor.clear
        testView.layer.borderColor = UIColor.black.cgColor
        testView.layer.borderWidth = 2

        testView2.layer.cornerRadius = 120
        testView2.layer.masksToBounds = true
        testView2.backgroundColor = UIColor.clear
        testView2.layer.borderColor = UIColor.black.cgColor
        testView2.layer.borderWidth = 2

        testView3.layer.cornerRadius = 140
        testView3.layer.masksToBounds = true
        testView3.backgroundColor = UIColor.clear
        testView3.layer.borderColor = UIColor.black.cgColor
        testView3.layer.borderWidth = 2

        self.testView.alpha = 1
        self.testView2.alpha = 0
        self.testView3.alpha = 0

        UIView.animateKeyframes(withDuration: 2.5, delay: 0, options: [.repeat], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.8) {
                self.testView.transform = self.testView.transform.scaledBy(x: 1.4, y: 1.4)
                self.testView.alpha = 0
            }

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4) {
                self.testView2.transform = self.testView2.transform.scaledBy(x: 1.2, y: 1.2)
                self.testView2.alpha = 1
            }

            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.5) {
                self.testView2.transform = self.testView2.transform.scaledBy(x: 1.2, y: 1.2)
                self.testView2.alpha = 0
            }

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.7) {
                self.testView3.transform = self.testView3.transform.scaledBy(x: 1.2, y: 1.2)
                self.testView3.alpha = 1
            }

            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.6) {
                self.testView3.transform = self.testView3.transform.scaledBy(x: 1.2, y: 1.2)
                self.testView3.alpha = 0
            }
        }, completion: { _ in
            self.testView.alpha = 1
            self.testView2.alpha = 0
            self.testView3.alpha = 0
        })

        closure = { [weak self] in
            guard let self = self else { return }
            self.closure2 = { [weak self] str in
                guard let self = self else { return }
                print("================\(str) \(self)")
            }
        }
        closure()
        closure2("haha")
    }

}


