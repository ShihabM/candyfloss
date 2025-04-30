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

class UserCell: UITableViewCell, UIContextMenuInteractionDelegate {
    
    var currentProfile: AppBskyLexicon.Actor.ProfileViewBasicDefinition? = nil
    var defaultProfile: AppBskyLexicon.Actor.ProfileViewDefinition? = nil
    
    var bgView = UIView()
    
    var avatar = UIButton()
    var username = UILabel()
    var usertag = UILabel()
    var followsYouTag = UIButton()
    var bio = ActiveLabel()
    
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
        followsYouTag.setTitle("  Follows You  ", for: .normal)
        followsYouTag.setTitleColor(.white, for: .normal)
        followsYouTag.titleLabel?.font = UIFont.systemFont(ofSize: mostSmallestFontSize + GlobalStruct.customTextSize, weight: .semibold)
        followsYouTag.backgroundColor = GlobalStruct.baseTint
        followsYouTag.layer.cornerRadius = 6
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
        
        let viewsDict = [
            "bgView" : bgView,
            "avatar" : avatar,
            "username" : username,
            "usertag" : usertag,
            "followsYouTag" : followsYouTag,
            "bio" : bio,
        ]
        let metricsDict: [String: Any] = [
            "height" : mostSmallestFontSize + 8
        ]
        
        var followsYouLayoutString: String = ""
        if followsYou {
            followsYouTag.alpha = 1
            if bioText == "" {
                followsYouLayoutString = "V:|-12-[username]-1-[usertag]-6-[followsYouTag(height)]-(>=14)-|"
            } else {
                followsYouLayoutString = "V:|-12-[username]-1-[usertag]-6-[followsYouTag(height)]-5-[bio]-(>=14)-|"
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
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        if let _ = interaction.view as? UIButton {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                createMoreProfileMenu(nil, basicProfile: self.currentProfile, defaultProfile: self.defaultProfile)
            }
        } else {
            return nil
        }
    }
    
}


