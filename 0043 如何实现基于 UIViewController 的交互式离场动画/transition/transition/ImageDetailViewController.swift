//
//  ImageDetailViewController.swift
//  transition
//
//  Created by songzhou on 2020/4/20.
//  Copyright © 2020 songzhou. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        imageView = UIImageView()
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            imageView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant:0),
            imageView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant:0),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupPopinteractor()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func setImage(image: UIImage) {
         imageView.image = image
         
         ratioConstraint?.isActive = false
         ratioConstraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: image.size.height/image.size.width, constant: 0)
         ratioConstraint?.isActive = true
     }

    @objc func onBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupPopinteractor() {
        let scale: CGFloat
        if let fromFrame = self.fromImageViewFrame {
            scale = fromFrame.width/imageView.bounds.width
        } else {
            scale = 1
        }
        
        popInteractor = DismissCardInteractor(params: DismissCardInteractor.Params(scale: scale,
                                                                                   fromImageView: imageView))
        popInteractor?.addPanGesture(view: self.view)
        popInteractor?.didDragDownToDismiss = { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    let imageView: UIImageView
    var ratioConstraint: NSLayoutConstraint?
    
    var popInteractor: DismissCardInteractor?
    var fromImageViewFrame: CGRect?
}
