# 前言
`UIViewController` 在 push 和 pop 的时候可以通过实现 `UINavigatonController` 的 `delegate` 来做自定义转场动画。

甚至可以做交互式的离场动画，创建一个对象，继承自 `UIPercentDrivenInteractiveTransition`。

但 `UIPercentDrivenInteractiveTransition` 用的是 pop 的时候提供的动画，即 `func animateTransition(using transitionContext: UIViewControllerContextTransitioning)`，
通过 `func update(_ percentComplete: CGFloat)` 来更新手势滑动的进度，如果需要添加额外的动画，那这个就不适合了。我下面 demo 没有用这种方式，而是自己做动画。

# Demo
demo 演示的是一个纯粹基于图片的转场动画，通过下滑页面来做离场。

## pop 动画

先看做 pop 动画的对象：
```swift
class DismissCardAnimator: NSObject {
    init(params: Params, fromCardFrame: CGRect) {
        self.params = params
        self.fromCardFrame = fromCardFrame
        
        super.init()
    }

	/// 图片起始的 frame 大小，因为有可能会通过滑动来做离场，这时候的 frame 是在滑动缩放后的最终 frame 大小
    var fromCardFrame: CGRect
    
    private let params: Params
    
    struct Params {
    	/// 图片最后的 frame 大小
        let toCardFrame: CGRect
        /// 图片所在的 cell，push 动画时会隐藏，pop 动画做完后恢复
        let toCell: UITableViewCell
    }
}
```

首先在 push 页面前，需要设置代理 ` self.navigationController?.delegate = self`，然后提供一个实现了 `UIViewControllerAnimatedTransitioning` 协议的对象。

```swift
  func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        switch operation {
        case .push:
			/// push 不是关注的重点
        case .pop:
            let detailVC = fromVC as? ImageDetailViewController
            
            /// transition 是自定义对象，包含 push 和 pop 的动画，见 `CardTransition`
            let pop = transition?.popAnimator
            
            /// 这里记录一下图片缩放后的大小，如果是滑动来做离场的
            if let frame = detailVC?.popInteractor?.dragFinalFrame {
                pop?.fromCardFrame = frame
            }
            
            return pop
        default:
            return nil
        }
    }

```

实际动画代码：

```swift
extension DismissCardAnimator: UIViewControllerAnimatedTransitioning {
	/// 动画时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    /// 实际做动画的地方
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let ctx = transitionContext
        let container = ctx.containerView
        
        /// fromVC 是做离场时当前 UIViewController
        let fromVC = transitionContext.viewController(forKey: .from) as! ImageDetailViewController
        let fromImageView = fromVC.imageView
        
        /// 需要 pop 到的 UIViewController 的 view
        let cardHomeView = ctx.view(forKey: .to)!
        
		/// 需要自己添加 pop 到的 UIViewController 的 view
        container.addSubview(cardHomeView)
        cardHomeView.frame = container.bounds
        
        /// 新建一个做动画的 container view
        let animatedContainerView = UIView()
        container.addSubview(animatedContainerView)
        animatedContainerView.frame = container.bounds
        
        /// 新建一个做动画的 imageView
        let imageView = UIImageView(image: fromImageView.image)
        animatedContainerView.addSubview(imageView)
        imageView.frame = self.fromCardFrame
        
        func animateCardViewBackToPlace() {
            imageView.frame = self.params.toCardFrame
        }
        
        func completeEverything() {
            let success = !ctx.transitionWasCancelled
        
        	/// 做动画结束后，需要移除额外添加的 view
            animatedContainerView.removeFromSuperview()
            if success {
                self.params.toCell.isHidden = false
            } else {
            	/// 转场失败，移除 pop 到的 UIViewController 的 view
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

```

如果不带手势离场，那么这些代码就够了，也就是点击返回按钮后的效果。

## pop 手势交互

手势交互类 `DismissCardInteractor` 的大致结构：

```swift
class DismissCardInteractor: NSObject {
    init(params: Params) {
         self.params = params
         super.init()
     }
    
    func addPanGesture(view: UIView) {
        dismissalPanGesture.addTarget(self, action: #selector(handleDismissalPan(gesture:)))
        
        view.addGestureRecognizer(dismissalPanGesture)
    }
    
    /// 手势回调，稍后讲解
    @objc private func handleDismissalPan(gesture: UIPanGestureRecognizer) {...}
    
    
    let params: Params
    /// 动画结束后的回调
    var didDragDownToDismiss: ((DismissCardInteractor) -> ())?
    /// 拖拽中缩放后的图片 frame
    var dragFinalFrame: CGRect?
    
    /// 记录手势开始时的位置
    private var interactiveStartingPoint: CGPoint?
    /// 滑动时做的动画
    private var dismissalAnimator: UIViewPropertyAnimator?
    
    /// 实际的手势对象
    private lazy var dismissalPanGesture: DismissalPanGesture = {
        let pan = DismissalPanGesture()
        pan.maximumNumberOfTouches = 1
        return pan
    }()
    
    final private class DismissalPanGesture: UIPanGestureRecognizer {}
    
    /// 参数
    struct Params {
        /// 图片拖拽中的缩放比例
        let scale: CGFloat
        /// pop 到的 UIViewController 的 imageView
        let fromImageView: UIView
    }
}

```

在 pop 后的页面中设置交互离场对象：

``` swift

class ImageDetailViewController: UIViewController {
	...

	 private func setupPopinteractor() {
	 	/// 滑动时图片缩放的最大比例
		let scale: CGFloat
		if let fromFrame = self.fromImageViewFrame {
			scale = fromFrame.width/imageView.bounds.width
		} else {
			scale = 1
		}
	
		popInteractor = DismissCardInteractor(params: DismissCardInteractor.Params(scale: scale,
																				   fromImageView: imageView))
		popInteractor?.addPanGesture(view: self.view)
		/// 交互动画结束后，通过调用 `self?.navigationController?.popViewController(animated: true)` 进行常规的 pop 动画
		popInteractor?.didDragDownToDismiss = { [weak self] _ in
			self?.navigationController?.popViewController(animated: true)
		}
	}
}
```

处理手势：

```swift
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
	/// 滑动百分比
	let progress = (currentLocation.y - startingPoint.y) / 100
	/// 图片的圆角
	let targetCornerRadius: CGFloat = 16

	func createInteractiveDismissalAnimatorIfNeeded() -> UIViewPropertyAnimator {
		if let animator = dismissalAnimator {
			return animator
		} else {
			let animator = UIViewPropertyAnimator(duration: 0, curve: .linear, animations: {
				self.params.fromImageView.transform = .init(scaleX: self.params.scale, y: self.params.scale)
				self.params.fromImageView.layer.cornerRadius = targetCornerRadius
			})
			
			/// UIViewPropertyAnimator 动画是可以反过来做，这也是交互式动画的关键
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
		
		/// 滑动距离超过了规定的距离
		if isDismissalSuccess {
			/// 暂停动画
			dismissalAnimator!.stopAnimation(false)
			dismissalAnimator!.addCompletion { [unowned self] (pos) in
				switch pos {
				case .end:
					/// 记录图片缩放后的 frame
					self.dragFinalFrame = self.params.fromImageView.superview!.convert(self.params.fromImageView.frame, to: nil)
					/// 调用动画结束回调
					self.didSuccessfullyDragDownToDismiss()
				default:
					fatalError("Must finish dismissal at end!")
				}
			}
			/// 手动结束动画
			dismissalAnimator!.finishAnimation(at: .end)
		}
		
	case .ended, .cancelled:
		if dismissalAnimator == nil {
			// Gesture's too quick that it doesn't have dismissalAnimator!
			print("Too quick there's no animator!")
			didCancelDismissalTransition()
			return
		}

		/// 如果滑动结束，且滑动距离未超过规定范围，则恢复图片到滑动前的位置
		/// 这里通过 `isReversed = true` 来做反向动画
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
```
