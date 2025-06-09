//
//  ProfileHeaderCell.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 07/03/2025.
//

import Foundation
import UIKit
import Vision
import SafariServices
import MessageUI
import ATProtoKit

class ProfileHeaderCell: UITableViewCell, MFMailComposeViewControllerDelegate, UIContextMenuInteractionDelegate {
    
    var currentProfile: AppBskyLexicon.Actor.ProfileViewDetailedDefinition? = nil
    var mutuals: [AppBskyLexicon.Actor.ProfileViewDefinition] = []
    
    var bgView = UIView()
    
    var headerImage = UIButton()
    var avatar = UIButton()
    var username = UILabel()
    var usertag = UIButton()
    var followsYouTag = UIButton()
    var statsStackView = UIStackView()
    var bio = ActiveLabel()
    var joinedDate = UILabel()
    var moreButton = UIButton()
    var followingButton = UIButton()
    
    var avatar1 = UIButton()
    var avatar2 = UIButton()
    var avatar3 = UIButton()
    var avatarText = UIButton()
    
    var divider0 = UIView()
    var divider1 = UIView()
    
    // mail
    var emailAddress: String = ""
    
    var constraintST1: [NSLayoutConstraint] = []
    
    let defaultFontSize = UIFont.preferredFont(forTextStyle: .title3).pointSize
    let biggestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize + 6
    let biggerFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize + 4
    let smallerFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
    let smallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 2
    let mostSmallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 4
    
    let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.backgroundColor = GlobalStruct.detailQuoteCell
        bgView.layer.cornerRadius = 10
        bgView.layer.borderColor = UIColor.gray.cgColor
        bgView.layer.borderWidth = 0.35
        contentView.addSubview(bgView)
        
        headerImage.translatesAutoresizingMaskIntoConstraints = false
        headerImage.backgroundColor = GlobalStruct.modalBackground
        headerImage.imageView?.contentMode = .scaleAspectFill
        headerImage.imageView?.layer.masksToBounds = true
        headerImage.contentHorizontalAlignment = .fill
        headerImage.contentVerticalAlignment = .fill
        headerImage.layer.masksToBounds = true
        headerImage.adjustsImageWhenHighlighted = false
        headerImage.layer.cornerRadius = 10
        headerImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let interaction = UIContextMenuInteraction(delegate: self)
        headerImage.addInteraction(interaction)
        bgView.addSubview(headerImage)
        
        divider0.translatesAutoresizingMaskIntoConstraints = false
        divider0.backgroundColor = UIColor.gray
        bgView.addSubview(divider0)
        
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.backgroundColor = GlobalStruct.detailQuoteCell
        avatar.layer.borderWidth = 4
        avatar.layer.borderColor = GlobalStruct.detailQuoteCell.cgColor
        avatar.layer.cornerRadius = 80
        avatar.imageView?.contentMode = .scaleAspectFill
        avatar.imageView?.layer.masksToBounds = true
        avatar.contentHorizontalAlignment = .fill
        avatar.contentVerticalAlignment = .fill
        avatar.layer.masksToBounds = true
        avatar.adjustsImageWhenHighlighted = false
        let interaction2 = UIContextMenuInteraction(delegate: self)
        avatar.addInteraction(interaction2)
        bgView.addSubview(avatar)
        
        username.translatesAutoresizingMaskIntoConstraints = false
        username.textColor = .label
        username.textAlignment = .left
        username.font = UIFont.systemFont(ofSize: biggestFontSize + GlobalStruct.customTextSize, weight: .bold)
        bgView.addSubview(username)
        
        usertag.translatesAutoresizingMaskIntoConstraints = false
        usertag.setTitleColor(GlobalStruct.secondaryTextColor, for: .normal)
        usertag.titleLabel?.textAlignment = .left
        usertag.titleLabel?.font = UIFont.systemFont(ofSize: biggerFontSize + GlobalStruct.customTextSize, weight: .regular)
        usertag.contentHorizontalAlignment = .left
        bgView.addSubview(usertag)
        
        followsYouTag.translatesAutoresizingMaskIntoConstraints = false
        followsYouTag.setTitle("   Follows You   ", for: .normal)
        followsYouTag.setTitleColor(.white, for: .normal)
        followsYouTag.titleLabel?.font = UIFont.systemFont(ofSize: mostSmallestFontSize + GlobalStruct.customTextSize, weight: .semibold)
        followsYouTag.backgroundColor = GlobalStruct.baseTint
        followsYouTag.layer.cornerRadius = (mostSmallestFontSize + 10) / 2
        followsYouTag.alpha = 0
        bgView.addSubview(followsYouTag)
        
        statsStackView.translatesAutoresizingMaskIntoConstraints = false
        statsStackView.axis = .horizontal
        statsStackView.alignment = .fill
        statsStackView.distribution = .fillEqually
        statsStackView.spacing = 0
        bgView.addSubview(statsStackView)
        NSLayoutConstraint.activate([
            statsStackView.heightAnchor.constraint(equalToConstant: smallestFontSize + biggestFontSize + GlobalStruct.customTextSize + GlobalStruct.customTextSize + 40)
        ])
        
        bio.customize { bio in
            bio.translatesAutoresizingMaskIntoConstraints = false
            bio.textColor = GlobalStruct.textColor
            bio.textAlignment = .left
            bio.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
            bio.numberOfLines = 0
            bio.enabledTypes = [.mention, .hashtag, .url, .email]
            bio.mentionColor = GlobalStruct.baseTint
            bio.hashtagColor = GlobalStruct.baseTint
            bio.URLColor = GlobalStruct.baseTint
            bio.emailColor = GlobalStruct.baseTint
            bio.urlMaximumLength = 40
            bgView.addSubview(bio)
        }
        bio.handleMentionTap { (str) in
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
        bio.handleHashtagTap { (str) in
            defaultHaptics()
            let vc = HashtagViewController()
            vc.hashtag = str
            UIApplication.shared.pushToCurrentNavigationController(vc, animated: true)
        }
        bio.handleURLTap { (str) in
            defaultHaptics()
            if GlobalStruct.openLinksInApp {
                if str.absoluteString.contains("https://") {
                    let safariVC = SFSafariViewController(url: str)
                    getTopMostViewController()?.present(safariVC, animated: true, completion: nil)
                } else {
                    var newStr1 = str.absoluteString
                    if newStr1.last == "." {
                        newStr1 = "\(newStr1.dropLast())"
                    }
                    if let newStr2 = URL(string: "https://\(newStr1)") {
                        let safariVC = SFSafariViewController(url: newStr2)
                        getTopMostViewController()?.present(safariVC, animated: true, completion: nil)
                    }
                }
            } else {
                if str.absoluteString.contains("https://") {
                    UIApplication.shared.open(str, options: [:], completionHandler: nil)
                } else {
                    var newStr1 = str.absoluteString
                    if newStr1.last == "." {
                        newStr1 = "\(newStr1.dropLast())"
                    }
                    if let newStr2 = URL(string: "https://\(newStr1)") {
                        UIApplication.shared.open(newStr2, options: [:], completionHandler: nil)
                    }
                }
            }
        }
        bio.handleEmailTap { (str) in
            defaultHaptics()
            self.emailAddress = str
            self.goToMail()
        }
        
        joinedDate.translatesAutoresizingMaskIntoConstraints = false
        joinedDate.textColor = GlobalStruct.secondaryTextColor
        joinedDate.textAlignment = .left
        joinedDate.font = UIFont.systemFont(ofSize: smallestFontSize + GlobalStruct.customTextSize, weight: .regular)
        joinedDate.numberOfLines = 0
        bgView.addSubview(joinedDate)
        
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.setImage(UIImage(systemName: "ellipsis", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.textColor, renderingMode: .alwaysOriginal), for: .normal)
        moreButton.contentHorizontalAlignment = .center
        moreButton.backgroundColor = UIColor(named: "followButtonBG")
        moreButton.layer.cornerRadius = 17.5
        moreButton.alpha = 0
        bgView.addSubview(moreButton)
        
        followingButton.translatesAutoresizingMaskIntoConstraints = false
        followingButton.titleLabel?.textAlignment = .center
        followingButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        followingButton.contentHorizontalAlignment = .center
        followingButton.setTitleColor(.white, for: .normal)
        followingButton.backgroundColor = GlobalStruct.baseTint
        followingButton.layer.cornerRadius = 17.5
        followingButton.layer.cornerCurve = .continuous
        followingButton.alpha = 0
        bgView.addSubview(followingButton)
        
        avatar1.translatesAutoresizingMaskIntoConstraints = false
        avatar1.backgroundColor = GlobalStruct.pollBar.withAlphaComponent(0.25)
        avatar1.layer.borderWidth = 2.6
        avatar1.layer.borderColor = GlobalStruct.detailQuoteCell.cgColor
        avatar1.layer.cornerRadius = 16
        avatar1.imageView?.contentMode = .scaleAspectFill
        avatar1.imageView?.layer.masksToBounds = true
        avatar1.layer.masksToBounds = true
        avatar1.alpha = 0
        avatar1.addTarget(self, action: #selector(self.mutualsTapped), for: .touchUpInside)
        bgView.addSubview(avatar1)
        
        avatar2.translatesAutoresizingMaskIntoConstraints = false
        avatar2.backgroundColor = GlobalStruct.pollBar.withAlphaComponent(0.25)
        avatar2.layer.borderWidth = 2.6
        avatar2.layer.borderColor = GlobalStruct.detailQuoteCell.cgColor
        avatar2.layer.cornerRadius = 16
        avatar2.imageView?.contentMode = .scaleAspectFill
        avatar2.imageView?.layer.masksToBounds = true
        avatar2.layer.masksToBounds = true
        avatar2.alpha = 0
        avatar2.addTarget(self, action: #selector(self.mutualsTapped), for: .touchUpInside)
        bgView.addSubview(avatar2)
        
        avatar3.translatesAutoresizingMaskIntoConstraints = false
        avatar3.backgroundColor = GlobalStruct.pollBar.withAlphaComponent(0.25)
        avatar3.layer.borderWidth = 2.6
        avatar3.layer.borderColor = GlobalStruct.detailQuoteCell.cgColor
        avatar3.layer.cornerRadius = 16
        avatar3.imageView?.contentMode = .scaleAspectFill
        avatar3.imageView?.layer.masksToBounds = true
        avatar3.layer.masksToBounds = true
        avatar3.alpha = 0
        avatar3.addTarget(self, action: #selector(self.mutualsTapped), for: .touchUpInside)
        bgView.addSubview(avatar3)
        
        avatarText.translatesAutoresizingMaskIntoConstraints = false
        avatarText.setTitleColor(.secondaryText, for: .normal)
        avatarText.contentHorizontalAlignment = .left
        avatarText.titleLabel?.textAlignment = .left
        avatarText.titleLabel?.font = UIFont.systemFont(ofSize: smallestFontSize + GlobalStruct.customTextSize, weight: .regular)
        avatarText.titleLabel?.numberOfLines = 2
        avatarText.addTarget(self, action: #selector(self.mutualsTapped), for: .touchUpInside)
        bgView.addSubview(avatarText)
        
        divider1.translatesAutoresizingMaskIntoConstraints = false
        divider1.backgroundColor = UIColor.gray
        bgView.addSubview(divider1)
        
        let viewsDict = [
            "bgView" : bgView,
            "headerImage" : headerImage,
            "avatar" : avatar,
            "divider0" : divider0,
            "username" : username,
            "usertag" : usertag,
            "followsYouTag" : followsYouTag,
            "statsStackView" : statsStackView,
            "bio" : bio,
            "joinedDate" : joinedDate,
            "moreButton" : moreButton,
            "followingButton" : followingButton,
            "avatar1" : avatar1,
            "avatar2" : avatar2,
            "avatar3" : avatar3,
            "avatarText" : avatarText,
            "divider1" : divider1,
        ]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[bgView]-10-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[bgView]-20-|", options: [], metrics: nil, views: viewsDict))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[headerImage(154)]", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[headerImage]-0-|", options: [], metrics: nil, views: viewsDict))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-154-[divider0(0.18)]", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[divider0]-0-|", options: [], metrics: nil, views: viewsDict))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-42-[avatar2(32)]", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-64-[avatar3(32)]", options: [], metrics: nil, views: viewsDict))
        
        constraintST1 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-50-[avatar(160)]-12-[username]-(-5)-[usertag]-5-[bio]-12-[joinedDate]-18-|", options: [], metrics: nil, views: viewsDict)
        for x in constraintST1 {
            x.priority = .defaultHigh
        }
        NSLayoutConstraint.activate(constraintST1)
        
        if GlobalStruct.profilePagePicAlignment == 0 {
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[avatar(160)]", options: [], metrics: nil, views: viewsDict))
            avatar.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        } else {
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[avatar(160)]", options: [], metrics: nil, views: viewsDict))
        }
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[username]-20-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[usertag]-20-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[followsYouTag]-(>=20)-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[bio]-20-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[joinedDate]-20-|", options: [], metrics: nil, views: viewsDict))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[divider1]-0-|", options: [], metrics: nil, views: viewsDict))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-170-[moreButton(35)]", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-170-[followingButton(35)]", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[followingButton(100)]-12-[moreButton(35)]-20-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(followersCount: String, followingCount: String, postsCount: String, followsYou: Bool = false, following: String? = nil, currentProfile: AppBskyLexicon.Actor.ProfileViewDetailedDefinition?, mutuals: [AppBskyLexicon.Actor.ProfileViewDefinition]) {
        self.currentProfile = currentProfile
        self.mutuals = mutuals
        
        let button1 = createButton(title: "Followers", subtext: followersCount, style: 0)
        let button2 = createButton(title: "Following", subtext: followingCount, style: 1)
        var postText: String = "Posts"
        if postsCount == "1" {
            postText = "Post"
        }
        let button3 = createButton(title: postText, subtext: postsCount, style: 2)
        
        statsStackView.removeAllArrangedSubviews()
        statsStackView.addArrangedSubview(button1)
        statsStackView.addArrangedSubview(button2)
        statsStackView.addArrangedSubview(button3)
        
        moreButton.menu = createMoreProfileMenu(currentProfile)
        moreButton.showsMenuAsPrimaryAction = true
        
        followingButton.menu = nil
        followingButton.showsMenuAsPrimaryAction = false
        followingButton.removeTarget(self, action: #selector(self.followUser), for: .touchUpInside)
        if following != nil {
            followingButton.setTitle("Following", for: .normal)
            followingButton.setTitleColor(GlobalStruct.textColor, for: .normal)
            followingButton.backgroundColor = UIColor(named: "followButtonBG")
            followingButton.menu = createUnfollowMenu()
            followingButton.showsMenuAsPrimaryAction = true
        } else {
            followingButton.setTitle("Follow", for: .normal)
            followingButton.setTitleColor(.white, for: .normal)
            followingButton.backgroundColor = GlobalStruct.baseTint
            followingButton.addTarget(self, action: #selector(self.followUser), for: .touchUpInside)
        }
        
        if mutuals.count > 0 {
            let symbolConfig1 = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
            let avatarImage = UIImage(systemName: "person.fill", withConfiguration: symbolConfig1)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            avatar1.alpha = 1
            if let url = mutuals.first?.avatarImageURL {
                avatar1.sd_setImage(with: url, for: .normal)
                avatar1.backgroundColor = GlobalStruct.detailQuoteCell
            } else {
                avatar1.setImage(avatarImage, for: .normal)
                avatar1.backgroundColor = GlobalStruct.baseTint
            }
            if mutuals.count > 1 {
                avatar2.alpha = 1
                if let url = mutuals[1].avatarImageURL {
                    avatar2.sd_setImage(with: url, for: .normal)
                    avatar2.backgroundColor = GlobalStruct.detailQuoteCell
                } else {
                    avatar2.setImage(avatarImage, for: .normal)
                    avatar2.backgroundColor = GlobalStruct.baseTint
                }
                if mutuals.count > 2 {
                    avatar3.alpha = 1
                    if let url = mutuals[2].avatarImageURL {
                        avatar3.sd_setImage(with: url, for: .normal)
                        avatar3.backgroundColor = GlobalStruct.detailQuoteCell
                    } else {
                        avatar3.setImage(avatarImage, for: .normal)
                        avatar3.backgroundColor = GlobalStruct.baseTint
                    }
                }
            }
            if mutuals.count == 1 {
                avatarText.setTitle("Followed by \(resolveUser(mutuals.first).trimmingCharacters(in: .whitespacesAndNewlines))", for: .normal)
            } else if mutuals.count == 2 {
                avatarText.setTitle("Followed by \(resolveUser(mutuals.first).trimmingCharacters(in: .whitespacesAndNewlines)) and \(resolveUser(mutuals[1]).trimmingCharacters(in: .whitespacesAndNewlines))", for: .normal)
            } else if mutuals.count == 3 {
                avatarText.setTitle("Followed by \(resolveUser(mutuals.first).trimmingCharacters(in: .whitespacesAndNewlines)), \(resolveUser(mutuals[1]).trimmingCharacters(in: .whitespacesAndNewlines)), and \(resolveUser(mutuals[2]).trimmingCharacters(in: .whitespacesAndNewlines))", for: .normal)
            } else {
                avatarText.setTitle("Followed by \(resolveUser(mutuals.first).trimmingCharacters(in: .whitespacesAndNewlines)), \(resolveUser(mutuals[1]).trimmingCharacters(in: .whitespacesAndNewlines)), and \(mutuals.count - 1) others", for: .normal)
            }
        }
        
        if followsYou {
            followsYouTag.alpha = 1
        } else {
            followsYouTag.alpha = 0
        }
        let viewsDict = [
            "bgView" : bgView,
            "headerImage" : headerImage,
            "avatar" : avatar,
            "username" : username,
            "usertag" : usertag,
            "followsYouTag" : followsYouTag,
            "statsStackView" : statsStackView,
            "bio" : bio,
            "joinedDate" : self.joinedDate,
            "followingButton" : followingButton,
            "avatar1" : avatar1,
            "avatar2" : avatar2,
            "avatar3" : avatar3,
            "avatarText" : avatarText,
            "divider1" : divider1,
        ]
        let metricsDict: [String: Any] = [
            "height" : mostSmallestFontSize + 10
        ]
        NSLayoutConstraint.deactivate(constraintST1)
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[statsStackView]-0-|", options: [], metrics: nil, views: viewsDict))
        if mutuals.count == 1 {
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[avatar1(32)]-6-[avatarText]-20-|", options: [], metrics: nil, views: viewsDict))
        } else if mutuals.count == 2 {
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[avatar1(32)]", options: [], metrics: nil, views: viewsDict))
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[avatar2(32)]-12-[avatarText]-20-|", options: [], metrics: nil, views: viewsDict))
        } else {
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[avatar1(32)]", options: [], metrics: nil, views: viewsDict))
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[avatar3(32)]-12-[avatarText]-20-|", options: [], metrics: nil, views: viewsDict))
        }
        if mutuals.isEmpty {
            if bio.text == "" {
                if followsYou {
                    constraintST1 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-50-[avatar(160)]-12-[username]-(-5)-[usertag]-6-[followsYouTag(height)]-0-[statsStackView]-8-[joinedDate]-16-|", options: [], metrics: metricsDict, views: viewsDict)
                } else {
                    constraintST1 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-50-[avatar(160)]-12-[username]-(-5)-[usertag]-(-5)-[statsStackView]-8-[joinedDate]-16-|", options: [], metrics: nil, views: viewsDict)
                }
            } else {
                if followsYou {
                    constraintST1 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-50-[avatar(160)]-12-[username]-(-5)-[usertag]-6-[followsYouTag(height)]-0-[statsStackView]-8-[bio]-12-[joinedDate]-16-|", options: [], metrics: metricsDict, views: viewsDict)
                } else {
                    constraintST1 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-50-[avatar(160)]-12-[username]-(-5)-[usertag]-(-5)-[statsStackView]-8-[bio]-12-[joinedDate]-16-|", options: [], metrics: nil, views: viewsDict)
                }
            }
        } else {
            if bio.text == "" {
                if followsYou {
                    constraintST1 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-50-[avatar(160)]-12-[username]-(-5)-[usertag]-6-[followsYouTag(height)]-0-[statsStackView]-8-[joinedDate]-14-[divider1(0.18)]-14-[avatarText]-13-|", options: [], metrics: metricsDict, views: viewsDict)
                } else {
                    constraintST1 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-50-[avatar(160)]-12-[username]-(-5)-[usertag]-(-5)-[statsStackView]-8-[joinedDate]-14-[divider1(0.18)]-14-[avatarText]-13-|", options: [], metrics: nil, views: viewsDict)
                }
            } else {
                if followsYou {
                    constraintST1 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-50-[avatar(160)]-12-[username]-(-5)-[usertag]-6-[followsYouTag(height)]-0-[statsStackView]-8-[bio]-12-[joinedDate]-14-[divider1(0.18)]-14-[avatarText]-13-|", options: [], metrics: metricsDict, views: viewsDict)
                } else {
                    constraintST1 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-50-[avatar(160)]-12-[username]-(-5)-[usertag]-(-5)-[statsStackView]-8-[bio]-12-[joinedDate]-14-[divider1(0.18)]-14-[avatarText]-13-|", options: [], metrics: nil, views: viewsDict)
                }
            }
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[avatar1(32)]-12-|", options: [], metrics: nil, views: viewsDict))
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[avatar2(32)]-12-|", options: [], metrics: nil, views: viewsDict))
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[avatar3(32)]-12-|", options: [], metrics: nil, views: viewsDict))
        }
        NSLayoutConstraint.activate(constraintST1)
    }
    
    func createUnfollowMenu() -> UIMenu {
        var menuActions: [UIAction] = []
        let unfollow = UIAction(title: "Unfollow", image: UIImage(systemName: "person.slash"), identifier: nil) { action in
            self.unfollowUser()
        }
        unfollow.attributes = .destructive
        menuActions.append(unfollow)
        return UIMenu(title: "", options: [.displayInline], children: menuActions)
    }
    
    func unfollowUser() {
        defaultHaptics()
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    let atProtoBluesky = ATProtoBluesky(atProtoKitInstance: atProto)
                    let followRecord = try await atProtoBluesky.createFollowRecord(actorDID: self.currentProfile?.actorDID ?? "")
//                    _ = try await atProtoBluesky.deleteFollowRecord(.recordURI(atURI: followRecord.recordURI))
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateProfileHeader"), object: nil)
                    }
                }
            } catch {
                print("Error unfollowing user: \(error)")
            }
        }
    }
    
    @objc func followUser() {
        defaultHaptics()
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    let atProtoBluesky = ATProtoBluesky(atProtoKitInstance: atProto)
                    _ = try await atProtoBluesky.createFollowRecord(actorDID: currentProfile?.actorDID ?? "")
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateProfileHeader"), object: nil)
                    }
                }
            } catch {
                print("Error following user: \(error)")
            }
        }
    }
    
    private func createButton(title: String, subtext: String, style: Int) -> UIButton {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = GlobalStruct.secondaryTextColor
        titleLabel.font = UIFont.systemFont(ofSize: smallestFontSize + GlobalStruct.customTextSize, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.isUserInteractionEnabled = false
        
        let subtextLabel = UILabel()
        subtextLabel.text = subtext
        subtextLabel.textColor = .label
        subtextLabel.font = UIFont.systemFont(ofSize: biggestFontSize + GlobalStruct.customTextSize, weight: .bold)
        subtextLabel.textAlignment = .center
        subtextLabel.isUserInteractionEnabled = false
        
        let verticalStackView = UIStackView(arrangedSubviews: [titleLabel, subtextLabel])
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .center
        verticalStackView.distribution = .fillEqually
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.isUserInteractionEnabled = false
        
        let button = CustomButton(type: .system)
        if style == 0 {
            button.addTarget(self, action: #selector(self.viewFollowers), for: .touchUpInside)
        } else if style == 1 {
            button.addTarget(self, action: #selector(self.viewFollowing), for: .touchUpInside)
        } else {
            button.addTarget(self, action: #selector(self.viewPosts), for: .touchUpInside)
        }
        button.addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            verticalStackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            verticalStackView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        return button
    }
    
    @objc func viewFollowers() {
        defaultHaptics()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let vc = FriendsViewController()
            vc.profile = self.currentProfile?.actorDID ?? ""
            vc.isShowingFollowers = true
            UIApplication.shared.pushToCurrentNavigationController(vc, animated: true)
        }
    }
    
    @objc func viewFollowing() {
        defaultHaptics()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let vc = FriendsViewController()
            vc.profile = self.currentProfile?.actorDID ?? ""
            vc.isShowingFollowers = false
            UIApplication.shared.pushToCurrentNavigationController(vc, animated: true)
        }
    }
    
    @objc func viewPosts() {
        defaultHaptics()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "scrollToProfilePosts"), object: nil)
    }
    
    @objc func mutualsTapped() {
        defaultHaptics()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let vc = FriendsViewController()
            vc.followers = mutuals
            vc.isMutuals = true
            UIApplication.shared.pushToCurrentNavigationController(vc, animated: true)
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
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        if let button = interaction.view as? UIButton, let imageView = button.imageView {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: { self.makePreviewForImages(imageView) }) { _ in
                createImageMenu(imageView)
            }
        } else {
            return nil
        }
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
    
}



