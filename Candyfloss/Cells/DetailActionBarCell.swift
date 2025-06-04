//
//  DetailActionBarCell.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 07/03/2025.
//

import Foundation
import UIKit
import ATProtoKit

class DetailActionBarCell: UITableViewCell, UISheetPresentationControllerDelegate {
    
    var bgView = UIView()
    var stackView = UIStackView()
    
    var currentPost: AppBskyLexicon.Feed.PostViewDefinition? = nil
    
    let defaultFontSize = UIFont.preferredFont(forTextStyle: .title3).pointSize
    let smallerFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
    let smallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 2
    let mostSmallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 4
    
    var actionButtonReply = UIButton()
    var actionButtonRepost = UIButton()
    var actionButtonLike = UIButton()
    var actionButtonBookmark = UIButton()
    var actionButtonMore = UIButton()
    
    var actionButtonInsideBookmark = CustomButton()
    var actionButtonInsideMore = CustomButton()
    var actionButtonInsideReply = CustomButton()
    var actionButtonInsideRepost = CustomButton()
    var actionButtonInsideLike = CustomButton()
    
    var numberLabelReply = UILabel()
    var numberLabelRepost = UILabel()
    var numberLabelLike = UILabel()
    
    var combinedStackViewReply = UIStackView()
    var combinedStackViewRepost = UIStackView()
    var combinedStackViewLike = UIStackView()
    var combinedStackViewBookmark = UIStackView()
    
    let borderLayer = CAShapeLayer()
    let borderDividerLayer = CAShapeLayer()
    
    var constraintST1: [NSLayoutConstraint] = []
    let symbolConfig1 = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // reset constraints
        NSLayoutConstraint.deactivate(constraintST1)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        borderLayer.removeFromSuperlayer()
        borderDividerLayer.removeFromSuperlayer()
        
        let cornerRadius: CGFloat = 10
        let width: CGFloat = self.contentView.frame.size.width - 20
        let height: CGFloat = 50
        
        let borderPath = UIBezierPath()
        borderPath.move(to: CGPoint(x: 0, y: 0))
        borderPath.addLine(to: CGPoint(x: 0, y: height - cornerRadius))
        borderPath.addArc(
            withCenter: CGPoint(x: cornerRadius, y: height - cornerRadius),
            radius: cornerRadius,
            startAngle: CGFloat.pi,
            endAngle: CGFloat.pi / 2,
            clockwise: false
        )
        borderPath.addLine(to: CGPoint(x: width - cornerRadius, y: height))
        borderPath.addArc(
            withCenter: CGPoint(x: width - cornerRadius, y: height - cornerRadius),
            radius: cornerRadius,
            startAngle: CGFloat.pi / 2,
            endAngle: 0,
            clockwise: false
        )
        borderPath.addLine(to: CGPoint(x: width, y: 0))
        
        borderLayer.path = borderPath.cgPath
        borderLayer.strokeColor = UIColor.gray.cgColor
        borderLayer.lineWidth = 0.35
        borderLayer.fillColor = UIColor.clear.cgColor
        
        bgView.layer.addSublayer(borderLayer)
        
        let borderPathDivider = UIBezierPath()
        borderPathDivider.move(to: CGPoint(x: 0, y: 1))
        borderPathDivider.addLine(to: CGPoint(x: width, y: 1))
        
        borderDividerLayer.path = borderPathDivider.cgPath
        borderDividerLayer.strokeColor = UIColor.gray.cgColor
        borderDividerLayer.lineWidth = 0.35
        borderDividerLayer.fillColor = UIColor.clear.cgColor
        
        bgView.layer.addSublayer(borderDividerLayer)
        
        contentView.layer.masksToBounds = false
        contentView.clipsToBounds = false
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // background view
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.backgroundColor = GlobalStruct.detailQuoteCell
        bgView.layer.cornerRadius = 10
        bgView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        contentView.addSubview(bgView)
        
        // other elements
        
        NSLayoutConstraint.deactivate(self.constraintST1)
        
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
        
        combinedStackViewBookmark.translatesAutoresizingMaskIntoConstraints = false
        combinedStackViewBookmark.addArrangedSubview(actionButtonInsideBookmark)
        combinedStackViewBookmark.axis = .horizontal
        combinedStackViewBookmark.alignment = .center
        combinedStackViewBookmark.spacing = 4
        actionButtonBookmark.addSubview(combinedStackViewBookmark)
        actionButtonBookmark.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            combinedStackViewBookmark.centerXAnchor.constraint(equalTo: actionButtonBookmark.centerXAnchor),
            combinedStackViewBookmark.centerYAnchor.constraint(equalTo: actionButtonBookmark.centerYAnchor)
        ])
        
        numberLabelReply.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        numberLabelRepost.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        numberLabelLike.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        
        actionButtonInsideReply.setImage(UIImage(systemName: "arrowshape.turn.up.left", withConfiguration: symbolConfig1)?.withTintColor(GlobalStruct.secondaryTextColor, renderingMode: .alwaysOriginal), for: .normal)
        actionButtonInsideReply.contentMode = .scaleAspectFit
        actionButtonInsideReply.imageView?.contentMode = .scaleAspectFit
        actionButtonInsideReply.backgroundColor = .clear
        actionButtonInsideReply.addTarget(self, action: #selector(replyTapped), for: .touchUpInside)
        actionButtonInsideReply.showsMenuAsPrimaryAction = false
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressedReply))
        longPressRecognizer.minimumPressDuration = 0.27
        actionButtonInsideReply.addGestureRecognizer(longPressRecognizer)
        
        actionButtonInsideRepost.setImage(UIImage(systemName: "arrow.2.squarepath", withConfiguration: symbolConfig1)?.withTintColor(GlobalStruct.secondaryTextColor, renderingMode: .alwaysOriginal), for: .normal)
        actionButtonInsideRepost.contentMode = .scaleAspectFit
        actionButtonInsideRepost.imageView?.contentMode = .scaleAspectFit
        actionButtonInsideRepost.backgroundColor = .clear
        
        actionButtonInsideLike.setImage(UIImage(systemName: "heart", withConfiguration: symbolConfig1)?.withTintColor(GlobalStruct.secondaryTextColor, renderingMode: .alwaysOriginal), for: .normal)
        actionButtonInsideLike.contentMode = .scaleAspectFit
        actionButtonInsideLike.imageView?.contentMode = .scaleAspectFit
        actionButtonInsideLike.backgroundColor = .clear
        actionButtonInsideLike.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        actionButtonInsideLike.showsMenuAsPrimaryAction = false
        
        actionButtonInsideBookmark.setImage(UIImage(systemName: "bookmark", withConfiguration: symbolConfig1)?.withTintColor(GlobalStruct.secondaryTextColor, renderingMode: .alwaysOriginal), for: .normal)
        actionButtonInsideBookmark.contentMode = .scaleAspectFit
        actionButtonInsideBookmark.imageView?.contentMode = .scaleAspectFit
        actionButtonInsideBookmark.backgroundColor = .clear
        actionButtonInsideBookmark.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
        actionButtonInsideBookmark.backgroundColor = .clear
        
        actionButtonInsideMore.setImage(UIImage(systemName: "ellipsis", withConfiguration: symbolConfig1)?.withTintColor(GlobalStruct.secondaryTextColor, renderingMode: .alwaysOriginal), for: .normal)
        actionButtonInsideMore.contentMode = .scaleAspectFit
        actionButtonInsideMore.imageView?.contentMode = .scaleAspectFit
        actionButtonInsideMore.backgroundColor = .clear
        
        // layouts
        let viewsDict = [
            "bgView" : bgView,
        ]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[bgView]-10-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[bgView(50)]-20-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func longPressedReply(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            if GlobalStruct.switchHaptics {
                let haptics = UIImpactFeedbackGenerator(style: .medium)
                haptics.impactOccurred()
            }
        }
    }
    
    func makeCM(_ theButton: UIButton, index: Int) {
        
    }
    
    func setupButtons(_ post: AppBskyLexicon.Feed.PostViewDefinition? = nil) {
        self.currentPost = post
        
        if let post = currentPost {
            if GlobalStruct.bookmarks.contains(post) {
                actionButtonInsideBookmark.setImage(UIImage(systemName: "bookmark.fill", withConfiguration: symbolConfig1)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), for: .normal)
            } else {
                actionButtonInsideBookmark.setImage(UIImage(systemName: "bookmark", withConfiguration: symbolConfig1)?.withTintColor(GlobalStruct.secondaryTextColor, renderingMode: .alwaysOriginal), for: .normal)
            }
        }
        
        numberLabelReply.text = post?.replyCount ?? 0 > 0 ? "\((post?.replyCount ?? 0).formatUsingAbbreviation())" : ""
        numberLabelReply.textColor = GlobalStruct.secondaryTextColor
        
        actionButtonInsideRepost.tag = Int(post?.id ?? "0") ?? 0
        if currentPost?.viewer?.repostURI == nil {
            actionButtonInsideRepost.setImage(UIImage(systemName: "arrow.2.squarepath", withConfiguration: symbolConfig1)?.withTintColor(GlobalStruct.secondaryTextColor, renderingMode: .alwaysOriginal), for: .normal)
        } else {
            actionButtonInsideRepost.setImage(UIImage(systemName: "arrow.2.squarepath", withConfiguration: symbolConfig1)?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal), for: .normal)
        }
        makeCM(actionButtonInsideRepost, index: 2)
        numberLabelRepost.text = post?.repostCount ?? 0 > 0 ? "\((post?.repostCount ?? 0).formatUsingAbbreviation())" : ""
        numberLabelRepost.textColor = GlobalStruct.secondaryTextColor
        actionButtonInsideRepost.menu = UIMenu(title: "", options: [], children: [createRepostButtonsMenu(post)])
        actionButtonInsideRepost.showsMenuAsPrimaryAction = true
        
        actionButtonInsideLike.tag = Int(post?.id ?? "0") ?? 0
        if currentPost?.viewer?.likeURI == nil {
            actionButtonInsideLike.setImage(UIImage(systemName: "heart", withConfiguration: symbolConfig1)?.withTintColor(GlobalStruct.secondaryTextColor, renderingMode: .alwaysOriginal), for: .normal)
        } else {
            actionButtonInsideLike.setImage(UIImage(systemName: "heart.fill", withConfiguration: symbolConfig1)?.withTintColor(.systemPink, renderingMode: .alwaysOriginal), for: .normal)
        }
        makeCM(actionButtonInsideLike, index: 3)
        numberLabelLike.text = post?.likeCount ?? 0 > 0 ? "\((post?.likeCount ?? 0).formatUsingAbbreviation())" : ""
        numberLabelLike.textColor = GlobalStruct.secondaryTextColor
        
        actionButtonMore = createButtonWithMenu(image: "ellipsis", action: #selector(moreTapped), post: post)
        
        if post?.viewer?.areRepliesDisabled ?? false {
            actionButtonReply.alpha = 0.4
            actionButtonReply.isUserInteractionEnabled = false
        } else {
            actionButtonReply.alpha = 1
            actionButtonReply.isUserInteractionEnabled = true
        }
        
        stackView.removeFromSuperview()
        stackView = UIStackView(arrangedSubviews: [actionButtonReply, actionButtonRepost, actionButtonLike, actionButtonBookmark, actionButtonMore])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        let viewsDict = [
            "stackView" : stackView,
        ]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-35-[stackView]-35-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-13-[stackView]-30-|", options: [], metrics: nil, views: viewsDict))
        
        self.constraintST1 = [stackView.heightAnchor.constraint(equalToConstant: 50)]
        for x in self.constraintST1 {
            x.priority = .defaultHigh
        }
        NSLayoutConstraint.activate(constraintST1)
    }
    
    private func createButtonWithMenu(image: String, action: Selector, post: AppBskyLexicon.Feed.PostViewDefinition? = nil) -> UIButton {
        let newMenu = UIMenu(title: "", options: [], children: [createExtrasMenu(post)] + [createViewMenu(post)] + [createShareMenu(post)] + [createReportMenu(post)])
        actionButtonInsideMore.menu = newMenu
        actionButtonInsideMore.showsMenuAsPrimaryAction = true
        return actionButtonInsideMore
    }
    
    private func deletePost(_ post: AppBskyLexicon.Feed.PostViewDefinition? = nil) {
        
    }
    
    @objc func replyTapped() {
        defaultHaptics()
        let vc = ComposerViewController()
        if let post = currentPost {
            vc.allPosts = [post]
        }
        let nvc = SloppySwipingNav(rootViewController: vc)
        nvc.isModalInPresentation = true
        getTopMostViewController()?.present(nvc, animated: true, completion: nil)
    }
    
    @objc func likeTapped(_ sender: UIButton) {
        defaultHaptics()
        if currentPost?.viewer?.likeURI == nil {
            actionButtonInsideLike.setImage(UIImage(systemName: "heart.fill", withConfiguration: symbolConfig1)?.withTintColor(.systemPink, renderingMode: .alwaysOriginal), for: .normal)
            numberLabelLike.text = "\((Int(numberLabelLike.text ?? "0") ?? 0) + 1)"
            Task {
                do {
                    if let atProto = GlobalStruct.atProto {
                        let atProtoBluesky = ATProtoBluesky(atProtoKitInstance: atProto)
                        let strongReferenceResult = try await ATProtoTools.createStrongReference(from: currentPost?.uri ?? "")
                        let _ = try await atProtoBluesky.createLikeRecord(strongReferenceResult)
                        try await Task.sleep(nanoseconds: 300_000_000)
                        let y = try await atProto.getPosts([currentPost?.uri ?? ""])
                        if let post = y.posts.first {
                            currentPost = post
                            numberLabelLike.text = "\(currentPost?.likeCount ?? 0)"
                            GlobalStruct.updatedPost = post
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "updatePost"), object: nil)
                        }
                    }
                } catch {
                    print("Error updating post: \(error)")
                }
            }
        } else {
            actionButtonInsideLike.setImage(UIImage(systemName: "heart", withConfiguration: symbolConfig1)?.withTintColor(GlobalStruct.secondaryTextColor, renderingMode: .alwaysOriginal), for: .normal)
            numberLabelLike.text = "\((Int(numberLabelLike.text ?? "0") ?? 0) - 1)"
            Task {
                do {
                    if let atProto = GlobalStruct.atProto {
                        let atProtoBluesky = ATProtoBluesky(atProtoKitInstance: atProto)
                        let strongReferenceResult = try await ATProtoTools.createStrongReference(from: currentPost?.uri ?? "")
                        let x = try await atProtoBluesky.createLikeRecord(strongReferenceResult)
//                        let _ = try await atProtoBluesky.deleteLikeRecord(.recordURI(atURI: x.recordURI))
                        
//                        let _ = try await atProtoBluesky.deleteRecord(x.recordURI)
                        
//                        let session = try await GlobalStruct.atProto?.getUserSession()
//                        let recordKey = try ATProtoTools().parseURI(x.recordURI).recordKey
//                        _ = try await atProto.deleteRecord(repositoryDID: session?.sessionDID ?? "", collection: "app.bsky.feed.like", recordKey: recordKey)
                        
                        try await Task.sleep(nanoseconds: 300_000_000)
                        let y = try await atProto.getPosts([currentPost?.uri ?? ""])
                        if let post = y.posts.first {
                            currentPost = post
                            numberLabelLike.text = "\(currentPost?.likeCount ?? 0)"
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
        if let post = currentPost {
            if GlobalStruct.bookmarks.contains(post) {
                removeBookmark(post)
                actionButtonInsideBookmark.setImage(UIImage(systemName: "bookmark", withConfiguration: symbolConfig1)?.withTintColor(GlobalStruct.secondaryTextColor, renderingMode: .alwaysOriginal), for: .normal)
            } else {
                bookmark(post)
                actionButtonInsideBookmark.setImage(UIImage(systemName: "bookmark.fill", withConfiguration: symbolConfig1)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), for: .normal)
            }
        }
    }
    
    @objc func moreTapped() {
        defaultHaptics()
    }
    
}

