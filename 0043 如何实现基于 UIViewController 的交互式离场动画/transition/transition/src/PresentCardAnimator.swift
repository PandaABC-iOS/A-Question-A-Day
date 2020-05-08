//
//  PresentCardAnimator.swift
//  transition
//
//  Created by songzhou on 2020/4/20.
//  Copyright © 2020 songzhou. All rights reserved.
//

import UIKit

final class PresentCardAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    init(params: Params) {
        self.params = params
        self.springAnimator = PresentCardAnimator.createBaseSpringAnimator(params: params)
        self.presentAnimationDuration = springAnimator.duration
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return presentAnimationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        transitionDriver = PresentCardTransitionDriver(params: params,
                                                       transitionContext: transitionContext,
                                                       baseAnimator: springAnimator)
        interruptibleAnimator(using: transitionContext).startAnimation()
    }

    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        return transitionDriver!.animator
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        transitionDriver = nil
    }
    
    var transitionDriver: PresentCardTransitionDriver?
    
    private static func createBaseSpringAnimator(params: PresentCardAnimator.Params) -> UIViewPropertyAnimator {
        // Damping between 0.7 (far away) and 1.0 (nearer)
        let cardPositionY = params.fromCardFrame.minY
        let distanceToBounce = abs(params.fromCardFrame.minY)
        let extentToBounce = cardPositionY < 0 ? params.fromCardFrame.height : UIScreen.main.bounds.height
        let dampFactorInterval: CGFloat = 0.3
        let damping: CGFloat = 1.0 - dampFactorInterval * (distanceToBounce / extentToBounce)
        
        // Duration between 0.5 (nearer) and 0.9 (nearer)
        let baselineDuration: TimeInterval = 0.5
        let maxDuration: TimeInterval = 0.9
        let duration: TimeInterval = baselineDuration + (maxDuration - baselineDuration) * TimeInterval(max(0, distanceToBounce)/UIScreen.main.bounds.height)
        
        let springTiming = UISpringTimingParameters(dampingRatio: damping, initialVelocity: .init(dx: 0, dy: 0))
        return UIViewPropertyAnimator(duration: duration, timingParameters: springTiming)
    }
    
    private let params: Params
    private let presentAnimationDuration: TimeInterval
    private let springAnimator: UIViewPropertyAnimator
    
    struct Params {
        let fromCardFrame: CGRect
        let toCardFrame: CGRect
        let fromCell: UITableViewCell
    }
}

final class PresentCardTransitionDriver {
    let animator: UIViewPropertyAnimator
    
    init(params: PresentCardAnimator.Params, transitionContext: UIViewControllerContextTransitioning, baseAnimator: UIViewPropertyAnimator) {
        let ctx = transitionContext
        let container = ctx.containerView

        let cardDetailView = ctx.view(forKey: .to)!
        let fromCardFrame = params.fromCardFrame

        /// 创建临时的 container view，为了做动画
        let animatedContainerView = UIView()
        animatedContainerView.backgroundColor = UIColor.white
        container.addSubview(animatedContainerView)
        animatedContainerView.frame = container.bounds
        
        let fromCell = params.fromCell as! ImageCell
        let imageView = UIImageView(image: fromCell.bgImageView.image)
        animatedContainerView.addSubview(imageView)
        imageView.frame = fromCardFrame

        params.fromCell.isHidden = true

        func animateContainerBouncingUp() {
            imageView.frame.origin.y = 0
        }

        func animateCardDetailViewSizing() {
            imageView.frame = params.toCardFrame
        }

        func completeEverything() {
            animatedContainerView.removeFromSuperview()

            container.addSubview(cardDetailView)
            
            let success = !ctx.transitionWasCancelled
            ctx.completeTransition(success)
        }

        baseAnimator.addAnimations {
            animateContainerBouncingUp()

            let cardExpanding = UIViewPropertyAnimator(duration: baseAnimator.duration * 0.6, curve: .linear) {
                animateCardDetailViewSizing()
            }
            
            cardExpanding.startAnimation()
        }

        baseAnimator.addCompletion { (_) in
            completeEverything()
        }

        self.animator = baseAnimator
    }
}
