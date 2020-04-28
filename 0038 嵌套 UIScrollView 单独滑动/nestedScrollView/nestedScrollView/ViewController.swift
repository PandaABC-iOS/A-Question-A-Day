//
//  ViewController.swift
//  nestedScrollView
//
//  Created by songzhou on 2020/4/24.
//  Copyright © 2020 songzhou. All rights reserved.
//

import UIKit

class CustomScrollView: UIScrollView, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

class CustomTableView: UITableView, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

class ViewController: UIViewController {

    override func loadView() {
        view = UIView()
        view.addSubview(scrollView)
        scrollView.addSubview(childScrollView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.backgroundColor = .lightGray

        childScrollView.contentInset.top = 200
        
        scrollView.delegate = self
        childScrollView.delegate = self
        childScrollView.dataSource = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        childScrollView.frame = CGRect(x: 44, y: 200, width: view.bounds.width-88, height: childScrollView.contentSize.height)
        
        scrollView.contentSize = CGSize(width: view.bounds.width, height: 200+childScrollView.contentSize.height)
    }

    lazy var scrollView = CustomScrollView()
    lazy var childScrollView = CustomTableView()
}

extension ViewController: UIScrollViewDelegate, UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSetY = self.scrollView.contentOffset.y+self.childScrollView.contentOffset.y
        let insetTop = self.childScrollView.contentInset.top

        let childEnable: Bool
        if offSetY >= 0 {
            childEnable = false
        }else if offSetY < 0 && offSetY > -insetTop {
            childEnable = true
        } else {
            childEnable = false
        }

        if scrollView == self.childScrollView {
            if childEnable == false && offSetY > 0 {
                self.childScrollView.contentOffset.y = 0
            }
        } else if scrollView == self.scrollView {
            if childEnable {
                 self.scrollView.contentOffset.y = 0
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: " ")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: " ")
        }
        
        cell?.textLabel?.text = "\(indexPath.row + 1)"
        
        return cell!
    }
}
