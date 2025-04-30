//
//  SKPhotoBrowser.swift
//  SKViewExample
//
//  Created by suzuki_keishi on 2015/10/01.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit
import AVKit
import Vision
import NaturalLanguage
import LinkPresentation

public let SKPHOTO_LOADING_DID_END_NOTIFICATION = "photoLoadingDidEndNotification"

// MARK: - SKPhotoBrowser
open class SKPhotoBrowser: UIViewController, UIContextMenuInteractionDelegate, UIActivityItemSource, UISheetPresentationControllerDelegate {
    // open function
    open var currentPageIndex: Int = 0
    open var initPageIndex: Int = 0
    open var activityItemProvider: UIActivityItemProvider?
    open var photos: [SKPhotoProtocol] = []
    
    internal lazy var pagingScrollView: SKPagingScrollView = SKPagingScrollView(frame: self.view.frame, browser: self)
    
    // appearance
    fileprivate let bgColor: UIColor = SKPhotoBrowserOptions.backgroundColor
    // animation
    let animator: SKAnimator = .init()
    
    // child component
    fileprivate var actionView: SKActionView!
    fileprivate(set) var paginationView: SKPaginationView!
//    var toolbar: SKToolbar!

    // actions
    fileprivate var activityViewController: UIActivityViewController!
    fileprivate var panGesture: UIPanGestureRecognizer?

    // for status check property
//    fileprivate var isEndAnimationByToolBar: Bool = true
    fileprivate var isViewActive: Bool = false
    fileprivate var isPerformingLayout: Bool = false
    
    // pangesture property
    fileprivate var firstX: CGFloat = 0.0
    fileprivate var firstY: CGFloat = 0.0
    
    // timer
    fileprivate var controlVisibilityTimer: Timer!
    
    // delegate
    open weak var delegate: SKPhotoBrowserDelegate?

    // statusbar initial state
    private var statusbarHidden: Bool = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow })?.windowScene?.statusBarManager?.isStatusBarHidden ?? false
    
    // strings
    open var cancelTitle = "Cancel"
    
    fileprivate let crossView = UIButton()
    fileprivate var imageText : String? = ""
    fileprivate var imageText2 : Int? = 0
    fileprivate var imageText3 : Int? = 0
    fileprivate var imageText4 : String? = ""
    
    fileprivate var identity = CGAffineTransform.identity
    
    var detailY: CGFloat = 0
    
    var pageControl: UIPageControl!
    var blurView: UIVisualEffectView!
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    open override var shouldAutorotate: Bool {
        return true
    }
    
    private func setupBlurView() {
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 13
        blurView.clipsToBounds = true
        blurView.alpha = 0
    }
    
    private func setupPageControl() {
        pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.hidesForSinglePage = true
        pageControl.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func updateBlurViewFrame() {
        let numberOfDots = CGFloat(pageControl.numberOfPages)
        let dotWidth: CGFloat = 7
        let spacing: CGFloat = 7
        let blurWidth = numberOfDots * dotWidth + (numberOfDots - 1) * spacing + 16 + 20
        
        if photos.count <= 1 {
            blurView.alpha = 0
        } else {
            if let widthConstraint = blurView.constraints.first(where: { $0.firstAttribute == .width }) {
                widthConstraint.constant = blurWidth
            } else {
                let widthConstraint = blurView.widthAnchor.constraint(equalToConstant: blurWidth)
                widthConstraint.isActive = true
            }
            
            self.blurView.transform = self.identity.scaledBy(x: 0.1, y: 0.1)
            UIView.animate(withDuration: 0.2, animations: {
                self.blurView.transform = self.identity.scaledBy(x: 1, y: 1)
                self.blurView.alpha = 1
            }, completion: { _ in
                
            })
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.crossView.frame = CGRect(x: self.view.bounds.width - 62, y: 30, width: 32, height: 32)
    }

    // MARK: - Initializer
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    public convenience init(photos: [SKPhotoProtocol]) {
        self.init(photos: photos, initialPageIndex: 0)
    }
    
//    @available(*, deprecated)
    public convenience init(originImage: UIImage, photos: [SKPhotoProtocol], animatedFromView: UIView, imageText: String, imageText2: Int, imageText3: Int, imageText4: String) {
        self.init(nibName: nil, bundle: nil)
        self.photos = photos
        self.photos.forEach { $0.checkCache() }
        animator.senderOriginImage = originImage
        animator.senderViewForAnimation = animatedFromView
        animator.senderViewForAnimation2 = animatedFromView
        
        self.imageText = imageText
        self.imageText2 = imageText2
        self.imageText3 = imageText3
        self.imageText4 = imageText4
    }
    
    public convenience init(photos: [SKPhotoProtocol], initialPageIndex: Int) {
        self.init(nibName: nil, bundle: nil)
        self.photos = photos
        self.photos.forEach { $0.checkCache() }
        self.currentPageIndex = min(initialPageIndex, photos.count - 1)
        self.initPageIndex = self.currentPageIndex
        animator.senderOriginImage = photos[currentPageIndex].underlyingImage
        animator.senderViewForAnimation = photos[currentPageIndex] as? UIView
        animator.senderViewForAnimation2 = photos[currentPageIndex] as? UIView
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setup() {
        modalPresentationCapturesStatusBarAppearance = true
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleSKPhotoLoadingDidEndNotification(_:)),
                                               name: NSNotification.Name(rawValue: SKPHOTO_LOADING_DID_END_NOTIFICATION),
                                               object: nil)
    }
    
    open override var keyCommands: [UIKeyCommand]? {
        let dism = UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(dism))
        dism.discoverabilityTitle = "Dismiss"
        if #available(iOS 15, *) {
            dism.wantsPriorityOverSystemBehavior = true
        }
        return [dism]
    }
    
    @objc func rightMove() {
        if currentPageIndex < photos.count - 1 {
            currentPageIndex += 1
            jumpToPageAtIndex(currentPageIndex)
        }
    }
    
    @objc func leftMove() {
        if currentPageIndex == 0 {} else {
            currentPageIndex -= 1
            jumpToPageAtIndex(currentPageIndex)
        }
    }
    
    var isHidden: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.5) { () -> Void in
#if !os(visionOS)
                self.setNeedsStatusBarAppearanceUpdate()
                #endif
            }
        }
    }
    
    override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override open var prefersStatusBarHidden: Bool {
        return self.isHidden
    }
    
    // MARK: - override
    override open func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        configurePagingScrollView()
        configureGestureControl()
        configureActionView()
        configurePaginationView()
        animator.willPresent(self)
        
        let interaction0 = UIContextMenuInteraction(delegate: self)
        self.pagingScrollView.addInteraction(interaction0)
        
        if (UIDevice.current.userInterfaceIdiom == .phone || UIApplication.shared.windowMode().contains("slide")) && ((UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets.bottom ?? 0 > 0) {
            self.isHidden = true
#if !os(visionOS)
            setNeedsStatusBarAppearanceUpdate()
            #endif
        }
        
        setupPageControl()
        setupBlurView()
        view.addSubview(blurView)
        blurView.contentView.addSubview(pageControl)
        pageControl.numberOfPages = photos.count
        pageControl.currentPage = 0
        pageControl.addTarget(self, action: #selector(pageControlValueChanged(_:)), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            blurView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            blurView.heightAnchor.constraint(equalToConstant: 26),
            
            pageControl.centerXAnchor.constraint(equalTo: blurView.centerXAnchor),
            pageControl.centerYAnchor.constraint(equalTo: blurView.centerYAnchor)
        ])
        
        self.pageControl.currentPage = self.currentPageIndex
    }
    
    @objc private func pageControlValueChanged(_ sender: UIPageControl) {
        let page = sender.currentPage
        let offset = CGPoint(x: CGFloat(page) * pagingScrollView.bounds.width, y: 0)
        pagingScrollView.setContentOffset(offset, animated: false)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (UIDevice.current.userInterfaceIdiom == .phone || UIApplication.shared.windowMode().contains("slide")) && ((UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets.bottom ?? 0 > 0) {
            self.isHidden = false
#if !os(visionOS)
            setNeedsStatusBarAppearanceUpdate()
            #endif
        }
    }
    
    public func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        let pg = self.pagingScrollView.pageDisplayedAtIndex(self.currentPageIndex)
        pg?.backgroundColor = .clear
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        return UITargetedPreview(view: pg ?? UIView(), parameters: parameters)
    }
    
    public func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            return createImageMenu(imageInstead: self.photos[self.currentPageIndex].underlyingImage)
        })
    }
    
    func detectedLanguage(for string: String) -> String? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(string)
        guard let languageCode = recognizer.dominantLanguage?.rawValue else { return nil }
        return languageCode
    }
    
    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }

    public func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return nil
    }

    public func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let image = self.photos[self.currentPageIndex].underlyingImage ?? UIImage()
        let imageProvider = NSItemProvider(object: image)
        let metadata = LPLinkMetadata()
        metadata.imageProvider = imageProvider
        return metadata
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        reloadData()
        
        var i = 0
        for photo: SKPhotoProtocol in photos {
            photo.index = i
            i += 1
        }
    }
    
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        isPerformingLayout = true
        // where did start
        delegate?.didShowPhotoAtIndex?(self, index: currentPageIndex)

        // toolbar
//        toolbar.frame = frameForToolbarAtOrientation()
        
        // action
        actionView.updateFrame(frame: view.frame)

        // paging
        switch SKCaptionOptions.captionLocation {
        case .basic:
            paginationView.updateFrame(frame: view.frame)
        case .bottom:
            paginationView.frame = frameForPaginationAtOrientation()
        }
        pagingScrollView.updateFrame(view.bounds, currentPageIndex: currentPageIndex)

        isPerformingLayout = false
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        isViewActive = true
        configureToolbar()
        updateBlurViewFrame()
    }
    
    // MARK: - Notification
    @objc open func handleSKPhotoLoadingDidEndNotification(_ notification: Notification) {
        guard let photo = notification.object as? SKPhotoProtocol else {
            return
        }
        
        DispatchQueue.main.async(execute: { [weak self] in
            guard let page = self?.pagingScrollView.pageDisplayingAtPhoto(photo), let photo = page.photo else {
                return
            }
            
            if photo.underlyingImage != nil {
                page.displayImage(complete: true)
                self?.loadAdjacentPhotosIfNecessary(photo)
            } else {
                page.displayImageFailure()
            }
        })
    }
    
    open func loadAdjacentPhotosIfNecessary(_ photo: SKPhotoProtocol) {
        pagingScrollView.loadAdjacentPhotosIfNecessary(photo, currentPageIndex: currentPageIndex)
    }
    
    // MARK: - initialize / setup
    open func reloadData() {
        performLayout()
        view.setNeedsLayout()
    }
    
    open func performLayout() {
        isPerformingLayout = true

        // reset local cache
        pagingScrollView.reload()
        pagingScrollView.updateContentOffset(currentPageIndex)
        pagingScrollView.tilePages()
        
        delegate?.didShowPhotoAtIndex?(self, index: currentPageIndex)
        
        isPerformingLayout = false
    }
    
    open func prepareForClosePhotoBrowser() {
        cancelControlHiding()
        if let panGesture = panGesture {
            view.removeGestureRecognizer(panGesture)
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    open func dismissPhotoBrowser(animated: Bool, completion: (() -> Void)? = nil) {
        prepareForClosePhotoBrowser()
        dismiss(animated: !animated) {
            completion?()
            self.delegate?.didDismissAtPageIndex?(self.currentPageIndex)

            guard let sender = self.delegate?.viewForPhoto?(self, index: self.currentPageIndex) else {
                return
            }
            sender.alpha = 1
        }
    }
    
    @objc func dism() {
        self.determineAndClose()
    }
    
    open func determineAndClose() {
        delegate?.willDismissAtPageIndex?(self.currentPageIndex)
        animator.willDismiss(self)
    }
    
    open func popupShare(includeCaption: Bool = true) {
        let photo = photos[currentPageIndex]
        guard let underlyingImage = photo.underlyingImage else {
            return
        }
        
        var activityItems: [AnyObject] = [underlyingImage]
        if photo.caption != nil && includeCaption {
            if let shareExtraCaption = SKPhotoBrowserOptions.shareExtraCaption {
                let caption = photo.caption ?? "" + shareExtraCaption
                activityItems.append(caption as AnyObject)
            } else {
                activityItems.append(photo.caption as AnyObject)
            }
        }
        
        if let activityItemProvider = activityItemProvider {
            activityItems.append(activityItemProvider)
        }
        
        activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
            self.hideControlsAfterDelay()
            self.activityViewController = nil
        }
        if UIDevice.current.userInterfaceIdiom == .phone || UIApplication.shared.windowMode().contains("slide") {
            present(activityViewController, animated: true, completion: nil)
        } else {
            activityViewController.modalPresentationStyle = .popover
            present(activityViewController, animated: true, completion: nil)
        }
    }
}

// MARK: - Public Function For Customizing Buttons

public extension SKPhotoBrowser {
    func updateCloseButton(_ image: UIImage, size: CGSize? = nil) {
        actionView.updateCloseButton(image: image, size: size)
    }
    
    func updateDeleteButton(_ image: UIImage, size: CGSize? = nil) {
        actionView.updateDeleteButton(image: image, size: size)
    }
}

// MARK: - Public Function For Browser Control

public extension SKPhotoBrowser {
    func initializePageIndex(_ index: Int) {
        let i = min(index, photos.count - 1)
        currentPageIndex = i
        
        if isViewLoaded {
            jumpToPageAtIndex(index)
            if !isViewActive {
                pagingScrollView.tilePages()
            }
            paginationView.update(currentPageIndex)
        }
        self.initPageIndex = currentPageIndex
    }
    
    func jumpToPageAtIndex(_ index: Int) {
        if index < photos.count {
//            if !isEndAnimationByToolBar {
//                return
//            }
//            isEndAnimationByToolBar = false

            let pageFrame = frameForPageAtIndex(index)
            pagingScrollView.jumpToPageAtIndex(pageFrame)
        }
        hideControlsAfterDelay()
    }
    
    func photoAtIndex(_ index: Int) -> SKPhotoProtocol {
        return photos[index]
    }
    
    @objc func gotoPreviousPage() {
        jumpToPageAtIndex(currentPageIndex - 1)
    }
    
    @objc func gotoNextPage() {
        jumpToPageAtIndex(currentPageIndex + 1)
    }
    
    func cancelControlHiding() {
        if controlVisibilityTimer != nil {
            controlVisibilityTimer.invalidate()
            controlVisibilityTimer = nil
        }
    }
    
    func hideControlsAfterDelay() {
        // reset
        cancelControlHiding()
        // start
        controlVisibilityTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(SKPhotoBrowser.hideControls(_:)), userInfo: nil, repeats: false)
    }
    
    func hideControls() {
        setControlsHidden(true, animated: true, permanent: false)
    }
    
    @objc func hideControls(_ timer: Timer) {
        hideControls()
        delegate?.controlsVisibilityToggled?(self, hidden: true)
    }
    
    func areControlsHidden() -> Bool {
        return paginationView.alpha == 0.0
    }
    
    func getCurrentPageIndex() -> Int {
        return currentPageIndex
    }
    
    func addPhotos(photos: [SKPhotoProtocol]) {
        self.photos.append(contentsOf: photos)
        self.reloadData()
    }
    
    func insertPhotos(photos: [SKPhotoProtocol], at index: Int) {
        self.photos.insert(contentsOf: photos, at: index)
        self.reloadData()
    }
}

// MARK: - Internal Function

internal extension SKPhotoBrowser {
    func showButtons() {
        actionView.animate(hidden: false)
    }
    
    func pageDisplayedAtIndex(_ index: Int) -> SKZoomingScrollView? {
        return pagingScrollView.pageDisplayedAtIndex(index)
    }
    
    func getImageFromView(_ sender: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(sender.frame.size, true, 0.0)
        sender.layer.render(in: UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
}

// MARK: - Internal Function For Frame Calc

internal extension SKPhotoBrowser {
    func frameForToolbarAtOrientation() -> CGRect {
        let offset: CGFloat = {
            if #available(iOS 11.0, *) {
                return view.safeAreaInsets.bottom
            } else {
                return 15
            }
        }()
        return view.bounds.divided(atDistance: 44, from: .maxYEdge).slice.offsetBy(dx: 0, dy: -offset)
    }
    
    func frameForToolbarHideAtOrientation() -> CGRect {
        return view.bounds.divided(atDistance: 44, from: .maxYEdge).slice.offsetBy(dx: 0, dy: 44)
    }
    
    func frameForPaginationAtOrientation() -> CGRect {
#if !os(visionOS)
        let offset = UIDevice.current.orientation.isLandscape ? 35 : 44
        
        return CGRect(x: 0, y: self.view.bounds.size.height - CGFloat(offset), width: self.view.bounds.size.width, height: CGFloat(offset))
        #else
        let offset = 35
        
        return CGRect(x: 0, y: self.view.bounds.size.height - CGFloat(offset), width: self.view.bounds.size.width, height: CGFloat(offset))
        #endif
    }
    
    func frameForPageAtIndex(_ index: Int) -> CGRect {
        let bounds = pagingScrollView.bounds
        var pageFrame = bounds
        pageFrame.size.width -= (2 * 10)
        pageFrame.origin.x = (bounds.size.width * CGFloat(index)) + 10
        return pageFrame
    }
}

// MARK: - Internal Function For Button Pressed, UIGesture Control

internal extension SKPhotoBrowser {
    @objc func panGestureRecognized(_ sender: UIPanGestureRecognizer) {
        guard let zoomingScrollView: SKZoomingScrollView = pagingScrollView.pageDisplayedAtIndex(currentPageIndex) else {
            return
        }
        
        animator.backgroundView.isHidden = true
        let viewHeight: CGFloat = zoomingScrollView.frame.size.height
        let viewHalfHeight: CGFloat = viewHeight/2
        var translatedPoint: CGPoint = sender.translation(in: self.view)
        
        // gesture began
        if sender.state == .began {
            firstX = zoomingScrollView.center.x
            firstY = zoomingScrollView.center.y
            
            hideControls()
#if !os(visionOS)
            setNeedsStatusBarAppearanceUpdate()
            #endif
        }
        
        translatedPoint = CGPoint(x: firstX, y: firstY + translatedPoint.y)
        zoomingScrollView.center = translatedPoint
        
        let offset: CGFloat = 1 - (zoomingScrollView.center.y > viewHalfHeight
            ? zoomingScrollView.center.y - viewHalfHeight
            : -(zoomingScrollView.center.y - viewHalfHeight)) / viewHalfHeight
        
        view.backgroundColor = bgColor.withAlphaComponent(max(0.7, offset))
        
        if offset <= 0.85 {
            UIView.animate(withDuration: 0.2, animations: {
                self.blurView.alpha = 0
                self.crossView.alpha = 0
            }, completion: { _ in
                
            })
        } else {
            if photos.count <= 1 {} else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.blurView.alpha = 1
                    self.crossView.alpha = 1
                }, completion: { _ in
                    
                })
            }
        }
        
        // gesture end
        if sender.state == .ended {
            if (UIDevice.current.userInterfaceIdiom == .phone || UIApplication.shared.windowMode().contains("slide")) && ((UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets.bottom ?? 0 > 0) {
                self.isHidden = false
#if !os(visionOS)
                setNeedsStatusBarAppearanceUpdate()
#endif
            }
            
            determineAndClose()
        }
    }
   
    @objc func actionButtonPressed(ignoreAndShare: Bool) {
        delegate?.willShowActionSheet?(currentPageIndex)
        
        guard photos.count > 0 else {
            return
        }
        
        if let titles = SKPhotoBrowserOptions.actionButtonTitles {
            let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheetController.addAction(UIAlertAction(title: cancelTitle, style: .cancel))
            
            for idx in titles.indices {
                actionSheetController.addAction(UIAlertAction(title: titles[idx], style: .default, handler: { (_) -> Void in
                    self.delegate?.didDismissActionSheetWithButtonIndex?(idx, photoIndex: self.currentPageIndex)
                }))
            }
            
            if UIDevice.current.userInterfaceIdiom == .phone || UIApplication.shared.windowMode().contains("slide") {
                present(actionSheetController, animated: true, completion: nil)
            } else {
                actionSheetController.modalPresentationStyle = .popover
                
                if let popoverController = actionSheetController.popoverPresentationController {
                    popoverController.sourceView = self.view
//                    popoverController.barButtonItem = toolbar.toolActionButton
                }
                
                present(actionSheetController, animated: true, completion: { () -> Void in
                })
            }
            
        } else {
            popupShare()
        }
    }
    
    func deleteImage() {
        defer {
            reloadData()
        }
        
        if photos.count > 1 {
            pagingScrollView.deleteImage()
            
            photos.remove(at: currentPageIndex)
            if currentPageIndex != 0 {
                gotoPreviousPage()
            }
            paginationView.update(currentPageIndex)
            
        } else if photos.count == 1 {
            dismissPhotoBrowser(animated: true)
        }
    }
}

// MARK: - Private Function
private extension SKPhotoBrowser {
    func configureAppearance() {
        view.backgroundColor = bgColor
        view.clipsToBounds = true
        view.isOpaque = false
        
        if #available(iOS 11.0, *) {
            view.accessibilityIgnoresInvertColors = true
        }
    }
    
    func configurePagingScrollView() {
        pagingScrollView.delegate = self
        view.addSubview(pagingScrollView)
    }

    func configureGestureControl() {
        guard !SKPhotoBrowserOptions.disableVerticalSwipe else { return }
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(SKPhotoBrowser.panGestureRecognized(_:)))
        panGesture?.allowedScrollTypesMask = .continuous
//        panGesture?.minimumNumberOfTouches = 1

        if let panGesture = panGesture {
            view.addGestureRecognizer(panGesture)
        }
    }
    
    func configureActionView() {
        actionView = SKActionView(frame: view.frame, browser: self)
        view.addSubview(actionView)
    }

    func configurePaginationView() {
        paginationView = SKPaginationView(frame: view.frame, browser: self)
        view.addSubview(paginationView)
    }
    
    @objc func crossTapped() {
        #if !os(visionOS)
        if GlobalStruct.switchHaptics {
            let haptics = UIImpactFeedbackGenerator(style: .rigid)
            haptics.impactOccurred()
        }
        #endif
        self.determineAndClose()
    }
    
    @objc func hovering1(_ recognizer: UIHoverGestureRecognizer) {
        switch recognizer.state {
        case .began, .changed:
            DispatchQueue.main.async { [weak self] in
                UIView.animate(withDuration: 0.06, delay: 0.0, options: [.curveEaseInOut], animations: { () -> Void in
                    self?.crossView.transform = self?.identity.scaledBy(x: 1.2, y: 1.2) ?? .identity
                }) { (animationCompleted: Bool) -> Void in
                }
            }
            #if targetEnvironment(macCatalyst)
//            NSCursor.pointingHand.set()
            #endif
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.06, delay: 0.0, options: [.curveEaseInOut], animations: { () -> Void in
                self.crossView.transform = self.identity.scaledBy(x: 1, y: 1)
            }) { (animationCompleted: Bool) -> Void in
            }
            #if targetEnvironment(macCatalyst)
//            NSCursor.arrow.set()
            #endif
        default:
            break
        }
    }
    
    func configureToolbar() {
        let symbolConfig0 = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        
        self.crossView.frame = CGRect(x: self.view.bounds.width - 62, y: 30, width: 32, height: 32)
        
        self.crossView.setImage(UIImage(systemName: "xmark", withConfiguration: symbolConfig0)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal), for: .normal)
        self.crossView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.33)
        self.crossView.layer.cornerRadius = 16
        self.crossView.imageEdgeInsets = UIEdgeInsets(top: 9, left: 9, bottom: 9, right: 9)
        
        self.crossView.addTarget(self, action: #selector(self.crossTapped), for: .touchUpInside)
        self.view.addSubview(self.crossView)
        
        let hover1 = UIHoverGestureRecognizer(target: self, action: #selector(hovering1(_:)))
        self.crossView.addGestureRecognizer(hover1)
        self.crossView.addInteraction(UIPointerInteraction(delegate: nil))
        
        self.crossView.transform = self.identity.scaledBy(x: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.12, animations: {
            self.crossView.transform = self.identity.scaledBy(x: 1, y: 1)
        }, completion: { _ in
            
        })
    }

    func setControlsHidden(_ hidden: Bool, animated: Bool, permanent: Bool) {
        // timer update
        cancelControlHiding()
        
        // scroll animation
        pagingScrollView.setControlsHidden(hidden: hidden)

        // paging animation
        paginationView.setControlsHidden(hidden: hidden)
        
        // action view animation
        actionView.animate(hidden: hidden)
        
        if !hidden && !permanent {
            hideControlsAfterDelay()
        }
#if !os(visionOS)
        setNeedsStatusBarAppearanceUpdate()
        #endif
    }
}

// MARK: - UIScrollView Delegate

extension SKPhotoBrowser: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isViewActive else { return }
        guard !isPerformingLayout else { return }
        
        // tile page
        pagingScrollView.tilePages()
        
        // Calculate current page
        let previousCurrentPage = currentPageIndex
        let visibleBounds = pagingScrollView.bounds
        currentPageIndex = min(max(Int(floor(visibleBounds.midX / visibleBounds.width)), 0), photos.count - 1)
        
        if currentPageIndex != previousCurrentPage {
            delegate?.didShowPhotoAtIndex?(self, index: currentPageIndex)
            paginationView.update(currentPageIndex)
        }
        
        for (c,_) in photos.enumerated() {
            if let current = delegate?.viewForPhoto?(self, index: c) {
                current.alpha = 1
            }
        }
        if let current = delegate?.viewForPhoto?(self, index: self.currentPageIndex) {
            current.alpha = 0
        }
        
        let pageIndex = round(scrollView.contentOffset.x / UIScreen.main.bounds.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        hideControlsAfterDelay()
        
        let currentIndex = pagingScrollView.contentOffset.x / pagingScrollView.frame.size.width
        delegate?.didScrollToIndex?(self, index: Int(currentIndex))
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        isEndAnimationByToolBar = true
    }
}
