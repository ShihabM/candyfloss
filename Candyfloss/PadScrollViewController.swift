//
//  PadScrollViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 29/05/2025.
//

import Foundation
import UIKit

class PadScrollViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    public static let shared = PadScrollViewController()
    
    var doneOnceLayout: Bool = false
    var scrollView = UIScrollView()
    var viewControllers: [UIViewController] = [] {
        didSet {
            _ = viewControllers.map({ viewController in
                let vcv = viewController.view
                vcv!.layer.cornerRadius = 0
                vcv!.layer.borderWidth = 0
                vcv!.layer.cornerCurve = .continuous
                vcv!.layer.masksToBounds = true
                self.scrollView.addSubview(vcv!)
            })
        }
    }
    
    var overlayView = UIView()
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func updateTintFullBlack() {
        GlobalStruct.backgroundTint = (UserDefaults.standard.value(forKey: "sepiaBG") as? Bool ?? false) ? UIColor(named: "sepiaBG")! : ((UserDefaults.standard.value(forKey: "fullBlackBG") as? Bool ?? false) ? UIColor(named: "fullBlack")! : UIColor(named: "bg")!)
        GlobalStruct.groupBG = (UserDefaults.standard.value(forKey: "sepiaBG") as? Bool ?? false) ? UIColor(named: "groupSepiaBG")! : ((UserDefaults.standard.value(forKey: "fullBlackBG") as? Bool ?? false) ? UIColor(named: "groupBG2")! : UIColor(named: "groupBG")!)
        GlobalStruct.spoilerBG = (UserDefaults.standard.value(forKey: "sepiaBG") as? Bool ?? false) ? UIColor(named: "groupSepiaBG")! : ((UserDefaults.standard.value(forKey: "fullBlackBG") as? Bool ?? false) ? UIColor(named: "spoilerBGFullBlack")! : UIColor(named: "spoilerBG")!)
        GlobalStruct.pollBar = (UserDefaults.standard.value(forKey: "sepiaBG") as? Bool ?? false) ? UIColor(named: "sepiaBG")! : ((UserDefaults.standard.value(forKey: "fullBlackBG") as? Bool ?? false) ? UIColor(named: "spoilerBGFullBlack")! : UIColor(named: "pollBar")!)
        GlobalStruct.textColor = (UserDefaults.standard.value(forKey: "sepiaBG") as? Bool ?? false) ? UIColor(named: "sepiaPrimary")! : UIColor(named: "textColor")!
        GlobalStruct.secondaryTextColor = (UserDefaults.standard.value(forKey: "sepiaBG") as? Bool ?? false) ? UIColor(named: "sepiaSecondary")! : UIColor(named: "secondaryTextColor")!
        overlayView.backgroundColor = GlobalStruct.backgroundTint
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.layoutAll()
        self.scrollView.backgroundColor = GlobalStruct.separator
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTintFullBlack), name: NSNotification.Name(rawValue: "updateTintFullBlack"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.layoutAll), name: NSNotification.Name(rawValue: "layoutAll"), object: nil)
        
        self.scrollView.backgroundColor = GlobalStruct.separator
        self.scrollView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.scrollView.panGestureRecognizer.minimumNumberOfTouches = 1
        self.scrollView.isScrollEnabled = false
        self.scrollView.isUserInteractionEnabled = true
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.delegate = self
        self.view = (self.scrollView)
    }
    
    @objc func layoutAll() {
        if self.doneOnceLayout == false {
            let width: CGFloat = (getTopMostViewController()?.view.bounds.width ?? UIScreen.main.bounds.width)
            let spacer: CGFloat = 1
            self.scrollView.contentSize = CGSize(width: (CGFloat(width * CGFloat(viewControllers.count))) + (CGFloat(spacer * CGFloat(viewControllers.count + 1))), height: CGFloat(self.view.bounds.height))
            for (c, viewController) in viewControllers.enumerated() {
                self.scrollView.touchesShouldCancel(in: viewController.view)
                viewController.view.layer.cornerRadius = 0
                if c == 0 {
                    viewController.view.frame = CGRect(x: 0, y: 0, width: width * 0.58, height: self.view.bounds.height)
                } else {
                    viewController.view.frame = CGRect(x: (width * 0.58) + 0.82, y: 0, width: (width * 0.42) - 0.82, height: self.view.bounds.height)
                }
                viewController.view.layer.borderWidth = 0
            }
        }
    }
}
