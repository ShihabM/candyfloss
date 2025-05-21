//
//  PostsCell.swift
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
import Photos
import ATProtoKit

class PostsCell: UITableViewCell, SKPhotoBrowserDelegate, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, UIContextMenuInteractionDelegate, AVPlayerViewControllerDelegate {
    
    // elements
    var post: AppBskyLexicon.Feed.PostViewDefinition? = nil
    var currentProfile: AppBskyLexicon.Actor.ProfileViewBasicDefinition? = nil
    
    var bgView = UIView()
    var repost = UIButton()
    var avatar = UIButton()
    var time = UILabel()
    var username = UILabel()
    var usertag = UILabel()
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
        cell.backgroundColor = GlobalStruct.detailCell
        cell.isHidden = true
        cell.setContentCompressionResistancePriority(.required, for: .vertical)
        return cell
    }()
    var quoteTableView = UITableView()
    var quotePost: AppBskyLexicon.Feed.PostViewDefinition? = nil
    var nestedQuoteActorDID: String = ""
    var isNestedQuote: Bool = false
    
    // icons
    var indicatorIcon: UIImageView = UIImageView()
    
    // mail
    var emailAddress: String = ""
    
    // action buttons
    var actionButtonsStackView = UIStackView()
    var repliesCount: Int = 0
    var repostsCount: Int = 0
    var likesCount: Int = 0
    
    var actionButtonReply = UIButton()
    var actionButtonRepost = UIButton()
    var actionButtonLike = UIButton()
    var actionButtonBookmark = UIButton()
    var actionButtonMore = UIButton()
    
    var actionButtonInsideReply = CustomButton()
    var actionButtonInsideRepost = CustomButton()
    var actionButtonInsideLike = CustomButton()
    var actionButtonInsideBookmark = CustomButton()
    var actionButtonInsideMore = CustomButton()
    
    var numberLabelReply = UILabel()
    var numberLabelRepost = UILabel()
    var numberLabelLike = UILabel()
    
    var combinedStackViewReply = UIStackView()
    var combinedStackViewRepost = UIStackView()
    var combinedStackViewLike = UIStackView()
    
    // fonts and symbols
    let defaultFontSize = UIFont.preferredFont(forTextStyle: .title3).pointSize
    let smallerFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
    let smallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 2
    let mostSmallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 4
    
    let biggestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize + 6
    var symbolConfig1 = UIImage.SymbolConfiguration(pointSize: UIFont.systemFont(ofSize: 12, weight: .bold).pointSize)
    let smallestFontSize2 = UIFont.preferredFont(forTextStyle: .body).pointSize - 2 + GlobalStruct.customTextSize
    var symbolConfig3 = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
    
    // constraints
    var cellReplyConstraints: [NSLayoutConstraint] = []
    var cellStackViewConstraints1: [NSLayoutConstraint] = []
    var cellStackViewConstraints2: [NSLayoutConstraint] = []
    var cellStackViewConstraints3: [NSLayoutConstraint] = []
    var cellStackViewConstraints4: [NSLayoutConstraint] = []
    var cellStackViewConstraints5: [NSLayoutConstraint] = []
    var cellStackViewConstraints6: [NSLayoutConstraint] = []
    var cellStackViewConstraints7: [NSLayoutConstraint] = []
    var cellStackViewConstraintMedia1: NSLayoutConstraint?
    var cellStackViewConstraintMedia2: NSLayoutConstraint?
    var cellStackViewConstraintQuote: NSLayoutConstraint?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // reset constraints
        NSLayoutConstraint.deactivate(cellReplyConstraints + cellStackViewConstraints1 + cellStackViewConstraints2 + cellStackViewConstraints3 + cellStackViewConstraints4 + cellStackViewConstraints5 + cellStackViewConstraints6 + cellStackViewConstraints7)
        cellStackViewConstraintQuote?.isActive = false
        cellStackViewConstraintQuote?.isActive = false
        cellStackViewConstraintMedia1?.isActive = false
        cellStackViewConstraintMedia2?.isActive = false
        
        // reset player
        playerView.player?.pause()
        playerView.player?.replaceCurrentItem(with: nil)
        playerView.player = nil
        
        // remove subviews
        mediaStackView.removeAllArrangedSubviews()
        linkStackView.removeAllArrangedSubviews()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // background view
        bgView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bgView)
        
        // repost
        repost.translatesAutoresizingMaskIntoConstraints = false
        repost.setTitleColor(GlobalStruct.secondaryTextColor, for: .normal)
        repost.titleLabel?.textAlignment = .left
        repost.titleLabel?.font = UIFont.systemFont(ofSize: smallestFontSize + GlobalStruct.customTextSize, weight: .regular)
        repost.contentHorizontalAlignment = .left
        repost.isHidden = true
        repost.setContentHuggingPriority(.required, for: .vertical)
        repost.setContentCompressionResistancePriority(.required, for: .vertical)
        bgView.addSubview(repost)
        
        // media
        mediaStackView.translatesAutoresizingMaskIntoConstraints = false
        mediaStackView.axis = .vertical
        mediaStackView.alignment = .fill
        mediaStackView.distribution = .fillEqually
        mediaStackView.spacing = 4
        mediaStackView.layer.masksToBounds = true
        mediaStackView.clipsToBounds = true
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
        
        // icons
        let symbolConfigIcon = UIImage.SymbolConfiguration(pointSize: smallerFontSize + GlobalStruct.customTextSize, weight: .semibold)
        indicatorIcon.translatesAutoresizingMaskIntoConstraints = false
        indicatorIcon.contentMode = .scaleAspectFit
        indicatorIcon.image = UIImage(systemName: "pin.fill", withConfiguration: symbolConfigIcon)?.withTintColor(GlobalStruct.secondaryTextColor, renderingMode: .alwaysOriginal)
        indicatorIcon.isHidden = true
        bgView.addSubview(indicatorIcon)
        
        // action buttons
        combinedStackViewReply.translatesAutoresizingMaskIntoConstraints = false
        combinedStackViewReply.addArrangedSubview(actionButtonInsideReply)
        combinedStackViewReply.addArrangedSubview(numberLabelReply)
        combinedStackViewReply.axis = .horizontal
        combinedStackViewReply.alignment = .center
        combinedStackViewReply.spacing = 4
        actionButtonReply.addSubview(combinedStackViewReply)
        actionButtonReply.addTarget(self, action: #selector(replyTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            combinedStackViewReply.centerXAnchor.constraint(equalTo: actionButtonReply.centerXAnchor),
            combinedStackViewReply.centerYAnchor.constraint(equalTo: actionButtonReply.centerYAnchor)
        ])
        
        combinedStackViewRepost.translatesAutoresizingMaskIntoConstraints = false
        combinedStackViewRepost.addArrangedSubview(actionButtonInsideRepost)
        combinedStackViewRepost.addArrangedSubview(numberLabelRepost)
        combinedStackViewRepost.axis = .horizontal
        combinedStackViewRepost.alignment = .center
        combinedStackViewRepost.spacing = 4
        actionButtonRepost.addSubview(combinedStackViewRepost)
        NSLayoutConstraint.activate([
            combinedStackViewRepost.centerXAnchor.constraint(equalTo: actionButtonRepost.centerXAnchor),
            combinedStackViewRepost.centerYAnchor.constraint(equalTo: actionButtonRepost.centerYAnchor)
        ])
        
        combinedStackViewLike.translatesAutoresizingMaskIntoConstraints = false
        combinedStackViewLike.addArrangedSubview(actionButtonInsideLike)
        combinedStackViewLike.addArrangedSubview(numberLabelLike)
        combinedStackViewLike.axis = .horizontal
        combinedStackViewLike.alignment = .center
        combinedStackViewLike.spacing = 4
        actionButtonLike.addSubview(combinedStackViewLike)
        actionButtonLike.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            combinedStackViewLike.centerXAnchor.constraint(equalTo: actionButtonLike.centerXAnchor),
            combinedStackViewLike.centerYAnchor.constraint(equalTo: actionButtonLike.centerYAnchor)
        ])
        
        numberLabelReply.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        numberLabelReply.textColor = GlobalStruct.secondaryTextColor
        numberLabelRepost.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        numberLabelRepost.textColor = GlobalStruct.secondaryTextColor
        numberLabelLike.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        numberLabelLike.textColor = GlobalStruct.secondaryTextColor
        
        //
        
        actionButtonInsideReply.setImage(GlobalStruct.replyImage1, for: .normal)
        actionButtonInsideReply.contentMode = .scaleAspectFit
        actionButtonInsideReply.imageView?.contentMode = .scaleAspectFit
        actionButtonInsideReply.backgroundColor = .clear
        actionButtonInsideReply.addTarget(self, action: #selector(replyTapped), for: .touchUpInside)
        actionButtonInsideReply.showsMenuAsPrimaryAction = false
        
        actionButtonInsideRepost.contentMode = .scaleAspectFit
        actionButtonInsideRepost.imageView?.contentMode = .scaleAspectFit
        actionButtonInsideRepost.backgroundColor = .clear
        actionButtonInsideRepost.showsMenuAsPrimaryAction = false
        
        actionButtonInsideLike.contentMode = .scaleAspectFit
        actionButtonInsideLike.imageView?.contentMode = .scaleAspectFit
        actionButtonInsideLike.backgroundColor = .clear
        actionButtonInsideLike.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        actionButtonInsideLike.showsMenuAsPrimaryAction = false
        
        actionButtonInsideBookmark.setImage(GlobalStruct.bookmarkImage1, for: .normal)
        actionButtonInsideBookmark.contentMode = .scaleAspectFit
        actionButtonInsideBookmark.imageView?.contentMode = .scaleAspectFit
        actionButtonInsideBookmark.backgroundColor = .clear
        actionButtonInsideBookmark.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
        actionButtonInsideBookmark.backgroundColor = .clear
        
        actionButtonInsideMore.setImage(GlobalStruct.moreImage1, for: .normal)
        actionButtonInsideMore.contentMode = .scaleAspectFit
        actionButtonInsideMore.imageView?.contentMode = .scaleAspectFit
        actionButtonInsideMore.backgroundColor = .clear
        
        actionButtonsStackView.addArrangedSubview(actionButtonReply)
        actionButtonsStackView.addArrangedSubview(actionButtonRepost)
        actionButtonsStackView.addArrangedSubview(actionButtonLike)
        
        // other elements
        
        avatar.sd_imageTransition = .fade
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.backgroundColor = UIColor(named: "groupBG")
        avatar.layer.cornerRadius = 22
        avatar.imageView?.contentMode = .scaleAspectFill
        avatar.imageView?.layer.masksToBounds = true
        avatar.layer.masksToBounds = true
        avatar.setContentCompressionResistancePriority(.required, for: .vertical)
        bgView.addSubview(avatar)
        let interactionAvatar = UIContextMenuInteraction(delegate: self)
        avatar.addInteraction(interactionAvatar)
        
        text.customize { text in
            text.translatesAutoresizingMaskIntoConstraints = false
            text.textAlignment = .left
            text.textColor = GlobalStruct.textColor
            text.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
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
        text.setContentCompressionResistancePriority(.required, for: .vertical)
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
        
        time.translatesAutoresizingMaskIntoConstraints = false
        time.textColor = GlobalStruct.secondaryTextColor
        time.textAlignment = .left
        time.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
        time.setContentCompressionResistancePriority(.required, for: .horizontal)
        time.setContentCompressionResistancePriority(.required, for: .vertical)
        bgView.addSubview(time)
        
        username.translatesAutoresizingMaskIntoConstraints = false
        username.textColor = .label
        username.textAlignment = .left
        username.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .bold)
        username.setContentCompressionResistancePriority(.required, for: .vertical)
        bgView.addSubview(username)
        
        usertag.translatesAutoresizingMaskIntoConstraints = false
        usertag.textColor = GlobalStruct.secondaryTextColor
        usertag.textAlignment = .left
        usertag.font = UIFont.systemFont(ofSize: smallestFontSize + GlobalStruct.customTextSize, weight: .regular)
        usertag.setContentCompressionResistancePriority(.required, for: .vertical)
        bgView.addSubview(usertag)
        
        actionButtonsStackView.axis = .horizontal
        actionButtonsStackView.alignment = .fill
        actionButtonsStackView.distribution = .equalSpacing
        actionButtonsStackView.spacing = 0
        actionButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        bgView.addSubview(actionButtonsStackView)
        
        // layouts
        let viewsDict = [
            "avatar" : avatar,
        ]
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[avatar(44)]", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(post: AppBskyLexicon.Feed.PostViewDefinition?, showActionButtons: Bool = true, isRepost: AppBskyLexicon.Actor.ProfileViewBasicDefinition? = nil, isNestedQuote: Bool = false, isNestedReply: Bool = false, isPinned: Bool = false, fromPreview: Bool? = false) {
        
        self.post = post
        if let post = post {
            self.currentProfile = post.author
        }
        self.isNestedQuote = isNestedQuote
        
        var showActionButtons = showActionButtons
        if GlobalStruct.showActionButtons == false {
            showActionButtons = false
        }
        
        // nested quote profile
        if isNestedQuote {
            if let post = post {
                nestedQuoteActorDID = post.author.actorDID
            }
            avatar.addTarget(self, action: #selector(profileTapped(_:)), for: .touchUpInside)
        }
        if isNestedQuote || isNestedReply {
            mediaStackView.layer.cornerRadius = 8
        } else {
            mediaStackView.layer.cornerRadius = 10
        }
        if isNestedQuote {
            linkStackView.backgroundColor = GlobalStruct.raisedBackgroundTint
        } else {
            linkStackView.backgroundColor = GlobalStruct.detailQuoteCell
        }
        
        // layouts
        let viewsDict = [
            "bgView" : bgView,
            "repost" : repost,
            "avatar" : avatar,
            "time" : time,
            "username" : username,
            "usertag" : usertag,
            "text" : text,
            "mediaStackView" : mediaStackView,
            "playerView" : playerView,
            "linkStackView" : linkStackView,
            "quoteTableView" : quoteTableView,
            "indicatorIcon" : indicatorIcon,
            "actionButtonsStackView" : actionButtonsStackView,
        ]
        let metricsDict = [
            "offset" : 74 - mostSmallestFontSize - 10,
            "iconDiameter" : smallerFontSize + GlobalStruct.customTextSize
        ]
        
        var cellLayoutString: String = "H:|-0-[bgView]-0-|"
        if isNestedReply {
            cellLayoutString = "H:|-56-[bgView]-0-|"
        }
        cellReplyConstraints = NSLayoutConstraint.constraints(withVisualFormat: cellLayoutString, options: [], metrics: nil, views: viewsDict)
        NSLayoutConstraint.activate(cellReplyConstraints)
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[bgView]-0-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(offset)-[repost]-18-|", options: [], metrics: metricsDict, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[avatar(44)]-12-[username]-(>=10)-[indicatorIcon(iconDiameter)]-8-[time]-18-|", options: [], metrics: metricsDict, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[avatar(44)]-12-[usertag]-18-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[avatar(44)]-12-[text]-18-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[avatar(44)]-12-[linkStackView]-18-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-74-[actionButtonsStackView]-18-|", options: [], metrics: nil, views: viewsDict))
        
        cellStackViewConstraints5 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[avatar(44)]-12-[mediaStackView]-18-|", options: [], metrics: nil, views: viewsDict)
        cellStackViewConstraints6 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[avatar(44)]-12-[playerView]-18-|", options: [], metrics: nil, views: viewsDict)
        NSLayoutConstraint.activate(cellStackViewConstraints5 + cellStackViewConstraints6)
        
        // Repost
        if isRepost != nil {
            let attachment1 = NSTextAttachment()
            attachment1.image = UIImage(systemName: "arrow.2.squarepath", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold))?.withTintColor(GlobalStruct.secondaryTextColor, renderingMode: .alwaysOriginal)
            attachment1.bounds = CGRect(x: 0, y: -1.5, width: attachment1.image!.size.width, height: attachment1.image!.size.height)
            let attStringNewLine000 = NSMutableAttributedString()
            let attString00 = NSAttributedString(attachment: attachment1)
            attStringNewLine000.append(attString00)
            let attributedString = NSMutableAttributedString(string: " \(resolveUser(isRepost))", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: smallestFontSize, weight: .semibold), NSAttributedString.Key.foregroundColor: GlobalStruct.secondaryTextColor])
            attStringNewLine000.append(attributedString)
            repost.setAttributedTitle(attStringNewLine000, for: .normal)
            repost.isHidden = false
        } else {
            repost.isHidden = true
        }
        
        // Post embeds
        cellStackViewConstraintQuote?.isActive = false
        var hasMedia: Bool = false
        var hasLink: Bool = false
        var hasQuote: Bool = false
        var imageWidth: Int = 0
        var imageHeight: Int = 0
        if let post = post {
            if let embed = post.embed {
                switch embed {
                case .embedImagesView(let imageEmbed):
                    if GlobalStruct.switchMedia {
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
                            mediaView.backgroundColor = UIColor(named: "groupBG")
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
                    }
                case .embedVideoView(let videoEmbed):
                    if GlobalStruct.switchMedia {
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
                    }
                case .embedExternalView(let externalEmbed):
                    // handle external gifs
                    if externalEmbed.external.uri.contains(".gif?") {
                        if GlobalStruct.switchMedia {
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
                                SDWebImageManager.shared.loadImage(
                                    with: link,
                                    options: [],
                                    progress: nil
                                ) { image, _, error, _, _, _ in
                                    if let image = image {
                                        mediaView.image = image
                                        imageWidth = Int(image.size.width)
                                        imageHeight = Int(image.size.height)
                                    } else {
                                        print("Failed to load image: \(error?.localizedDescription ?? "unknown error")")
                                    }
                                }
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
                        }
                    } else {
                        if GlobalStruct.switchLinkPreviews {
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
                                if isNestedQuote || isNestedReply {
                                    mediaView.heightAnchor.constraint(equalToConstant: 120).isActive = true
                                } else {
                                    mediaView.heightAnchor.constraint(equalToConstant: 180).isActive = true
                                }
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
                            if isNestedQuote {
                                titleLabel.numberOfLines = 1
                            } else {
                                titleLabel.numberOfLines = 2
                            }
                            
                            let descriptionLabel = UILabel()
                            if externalEmbed.external.title == "" {
                                descriptionLabel.text = externalEmbed.external.uri
                            } else {
                                descriptionLabel.text = externalEmbed.external.description.replacingOccurrences(of: "\n\n\n", with: "\n").replacingOccurrences(of: "\n\n", with: "\n")
                            }
                            descriptionLabel.font = UIFont.systemFont(ofSize: smallestFontSize, weight: .regular)
                            descriptionLabel.textColor = .secondaryText
                            if isNestedQuote {
                                descriptionLabel.numberOfLines = 2
                            } else {
                                descriptionLabel.numberOfLines = 3
                            }
                            
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
                case .embedRecordView(let record):
                    switch record.record {
                    case .viewRecord(let record):
                        if GlobalStruct.switchQuotePreviews {
                            if !isNestedQuote {
                                hasQuote = true
                                
                                if let height = GlobalStruct.quoteTableHeights[record.uri] {
                                    cellStackViewConstraintQuote = quoteTableView.heightAnchor.constraint(equalToConstant: height)
                                    cellStackViewConstraintQuote?.priority = .defaultHigh
                                    cellStackViewConstraintQuote?.isActive = true
                                }
                                
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
                            }
                        }
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
                            mediaView.backgroundColor = UIColor(named: "groupBG")
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
                        if GlobalStruct.switchMedia {
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
                        }
                    case .embedExternalView(let externalEmbed):
                        // handle external gifs
                        if externalEmbed.external.uri.contains(".gif?") {
                            if GlobalStruct.switchMedia {
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
                                    SDWebImageManager.shared.loadImage(
                                        with: link,
                                        options: [],
                                        progress: nil
                                    ) { image, _, error, _, _, _ in
                                        if let image = image {
                                            mediaView.image = image
                                            imageWidth = Int(image.size.width)
                                            imageHeight = Int(image.size.height)
                                        } else {
                                            print("Failed to load image: \(error?.localizedDescription ?? "unknown error")")
                                        }
                                    }
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
                            }
                        } else {
                            if GlobalStruct.switchLinkPreviews {
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
                                    if isNestedQuote || isNestedReply {
                                        mediaView.heightAnchor.constraint(equalToConstant: 120).isActive = true
                                    } else {
                                        mediaView.heightAnchor.constraint(equalToConstant: 180).isActive = true
                                    }
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
                                if isNestedQuote {
                                    titleLabel.numberOfLines = 1
                                } else {
                                    titleLabel.numberOfLines = 2
                                }
                                
                                let descriptionLabel = UILabel()
                                if externalEmbed.external.title == "" {
                                    descriptionLabel.text = externalEmbed.external.uri
                                } else {
                                    descriptionLabel.text = externalEmbed.external.description.replacingOccurrences(of: "\n\n\n", with: "\n").replacingOccurrences(of: "\n\n", with: "\n")
                                }
                                descriptionLabel.font = UIFont.systemFont(ofSize: smallestFontSize, weight: .regular)
                                descriptionLabel.textColor = .secondaryText
                                if isNestedQuote {
                                    descriptionLabel.numberOfLines = 2
                                } else {
                                    descriptionLabel.numberOfLines = 3
                                }
                                
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
                    }
                    switch record.record.record {
                    case .viewRecord(let record):
                        if GlobalStruct.switchQuotePreviews {
                            if !isNestedQuote {
                                hasQuote = true
                                
                                if let height = GlobalStruct.quoteTableHeights[record.uri] {
                                    cellStackViewConstraintQuote = quoteTableView.heightAnchor.constraint(equalToConstant: height)
                                    cellStackViewConstraintQuote?.priority = .defaultHigh
                                    cellStackViewConstraintQuote?.isActive = true
                                }
                                
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
                            }
                        }
                    default:
                        break
                    }
                }
            }
        }
        mediaStackView.isHidden = !hasMedia
        linkStackView.isHidden = !hasLink
        actionButtonsStackView.isHidden = !showActionButtons
        
        // quote
        if hasQuote {
            quoteTableView.isHidden = false
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[avatar(44)]-12-[quoteTableView]-18-|", options: [], metrics: nil, views: viewsDict))
        } else {
            quoteTableView.isHidden = true
        }
        if isNestedQuote {
            actionButtonsStackView.isHidden = true
            text.numberOfLines = 6
        }
        
        // hide text view if no text
        var textString: String = "-5-[text]"
        if text.text == "" {
            textString = ""
        }
        
        // media sizing
        var mediaHeight: String = "200"
        if mediaViews.count == 1 && imageWidth != 0 && imageHeight != 0 {
            let imageRatio = CGFloat(imageWidth) / CGFloat(imageHeight)
            if imageRatio >= 0.6 {
                // landscape
                // fixed width, variable height
                if isNestedQuote {
                    let theWidth: CGFloat = UIScreen.main.bounds.width - 184
                    let theHeight: CGFloat = theWidth/imageRatio
                    mediaHeight = "\(Int(theHeight))"
                } else {
                    let theWidth: CGFloat = UIScreen.main.bounds.width - 92
                    let theHeight: CGFloat = theWidth/imageRatio
                    mediaHeight = "\(Int(theHeight))"
                }
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
                if isNestedQuote {
                    let theWidth: CGFloat = UIScreen.main.bounds.width - 184
                    let theHeight: CGFloat = theWidth/videoRatio
                    mediaHeight = "\(Int(theHeight))"
                } else {
                    let theWidth: CGFloat = UIScreen.main.bounds.width - 92
                    let theHeight: CGFloat = theWidth/videoRatio
                    mediaHeight = "\(Int(theHeight))"
                }
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
            if isNestedQuote || isNestedReply {
                mediaHeight = "150"
            } else {
                mediaHeight = "200"
            }
        }
        
        // vertical layouts
        var verticalLayoutString1: String = ""
        var verticalLayoutString1b: String = ""
        if hasMedia {
            if showActionButtons && !isNestedQuote {
                if isRepost == nil {
                    if hasQuote {
                        if hasLink {
                            verticalLayoutString1 = "V:|-14-[username]-1-[usertag]\(textString)-12-[mediaStackView]-12-[linkStackView]-12-[quoteTableView]-8-[actionButtonsStackView]-10-|"
                            verticalLayoutString1b = "V:|-14-[username]-1-[usertag]\(textString)-12-[playerView]"
                        } else {
                            verticalLayoutString1 = "V:|-14-[username]-1-[usertag]\(textString)-12-[mediaStackView]-12-[quoteTableView]-8-[actionButtonsStackView]-10-|"
                            verticalLayoutString1b = "V:|-14-[username]-1-[usertag]\(textString)-12-[playerView]"
                        }
                    } else {
                        if hasLink {
                            verticalLayoutString1 = "V:|-14-[username]-1-[usertag]\(textString)-12-[mediaStackView]-12-[linkStackView]-8-[actionButtonsStackView]-10-|"
                            verticalLayoutString1b = "V:|-14-[username]-1-[usertag]\(textString)-12-[playerView]"
                        } else {
                            verticalLayoutString1 = "V:|-14-[username]-1-[usertag]\(textString)-12-[mediaStackView]-8-[actionButtonsStackView]-10-|"
                            verticalLayoutString1b = "V:|-14-[username]-1-[usertag]\(textString)-12-[playerView]"
                        }
                    }
                } else {
                    if hasQuote {
                        if hasLink {
                            verticalLayoutString1 = "V:|-14-[repost]-2-[username]-1-[usertag]\(textString)-12-[mediaStackView]-12-[linkStackView]-12-[quoteTableView]-8-[actionButtonsStackView]-10-|"
                            verticalLayoutString1b = "V:|-14-[repost]-2-[username]-1-[usertag]\(textString)-12-[playerView]"
                        } else {
                            verticalLayoutString1 = "V:|-14-[repost]-2-[username]-1-[usertag]\(textString)-12-[mediaStackView]-12-[quoteTableView]-8-[actionButtonsStackView]-10-|"
                            verticalLayoutString1b = "V:|-14-[repost]-2-[username]-1-[usertag]\(textString)-12-[playerView]"
                        }
                    } else {
                        if hasLink {
                            verticalLayoutString1 = "V:|-14-[repost]-2-[username]-1-[usertag]\(textString)-12-[mediaStackView]-12-[linkStackView]-8-[actionButtonsStackView]-10-|"
                            verticalLayoutString1b = "V:|-14-[repost]-2-[username]-1-[usertag]\(textString)-12-[playerView]"
                        } else {
                            verticalLayoutString1 = "V:|-14-[repost]-2-[username]-1-[usertag]\(textString)-12-[mediaStackView]-8-[actionButtonsStackView]-10-|"
                            verticalLayoutString1b = "V:|-14-[repost]-2-[username]-1-[usertag]\(textString)-12-[playerView]"
                        }
                    }
                }
            } else {
                if isRepost == nil {
                    if hasQuote {
                        if hasLink {
                            verticalLayoutString1 = "V:|-14-[username]-1-[usertag]\(textString)-12-[mediaStackView]-12-[linkStackView]-12-[quoteTableView]-14-|"
                            verticalLayoutString1b = "V:|-14-[username]-1-[usertag]\(textString)-12-[playerView]"
                        } else {
                            verticalLayoutString1 = "V:|-14-[username]-1-[usertag]\(textString)-12-[mediaStackView]-12-[quoteTableView]-14-|"
                            verticalLayoutString1b = "V:|-14-[username]-1-[usertag]\(textString)-12-[playerView]"
                        }
                    } else {
                        if hasLink {
                            verticalLayoutString1 = "V:|-14-[username]-1-[usertag]\(textString)-12-[mediaStackView]-12-[linkStackView]-14-|"
                            verticalLayoutString1b = "V:|-14-[username]-1-[usertag]\(textString)-12-[playerView]"
                        } else {
                            verticalLayoutString1 = "V:|-14-[username]-1-[usertag]\(textString)-12-[mediaStackView]-17-|"
                            verticalLayoutString1b = "V:|-14-[username]-1-[usertag]\(textString)-12-[playerView]"
                        }
                    }
                } else {
                    if hasQuote {
                        if hasLink {
                            verticalLayoutString1 = "V:|-14-[repost]-2-[username]-1-[usertag]\(textString)-12-[mediaStackView]-12-[linkStackView]-12-[quoteTableView]-14-|"
                            verticalLayoutString1b = "V:|-14-[repost]-2-[username]-1-[usertag]\(textString)-12-[playerView]"
                        } else {
                            verticalLayoutString1 = "V:|-14-[repost]-2-[username]-1-[usertag]\(textString)-12-[mediaStackView]-12-[quoteTableView]-14-|"
                            verticalLayoutString1b = "V:|-14-[repost]-2-[username]-1-[usertag]\(textString)-12-[playerView]"
                        }
                    } else {
                        if hasLink {
                            verticalLayoutString1 = "V:|-14-[repost]-2-[username]-1-[usertag]\(textString)-12-[mediaStackView]-12-[linkStackView]-14-|"
                            verticalLayoutString1b = "V:|-14-[repost]-2-[username]-1-[usertag]\(textString)-12-[playerView]"
                        } else {
                            verticalLayoutString1 = "V:|-14-[repost]-2-[username]-1-[usertag]\(textString)-12-[mediaStackView]-18-|"
                            verticalLayoutString1b = "V:|-14-[repost]-2-[username]-1-[usertag]\(textString)-12-[playerView]"
                        }
                    }
                }
            }
            cellStackViewConstraints7 = NSLayoutConstraint.constraints(withVisualFormat: verticalLayoutString1b, options: [], metrics: nil, views: viewsDict)
            for constraint in cellStackViewConstraints7 {
                constraint.priority = .defaultLow
            }
            NSLayoutConstraint.activate(cellStackViewConstraints7)
        } else {
            if showActionButtons && !isNestedQuote {
                if isRepost == nil {
                    if hasQuote {
                        if hasLink {
                            verticalLayoutString1 = "V:|-14-[username]-1-[usertag]\(textString)-12-[linkStackView]-12-[quoteTableView]-8-[actionButtonsStackView]-10-|"
                        } else {
                            verticalLayoutString1 = "V:|-14-[username]-1-[usertag]\(textString)-12-[quoteTableView]-8-[actionButtonsStackView]-10-|"
                        }
                    } else {
                        if hasLink {
                            verticalLayoutString1 = "V:|-14-[username]-1-[usertag]\(textString)-12-[linkStackView]-8-[actionButtonsStackView]-10-|"
                        } else {
                            verticalLayoutString1 = "V:|-14-[username]-1-[usertag]\(textString)-8-[actionButtonsStackView]-10-|"
                        }
                    }
                } else {
                    if hasQuote {
                        if hasLink {
                            verticalLayoutString1 = "V:|-14-[repost]-2-[username]-1-[usertag]\(textString)-12-[linkStackView]-12-[quoteTableView]-8-[actionButtonsStackView]-10-|"
                        } else {
                            verticalLayoutString1 = "V:|-14-[repost]-2-[username]-1-[usertag]\(textString)-12-[quoteTableView]-8-[actionButtonsStackView]-10-|"
                        }
                    } else {
                        if hasLink {
                            verticalLayoutString1 = "V:|-14-[repost]-2-[username]-1-[usertag]\(textString)-12-[linkStackView]-8-[actionButtonsStackView]-10-|"
                        } else {
                            verticalLayoutString1 = "V:|-14-[repost]-2-[username]-1-[usertag]\(textString)-8-[actionButtonsStackView]-10-|"
                        }
                    }
                }
            } else {
                if isRepost == nil {
                    if hasQuote {
                        if hasLink {
                            verticalLayoutString1 = "V:|-14-[username]-1-[usertag]\(textString)-12-[linkStackView]-12-[quoteTableView]-14-|"
                        } else {
                            verticalLayoutString1 = "V:|-14-[username]-1-[usertag]\(textString)-12-[quoteTableView]-14-|"
                        }
                    } else {
                        if hasLink {
                            verticalLayoutString1 = "V:|-14-[username]-1-[usertag]\(textString)-12-[linkStackView]-14-|"
                        } else {
                            verticalLayoutString1 = "V:|-14-[username]-1-[usertag]\(textString)-14-|"
                        }
                    }
                } else {
                    if hasQuote {
                        if hasLink {
                            verticalLayoutString1 = "V:|-14-[repost]-2-[username]-1-[usertag]\(textString)-12-[linkStackView]-12-[quoteTableView]-14-|"
                        } else {
                            verticalLayoutString1 = "V:|-14-[repost]-2-[username]-1-[usertag]\(textString)-12-[quoteTableView]-14-|"
                        }
                    } else {
                        if hasLink {
                            verticalLayoutString1 = "V:|-14-[repost]-2-[username]-1-[usertag]\(textString)-12-[linkStackView]-14-|"
                        } else {
                            verticalLayoutString1 = "V:|-14-[repost]-2-[username]-1-[usertag]\(textString)-14-|"
                        }
                    }
                }
            }
        }
        var verticalLayoutString2: String = ""
        if isRepost == nil {
            verticalLayoutString2 = "V:|-14-[avatar]"
        } else {
            verticalLayoutString2 = "V:|-14-[repost]-2-[avatar]"
        }
        var verticalLayoutString3: String = ""
        if isRepost == nil {
            verticalLayoutString3 = "V:|-14-[time]"
        } else {
            verticalLayoutString3 = "V:|-14-[repost]-2-[time]"
        }
        var verticalLayoutString4: String = ""
        if isRepost == nil {
            verticalLayoutString4 = "V:|-16-[indicatorIcon(iconDiameter)]"
        } else {
            verticalLayoutString4 = "V:|-14-[repost]-4-[indicatorIcon(iconDiameter)]"
        }
        
        if isPinned {
            indicatorIcon.isHidden = false
        } else {
            indicatorIcon.isHidden = true
        }
        
        cellStackViewConstraintMedia1?.isActive = false
        cellStackViewConstraintMedia2?.isActive = false
        cellStackViewConstraintMedia1 = mediaStackView.heightAnchor.constraint(equalToConstant: CGFloat(Int(mediaHeight) ?? 200))
        cellStackViewConstraintMedia1?.priority = .required
        cellStackViewConstraintMedia2 = playerView.heightAnchor.constraint(equalToConstant: CGFloat(Int(mediaHeight) ?? 200))
        cellStackViewConstraintMedia2?.priority = .required
        cellStackViewConstraints1 = NSLayoutConstraint.constraints(withVisualFormat: verticalLayoutString1, options: [], metrics: nil, views: viewsDict)
        cellStackViewConstraints2 = NSLayoutConstraint.constraints(withVisualFormat: verticalLayoutString2, options: [], metrics: nil, views: viewsDict)
        cellStackViewConstraints3 = NSLayoutConstraint.constraints(withVisualFormat: verticalLayoutString3, options: [], metrics: nil, views: viewsDict)
        cellStackViewConstraints4 = NSLayoutConstraint.constraints(withVisualFormat: verticalLayoutString4, options: [], metrics: metricsDict, views: viewsDict)
        for x in cellStackViewConstraints1 + cellStackViewConstraints2 + cellStackViewConstraints3 + cellStackViewConstraints4 {
            x.priority = .defaultHigh
        }
        NSLayoutConstraint.activate(cellStackViewConstraints1 + cellStackViewConstraints2 + cellStackViewConstraints3 + cellStackViewConstraints4)
        cellStackViewConstraintMedia1?.isActive = true
        cellStackViewConstraintMedia2?.isActive = true
        
        // action buttons
        if showActionButtons && !isNestedQuote {
            actionButtonRepost.menu = UIMenu(title: "", options: [], children: [createRepostButtonsMenu(post)])
            actionButtonRepost.showsMenuAsPrimaryAction = true
            
            if GlobalStruct.showActionButtonCounts {
                if fromPreview ?? false {
                    numberLabelReply.text = "24"
                    numberLabelRepost.text = "452"
                    numberLabelLike.text = "654"
                } else {
                    numberLabelReply.text = repliesCount > 0 ? "\(repliesCount.formatUsingAbbreviation())" : ""
                    numberLabelRepost.text = repostsCount > 0 ? "\(repostsCount.formatUsingAbbreviation())" : ""
                    numberLabelLike.text = likesCount > 0 ? "\(likesCount.formatUsingAbbreviation())" : ""
                }
                numberLabelReply.isHidden = false
                numberLabelRepost.isHidden = false
                numberLabelLike.isHidden = false
            } else {
                numberLabelReply.isHidden = true
                numberLabelRepost.isHidden = true
                numberLabelLike.isHidden = true
            }
            
            if let post = post {
                if post.viewer?.repostURI != nil {
                    actionButtonInsideRepost.setImage(GlobalStruct.repostImage1, for: .normal)
                } else {
                    actionButtonInsideRepost.setImage(GlobalStruct.repostImage2, for: .normal)
                }
                
                if post.viewer?.likeURI != nil {
                    actionButtonInsideLike.setImage(GlobalStruct.likeImage1, for: .normal)
                } else {
                    actionButtonInsideLike.setImage(GlobalStruct.likeImage2, for: .normal)
                }
            } else {
                actionButtonInsideRepost.setImage(GlobalStruct.repostImage2, for: .normal)
                actionButtonInsideLike.setImage(GlobalStruct.likeImage2, for: .normal)
            }
            
            actionButtonBookmark = actionButtonInsideBookmark
            
            createMoreMenu()
            
            actionButtonsStackView.addArrangedSubview(actionButtonBookmark)
            actionButtonsStackView.addArrangedSubview(actionButtonMore)
            
            if post?.viewer?.areRepliesDisabled ?? false {
                actionButtonReply.alpha = 0.4
                actionButtonReply.isUserInteractionEnabled = false
            } else {
                actionButtonReply.alpha = 1
                actionButtonReply.isUserInteractionEnabled = true
            }
        }
        
        if let post = post {
            if GlobalStruct.bookmarks.contains(post) {
                actionButtonInsideBookmark.setImage(GlobalStruct.bookmarkImage2, for: .normal)
            } else {
                actionButtonInsideBookmark.setImage(GlobalStruct.bookmarkImage1, for: .normal)
            }
        }
        
        text.customize { text in
            text.textColor = GlobalStruct.textColor
            text.mentionColor = GlobalStruct.baseTint
            text.hashtagColor = GlobalStruct.baseTint
            text.URLColor = GlobalStruct.baseTint
            text.emailColor = GlobalStruct.baseTint
        }
    }
    
    func updateQuoteView(_ quote: AppBskyLexicon.Feed.PostViewDefinition, recordURI: String) {
        DispatchQueue.main.async {
            self.quotePost = quote
            GlobalStruct.quoteTable[recordURI] = quote
            self.cellStackViewConstraintQuote?.isActive = false
            self.quoteTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            DispatchQueue.main.async {
                let height = self.quoteTableView.contentSize.height
                self.cellStackViewConstraintQuote = self.quoteTableView.heightAnchor.constraint(equalToConstant: height)
                self.cellStackViewConstraintQuote?.priority = .defaultHigh
                self.cellStackViewConstraintQuote?.isActive = true
                GlobalStruct.quoteTableHeights[recordURI] = height
                if let tableView = self.findSuperview(ofType: UITableView.self) {
                    tableView.performBatchUpdates {
                        tableView.beginUpdates()
                        tableView.endUpdates()
                    }
                }
            }
        }
    }
    
    func createMoreMenu() {
        let newMenu = UIMenu(title: "", options: [], children: [createExtrasMenu(post)] + [createViewMenu(post)] + [createShareMenu(post)] + [createReportMenu(post)])
        actionButtonInsideMore.menu = newMenu
        actionButtonInsideMore.showsMenuAsPrimaryAction = true
        actionButtonMore = actionButtonInsideMore
    }
    
    @objc func replyTapped() {
        defaultHaptics()
        let vc = ComposerViewController()
        if let post = post {
            vc.allPosts = [post]
        }
        let nvc = SloppySwipingNav(rootViewController: vc)
        nvc.isModalInPresentation = true
        getTopMostViewController()?.present(nvc, animated: true, completion: nil)
    }
    
    @objc func likeTapped(_ sender: UIButton) {
        defaultHaptics()
        if self.post?.viewer?.likeURI == nil {
            actionButtonInsideLike.setImage(GlobalStruct.likeImage1, for: .normal)
            numberLabelLike.text = "\((Int(numberLabelLike.text ?? "0") ?? 0) + 1)"
            Task {
                do {
                    if let atProto = GlobalStruct.atProto {
                        let atProtoBluesky = ATProtoBluesky(atProtoKitInstance: atProto)
                        let strongReferenceResult = try await ATProtoTools.createStrongReference(from: self.post?.uri ?? "")
                        let _ = try await atProtoBluesky.createLikeRecord(strongReferenceResult)
                        try await Task.sleep(nanoseconds: 300_000_000)
                        let y = try await atProto.getPosts([self.post?.uri ?? ""])
                        if let post = y.posts.first {
                            self.post = post
                            numberLabelLike.text = "\(self.post?.likeCount ?? 0)"
                            GlobalStruct.updatedPost = post
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "updatePost"), object: nil)
                        }
                    }
                } catch {
                    print("Error updating post: \(error)")
                }
            }
        } else {
            actionButtonInsideLike.setImage(GlobalStruct.likeImage2, for: .normal)
            numberLabelLike.text = "\((Int(numberLabelLike.text ?? "0") ?? 0) - 1)"
            Task {
                do {
                    if let atProto = GlobalStruct.atProto {
                        let atProtoBluesky = ATProtoBluesky(atProtoKitInstance: atProto)
                        let strongReferenceResult = try await ATProtoTools.createStrongReference(from: self.post?.uri ?? "")
                        let x = try await atProtoBluesky.createLikeRecord(strongReferenceResult)
                        let _ = try await atProtoBluesky.deleteLikeRecord(.recordURI(atURI: x.recordURI))
                        try await Task.sleep(nanoseconds: 300_000_000)
                        let y = try await atProto.getPosts([self.post?.uri ?? ""])
                        if let post = y.posts.first {
                            self.post = post
                            numberLabelLike.text = "\(self.post?.likeCount ?? 0)"
                            GlobalStruct.updatedPost = post
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "updatePost"), object: nil)
                        }
                    }
                } catch {
                    print("Error updating post: \(error)")
                }
            }
        }
    }
    
    @objc func bookmarkTapped(_ sender: UIButton) {
        defaultHaptics()
        if let post = post {
            if GlobalStruct.bookmarks.contains(post) {
                removeBookmark(post)
                actionButtonInsideBookmark.setImage(GlobalStruct.bookmarkImage1, for: .normal)
            } else {
                bookmark(post)
                actionButtonInsideBookmark.setImage(GlobalStruct.bookmarkImage2, for: .normal)
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
    
    // profile
    
    @objc func profileTapped(_ sender: UIButton) {
        defaultHaptics()
        let vc = ProfileViewController()
        vc.profile = nestedQuoteActorDID
        UIApplication.shared.pushToCurrentNavigationController(vc, animated: true)
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
        if let _ = interaction.view as? PlayerView {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: { self.makePreviewForVideos() }) { _ in
                createVideoMenu(self.playerView.player?.currentItem?.asset)
            }
        } else if let imageView = interaction.view as? UIImageView {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: { self.makePreviewForImages(imageView) }) { _ in
                createImageMenu(imageView)
            }
        } else if let _ = interaction.view as? UIButton {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                createMoreProfileMenu(nil, basicProfile: self.currentProfile)
            }
        } else {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                createLinkMenu(self.currentLink)
            }
        }
    }
    
    func makePreviewForVideos() -> UIViewController {
        let viewController = UIViewController()
        let player = playerView.player
        let playerLayer = AVPlayerLayer(player: player)
        var ratioS: CGFloat = 1
        if videoAspectRatioHeight == 0 {} else {
            ratioS = videoAspectRatioWidth/videoAspectRatioHeight
        }
        if videoAspectRatioHeight >= (videoAspectRatioWidth * 2) {
            playerLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2/ratioS)
            
            playerLayer.videoGravity = .resizeAspect
            viewController.view.layer.addSublayer(playerLayer)
            viewController.preferredContentSize = playerLayer.frame.size
        } else {
            playerLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width/ratioS)
            
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
            imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width/ratioS)
            imageView.contentMode = .scaleAspectFit
            viewController.preferredContentSize = imageView.frame.size
            return viewController
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
        cell.backgroundColor = GlobalStruct.detailQuoteCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        defaultHaptics()
        let vc = DetailsViewController()
        vc.detailPost = quotePost
        UIApplication.shared.pushToCurrentNavigationController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return makePostContextMenu(0, post: self.quotePost)
        }
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
