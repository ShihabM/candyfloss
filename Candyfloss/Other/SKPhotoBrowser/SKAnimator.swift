//
//  SKAnimator.swift
//  SKPhotoBrowser
//
//  Created by keishi suzuki on 2016/08/09.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit

@objc public protocol SKPhotoBrowserAnimatorDelegate {
    func willPresent(_ browser: SKPhotoBrowser)
    func willDismiss(_ browser: SKPhotoBrowser)
}

class SKAnimator: NSObject, SKPhotoBrowserAnimatorDelegate {
    fileprivate let window = UIApplication.shared.preferredApplicationWindow2
    fileprivate var resizableImageView: UIImageView?
    fileprivate var finalImageViewFrame: CGRect = .zero
    
    internal lazy var backgroundView: UIView = {
        guard let window = UIApplication.shared.preferredApplicationWindow2 else { fatalError() }
        
        let backgroundView = UIView(frame: window.frame)
        backgroundView.backgroundColor = SKPhotoBrowserOptions.backgroundColor
        backgroundView.alpha = 0.0
        return backgroundView
    }()
    internal var senderOriginImage: UIImage!
    internal var senderViewOriginalFrame: CGRect = .zero
    internal var senderViewForAnimation: UIView?
    internal var senderViewForAnimation2: UIView?
    
    fileprivate var animationDuration: TimeInterval {
//        if SKPhotoBrowserOptions.bounceAnimation { return 0.52 }
        return 0.50
    }
    fileprivate var animationDamping: CGFloat {
//        if SKPhotoBrowserOptions.bounceAnimation { return 0.9 }
        return 0.75
    }
    
    override init() {
        super.init()
        window?.addSubview(backgroundView)
    }
    
    deinit {
        backgroundView.removeFromSuperview()
    }
    
    func willPresent(_ browser: SKPhotoBrowser) {
        guard let sender = browser.delegate?.viewForPhoto?(browser, index: browser.currentPageIndex) ?? senderViewForAnimation else {
            presentAnimation(browser)
            return
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "hideBar"), object: nil)

        let photo = browser.photoAtIndex(browser.currentPageIndex)
        let imageFromView = (senderOriginImage ?? browser.getImageFromView(sender)).rotateImageByOrientation()
        let imageRatio = imageFromView.size.width / imageFromView.size.height
        
        senderViewOriginalFrame = calcOriginFrame(sender)
        finalImageViewFrame = calcFinalFrame(imageRatio)
        resizableImageView = UIImageView(image: imageFromView)
        
        if let resizableImageView = resizableImageView {
            resizableImageView.frame = senderViewOriginalFrame
            resizableImageView.clipsToBounds = true
            resizableImageView.contentMode = photo.contentMode
            if sender.layer.cornerRadius != 0 {
                let duration = (animationDuration * Double(animationDamping))
                resizableImageView.layer.masksToBounds = true
                resizableImageView.addCornerRadiusAnimation(sender.layer.cornerRadius, to: 0, duration: duration)
            }
            window?.addSubview(resizableImageView)
        }

        presentAnimation(browser)
    }
    
    func willDismiss(_ browser: SKPhotoBrowser) {
        guard let sender = browser.delegate?.viewForPhoto?(browser, index: browser.currentPageIndex) ?? senderViewForAnimation else {
            return
        }
        guard let image = browser.photoAtIndex(browser.currentPageIndex).underlyingImage, let scrollView = browser.pageDisplayedAtIndex(browser.currentPageIndex) else {
            senderViewForAnimation?.isHidden = false
            senderViewForAnimation?.alpha = 1
            browser.dismissPhotoBrowser(animated: false) {
                self.resizableImageView?.removeFromSuperview()
                self.backgroundView.removeFromSuperview()
            }
            return
        }
        
        senderViewForAnimation = sender
        senderViewForAnimation?.isHidden = false
        browser.view.isHidden = true
        backgroundView.isHidden = false
        backgroundView.alpha = 1.0
        backgroundView.backgroundColor = .clear
        senderViewOriginalFrame = calcOriginFrame(sender)
        
        if senderViewForAnimation?.tag ?? 0 != senderViewForAnimation2?.tag ?? 0 {
            senderViewForAnimation2?.alpha = 1
        }
        
        if let resizableImageView = resizableImageView {
            let photo = browser.photoAtIndex(browser.currentPageIndex)
            let contentOffset = scrollView.contentOffset
            let scrollFrame = scrollView.imageView.frame
            let offsetY = scrollView.center.y - (scrollView.bounds.height/2)
            let frame = CGRect(
                x: scrollFrame.origin.x - contentOffset.x,
                y: scrollFrame.origin.y + contentOffset.y + offsetY - scrollView.contentOffset.y,
                width: scrollFrame.width,
                height: scrollFrame.height)

            resizableImageView.image = image.rotateImageByOrientation()
            resizableImageView.frame = frame
            resizableImageView.alpha = 1.0
            resizableImageView.clipsToBounds = true
            resizableImageView.contentMode = photo.contentMode
            if let view = senderViewForAnimation, view.layer.cornerRadius != 0 {
                let duration = (animationDuration * Double(animationDamping))
                resizableImageView.layer.masksToBounds = true
                resizableImageView.addCornerRadiusAnimation(0, to: view.layer.cornerRadius, duration: duration)
            }
        }
        dismissAnimation(browser)
    }
}

private extension SKAnimator {
    func calcOriginFrame(_ sender: UIView) -> CGRect {
        if let senderViewOriginalFrameTemp = sender.superview?.convert(sender.frame, to: nil) {
            return senderViewOriginalFrameTemp
        } else if let senderViewOriginalFrameTemp = sender.layer.superlayer?.convert(sender.frame, to: nil) {
            return senderViewOriginalFrameTemp
        } else {
            return .zero
        }
    }
    
    func calcFinalFrame(_ imageRatio: CGFloat) -> CGRect {
        guard !imageRatio.isNaN else { return .zero }
        
        if SKMesurement.screenRatio < imageRatio {
            let width = SKMesurement.screenWidth
            let height = width / imageRatio
            let yOffset = (SKMesurement.screenHeight - height) / 2
            return CGRect(x: 0, y: yOffset, width: width, height: height)

        } else if SKPhotoBrowserOptions.longPhotoWidthMatchScreen && imageRatio <= 1.0 {
            let height = SKMesurement.screenWidth / imageRatio
            return CGRect(x: 0.0, y: 0, width: SKMesurement.screenWidth, height: height)
            
        } else {
            let height = SKMesurement.screenHeight
            let width = height * imageRatio
            let xOffset = (SKMesurement.screenWidth - width) / 2
            return CGRect(x: xOffset, y: 0, width: width, height: height)
        }
    }
}

private extension SKAnimator {
    func presentAnimation(_ browser: SKPhotoBrowser, completion: (() -> Void)? = nil) {
        self.senderViewForAnimation?.alpha = 0
        
        let finalFrame = self.finalImageViewFrame
        browser.view.isHidden = true
        browser.view.alpha = 0.0
        
        if #available(iOS 11.0, *) {
            backgroundView.accessibilityIgnoresInvertColors = true
            self.resizableImageView?.accessibilityIgnoresInvertColors = true
        }

        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            usingSpringWithDamping: animationDamping,
            initialSpringVelocity: 0,
            options: UIView.AnimationOptions(),
            animations: {
                browser.showButtons()
                self.backgroundView.alpha = 1.0
                self.resizableImageView?.frame = finalFrame
            },
            completion: { (_) -> Void in
                browser.view.alpha = 1.0
                browser.view.isHidden = false
                self.backgroundView.isHidden = true
                self.resizableImageView?.alpha = 0.0
            })
    }
    
    func dismissAnimation(_ browser: SKPhotoBrowser, completion: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.49) {
            if GlobalStruct.fromComposerMedia {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "rotateComposerMedia"), object: nil)
            }
        }
        let finalFrame = self.senderViewOriginalFrame
        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            usingSpringWithDamping: animationDamping,
            initialSpringVelocity: 0,
            options: UIView.AnimationOptions(),
            animations: {
                self.backgroundView.alpha = 0.0
                if GlobalStruct.mediaBrowserRadiusType == 0 {
                    self.resizableImageView?.layer.cornerRadius = 10
                } else if GlobalStruct.mediaBrowserRadiusType == 1 {
                    self.resizableImageView?.layer.cornerRadius = 80
                    self.resizableImageView?.layer.borderWidth = 4
                    self.resizableImageView?.layer.borderColor = GlobalStruct.backgroundTint.cgColor
                } else {
                    self.resizableImageView?.layer.cornerRadius = 10
                    self.resizableImageView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                }
                self.resizableImageView?.layer.frame = finalFrame
            },
            completion: { (_) -> Void in
                browser.dismissPhotoBrowser(animated: true) {
                    GlobalStruct.mediaBrowserRadiusType = 0
                    self.resizableImageView?.removeFromSuperview()
                    self.backgroundView.removeFromSuperview()
                    self.senderViewForAnimation?.alpha = 1
                    if GlobalStruct.fromHeaderTap {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "showAvatarView"), object: nil)
                    }
                    GlobalStruct.fromHeaderTap = false
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "showBar"), object: nil)
                }
            })
    }
}

