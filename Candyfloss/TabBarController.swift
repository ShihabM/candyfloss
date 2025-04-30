//
//  TabBarController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 07/03/2025.
//

import Foundation
import UIKit

class TabBarController: AnimateTabController, UITabBarControllerDelegate, UIGestureRecognizerDelegate {
    
    var firstVC = SloppySwipingNav()
    var secondVC = SloppySwipingNav()
    var thirdVC = SloppySwipingNav()
    var fourthVC = SloppySwipingNav()
    var fifthVC = SloppySwipingNav()
    let newPostButton = UIButton()
    var longPressRecognizer = UILongPressGestureRecognizer()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateNewPostPosition()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        view.backgroundColor = GlobalStruct.backgroundTint
        
        tabBar.backgroundImage = UIImage()
        tabBar.backgroundColor = view.backgroundColor
        tabBar.barTintColor = view.backgroundColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTintMain), name: NSNotification.Name(rawValue: "updateTintMain"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTintFullBlack), name: NSNotification.Name(rawValue: "updateTintFullBlack"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showNewPostButton), name: NSNotification.Name(rawValue: "showNewPostButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideNewPostButton), name: NSNotification.Name(rawValue: "hideNewPostButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateNewPostPosition), name: NSNotification.Name(rawValue: "updateNewPostPosition"), object: nil)
        
        let divider = UIView()
        divider.backgroundColor = UIColor.label.withAlphaComponent(0.2)
        divider.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 0.27)
        tabBar.addSubview(divider)
        
        updateTabs()
        
        if GlobalStruct.readerMode {
            hideNewPostButton()
        } else {
            showNewPostButton()
        }
    }
    
    @objc func updateTintMain() {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        if GlobalStruct.startLocation == 0 {
            newPostButton.backgroundColor = UIColor.clear
            newPostButton.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), for: .normal)
        } else {
            newPostButton.backgroundColor = GlobalStruct.baseTint
            newPostButton.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: symbolConfig)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal), for: .normal)
        }
        if UIDevice.current.userInterfaceIdiom == .phone {
            let image1 = UIImage(systemName: "heart.text.square.fill")
            let image2 = UIImage(systemName: "bell.fill")
            let image3 = UIImage(systemName: "magnifyingglass")
            let image4 = UIImage(systemName: "bookmark.fill")
            let image5 = UIImage(systemName: "person.fill")
            self.viewControllers?[0].tabBarItem.selectedImage = imageWithImage(image: image1 ?? UIImage(), scaledToSize: CGSize(width: 28, height: 28)).withRenderingMode(.alwaysOriginal).withTintColor(GlobalStruct.baseTint)
            self.viewControllers?[1].tabBarItem.selectedImage = imageWithImage(image: image2 ?? UIImage(), scaledToSize: CGSize(width: 28, height: 28)).withRenderingMode(.alwaysOriginal).withTintColor(GlobalStruct.baseTint)
                self.viewControllers?[2].tabBarItem.selectedImage = imageWithImage(image: image3 ?? UIImage(), scaledToSize: CGSize(width: 28, height: 28)).withRenderingMode(.alwaysOriginal).withTintColor(GlobalStruct.baseTint)
            self.viewControllers?[3].tabBarItem.selectedImage = imageWithImage(image: image4 ?? UIImage(), scaledToSize: CGSize(width: 28, height: 28)).withRenderingMode(.alwaysOriginal).withTintColor(GlobalStruct.baseTint)
            self.viewControllers?[4].tabBarItem.selectedImage = imageWithImage(image: image5 ?? UIImage(), scaledToSize: CGSize(width: 28, height: 28)).withRenderingMode(.alwaysOriginal).withTintColor(GlobalStruct.baseTint)
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateCounters"), object: nil)
    }
    
    @objc func updateTintFullBlack() {
        GlobalStruct.backgroundTint = (UserDefaults.standard.value(forKey: "fullBlackBG") as? Bool ?? false) ? UIColor(named: "fullBlack")! : UIColor(named: "bg")!
        GlobalStruct.groupBG = (UserDefaults.standard.value(forKey: "sepiaBG") as? Bool ?? false) ? UIColor(named: "groupSepiaBG")! : ((UserDefaults.standard.value(forKey: "fullBlackBG") as? Bool ?? false) ? UIColor(named: "groupBG2")! : UIColor(named: "groupBG")!)
        GlobalStruct.spoilerBG = (UserDefaults.standard.value(forKey: "sepiaBG") as? Bool ?? false) ? UIColor(named: "groupSepiaBG")! : ((UserDefaults.standard.value(forKey: "fullBlackBG") as? Bool ?? false) ? UIColor(named: "spoilerBGFullBlack")! : UIColor(named: "spoilerBG")!)
        GlobalStruct.pollBar = (UserDefaults.standard.value(forKey: "sepiaBG") as? Bool ?? false) ? UIColor(named: "sepiaBG")! : ((UserDefaults.standard.value(forKey: "fullBlackBG") as? Bool ?? false) ? UIColor(named: "spoilerBGFullBlack")! : UIColor(named: "pollBar")!)
        GlobalStruct.textColor = (UserDefaults.standard.value(forKey: "sepiaBG") as? Bool ?? false) ? UIColor(named: "sepiaPrimary")! : UIColor(named: "textColor")!
        GlobalStruct.secondaryTextColor = (UserDefaults.standard.value(forKey: "sepiaBG") as? Bool ?? false) ? UIColor(named: "sepiaSecondary")! : UIColor(named: "secondaryTextColor")!
        view.backgroundColor = GlobalStruct.backgroundTint
        tabBar.backgroundColor = view.backgroundColor
        tabBar.barTintColor = view.backgroundColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupNewPostButton()
    }
    
    func updateTabs() {
        let rootViewController1 = ViewController()
        firstVC = SloppySwipingNav(rootViewController: rootViewController1)
        if UIDevice.current.userInterfaceIdiom == .phone || UIApplication.shared.windowMode().contains("slide") {
            let image = UIImage(systemName: "heart.text.square")
            let image2 = UIImage(systemName: "heart.text.square.fill")
            firstVC.tabBarItem = UITabBarItem(title: "", image: imageWithImage(image: image ?? UIImage(), scaledToSize: CGSize(width: 28, height: 28)).withRenderingMode(.alwaysOriginal).withTintColor(UIColor.label.withAlphaComponent(0.34)), selectedImage: imageWithImage(image: image2 ?? UIImage(), scaledToSize: CGSize(width: 28, height: 28)).withRenderingMode(.alwaysOriginal).withTintColor(GlobalStruct.baseTint))
            firstVC.tabBarItem.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
            firstVC.accessibilityLabel = ""
        }
        firstVC.tabBarItem.tag = 0
        
        let rootViewController2 = ActivityViewController()
        secondVC = SloppySwipingNav(rootViewController: rootViewController2)
        if UIDevice.current.userInterfaceIdiom == .phone || UIApplication.shared.windowMode().contains("slide") {
            let image = UIImage(systemName: "bell")
            let image2 = UIImage(systemName: "bell.fill")
            secondVC.tabBarItem = UITabBarItem(title: "", image: imageWithImage(image: image ?? UIImage(), scaledToSize: CGSize(width: 28, height: 28)).withRenderingMode(.alwaysOriginal).withTintColor(UIColor.label.withAlphaComponent(0.34)), selectedImage: imageWithImage(image: image2 ?? UIImage(), scaledToSize: CGSize(width: 28, height: 28)).withRenderingMode(.alwaysOriginal).withTintColor(GlobalStruct.baseTint))
            secondVC.tabBarItem.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
            secondVC.accessibilityLabel = ""
        }
        secondVC.tabBarItem.tag = 1
        
        let rootViewController3 = ExploreViewController()
        thirdVC = SloppySwipingNav(rootViewController: rootViewController3)
        if UIDevice.current.userInterfaceIdiom == .phone || UIApplication.shared.windowMode().contains("slide") {
            let image = UIImage(systemName: "magnifyingglass")
            let image2 = UIImage(systemName: "magnifyingglass")
            thirdVC.tabBarItem = UITabBarItem(title: "", image: imageWithImage(image: image ?? UIImage(), scaledToSize: CGSize(width: 28, height: 28)).withRenderingMode(.alwaysOriginal).withTintColor(UIColor.label.withAlphaComponent(0.34)), selectedImage: imageWithImage(image: image2 ?? UIImage(), scaledToSize: CGSize(width: 28, height: 28)).withRenderingMode(.alwaysOriginal).withTintColor(GlobalStruct.baseTint))
            thirdVC.tabBarItem.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
            thirdVC.accessibilityLabel = ""
        }
        thirdVC.tabBarItem.tag = 2
        
        let rootViewController4 = BookmarksViewController()
        fourthVC = SloppySwipingNav(rootViewController: rootViewController4)
        if UIDevice.current.userInterfaceIdiom == .phone || UIApplication.shared.windowMode().contains("slide") {
            let image = UIImage(systemName: "bookmark")
            let image2 = UIImage(systemName: "bookmark.fill")
            fourthVC.tabBarItem = UITabBarItem(title: "", image: imageWithImage(image: image ?? UIImage(), scaledToSize: CGSize(width: 28, height: 28)).withRenderingMode(.alwaysOriginal).withTintColor(UIColor.label.withAlphaComponent(0.34)), selectedImage: imageWithImage(image: image2 ?? UIImage(), scaledToSize: CGSize(width: 28, height: 28)).withRenderingMode(.alwaysOriginal).withTintColor(GlobalStruct.baseTint))
            fourthVC.tabBarItem.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
            fourthVC.accessibilityLabel = ""
        }
        fourthVC.tabBarItem.tag = 3
        
        let rootViewController5 = ProfileViewController()
        rootViewController5.fromTab = true
        fifthVC = SloppySwipingNav(rootViewController: rootViewController5)
        if UIDevice.current.userInterfaceIdiom == .phone || UIApplication.shared.windowMode().contains("slide") {
            let image = UIImage(systemName: "person")
            let image2 = UIImage(systemName: "person.fill")
            fifthVC.tabBarItem = UITabBarItem(title: "", image: imageWithImage(image: image ?? UIImage(), scaledToSize: CGSize(width: 28, height: 28)).withRenderingMode(.alwaysOriginal).withTintColor(UIColor.label.withAlphaComponent(0.34)), selectedImage: imageWithImage(image: image2 ?? UIImage(), scaledToSize: CGSize(width: 28, height: 28)).withRenderingMode(.alwaysOriginal).withTintColor(GlobalStruct.baseTint))
            fifthVC.tabBarItem.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
            fifthVC.accessibilityLabel = ""
        }
        fifthVC.tabBarItem.tag = 4
        
        setViewControllers([firstVC, secondVC, thirdVC, fourthVC, fifthVC], animated: false)
        
        self.longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        self.longPressRecognizer.minimumPressDuration = 0.33
        self.tabBar.addGestureRecognizer(self.longPressRecognizer)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            if GlobalStruct.currentTab == 0 {
                defaultHaptics()
                let loc = sender.location(in: view).x
                if loc < view.bounds.width/5 {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "goToFeeds"), object: nil)
                }
            }
        }
    }
    
    @objc func showNewPostButton() {
        if GlobalStruct.readerMode == false {
            UIView.animate(withDuration: 0.05) { [weak self] in
                guard let self else { return }
                self.newPostButton.alpha = 1
            }
        }
    }
    
    @objc func hideNewPostButton() {
        if GlobalStruct.startLocation == 0 {
            UIView.animate(withDuration: 0.05) { [weak self] in
                guard let self else { return }
                self.newPostButton.alpha = 0
            }
        }
    }
    
    @objc func updateNewPostPosition() {
        if GlobalStruct.startLocation == 0 {
            newPostButton.frame = CGRect(x: view.bounds.width - 62, y: (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) - 9, width: 60, height: 60)
        } else if GlobalStruct.startLocation == 1 {
            newPostButton.frame = CGRect(x: 20, y: view.bounds.height - 70 - tabBar.bounds.height, width: 60, height: 60)
        } else if GlobalStruct.startLocation == 2 {
            newPostButton.frame = CGRect(x: view.bounds.width/2 - 30, y: view.bounds.height - 70 - tabBar.bounds.height, width: 60, height: 60)
        } else if GlobalStruct.startLocation == 3 {
            newPostButton.frame = CGRect(x: view.bounds.width - 70, y: view.bounds.height - 70 - tabBar.bounds.height, width: 60, height: 60)
        }
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        if GlobalStruct.startLocation == 0 {
            newPostButton.backgroundColor = UIColor.clear
            newPostButton.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), for: .normal)
        } else {
            newPostButton.backgroundColor = GlobalStruct.baseTint
            newPostButton.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: symbolConfig)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal), for: .normal)
        }
    }
    
    @objc func setupNewPostButton() {
        GlobalStruct.startLocation = UserDefaults.standard.value(forKey: "startLocation") as? Int ?? 0
        updateNewPostPosition()
        newPostButton.layer.cornerRadius = 30
        newPostButton.addTarget(self, action: #selector(newPostTap), for: .touchUpInside)
        newPostButton.layer.shadowColor = UIColor.black.cgColor
        newPostButton.layer.shadowOffset = CGSize(width: 0, height: 15)
        newPostButton.layer.shadowRadius = 14
        newPostButton.layer.shadowOpacity = 0.18
        newPostButton.accessibilityLabel = "New Post"
        view.addSubview(newPostButton)
        
        let panGesture = UIPanGestureRecognizer(target: self, action:(#selector(handleGesture(_:))))
        panGesture.delegate = self
        newPostButton.addGestureRecognizer(panGesture)
    }
    
    @objc func handleGesture(_ sender: UIPanGestureRecognizer) {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        let translation = sender.location(in: view)
        switch sender.state {
        case .began:
            break
        case .changed:
            // move the view with a finger
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.52, initialSpringVelocity: 0.52, options: [.curveEaseInOut]) { [weak self] in
                guard let self else { return }
                self.newPostButton.center = translation
                if translation.y < 130 {
                    // change to clear bg
                    self.newPostButton.backgroundColor = UIColor.clear
                    self.newPostButton.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), for: .normal)
                    GlobalStruct.isPostButtonInNavBar = true
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "setUpNavigationBar"), object: nil)
                } else {
                    // change to tint bg
                    self.newPostButton.backgroundColor = GlobalStruct.baseTint
                    self.newPostButton.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: symbolConfig)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal), for: .normal)
                    GlobalStruct.isPostButtonInNavBar = false
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "setUpNavigationBar"), object: nil)
                }
            }
        case .ended:
            defaultHaptics()
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.52, initialSpringVelocity: 0.52, options: [.curveEaseInOut]) { [weak self] in
                guard let self else { return }
                if (translation.y < self.view.bounds.height/3) {
                    // move to nav bar
                    self.newPostButton.backgroundColor = UIColor.clear
                    self.newPostButton.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), for: .normal)
                    self.newPostButton.frame = CGRect(x: self.view.bounds.width - 62, y: (self.view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) - 9, width: 60, height: 60)
                    GlobalStruct.startLocation = 0
                    UserDefaults.standard.set(GlobalStruct.startLocation, forKey: "startLocation")
                } else {
                    self.newPostButton.backgroundColor = GlobalStruct.baseTint
                    self.newPostButton.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: symbolConfig)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal), for: .normal)
                    if translation.x < self.view.bounds.width/3 {
                        // move to first third
                        self.newPostButton.frame = CGRect(x: 20, y: self.view.bounds.height - 70 - self.tabBar.bounds.height, width: 60, height: 60)
                        GlobalStruct.startLocation = 1
                        UserDefaults.standard.set(GlobalStruct.startLocation, forKey: "startLocation")
                    } else if translation.x > ((self.view.bounds.width/3)*2) {
                        // move to last third
                        self.newPostButton.frame = CGRect(x: self.view.bounds.width - 70, y: self.view.bounds.height - 70 - self.tabBar.bounds.height, width: 60, height: 60)
                        GlobalStruct.startLocation = 3
                        UserDefaults.standard.set(GlobalStruct.startLocation, forKey: "startLocation")
                    } else {
                        // move to middle third
                        self.newPostButton.frame = CGRect(x: self.view.bounds.width/2 - 30, y: self.view.bounds.height - 70 - self.tabBar.bounds.height, width: 60, height: 60)
                        GlobalStruct.startLocation = 2
                        UserDefaults.standard.set(GlobalStruct.startLocation, forKey: "startLocation")
                    }
                }
            }
        default:
            break
        }
    }
    
    @objc func newPostTap() {
        defaultHaptics()
        let vc = ComposerViewController()
        let nvc = SloppySwipingNav(rootViewController: vc)
        nvc.isModalInPresentation = true
        self.present(nvc, animated: true, completion: nil)
    }
    
}

class AnimateTabController: UITabBarController {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if GlobalStruct.switchHaptics {
            let haptics = UIImpactFeedbackGenerator(style: .rigid)
            haptics.impactOccurred()
        }
        
        guard let barItemView = item.value(forKey: "view") as? UIView else { return }
        
        if GlobalStruct.animateTabSelections {
            let timeInterval: TimeInterval = 0.45
            let propertyAnimator = UIViewPropertyAnimator(duration: timeInterval, dampingRatio: 0.85) {
                barItemView.transform = CGAffineTransform.identity.scaledBy(x: 1.14, y: 1.14)
            }
            propertyAnimator.addAnimations({ barItemView.transform = .identity }, delayFactor: CGFloat(timeInterval))
            propertyAnimator.startAnimation()
        }
        
        if item.tag == 0 && GlobalStruct.currentTab == 0 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "scrollUp0"), object: nil)
        }
        if item.tag == 1 && GlobalStruct.currentTab == 1 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "scrollUp1"), object: nil)
        }
        if item.tag == 2 && GlobalStruct.currentTab == 2 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "scrollUp2"), object: nil)
        }
        if item.tag == 3 && GlobalStruct.currentTab == 3 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "scrollUp3"), object: nil)
        }
        if item.tag == 4 && GlobalStruct.currentTab == 4 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "scrollUp4"), object: nil)
        }
    }
}

