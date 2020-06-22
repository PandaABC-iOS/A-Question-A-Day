//
//  ViewController.swift
//  WeakSelf
//
//  Created by Albert on 2020/6/22.
//  Copyright © 2020 PandaABC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var closure1 = {}
    var closure2 = { (str: String) in }

    override func viewDidLoad() {
        super.viewDidLoad()

        closure1 = { [weak self] in
            guard let self = self else { return }

            //这种写法会造成循环引用
            self.closure2 = { str in
                print("================closure2 executed \(str) \(self)")
            }

            //这种写法不会
//            self.closure2 = { [weak self] str in
//                guard let self = self else { return }
//                print("================closure2 executed \(str) \(self)")
//            }
//            print("================closure1 executed \(self)")
        }
        closure1()
        closure2("haha")


    }

    deinit {
        print("================deinit")
    }


}

