//
//  DetailImageCell.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 10/03/2025.
//

import UIKit
import Photos
import SDWebImage
import Vision
import AVFoundation
import AVKit
import Photos
import ATProtoKit

class DetailImagesCell: UITableViewCell, UISheetPresentationControllerDelegate, AVPlayerViewControllerDelegate {
    
    var currentPost: AppBskyLexicon.Feed.PostViewDefinition? = nil
    var bgView = UIView()
    var collectionView: UICollectionView!
    var pageControl: UIPageControl!
    var blurView: UIVisualEffectView!
    let blurEffect = UIBlurEffect(style: .systemThinMaterial)
    var hasVideo: Bool = false
    let playerView = PlayerView()
    var cellStackViewConstraints1: [NSLayoutConstraint] = []
    var detailMediaHeight: CGFloat = 300
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func configureCell(_ video: AppBskyLexicon.Embed.VideoDefinition.View? = nil) {
        if GlobalStruct.detailImageHeight != 0 {
            let imageRatio = CGFloat(GlobalStruct.detailImageWidth) / CGFloat(GlobalStruct.detailImageHeight)
            if imageRatio >= 0.6 {
                // landscape
                // fixed width, variable height
                let theWidth: CGFloat = contentView.frame.width - 20
                let theHeight: CGFloat = theWidth/imageRatio
                detailMediaHeight = theHeight
            } else {
                // portrait
                // fixed height, variable width
                detailMediaHeight = 420
            }
        } else if GlobalStruct.detailVideoAspectRatioHeight != 0 {
            let videoRatio = CGFloat(GlobalStruct.detailVideoAspectRatioWidth) / CGFloat(GlobalStruct.detailVideoAspectRatioHeight)
            if videoRatio >= 0.6 {
                // landscape
                // fixed width, variable height
                let theWidth: CGFloat = contentView.frame.width - 20
                let theHeight: CGFloat = theWidth/videoRatio
                detailMediaHeight = theHeight
            } else {
                // portrait
                // fixed height, variable width
                detailMediaHeight = 420
            }
        }
        
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.backgroundColor = GlobalStruct.backgroundTint
        contentView.addSubview(bgView)
        
        setupCollectionView()
        setupPageControl()
        setupBlurView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showBar), name: NSNotification.Name(rawValue: "showBar"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideBar), name: NSNotification.Name(rawValue: "hideBar"), object: nil)
        
        contentView.addSubview(collectionView)
        contentView.addSubview(blurView)
        blurView.contentView.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            bgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            bgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            bgView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            blurView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            blurView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            blurView.heightAnchor.constraint(equalToConstant: 26),
            
            pageControl.centerXAnchor.constraint(equalTo: blurView.centerXAnchor),
            pageControl.centerYAnchor.constraint(equalTo: blurView.centerYAnchor)
        ])
        
        NSLayoutConstraint.deactivate(cellStackViewConstraints1)
        cellStackViewConstraints1 = [collectionView.heightAnchor.constraint(equalToConstant: detailMediaHeight)]
        NSLayoutConstraint.activate(cellStackViewConstraints1)
        
        pageControl.addTarget(self, action: #selector(pageControlValueChanged(_:)), for: .valueChanged)
        
        collectionView.reloadData()
        pageControl.numberOfPages = GlobalStruct.detailImages.count
        pageControl.currentPage = 0
        updateBlurViewFrame()
        
        if let video = video {
            addPlayerView(video)
        }
    }
    
    @objc func showBar() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0.075) { [weak self] in
            guard let self else { return }
            self.blurView.alpha = 1
            self.pageControl.alpha = 1
        }
        for (c,_) in GlobalStruct.detailImages.enumerated() {
            if let cell = self.collectionView.cellForItem(at: IndexPath(item: c, section: 0)) as? ImageCollectionViewCell {
                cell.imageView.alpha = 1
            }
        }
        self.updateBlurViewFrame()
    }
    
    @objc func hideBar() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0.075) { [weak self] in
            guard let self else { return }
            self.blurView.alpha = 0
            self.pageControl.alpha = 0
        }
        for (c,_) in GlobalStruct.detailImages.enumerated() {
            if let cell = self.collectionView.cellForItem(at: IndexPath(item: c, section: 0)) as? ImageCollectionViewCell {
                cell.imageView.alpha = 0
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        GlobalStruct.detailImages = []
        
        // reset player
        playerView.player?.pause()
        playerView.player?.replaceCurrentItem(with: nil)
        playerView.player = nil
    }
    
    // video
    
    func addPlayerView(_ video: AppBskyLexicon.Embed.VideoDefinition.View) {
        hasVideo = true
        playerView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width - 20, height: detailMediaHeight)
        playerView.layer.cornerRadius = 10
        playerView.layer.masksToBounds = true
        playerView.clipsToBounds = true
        collectionView.addSubview(playerView)
        if let url = URL(string: video.playlistURI) {
            let currentItem = (playerView.player?.currentItem as? AVPlayerItem)?.asset as? AVURLAsset
            if currentItem?.url != url {
                if playerView.player == nil {
                    playerView.player = AVPlayer(playerItem: AVPlayerItem(url: url))
                } else {
                    playerView.player?.replaceCurrentItem(with: AVPlayerItem(url: url))
                }
            }
            playerView.playerLayer?.videoGravity = .resizeAspect
            if playerView.player?.rate == 0 {
                if GlobalStruct.switchAutoplay {
                    playerView.player?.play()
                }
            }
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(playerViewTapped))
            playerView.addGestureRecognizer(tapGestureRecognizer)
            playerView.isUserInteractionEnabled = true
        }
    }
    
    @objc private func playerViewTapped() {
        guard let player = playerView.player else { return }
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.allowsPictureInPicturePlayback = true
        playerViewController.delegate = self
        getTopMostViewController()?.present(playerViewController, animated: true) {
            player.play()
        }
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, willBeginFullScreenPresentationWithAnimationCoordinator coordinator: any UIViewControllerTransitionCoordinator) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
        }) { _ in
            if GlobalStruct.inPiP == false {
                do {
                    try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: .mixWithOthers)
                    try AVAudioSession.sharedInstance().setActive(true)
                } catch {
                    print(error)
                }
            }
            self.playerView.player?.play()
        }
    }
    
    func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        GlobalStruct.inPiP = true
    }
    
    func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
        GlobalStruct.inPiP = false
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        playerView.player?.play()
    }
    
    // collection view
    
    @objc private func pageControlValueChanged(_ sender: UIPageControl) {
        let page = sender.currentPage
        let offset = CGPoint(x: CGFloat(page) * collectionView.bounds.width, y: 0)
        collectionView.setContentOffset(offset, animated: false)
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: self.contentView.frame.size.width - 20, height: detailMediaHeight)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = GlobalStruct.backgroundTint
        collectionView.layer.borderWidth = 0.35
        collectionView.layer.borderColor = UIColor.gray.cgColor
    }
    
    private func setupBlurView() {
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 12
        blurView.clipsToBounds = true
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
        if GlobalStruct.detailImages.count <= 1 {
            blurView.alpha = 0
        } else {
            if let widthConstraint = blurView.constraints.first(where: { $0.firstAttribute == .width }) {
                widthConstraint.constant = blurWidth
            } else {
                let widthConstraint = blurView.widthAnchor.constraint(equalToConstant: blurWidth)
                widthConstraint.isActive = true
            }
            blurView.alpha = 1
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateBlurViewFrame()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: contentView.frame.size.width - 20, height: detailMediaHeight)
        collectionView.collectionViewLayout = layout
    }
}

extension DetailImagesCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SKPhotoBrowserDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return GlobalStruct.detailImages.count
    }
    
    func didScrollToIndex(_ browser: SKPhotoBrowser, index: Int) {
        self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCollectionViewCell
        
        cell.imageView.alpha = 1
        cell.imageView.sd_imageTransition = .fade
        cell.imageView.sd_setImage(with: GlobalStruct.detailImages[indexPath.item])
        
//        if indexPath.item < 4 {
//            if let _ = self.currentPost.[indexPath.row].description {
//                let altView = UIButton()
//                altView.tag = indexPath.row
//                altView.frame = CGRect(x: 8, y: 8, width: 40, height: 26)
//                altView.setTitle("ALT", for: .normal)
//                altView.setTitleColor(UIColor.label, for: .normal)
//                altView.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
//                altView.backgroundColor = UIColor.clear
//                altView.layer.cornerRadius = 8
//                altView.layer.cornerCurve = .continuous
//                altView.addTarget(self, action: #selector(self.tappedAltView(_:)), for: .touchUpInside)
//                for x in cell.subviews {
//                    if let y = x as? UIButton {
//                        y.removeFromSuperview()
//                    }
//                }
//                if GlobalStruct.showAltTags {
//                    cell.addSubview(altView)
//                }
//                
//                let blurView = UIVisualEffectView(effect: blurEffect)
//                blurView.frame = altView.bounds
//                blurView.layer.cornerRadius = 8
//                blurView.clipsToBounds = true
//                blurView.isUserInteractionEnabled = false
//                altView.addTarget(self, action: #selector(self.tappedAltView(_:)), for: .touchUpInside)
//                for x in altView.subviews {
//                    if let y = x as? UIVisualEffectView {
//                        y.removeFromSuperview()
//                    }
//                }
//                altView.insertSubview(blurView, at: 0)
//            }
//        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = self.collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
            let index = indexPath.item
            GlobalStruct.mediaBrowserRadiusType = 2
            var images = [SKPhoto]()
            for x in GlobalStruct.detailImages {
                let photo = SKPhoto.photoWithImageURL(x.absoluteString)
                photo.shouldCachePhotoURLImage = true
                photo.contentMode = .scaleAspectFit
                images.append(photo)
            }
            let originImage = cell.imageView.image ?? UIImage()
            let browser = SKPhotoBrowser(originImage: originImage, photos: images, animatedFromView: self.collectionView, imageText: "", imageText2: 0, imageText3: 0, imageText4: "")
            browser.delegate = self
            SKPhotoBrowserOptions.enableSingleTapDismiss = false
            SKPhotoBrowserOptions.displayCounterLabel = false
            SKPhotoBrowserOptions.displayBackAndForwardButton = false
            SKPhotoBrowserOptions.displayAction = false
            SKPhotoBrowserOptions.displayHorizontalScrollIndicator = false
            SKPhotoBrowserOptions.displayVerticalScrollIndicator = false
            SKPhotoBrowserOptions.displayCloseButton = false
            SKPhotoBrowserOptions.displayStatusbar = false
            browser.initializePageIndex(index)
            getTopMostViewController()?.present(browser, animated: true, completion: {})
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if hasVideo {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: { self.makePreviewForVideos() }) { _ in
                createVideoMenu(self.playerView.player?.currentItem?.asset)
            }
        } else if let cell = self.collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: { self.makePreviewForImages(cell.imageView) }) { _ in
                createImageMenu(cell.imageView)
            }
        }
        return nil
    }
    
    func makePreviewForVideos() -> UIViewController {
        let viewController = UIViewController()
        let player = playerView.player
        let playerLayer = AVPlayerLayer(player: player)
        var ratioS: CGFloat = 1
        if GlobalStruct.detailVideoAspectRatioHeight == 0 {} else {
            ratioS = GlobalStruct.detailVideoAspectRatioWidth/GlobalStruct.detailVideoAspectRatioHeight
        }
        if GlobalStruct.detailVideoAspectRatioHeight >= (GlobalStruct.detailVideoAspectRatioWidth * 2) {
            playerLayer.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width/2, height: contentView.bounds.width/2/ratioS)
            
            playerLayer.videoGravity = .resizeAspect
            viewController.view.layer.addSublayer(playerLayer)
            viewController.preferredContentSize = playerLayer.frame.size
        } else {
            playerLayer.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: contentView.bounds.width/ratioS)
            
            playerLayer.videoGravity = .resizeAspect
            viewController.view.layer.addSublayer(playerLayer)
            viewController.preferredContentSize = playerLayer.frame.size
        }
        return viewController
    }
    
    func makePreviewForImages(_ imageView: UIImageView) -> UIViewController {
        let theImage = imageView.image ?? UIImage()
        let viewController = UIViewController()
        let imageView = UIImageView(image: theImage)
        viewController.view = imageView
        var ratioS: CGFloat = 1
        if theImage.size.height == 0 {} else {
            ratioS = theImage.size.width/theImage.size.height
        }
        if theImage == UIImage() {
            imageView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            imageView.contentMode = .scaleAspectFit
            viewController.preferredContentSize = imageView.frame.size
            return viewController
        } else {
            imageView.frame = CGRect(x: 0, y: 0, width: self.contentView.bounds.width, height: self.contentView.bounds.width/ratioS)
            imageView.contentMode = .scaleAspectFit
            viewController.preferredContentSize = imageView.frame.size
            return viewController
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / (UIScreen.main.bounds.width - 20))
        pageControl.currentPage = Int(pageIndex)
    }
    
    @objc func tappedAltView(_ sender: UIButton) {
        defaultHaptics()
//        let avc = AltViewController()
//        avc.currentText = self.currentPost?.repost?.mediaAttachments[sender.tag].description ?? self.currentPost?.mediaAttachments[sender.tag].description ?? ""
//        let vc = SloppySwipingNav(rootViewController: avc)
//        if let sheet = vc.sheetPresentationController {
//            sheet.detents = [.medium(), .large()]
//            sheet.largestUndimmedDetentIdentifier = .none
//            sheet.preferredCornerRadius = 18
//            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
//            sheet.prefersGrabberVisible = true
//            sheet.delegate = self
//        }
//        getTopMostViewController()?.present(vc, animated: true)
    }
}

class ImageCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.clear
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
