//
//  ViewController.swift
//  SafeLayoutGuide
//
//  Created by songzhou on 2020/5/20.
//  Copyright © 2020 songzhou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func loadView() {
        print("loadView")
        self.view = rootView
    }
    
    override func viewDidLoad() {
        print("viewDidLoad")
        super.viewDidLoad()

        view.backgroundColor = .white
        
        /// viewController 的 topLayoutGuide 必须在 self.view 载入后才能访问的到
        rootView.graView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
            topConstraint = rootView.graView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        } else {
            topConstraint = rootView.graView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor)
        }
        
        NSLayoutConstraint.activate([
            topConstraint,
            rootView.graView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            rootView.graView.heightAnchor.constraint(equalToConstant: 50),
            rootView.graView.widthAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    override func viewWillLayoutSubviews() {
        print("viewWillLayoutSubviews")
        super.viewWillLayoutSubviews()
        
        print("topLayoutGuide:\(self.topLayoutGuide.length)")
    }
    
    override func viewDidLayoutSubviews() {
        print("viewDidLayoutSubviews")
        super.viewDidLayoutSubviews()
        
        let layoutFrame: CGRect
        let safeInset: UIEdgeInsets
        if #available(iOS 11.0, *) {
            layoutFrame = self.view.safeAreaLayoutGuide.layoutFrame
            safeInset = self.view.safeAreaInsets
        } else {
            let length = self.topLayoutGuide.length
            layoutFrame = CGRect(x: 0, y: length, width: view.bounds.width, height: view.bounds.height-length)
            safeInset = UIEdgeInsets(top: length, left: 0, bottom: 0, right: 0)
        }
        
        print("bounds:\(self.view.bounds)\nsafe layoutFrame:\(layoutFrame) \ninset:\(safeInset) \nlayoutGuide:\(self.topLayoutGuide.length)")
        
        rootView.redView.frame.origin.y = layoutFrame.origin.y
    }
    
    lazy var rootView: RootView = {
        let o = RootView()
        return o
    }()
}


class RootView: UIView {
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        addSubview(redView)
        
        addSubview(graView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        print("layoutSubviews")
        super.layoutSubviews()
    }
    
    lazy var redView: UIView = {
        let o = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        o.backgroundColor = .red
        return o
    }()
    
    lazy var graView: UIView = {
        let o = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        o.backgroundColor = .lightGray
        return o
    }()
}

