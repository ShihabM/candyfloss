//
//  UserCell.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 09/03/2025.
//

import Foundation
import UIKit
import SDWebImage
import ATProtoKit
import SafariServices
import MessageUI

class UserCell: UITableViewCell, UIContextMenuInteractionDelegate, MFMailComposeViewControllerDelegate {
    
    var currentProfile: AppBskyLexicon.Actor.ProfileViewBasicDefinition? = nil
    var defaultProfile: AppBskyLexicon.Actor.ProfileViewDefinition? = nil
    
    var bgView = UIView()
    
    var avatar = UIButton()
    var username = UILabel()
    var usertag = UILabel()
    var followsYouTag = UIButton()
    var bio = ActiveLabel()
    
    var emailAddress: String = ""
    var currentLink: String = ""
    
    let defaultFontSize = UIFont.preferredFont(forTextStyle: .title3).pointSize
    let smallerFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
    let smallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 2
    let mostSmallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 4
    
    let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
    
    var cellStackViewConstraints1: [NSLayoutConstraint] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        bgView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bgView)
        
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.backgroundColor = UIColor(named: "groupBG")
        avatar.layer.cornerRadius = 22
        avatar.imageView?.contentMode = .scaleAspectFill
        avatar.imageView?.layer.masksToBounds = true
        avatar.layer.masksToBounds = true
        bgView.addSubview(avatar)
        let interactionAvatar = UIContextMenuInteraction(delegate: self)
        avatar.addInteraction(interactionAvatar)
        
        username.translatesAutoresizingMaskIntoConstraints = false
        username.textColor = .label
        username.textAlignment = .left
        username.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .bold)
        username.setContentCompressionResistancePriority(.required, for: .horizontal)
        username.isUserInteractionEnabled = false
        username.numberOfLines = 0
        bgView.addSubview(username)
        
        usertag.translatesAutoresizingMaskIntoConstraints = false
        usertag.textColor = GlobalStruct.secondaryTextColor
        usertag.textAlignment = .left
        usertag.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
        usertag.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        usertag.lineBreakMode = .byTruncatingTail
        usertag.isUserInteractionEnabled = false
        bgView.addSubview(usertag)
        
        followsYouTag.translatesAutoresizingMaskIntoConstraints = false
        followsYouTag.setTitle("   Follows You   ", for: .normal)
        followsYouTag.setTitleColor(.white, for: .normal)
        followsYouTag.titleLabel?.font = UIFont.systemFont(ofSize: mostSmallestFontSize + GlobalStruct.customTextSize, weight: .semibold)
        followsYouTag.backgroundColor = GlobalStruct.baseTint
        followsYouTag.layer.cornerRadius = (mostSmallestFontSize + 10) / 2
        followsYouTag.alpha = 0
        bgView.addSubview(followsYouTag)
        
        bio.customize { bio in
            bio.translatesAutoresizingMaskIntoConstraints = false
            bio.textColor = GlobalStruct.textColor
            bio.textAlignment = .left
            bio.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
            bio.numberOfLines = 2
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
            if let link = URL(string: self.currentLink) {
                if GlobalStruct.openLinksInApp {
                    let safariVC = SFSafariViewController(url: link)
                    getTopMostViewController()?.present(safariVC, animated: true, completion: nil)
                } else {
                    UIApplication.shared.open(link, options: [:], completionHandler: nil)
                }
            }
        }
        bio.handleEmailTap { (str) in
            defaultHaptics()
            self.emailAddress = str
            self.goToMail()
        }
        
        let viewsDict = [
            "bgView" : bgView,
            "avatar" : avatar,
            "username" : username,
            "usertag" : usertag,
            "followsYouTag" : followsYouTag,
            "bio" : bio,
        ]
        let metricsDict: [String: Any] = [
            "offset" : 74 - mostSmallestFontSize - 10
        ]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[bgView]-0-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bgView]-0-|", options: [], metrics: nil, views: viewsDict))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[avatar(44)]-(>=15)-|", options: [], metrics: nil, views: viewsDict))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[avatar(44)]-12-[username]-(>=18)-|", options: [], metrics: metricsDict, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[avatar(44)]-12-[usertag]-(>=18)-|", options: [], metrics: metricsDict, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[avatar(44)]-12-[followsYouTag]-(>=18)-|", options: [], metrics: metricsDict, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[avatar(44)]-12-[bio]-18-|", options: [], metrics: metricsDict, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(_ followsYou: Bool = false, bioText: String = "", currentProfile: AppBskyLexicon.Actor.ProfileViewBasicDefinition? = nil, defaultProfile: AppBskyLexicon.Actor.ProfileViewDefinition? = nil) {
        self.currentProfile = currentProfile
        self.defaultProfile = defaultProfile
        bio.text = bioText.trimmingCharacters(in: .whitespacesAndNewlines)
        avatar.addTarget(self, action: #selector(avatarTapped), for: .touchUpInside)
        
        let viewsDict = [
            "bgView" : bgView,
            "avatar" : avatar,
            "username" : username,
            "usertag" : usertag,
            "followsYouTag" : followsYouTag,
            "bio" : bio,
        ]
        let metricsDict: [String: Any] = [
            "height" : mostSmallestFontSize + 10
        ]
        
        var followsYouLayoutString: String = ""
        if followsYou {
            followsYouTag.alpha = 1
            if bioText == "" {
                followsYouLayoutString = "V:|-12-[username]-1-[usertag]-10-[followsYouTag(height)]-(>=14)-|"
            } else {
                followsYouLayoutString = "V:|-12-[username]-1-[usertag]-10-[followsYouTag(height)]-8-[bio]-(>=14)-|"
            }
        } else {
            followsYouTag.alpha = 0
            if bioText == "" {
                followsYouLayoutString = "V:|-12-[username]-1-[usertag]-(>=14)-|"
            } else {
                followsYouLayoutString = "V:|-12-[username]-1-[usertag]-4-[bio]-(>=14)-|"
            }
        }
        NSLayoutConstraint.deactivate(cellStackViewConstraints1)
        cellStackViewConstraints1 = NSLayoutConstraint.constraints(withVisualFormat: followsYouLayoutString, options: [], metrics: metricsDict, views: viewsDict)
        NSLayoutConstraint.activate(cellStackViewConstraints1)
    }
    
    @objc func avatarTapped() {
        if let tableView = self.findSuperview(ofType: UITableView.self),
           let indexPath = tableView.indexPath(for: self),
           let delegate = tableView.delegate {
            delegate.tableView?(tableView, didSelectRowAt: indexPath)
        }
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        if let _ = interaction.view as? UIButton {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                createMoreProfileMenu(nil, basicProfile: self.currentProfile, defaultProfile: self.defaultProfile)
            }
        } else {
            return nil
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


