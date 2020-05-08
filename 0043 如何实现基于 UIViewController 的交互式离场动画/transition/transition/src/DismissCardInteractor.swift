//
//  DismissCardInteractor.swift
//  transition
//
//  Created by songzhou on 2020/5/7.
//  Copyright © 2020 songzhou. All rights reserved.
//

import UIKit

class DismissCardInteractor: NSObject {
    init(params: Params) {
         self.params = params
         super.init()
     }
    
    func addPanGesture(view: UIView) {
        dismissalPanGesture.addTarget(self, action: #selector(handleDismissalPan(gesture:)))
        
        view.addGestureRecognizer(dismissalPanGesture)
    }
    
    @objc private func handleDismissalPan(gesture: UIPanGestureRecognizer) {
        let startingPoint: CGPoint
        
        if let p = interactiveStartingPoint {
            startingPoint = p
        } else {
            // Initial location
            startingPoint = gesture.location(in: nil)
            interactiveStartingPoint = startingPoint
        }
        
        let currentLocation = gesture.location(in: nil)
        let progress = (currentLocation.y - startingPoint.y) / 100
        let targetCornerRadius: CGFloat = 16

        func createInteractiveDismissalAnimatorIfNeeded() -> UIViewPropertyAnimator {
            if let animator = dismissalAnimator {
                return animator
            } else {
                let animator = UIViewPropertyAnimator(duration: 0, curve: .linear, animations: {
                    self.params.fromImageView.transform = .init(scaleX: self.params.scale, y: self.params.scale)
                    self.params.fromImageView.layer.cornerRadius = targetCornerRadius
                })
                animator.isReversed = false
                animator.pauseAnimation()
                animator.fractionComplete = progress
                return animator
            }
        }
        
        switch gesture.state {
        case .began:
            dismissalAnimator = createInteractiveDismissalAnimatorIfNeeded()
        case .changed:
            dismissalAnimator = createInteractiveDismissalAnimatorIfNeeded()
            
            let actualProgress = progress
            let isDismissalSuccess = actualProgress >= 1.0
            
            dismissalAnimator!.fractionComplete = actualProgress
            
            if isDismissalSuccess {
                dismissalAnimator!.stopAnimation(false)
                dismissalAnimator!.addCompletion { [unowned self] (pos) in
                    switch pos {
                    case .end:
                        self.dragFinalFrame = self.params.fromImageView.superview!.convert(self.params.fromImageView.frame, to: nil)
                        self.didSuccessfullyDragDownToDismiss()
                    default:
                        fatalError("Must finish dismissal at end!")
                    }
                }
                dismissalAnimator!.finishAnimation(at: .end)
            }
            
        case .ended, .cancelled:
            if dismissalAnimator == nil {
                // Gesture's too quick that it doesn't have dismissalAnimator!
                print("Too quick there's no animator!")
                didCancelDismissalTransition()
                return
            }
            // NOTE:
            // If user lift fingers -> ended
            // If gesture.isEnabled -> cancelled
            
            // Ended, Animate back to start
            dismissalAnimator!.pauseAnimation()
            dismissalAnimator!.isReversed = true
            
            // Disable gesture until reverse closing animation finishes.
            gesture.isEnabled = false
            dismissalAnimator!.addCompletion { [unowned self] (pos) in
                self.didCancelDismissalTransition()
                gesture.isEnabled = true
            }
            dismissalAnimator!.startAnimation()
        default:
            fatalError("Impossible gesture state? \(gesture.state.rawValue)")
        }
    }
    
    private func didCancelDismissalTransition() {
        // Clean up
        interactiveStartingPoint = nil
        dismissalAnimator = nil
    }
    
    private func didSuccessfullyDragDownToDismiss() {
        didDragDownToDismiss?(self)
    }
    
    let params: Params
    var didDragDownToDismiss: ((DismissCardInteractor) -> ())?
    /// 拖拽中缩放后的图片 frame
    var dragFinalFrame: CGRect?
    
    private var interactiveStartingPoint: CGPoint?
    private var dismissalAnimator: UIViewPropertyAnimator?
    
    private lazy var dismissalPanGesture: DismissalPanGesture = {
        let pan = DismissalPanGesture()
        pan.maximumNumberOfTouches = 1
        return pan
    }()
    
    final private class DismissalPanGesture: UIPanGestureRecognizer {}
    
    struct Params {
        /// 图片拖拽中的缩放比例
        let scale: CGFloat
        let fromImageView: UIView
    }
}

