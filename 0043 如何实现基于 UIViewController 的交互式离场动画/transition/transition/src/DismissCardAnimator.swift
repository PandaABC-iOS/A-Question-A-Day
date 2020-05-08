//
//  DismissCardAnimator.swift
//  transition
//
//  Created by songzhou on 2020/4/21.
//  Copyright © 2020 songzhou. All rights reserved.
//

import UIKit

class DismissCardAnimator: NSObject {
    init(params: Params, fromCardFrame: CGRect) {
        self.params = params
        self.fromCardFrame = fromCardFrame
        
        super.init()
    }

    var fromCardFrame: CGRect
    
    private let params: Params
    
    struct Params {
        let toCardFrame: CGRect
        let toCell: UITableViewCell
    }
}

extension DismissCardAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let ctx = transitionContext
        let container = ctx.containerView
        
        let fromVC = transitionContext.viewController(forKey: .from) as! ImageDetailViewController
        let fromImageView = fromVC.imageView
        
        let cardHomeView = ctx.view(forKey: .to)!
        
        /// 列表页面的 view
        container.addSubview(cardHomeView)
        cardHomeView.frame = container.bounds
        
        /// 做动画的 container view
        let animatedContainerView = UIView()
        container.addSubview(animatedContainerView)
        animatedContainerView.frame = container.bounds
        
        /// 做动画的 imageView
        let imageView = UIImageView(image: fromImageView.image)
        animatedContainerView.addSubview(imageView)
        imageView.frame = self.fromCardFrame
        
        func animateCardViewBackToPlace() {
            imageView.frame = self.params.toCardFrame
        }
        
        func completeEverything() {
            let success = !ctx.transitionWasCancelled
        
            animatedContainerView.removeFromSuperview()
            if success {
                self.params.toCell.isHidden = false
            } else {
                cardHomeView.removeFromSuperview()
            }
            
            ctx.completeTransition(success)
        }
        
        UIView.animate(withDuration: transitionDuration(using: ctx), delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: {
            animateCardViewBackToPlace()
        }) { (finished) in
            completeEverything()
        }
    }
}
