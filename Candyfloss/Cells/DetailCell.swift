//
//  DetailCell.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 07/03/2025.
//

import Foundation
import UIKit
import SDWebImage
import SafariServices
import MessageUI
import AVFoundation
import AVKit
import ATProtoKit

class DetailCell: UITableViewCell, SKPhotoBrowserDelegate, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, UIContextMenuInteractionDelegate, AVPlayerViewControllerDelegate {
    
    // elements
    var bgView = UIView()
    var avatar = UIButton()
    var username = UILabel()
    var usertag = UILabel()
    var time = UILabel()
    var text = ActiveLabel()
    
    // media
    var mediaStackView = UIStackView()
    var media: [URL] = []
    var mediaViews: [UIImageView] = []
    let playerView = PlayerView()
    var videoAspectRatioWidth: CGFloat = 0
    var videoAspectRatioHeight: CGFloat = 0
    
    // links
    var linkStackView = UIStackView()
    var currentLink: String = ""
    let uriLabel = UILabel()
    
    // quotes
    lazy var quoteCell: PostsCell = {
        let cell = PostsCell(style: .default, reuseIdentifier: "QuoteCell")
        cell.translatesAutoresizingMaskIntoConstraints = false
        cell.backgroundColor = GlobalStruct.groupBG
        cell.isHidden = true
        cell.setContentCompressionResistancePriority(.required, for: .vertical)
        return cell
    }()
    var quoteTableView = UITableView()
    var quotePost: AppBskyLexicon.Feed.PostViewDefinition? = nil
    
    // mail
    var emailAddress: String = ""
    
    // fonts and symbols
    let defaultFontSize = UIFont.preferredFont(forTextStyle: .title3).pointSize + 1
    let smallerFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
    let smallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 2
    let mostSmallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 4
    
    let biggestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize + 6
    var symbolConfig1 = UIImage.SymbolConfiguration(pointSize: UIFont.systemFont(ofSize: 12, weight: .bold).pointSize)
    let smallestFontSize2 = UIFont.preferredFont(forTextStyle: .body).pointSize - 2 + GlobalStruct.customTextSize
    var symbolConfig3 = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
    
    let borderLayer = CAShapeLayer()
    
    // constraints
    var cellStackViewConstraints5: [NSLayoutConstraint] = []
    var cellStackViewConstraints6: [NSLayoutConstraint] = []
    var cellStackViewConstraints7: [NSLayoutConstraint] = []
    var cellStackViewConstraints8: [NSLayoutConstraint] = []
    var cellStackViewConstraintMedia1: NSLayoutConstraint?
    var cellStackViewConstraintMedia2: NSLayoutConstraint?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // reset constraints
        NSLayoutConstraint.deactivate(cellStackViewConstraints5 + cellStackViewConstraints6 + cellStackViewConstraints7 + cellStackViewConstraints8)
        
        // reset player
        playerView.player?.pause()
        playerView.player?.replaceCurrentItem(with: nil)
        playerView.player = nil
        
        // remove subviews
        mediaStackView.removeAllArrangedSubviews()
        linkStackView.removeAllArrangedSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        borderLayer.removeFromSuperlayer()
        
        let cornerRadius: CGFloat = 10
        let width = bgView.bounds.width
        let height = bgView.bounds.height
        
        let borderPath = UIBezierPath()
        borderPath.move(to: CGPoint(x: 0, y: height))
        borderPath.addLine(to: CGPoint(x: 0, y: cornerRadius))
        borderPath.addArc(
            withCenter: CGPoint(x: cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: CGFloat.pi,
            endAngle: CGFloat.pi * 1.5,
            clockwise: true
        )
        borderPath.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
        borderPath.addArc(
            withCenter: CGPoint(x: width - cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: CGFloat.pi * 1.5,
            endAngle: 0,
            clockwise: true
        )
        borderPath.addLine(to: CGPoint(x: width, y: height))
        
        borderLayer.path = borderPath.cgPath
        borderLayer.strokeColor = UIColor.gray.cgColor
        borderLayer.lineWidth = 0.35
        borderLayer.fillColor = UIColor.clear.cgColor
        
        bgView.layer.addSublayer(borderLayer)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // background view
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.backgroundColor = GlobalStruct.detailQuoteCell
        bgView.layer.cornerRadius = 10
        bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.addSubview(bgView)
        
        // media
        mediaStackView.translatesAutoresizingMaskIntoConstraints = false
        mediaStackView.axis = .vertical
        mediaStackView.alignment = .fill
        mediaStackView.distribution = .fillEqually
        mediaStackView.spacing = 4
        mediaStackView.layer.masksToBounds = true
        mediaStackView.clipsToBounds = true
        mediaStackView.layer.cornerRadius = 10
        bgView.addSubview(mediaStackView)
        
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.layer.cornerRadius = 10
        playerView.layer.masksToBounds = true
        playerView.clipsToBounds = true
        playerView.playerLayer?.videoGravity = .resizeAspect
        playerView.isHidden = true
        bgView.addSubview(playerView)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(playerViewTapped))
        playerView.addGestureRecognizer(tapGestureRecognizer)
        let interaction = UIContextMenuInteraction(delegate: self)
        playerView.addInteraction(interaction)
        playerView.isUserInteractionEnabled = true
        
        // link
        linkStackView.translatesAutoresizingMaskIntoConstraints = false
        linkStackView.backgroundColor = GlobalStruct.groupBG
        linkStackView.axis = .vertical
        linkStackView.alignment = .fill
        linkStackView.distribution = .equalSpacing
        linkStackView.spacing = 0
        linkStackView.layer.borderColor = UIColor.gray.cgColor
        linkStackView.layer.borderWidth = 0.35
        linkStackView.layer.cornerRadius = 10
        linkStackView.layer.cornerCurve = .continuous
        linkStackView.layer.masksToBounds = true
        linkStackView.clipsToBounds = true
        bgView.addSubview(linkStackView)
        
        // quote
        quoteTableView.translatesAutoresizingMaskIntoConstraints = false
        bgView.addSubview(quoteTableView)
        
        // other elements
        
        avatar.sd_imageTransition = .fade
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.backgroundColor = UIColor(named: "groupBG")
        avatar.layer.cornerRadius = 22
        avatar.imageView?.contentMode = .scaleAspectFill
        avatar.imageView?.layer.masksToBounds = true
        avatar.layer.masksToBounds = true
        bgView.addSubview(avatar)
        
        text.customize { text in
            text.translatesAutoresizingMaskIntoConstraints = false
            text.textAlignment = .left
            text.textColor = UIColor.label
            text.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize + 1, weight: .regular)
            text.numberOfLines = 0
            text.lineSpacing = GlobalStruct.customLineSize
            text.numberOfLines = GlobalStruct.maxLines
            text.enabledTypes = [.mention, .hashtag, .url, .email]
            text.mentionColor = GlobalStruct.baseTint
            text.hashtagColor = GlobalStruct.baseTint
            text.URLColor = GlobalStruct.baseTint
            text.emailColor = GlobalStruct.baseTint
            text.urlMaximumLength = 40
            bgView.addSubview(text)
        }
        text.handleMentionTap { (str) in
            defaultHaptics()
            Task {
                do {
                    if let atProto = GlobalStruct.atProto {
                        let x = try await atProto.getProfile(for: str)
                        let vc = ProfileViewController()
                        vc.profile = x.actorDID
                        UIApplication.shared.pushToCurrentNavigationController(vc, animated: true)
                    }
                } catch {
                    print("Error fetching profile: \(error)")
                }
            }
        }
        text.handleHashtagTap { (str) in
            defaultHaptics()
            let vc = HashtagViewController()
            vc.hashtag = str
            UIApplication.shared.pushToCurrentNavigationController(vc, animated: true)
        }
        text.handleURLTap { (str) in
            defaultHaptics()
            if let link = URL(string: self.currentLink) {
                if GlobalStruct.openLinksInApp {
                    let safariVC = SFSafariViewController(url: link)
                    getTopMostViewController()?.present(safariVC, animated: true, completion: nil)
                } else {
                    UIApplication.shared.open(link, options: [:], completionHandler: nil)
                }
            }
        }
        text.handleEmailTap { (str) in
            defaultHaptics()
            self.emailAddress = str
            self.goToMail()
        }
        
        username.translatesAutoresizingMaskIntoConstraints = false
        username.textColor = .label
        username.textAlignment = .left
        username.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .bold)
        bgView.addSubview(username)
        
        usertag.translatesAutoresizingMaskIntoConstraints = false
        usertag.textColor = GlobalStruct.secondaryTextColor
        usertag.textAlignment = .left
        usertag.font = UIFont.systemFont(ofSize: smallestFontSize + GlobalStruct.customTextSize, weight: .regular)
        bgView.addSubview(usertag)
        
        time.translatesAutoresizingMaskIntoConstraints = false
        time.textColor = GlobalStruct.secondaryTextColor
        time.textAlignment = .left
        time.font = UIFont.systemFont(ofSize: smallestFontSize + GlobalStruct.customTextSize, weight: .regular)
        time.numberOfLines = 0
        bgView.addSubview(time)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(post: AppBskyLexicon.Feed.PostViewDefinition) {
        // layouts
        let viewsDict = [
            "bgView" : bgView,
            "avatar" : avatar,
            "username" : username,
            "usertag" : usertag,
            "text" : text,
            "time" : time,
            "mediaStackView" : mediaStackView,
            "playerView" : playerView,
            "linkStackView" : linkStackView,
            "quoteTableView" : quoteTableView,
        ]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[bgView]-10-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[bgView]-0-|", options: [], metrics: nil, views: viewsDict))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[avatar(44)]-12-[username]-(>=18)-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[avatar(44)]-12-[usertag]-(>=18)-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[text]-18-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[time]-18-|", options: [], metrics: nil, views: viewsDict))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[linkStackView]-18-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[quoteTableView]-18-|", options: [], metrics: nil, views: viewsDict))
        
        cellStackViewConstraints5 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[mediaStackView]-18-|", options: [], metrics: nil, views: viewsDict)
        cellStackViewConstraints6 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[playerView]-18-|", options: [], metrics: nil, views: viewsDict)
        NSLayoutConstraint.activate(cellStackViewConstraints5 + cellStackViewConstraints6)
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-14-[avatar(44)]-(>=14)-|", options: [], metrics: nil, views: viewsDict))
        
        var hasMedia: Bool = false
        var hasLink: Bool = false
        var hasQuote: Bool = false
        var imageWidth: Int = 0
        var imageHeight: Int = 0
        if let embed = post.embed {
            switch embed {
            case .embedExternalView(let externalEmbed):
                // handle external gifs
                if externalEmbed.external.uri.contains(".gif?") {
                    break
                } else {
                    hasLink = true
                    currentLink = externalEmbed.external.uri
                    linkStackView.removeAllArrangedSubviews()
                    
                    if let imageURL = externalEmbed.external.thumbnailImageURL {
                        let mediaView = UIImageView()
                        mediaView.translatesAutoresizingMaskIntoConstraints = false
                        mediaView.backgroundColor = UIColor(named: "groupBG")
                        mediaView.contentMode = .scaleAspectFill
                        mediaView.layer.masksToBounds = true
                        mediaView.sd_imageTransition = .fade
                        mediaView.sd_setImage(with: imageURL)
                        mediaView.isUserInteractionEnabled = false
                        mediaView.heightAnchor.constraint(equalToConstant: 180).isActive = true
                        linkStackView.addArrangedSubview(mediaView)
                        
                        let topBorder = UIView()
                        topBorder.translatesAutoresizingMaskIntoConstraints = false
                        topBorder.backgroundColor = UIColor.gray
                        topBorder.heightAnchor.constraint(equalToConstant: 0.18).isActive = true
                        linkStackView.addArrangedSubview(topBorder)
                    }
                    
                    let titleLabel = UILabel()
                    if externalEmbed.external.title == "" {
                        titleLabel.text = "\((URL(string: externalEmbed.external.uri)?.host() ?? "").split(separator: ".").first ?? "")"
                    } else {
                        titleLabel.text = externalEmbed.external.title
                    }
                    titleLabel.font = UIFont.systemFont(ofSize: smallerFontSize, weight: .semibold)
                    titleLabel.textColor = .label
                    titleLabel.numberOfLines = 2
                    
                    let descriptionLabel = UILabel()
                    if externalEmbed.external.title == "" {
                        descriptionLabel.text = externalEmbed.external.uri
                    } else {
                        descriptionLabel.text = externalEmbed.external.description.replacingOccurrences(of: "\n\n\n", with: "\n").replacingOccurrences(of: "\n\n", with: "\n")
                    }
                    descriptionLabel.font = UIFont.systemFont(ofSize: smallestFontSize, weight: .regular)
                    descriptionLabel.textColor = .secondaryText
                    descriptionLabel.numberOfLines = 4
                    
                    uriLabel.text = URL(string: externalEmbed.external.uri)?.host() ?? externalEmbed.external.uri
                    uriLabel.font = UIFont.systemFont(ofSize: smallestFontSize, weight: .regular)
                    uriLabel.textColor = GlobalStruct.baseTint
                    
                    let authorFavicon = UIImageView()
                    authorFavicon.translatesAutoresizingMaskIntoConstraints = false
                    authorFavicon.backgroundColor = GlobalStruct.detailQuoteCell
                    authorFavicon.layer.cornerRadius = 4
                    if let url = URL(string: FavIcon(URL(string: externalEmbed.external.uri)?.host() ?? externalEmbed.external.uri)[.l]) {
                        let cornerRadius: CGFloat = 14
                        let transformer = SDImagePipelineTransformer(transformers: [
                            SDImageRoundCornerTransformer(radius: cornerRadius, corners: .allCorners, borderWidth: 0, borderColor: nil)
                        ])
                        authorFavicon.sd_setImage(with: url, placeholderImage: nil, options: [], context: [.imageTransformer: transformer])
                    }
                    authorFavicon.heightAnchor.constraint(equalToConstant: smallestFontSize).isActive = true
                    authorFavicon.widthAnchor.constraint(equalToConstant: smallestFontSize).isActive = true
                    
                    let authorSubviews: [UIView] = [authorFavicon, uriLabel]
                    let authorStackView = UIStackView(arrangedSubviews: authorSubviews)
                    authorStackView.alignment = .center
                    authorStackView.distribution = .fillProportionally
                    authorStackView.axis = .horizontal
                    authorStackView.spacing = 8
                    authorStackView.isLayoutMarginsRelativeArrangement = true
                    
                    var arrangedSubviews: [UIView] = [titleLabel, descriptionLabel]
                    if descriptionLabel.text == "" || descriptionLabel.text == nil {
                        arrangedSubviews = [titleLabel]
                    }
                    let labelsStackView = UIStackView(arrangedSubviews: arrangedSubviews)
                    labelsStackView.distribution = .equalSpacing
                    labelsStackView.axis = .vertical
                    labelsStackView.spacing = 8
                    labelsStackView.layoutMargins = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
                    labelsStackView.isLayoutMarginsRelativeArrangement = true
                    linkStackView.addArrangedSubview(labelsStackView)
                    
                    let bottomBorder = UIView()
                    bottomBorder.translatesAutoresizingMaskIntoConstraints = false
                    bottomBorder.backgroundColor = UIColor.gray
                    bottomBorder.heightAnchor.constraint(equalToConstant: 0.18).isActive = true
                    linkStackView.addArrangedSubview(bottomBorder)
                    
                    let labelsStackViewAuthor = UIStackView(arrangedSubviews: [authorStackView])
                    labelsStackViewAuthor.distribution = .equalSpacing
                    labelsStackViewAuthor.axis = .vertical
                    labelsStackViewAuthor.spacing = 8
                    labelsStackViewAuthor.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 10, right: 12)
                    labelsStackViewAuthor.isLayoutMarginsRelativeArrangement = true
                    linkStackView.addArrangedSubview(labelsStackViewAuthor)
                    
                    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(linkStackViewTapped))
                    linkStackView.addGestureRecognizer(tapGestureRecognizer)
                    let interaction = UIContextMenuInteraction(delegate: self)
                    linkStackView.addInteraction(interaction)
                }
            case .embedRecordView(let record):
                switch record.record {
                case .viewRecord(let record):
                    hasQuote = true
                    if let quote = GlobalStruct.quoteTable[record.uri] {
                        updateQuoteView(quote, recordURI: record.uri)
                    } else {
                        Task {
                            if let quote = await QuoteCacheManager.shared.getQuote(for: record.uri, fetcher: {
                                guard let post = try? await GlobalStruct.atProto?.getPosts([record.uri]).posts.first else {
                                    return nil
                                }
                                return post as? AppBskyLexicon.Feed.PostViewDefinition
                            }) {
                                updateQuoteView(quote, recordURI: record.uri)
                            }
                        }
                    }
                    setUpTable()
                default:
                    break
                }
            case .embedRecordWithMediaView(let record):
                switch record.media {
                case .embedImagesView(let imageEmbed):
                    hasMedia = true
                    media = []
                    mediaViews = []
                    playerView.isHidden = true
                    for (index, image) in imageEmbed.images.enumerated() {
                        if index == 0 {
                            imageWidth = image.aspectRatio?.width ?? 0
                            imageHeight = image.aspectRatio?.height ?? 0
                        }
                        let mediaView = UIImageView()
                        mediaView.translatesAutoresizingMaskIntoConstraints = false
                        mediaView.backgroundColor = GlobalStruct.groupBG
                        mediaView.contentMode = .scaleAspectFill
                        mediaView.layer.masksToBounds = true
                        mediaView.sd_imageTransition = .fade
                        mediaView.sd_setImage(with: image.fullSizeImageURL)
                        media.append(image.fullSizeImageURL)
                        mediaViews.append(mediaView)
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
                        mediaView.addGestureRecognizer(tapGesture)
                        let interaction = UIContextMenuInteraction(delegate: self)
                        mediaView.addInteraction(interaction)
                        mediaView.tag = index
                        mediaView.isUserInteractionEnabled = true
                    }
                    switch imageEmbed.images.count {
                    case 2:
                        mediaStackView.axis = .horizontal
                        let stack1 = UIStackView(arrangedSubviews: mediaViews)
                        stack1.axis = .horizontal
                        stack1.alignment = .fill
                        stack1.distribution = .fillEqually
                        stack1.spacing = 4
                        mediaStackView.addArrangedSubview(stack1)
                        mediaStackView.layer.borderWidth = 0
                    case 3:
                        mediaStackView.axis = .horizontal
                        let leftImage = mediaViews[0]
                        let rightStack = UIStackView(arrangedSubviews: Array(mediaViews[1...]))
                        rightStack.axis = .vertical
                        rightStack.alignment = .fill
                        rightStack.distribution = .fillEqually
                        rightStack.spacing = 4
                        mediaStackView.addArrangedSubview(leftImage)
                        mediaStackView.addArrangedSubview(rightStack)
                        mediaStackView.layer.borderWidth = 0
                    case 4:
                        mediaStackView.axis = .vertical
                        for i in stride(from: 0, to: mediaViews.count, by: 2) {
                            let stackRow = UIStackView(arrangedSubviews: Array(mediaViews[i..<i+2]))
                            stackRow.axis = .horizontal
                            stackRow.alignment = .fill
                            stackRow.distribution = .fillEqually
                            stackRow.spacing = 4
                            mediaStackView.addArrangedSubview(stackRow)
                        }
                        mediaStackView.layer.borderWidth = 0
                    default:
                        mediaStackView.axis = .horizontal
                        mediaStackView.addArrangedSubview(mediaViews[0])
                        mediaStackView.layer.borderColor = UIColor.gray.cgColor
                        mediaStackView.layer.borderWidth = 0.35
                    }
                case .embedVideoView(let videoEmbed):
                    hasMedia = true
                    media = []
                    mediaViews = []
                    let mediaView = UIImageView()
                    mediaView.translatesAutoresizingMaskIntoConstraints = false
                    mediaView.backgroundColor = UIColor(named: "groupBG")
                    mediaView.contentMode = .scaleAspectFill
                    mediaView.layer.masksToBounds = true
                    mediaView.sd_imageTransition = .fade
                    if let link = videoEmbed.thumbnailImageURL, let thumbnail = URL(string: link) {
                        mediaView.sd_setImage(with: thumbnail)
                        media.append(thumbnail)
                    }
                    mediaViews.append(mediaView)
                    mediaStackView.axis = .horizontal
                    mediaStackView.addArrangedSubview(mediaViews[0])
                    
                    videoAspectRatioWidth = CGFloat(videoEmbed.aspectRatio?.width ?? 0)
                    videoAspectRatioHeight = CGFloat(videoEmbed.aspectRatio?.height ?? 0)
                    playerView.isHidden = false
                    if let url = URL(string: videoEmbed.playlistURI) {
                        let currentItem = (playerView.player?.currentItem as? AVPlayerItem)?.asset as? AVURLAsset
                        if currentItem?.url != url {
                            if playerView.player == nil {
                                playerView.player = AVPlayer(playerItem: AVPlayerItem(url: url))
                            } else {
                                playerView.player?.replaceCurrentItem(with: AVPlayerItem(url: url))
                            }
                        }
                        if playerView.player?.rate == 0 {
                            if GlobalStruct.switchAutoplay {
                                playerView.player?.play()
                            }
                        }
                    }
                case .embedExternalView(let externalEmbed):
                    // handle external gifs
                    if externalEmbed.external.uri.contains(".gif?") {
                        hasMedia = true
                        media = []
                        mediaViews = []
                        let mediaView = UIImageView()
                        mediaView.translatesAutoresizingMaskIntoConstraints = false
                        mediaView.backgroundColor = UIColor(named: "groupBG")
                        mediaView.contentMode = .scaleAspectFill
                        mediaView.layer.masksToBounds = true
                        mediaView.sd_imageTransition = .fade
                        if let link = URL(string: "\(externalEmbed.external.uri)") {
                            mediaView.sd_setImage(with: link)
                            media.append(link)
                        }
                        mediaViews.append(mediaView)
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
                        mediaView.addGestureRecognizer(tapGesture)
                        let interaction = UIContextMenuInteraction(delegate: self)
                        mediaView.addInteraction(interaction)
                        mediaView.tag = 0
                        mediaView.isUserInteractionEnabled = true
                        mediaStackView.axis = .horizontal
                        mediaStackView.addArrangedSubview(mediaViews[0])
                        mediaStackView.layer.borderColor = UIColor.gray.cgColor
                        mediaStackView.layer.borderWidth = 0.35
                    } else {
                        hasLink = true
                        currentLink = externalEmbed.external.uri
                        
                        if let imageURL = externalEmbed.external.thumbnailImageURL {
                            let mediaView = UIImageView()
                            mediaView.translatesAutoresizingMaskIntoConstraints = false
                            mediaView.backgroundColor = UIColor(named: "groupBG")
                            mediaView.contentMode = .scaleAspectFill
                            mediaView.layer.masksToBounds = true
                            mediaView.sd_imageTransition = .fade
                            mediaView.sd_setImage(with: imageURL)
                            mediaView.isUserInteractionEnabled = false
                            mediaView.heightAnchor.constraint(equalToConstant: 180).isActive = true
                            linkStackView.addArrangedSubview(mediaView)
                            
                            let topBorder = UIView()
                            topBorder.translatesAutoresizingMaskIntoConstraints = false
                            topBorder.backgroundColor = UIColor.gray
                            topBorder.heightAnchor.constraint(equalToConstant: 0.18).isActive = true
                            linkStackView.addArrangedSubview(topBorder)
                        }
                        
                        let titleLabel = UILabel()
                        if externalEmbed.external.title == "" {
                            titleLabel.text = "\((URL(string: externalEmbed.external.uri)?.host() ?? "").split(separator: ".").first ?? "")"
                        } else {
                            titleLabel.text = externalEmbed.external.title
                        }
                        titleLabel.font = UIFont.systemFont(ofSize: smallerFontSize, weight: .semibold)
                        titleLabel.textColor = .label
                        titleLabel.numberOfLines = 2
                        
                        let descriptionLabel = UILabel()
                        if externalEmbed.external.title == "" {
                            descriptionLabel.text = externalEmbed.external.uri
                        } else {
                            descriptionLabel.text = externalEmbed.external.description.replacingOccurrences(of: "\n\n\n", with: "\n").replacingOccurrences(of: "\n\n", with: "\n")
                        }
                        descriptionLabel.font = UIFont.systemFont(ofSize: smallestFontSize, weight: .regular)
                        descriptionLabel.textColor = .secondaryText
                        descriptionLabel.numberOfLines = 3
                        
                        uriLabel.text = URL(string: externalEmbed.external.uri)?.host() ?? externalEmbed.external.uri
                        uriLabel.font = UIFont.systemFont(ofSize: smallestFontSize, weight: .regular)
                        uriLabel.textColor = GlobalStruct.baseTint
                        
                        let authorFavicon = UIImageView()
                        authorFavicon.translatesAutoresizingMaskIntoConstraints = false
                        authorFavicon.backgroundColor = GlobalStruct.detailQuoteCell
                        authorFavicon.layer.cornerRadius = 4
                        if let url = URL(string: FavIcon(URL(string: externalEmbed.external.uri)?.host() ?? externalEmbed.external.uri)[.l]) {
                            let cornerRadius: CGFloat = 14
                            let transformer = SDImagePipelineTransformer(transformers: [
                                SDImageRoundCornerTransformer(radius: cornerRadius, corners: .allCorners, borderWidth: 0, borderColor: nil)
                            ])
                            authorFavicon.sd_setImage(with: url, placeholderImage: nil, options: [], context: [.imageTransformer: transformer])
                        }
                        authorFavicon.heightAnchor.constraint(equalToConstant: smallestFontSize).isActive = true
                        authorFavicon.widthAnchor.constraint(equalToConstant: smallestFontSize).isActive = true
                        
                        let authorSubviews: [UIView] = [authorFavicon, uriLabel]
                        let authorStackView = UIStackView(arrangedSubviews: authorSubviews)
                        authorStackView.alignment = .center
                        authorStackView.distribution = .fillProportionally
                        authorStackView.axis = .horizontal
                        authorStackView.spacing = 8
                        authorStackView.isLayoutMarginsRelativeArrangement = true
                        
                        var arrangedSubviews: [UIView] = [titleLabel, descriptionLabel]
                        if descriptionLabel.text == "" || descriptionLabel.text == nil {
                            arrangedSubviews = [titleLabel]
                        }
                        let labelsStackView = UIStackView(arrangedSubviews: arrangedSubviews)
                        labelsStackView.distribution = .equalSpacing
                        labelsStackView.axis = .vertical
                        labelsStackView.spacing = 8
                        labelsStackView.layoutMargins = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
                        labelsStackView.isLayoutMarginsRelativeArrangement = true
                        linkStackView.addArrangedSubview(labelsStackView)
                        
                        let bottomBorder = UIView()
                        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
                        bottomBorder.backgroundColor = UIColor.gray
                        bottomBorder.heightAnchor.constraint(equalToConstant: 0.18).isActive = true
                        linkStackView.addArrangedSubview(bottomBorder)
                        
                        let labelsStackViewAuthor = UIStackView(arrangedSubviews: [authorStackView])
                        labelsStackViewAuthor.distribution = .equalSpacing
                        labelsStackViewAuthor.axis = .vertical
                        labelsStackViewAuthor.spacing = 8
                        labelsStackViewAuthor.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 10, right: 12)
                        labelsStackViewAuthor.isLayoutMarginsRelativeArrangement = true
                        linkStackView.addArrangedSubview(labelsStackViewAuthor)
                        
                        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(linkStackViewTapped))
                        linkStackView.addGestureRecognizer(tapGestureRecognizer)
                        let interaction = UIContextMenuInteraction(delegate: self)
                        linkStackView.addInteraction(interaction)
                    }
                }
                switch record.record.record {
                case .viewRecord(let record):
                    hasQuote = true
                    if let quote = GlobalStruct.quoteTable[record.uri] {
                        updateQuoteView(quote, recordURI: record.uri)
                    } else {
                        Task {
                            if let quote = await QuoteCacheManager.shared.getQuote(for: record.uri, fetcher: {
                                guard let post = try? await GlobalStruct.atProto?.getPosts([record.uri]).posts.first else {
                                    return nil
                                }
                                return post as? AppBskyLexicon.Feed.PostViewDefinition
                            }) {
                                updateQuoteView(quote, recordURI: record.uri)
                            }
                        }
                    }
                    setUpTable()
                default:
                    break
                }
            default:
                break
            }
        }
        
        // hide text view if no text
        var textString: String = "-12-[text]"
        if text.text == "" {
            textString = ""
        }
        mediaStackView.isHidden = !hasMedia
        
        // media sizing
        var mediaHeight: String = "200"
        if mediaViews.count == 1 && imageWidth != 0 && imageHeight != 0 {
            let imageRatio = CGFloat(imageWidth) / CGFloat(imageHeight)
            if imageRatio >= 0.6 {
                // landscape
                // fixed width, variable height
                let theWidth: CGFloat = UIScreen.main.bounds.width - 92
                let theHeight: CGFloat = theWidth/imageRatio
                mediaHeight = "\(Int(theHeight))"
            } else {
                // portrait
                // fixed height, variable width
                let theWidth: CGFloat = 320 * CGFloat(imageRatio)
                mediaHeight = "320"
                NSLayoutConstraint.deactivate(cellStackViewConstraints5 + cellStackViewConstraints6)
                cellStackViewConstraints5 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[avatar(44)]-12-[mediaStackView(\(theWidth))]-(>=18)-|", options: [], metrics: nil, views: viewsDict)
                cellStackViewConstraints6 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[avatar(44)]-12-[playerView(\(theWidth))]-(>=18)-|", options: [], metrics: nil, views: viewsDict)
                NSLayoutConstraint.activate(cellStackViewConstraints5 + cellStackViewConstraints6)
            }
        } else if mediaViews.count == 1 && videoAspectRatioWidth != 0 && videoAspectRatioHeight != 0 {
            let videoRatio = CGFloat(videoAspectRatioWidth) / CGFloat(videoAspectRatioHeight)
            if videoRatio >= 0.6 {
                // landscape
                // fixed width, variable height
                let theWidth: CGFloat = UIScreen.main.bounds.width - 92
                let theHeight: CGFloat = theWidth/videoRatio
                mediaHeight = "\(Int(theHeight))"
            } else {
                // portrait
                // fixed height, variable width
                let theWidth: CGFloat = 320 * CGFloat(videoRatio)
                mediaHeight = "320"
                NSLayoutConstraint.deactivate(cellStackViewConstraints5 + cellStackViewConstraints6)
                cellStackViewConstraints5 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[avatar(44)]-12-[mediaStackView(\(theWidth))]-(>=18)-|", options: [], metrics: nil, views: viewsDict)
                cellStackViewConstraints6 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[avatar(44)]-12-[playerView(\(theWidth))]-(>=18)-|", options: [], metrics: nil, views: viewsDict)
                NSLayoutConstraint.activate(cellStackViewConstraints5 + cellStackViewConstraints6)
            }
        } else {
            mediaHeight = "200"
        }
        
        var verticalLayoutString1: String = ""
        var verticalLayoutString1b: String = ""
        if hasMedia {
            if hasQuote {
                if hasLink {
                    verticalLayoutString1 = "V:|-16-[username]-1-[usertag]\(textString)-12-[mediaStackView]-14-[linkStackView]-12-[quoteTableView]-12-[time]-16-|"
                    verticalLayoutString1b = "V:|-16-[username]-1-[usertag]\(textString)-12-[playerView]"
                } else {
                    verticalLayoutString1 = "V:|-16-[username]-1-[usertag]\(textString)-12-[mediaStackView]-12-[quoteTableView]-12-[time]-16-|"
                    verticalLayoutString1b = "V:|-16-[username]-1-[usertag]\(textString)-12-[playerView]"
                }
            } else {
                if hasLink {
                    verticalLayoutString1 = "V:|-16-[username]-1-[usertag]\(textString)-12-[mediaStackView]-14-[linkStackView]-14-[time]-16-|"
                    verticalLayoutString1b = "V:|-16-[username]-1-[usertag]\(textString)-12-[playerView]"
                } else {
                    verticalLayoutString1 = "V:|-16-[username]-1-[usertag]\(textString)-12-[mediaStackView]-10-[time]-16-|"
                    verticalLayoutString1b = "V:|-16-[username]-1-[usertag]\(textString)-12-[playerView]"
                }
            }
            cellStackViewConstraints8 = NSLayoutConstraint.constraints(withVisualFormat: verticalLayoutString1b, options: [], metrics: nil, views: viewsDict)
            for constraint in cellStackViewConstraints8 {
                constraint.priority = .defaultLow
            }
            NSLayoutConstraint.activate(cellStackViewConstraints8)
        } else {
            if hasQuote {
                if hasLink {
                    verticalLayoutString1 = "V:|-16-[username]-1-[usertag]\(textString)-14-[linkStackView]-12-[quoteTableView]-12-[time]-16-|"
                } else {
                    verticalLayoutString1 = "V:|-16-[username]-1-[usertag]\(textString)-12-[quoteTableView]-12-[time]-16-|"
                }
            } else {
                if hasLink {
                    verticalLayoutString1 = "V:|-16-[username]-1-[usertag]\(textString)-14-[linkStackView]-14-[time]-16-|"
                } else {
                    verticalLayoutString1 = "V:|-16-[username]-1-[usertag]\(textString)-10-[time]-16-|"
                }
            }
        }
        
        text.customize { text in
            text.textColor = UIColor.label
            text.mentionColor = GlobalStruct.baseTint
            text.hashtagColor = GlobalStruct.baseTint
            text.URLColor = GlobalStruct.baseTint
            text.emailColor = GlobalStruct.baseTint
        }
        
        cellStackViewConstraints7 = NSLayoutConstraint.constraints(withVisualFormat: verticalLayoutString1, options: [], metrics: nil, views: viewsDict)
        for constraint in cellStackViewConstraints7 {
            constraint.priority = .defaultLow
        }
        NSLayoutConstraint.activate(cellStackViewConstraints7)
        cellStackViewConstraintMedia1?.isActive = false
        cellStackViewConstraintMedia2?.isActive = false
        cellStackViewConstraintMedia1 = mediaStackView.heightAnchor.constraint(equalToConstant: CGFloat(Int(mediaHeight) ?? 200))
        cellStackViewConstraintMedia1?.priority = .required
        cellStackViewConstraintMedia2 = playerView.heightAnchor.constraint(equalToConstant: CGFloat(Int(mediaHeight) ?? 200))
        cellStackViewConstraintMedia2?.priority = .required
        cellStackViewConstraintMedia1?.isActive = true
        cellStackViewConstraintMedia2?.isActive = true
    }
    
    func updateQuoteView(_ quote: AppBskyLexicon.Feed.PostViewDefinition, recordURI: String) {
        DispatchQueue.main.async {
            self.quotePost = quote
            self.quoteTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            DispatchQueue.main.async {
                NSLayoutConstraint.deactivate(self.quoteTableView.constraints)
                NSLayoutConstraint.activate([
                    self.quoteTableView.heightAnchor.constraint(equalToConstant: self.quoteTableView.contentSize.height)
                ])
                if let tableView = self.superview as? UITableView {
                    tableView.performBatchUpdates {
                        tableView.beginUpdates()
                        tableView.endUpdates()
                    }
                }
            }
        }
    }
    
    @objc func imageTapped(_ gesture: UITapGestureRecognizer) {
        if let imageView = gesture.view as? UIImageView {
            let index = imageView.tag
            var images = [SKPhoto]()
            for x in media {
                let photo = SKPhoto.photoWithImageURL(x.absoluteString)
                photo.shouldCachePhotoURLImage = true
                photo.contentMode = .scaleAspectFill
                images.append(photo)
            }
            let originImage = mediaViews[index].image ?? UIImage()
            let browser = SKPhotoBrowser(originImage: originImage, photos: images, animatedFromView: mediaViews[index], imageText: "", imageText2: 0, imageText3: 0, imageText4: "")
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
    
    func viewForPhoto(_ browser: SKPhotoBrowser, index: Int) -> UIView? {
        return self.mediaViews[index]
    }
    
    // videos
    
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
    
    // link
    
    @objc func linkStackViewTapped() {
        defaultHaptics()
        if let link = URL(string: currentLink) {
            if GlobalStruct.openLinksInApp {
                let safariVC = SFSafariViewController(url: link)
                getTopMostViewController()?.present(safariVC, animated: true, completion: nil)
            } else {
                UIApplication.shared.open(link, options: [:], completionHandler: nil)
            }
        }
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            createLinkMenu(self.currentLink)
        }
    }
    
    // quote
    
    func setUpTable() {
        quoteTableView.register(PostsCell.self, forCellReuseIdentifier: "PostsCell")
        quoteTableView.dataSource = self
        quoteTableView.delegate = self
        quoteTableView.backgroundColor = UIColor.clear
        quoteTableView.layer.masksToBounds = true
        quoteTableView.rowHeight = UITableView.automaticDimension
        quoteTableView.estimatedRowHeight = 200
        quoteTableView.layer.borderColor = UIColor.gray.cgColor
        quoteTableView.layer.borderWidth = 0.35
        quoteTableView.layer.cornerRadius = 10
        quoteTableView.isScrollEnabled = false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostsCell", for: indexPath) as! PostsCell
        if let post = quotePost {
            configurePostCell(cell, with: post, isNestedQuote: true)
        }
        
        cell.time.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
        cell.username.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .bold)
        cell.usertag.font = UIFont.systemFont(ofSize: smallestFontSize + GlobalStruct.customTextSize, weight: .regular)
        cell.text.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
        cell.repost.titleLabel?.font = UIFont.systemFont(ofSize: smallestFontSize + GlobalStruct.customTextSize, weight: .regular)
        cell.text.mentionColor = GlobalStruct.baseTint
        cell.text.hashtagColor = GlobalStruct.baseTint
        cell.text.URLColor = GlobalStruct.baseTint
        cell.text.emailColor = GlobalStruct.baseTint
        cell.text.lineSpacing = GlobalStruct.customLineSize
        cell.text.numberOfLines = GlobalStruct.maxLines
        if let text = cell.text.text {
            cell.text.text = nil
            cell.text.text = text
        }
        cell.uriLabel.textColor = GlobalStruct.baseTint
        
        cell.accessoryView = nil
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = bgColorView
        cell.backgroundColor = GlobalStruct.groupBG
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        defaultHaptics()
        let vc = DetailsViewController()
        vc.detailPost = quotePost
        UIApplication.shared.pushToCurrentNavigationController(vc, animated: true)
    }
    
    // mail
    
    @objc func goToMail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([emailAddress])
            getTopMostViewController()?.present(mail, animated: true)
        } else {
            let alert = UIAlertController(title: "The Mail app is not installed", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel , handler:{ (UIAlertAction) in
                
            }))
            if let presenter = alert.popoverPresentationController {
                presenter.sourceView = getTopMostViewController()?.view ?? UIView()
                presenter.sourceRect = getTopMostViewController()?.view.bounds ?? .zero
            }
            getTopMostViewController()?.present(alert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
