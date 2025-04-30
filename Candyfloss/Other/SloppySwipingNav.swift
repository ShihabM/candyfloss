//
//  SloppySwipingNav.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 07/03/2025.
//

import Foundation
import UIKit

open class SloppySwipingNav: UINavigationController, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    
    #if !os(visionOS)
    private class SloppySwipingPanGestureRecognizer: UIPanGestureRecognizer {
    }
    
    private class SloppySwipingEdgeGestureRecognizer: UIScreenEdgePanGestureRecognizer {
    }

    private class AnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

        private let bottomViewOffset: CGFloat = -60

        var reverse = false
        var linerAnimation = false {
            didSet {
                duration = linerAnimation ? 0.4 : 0.4
            }
        }
        private var duration: TimeInterval = 0

        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return duration
        }

        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard
                let fromViewController = transitionContext.viewController(forKey: .from),
                let toViewController = transitionContext.viewController(forKey: .to) else {
                    return
            }
            let initialFrameForFromViewController = transitionContext.initialFrame(for: fromViewController)
            let finalFrameForToViewController = transitionContext.finalFrame(for: toViewController)
            let containerView = transitionContext.containerView

            // Before move
            if !reverse {
                toViewController.view.frame = finalFrameForToViewController.offsetBy(dx: fromViewController.view.frame.width, dy: 0)
                addShadow(viewController: toViewController)
                containerView.addSubview(toViewController.view)
            } else {
                addShadow(viewController: fromViewController)
                containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)

                toViewController.view.frame = finalFrameForToViewController.offsetBy(dx: bottomViewOffset, dy: 0)
            }

            // Move
            let animations = {
                if !self.reverse {
                    toViewController.view.frame = finalFrameForToViewController
                    fromViewController.view.frame = finalFrameForToViewController.offsetBy(dx: self.bottomViewOffset, dy: 0)
                } else {
                    fromViewController.view.frame = initialFrameForFromViewController.offsetBy(dx: fromViewController.view.frame.width, dy: 0)
                    toViewController.view.frame = finalFrameForToViewController
                }
            }

            // After move
            let completion = { (finished: Bool) in
                if !self.reverse {
                    self.removeShadow(viewController: toViewController)
                    fromViewController.view.frame = finalFrameForToViewController
                } else {
                    self.removeShadow(viewController: fromViewController)
                    fromViewController.view.frame = initialFrameForFromViewController
                }

                if transitionContext.transitionWasCancelled {
                    toViewController.view.removeFromSuperview()
                } else {
                    fromViewController.view.removeFromSuperview()
                }
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }

            if linerAnimation {
                UIView.animate(
                    withDuration: transitionDuration(using: transitionContext),
                    delay: 0,
                    options: [.curveLinear, .allowUserInteraction],
                    animations: animations,
                    completion: completion
                )
            } else {
                UIView.animate(
                    withDuration: transitionDuration(using: transitionContext),
                    delay: 0,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 0,
                    options: [.curveEaseInOut, .allowUserInteraction],
                    animations: animations,
                    completion: completion
                )
            }
        }

        private func addShadow(viewController: UIViewController) {
            viewController.view.layer.masksToBounds = false
            viewController.view.layer.shadowColor = UIColor.black.cgColor
            viewController.view.layer.shadowRadius = 5
            viewController.view.layer.shadowOpacity = 0.2
        }

        private func removeShadow(viewController: UIViewController) {
            viewController.view.layer.shadowRadius = 0
        }

    }

    private class InteractiveTransition: UIPercentDrivenInteractiveTransition, UIGestureRecognizerDelegate {

        private weak var navigationController: UINavigationController?
        private var shouldCompleteTransition = false
        private(set) var transitionInProgress = false

        func attachToViewController(viewController: UIViewController) {
            navigationController = viewController.navigationController
            let sloppySwipingGestures = viewController.view.gestureRecognizers?.filter { $0 is SloppySwipingPanGestureRecognizer }
            if sloppySwipingGestures == nil || sloppySwipingGestures?.count == 0 {
                let gestureRecognizer = SloppySwipingPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gestureRecognizer:)))
                gestureRecognizer.delegate = self
                viewController.view.removeGestureRecognizer(gestureRecognizer)
                viewController.view.addGestureRecognizer(gestureRecognizer)
            }
        }

        @objc func handlePanGesture(gestureRecognizer: UIPanGestureRecognizer) {
            switch gestureRecognizer.state {
            case .began:
                transitionInProgress = true
                _ = navigationController?.popViewController(animated: true)

            case .changed:
                guard let view = gestureRecognizer.view else {
                    break
                }

                let translation = gestureRecognizer.translation(in: view)
                let percent: CGFloat = min(max(translation.x / view.frame.width, 0), 1)

                let velocity = gestureRecognizer.velocity(in: view)
                if velocity.x > 400 {
                    shouldCompleteTransition = true
                } else if velocity.x < -400 {
                    shouldCompleteTransition = false
                } else {
                    shouldCompleteTransition = percent > 0.5
                }

                update(percent)

            case .cancelled, .ended:
                transitionInProgress = false
                if !shouldCompleteTransition || gestureRecognizer.state == .cancelled {
                    cancel()
                } else {
                    finish()
                }
            default:
                break
            }
        }
        
        @objc func screenEdgeSwiped(gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
            switch gestureRecognizer.state {
            case .began:
                transitionInProgress = true
                _ = navigationController?.popViewController(animated: true)

            case .changed:
                guard let view = gestureRecognizer.view else {
                    break
                }

                let translation = gestureRecognizer.translation(in: view)
                let percent: CGFloat = min(max(translation.x / view.frame.width, 0), 1)

                let velocity = gestureRecognizer.velocity(in: view)
                if velocity.x > 300 {
                    shouldCompleteTransition = true
                } else if velocity.x < -300 {
                    shouldCompleteTransition = false
                } else {
                    shouldCompleteTransition = percent > 0.5
                }

                update(percent)

            case .cancelled, .ended:
                transitionInProgress = false
                if !shouldCompleteTransition || gestureRecognizer.state == .cancelled {
                    cancel()
                } else {
                    finish()
                }
            default:
                break
            }
        }

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard
                let view = gestureRecognizer.view,
                let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
                    return false
            }
            
//            if !GlobalStruct.switchSwipe {
//                return false
//            }

            let translation = gestureRecognizer.translation(in: view)
            if translation.x < 0 {
                return false
            } else {
                return abs(translation.x) >= abs(translation.y)
            }
        }

    }

    private let animatedTransitioning = AnimatedTransitioning()
    private let interactiveTransition = InteractiveTransition()

    open override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
    }

    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController != viewControllers.first {
            interactiveTransition.attachToViewController(viewController: viewController)
        }
    }

    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animatedTransitioning.reverse = operation == .pop
        return animatedTransitioning
    }

    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        animatedTransitioning.linerAnimation = interactiveTransition.transitionInProgress
        return interactiveTransition.transitionInProgress ? interactiveTransition : nil
    }
    #endif

}


