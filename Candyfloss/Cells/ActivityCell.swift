//
//  ActivityCell.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 10/03/2025.
//

import Foundation
import UIKit
import SDWebImage
import Vision
import ATProtoKit

class ActivityCell: UITableViewCell, SKPhotoBrowserDelegate, UISheetPresentationControllerDelegate, UIContextMenuInteractionDelegate {
    
    var currentProfile1: AppBskyLexicon.Actor.ProfileViewBasicDefinition? = nil
    var currentProfile2: AppBskyLexicon.Actor.ProfileViewBasicDefinition? = nil
    var currentProfile3: AppBskyLexicon.Actor.ProfileViewBasicDefinition? = nil
    
    var bgView = UIView()
    
    var avatar1 = UIButton()
    var avatar2 = UIButton()
    var avatar3 = UIButton()
    var avatar4 = UIButton()
    
    var typeIndicator = UIButton()
    var time = UILabel()
    var username = UILabel()
    var postContents = ActiveLabel()
    
    let defaultFontSize = UIFont.preferredFont(forTextStyle: .title3).pointSize
    let smallerFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
    let smallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 2
    let mostSmallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 4
    
    let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
    
    var postImage = UIImageView()
    var constraint1: [NSLayoutConstraint] = []
    var constraint2: [NSLayoutConstraint] = []
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        bgView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bgView)
        
        typeIndicator.translatesAutoresizingMaskIntoConstraints = false
        typeIndicator.setImage(UIImage(systemName: "heart.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemPink, renderingMode: .alwaysOriginal), for: .normal)
        typeIndicator.backgroundColor = .clear
        typeIndicator.imageView?.contentMode = .scaleAspectFill
        typeIndicator.imageView?.layer.masksToBounds = true
        typeIndicator.layer.masksToBounds = true
        typeIndicator.isUserInteractionEnabled = false
        bgView.addSubview(typeIndicator)
        
        avatar1.translatesAutoresizingMaskIntoConstraints = false
        avatar1.backgroundColor = GlobalStruct.pollBar.withAlphaComponent(0.25)
        avatar1.layer.cornerRadius = 16
        avatar1.imageView?.contentMode = .scaleAspectFill
        avatar1.imageView?.layer.masksToBounds = true
        avatar1.layer.masksToBounds = true
        bgView.addSubview(avatar1)
        avatar1.tag = 0
        let interactionAvatar1 = UIContextMenuInteraction(delegate: self)
        avatar1.addInteraction(interactionAvatar1)
        
        avatar2.translatesAutoresizingMaskIntoConstraints = false
        avatar2.backgroundColor = GlobalStruct.pollBar.withAlphaComponent(0.25)
        avatar2.layer.cornerRadius = 16
        avatar2.imageView?.contentMode = .scaleAspectFill
        avatar2.imageView?.layer.masksToBounds = true
        avatar2.layer.masksToBounds = true
        avatar2.alpha = 0
        bgView.addSubview(avatar2)
        avatar2.tag = 1
        let interactionAvatar2 = UIContextMenuInteraction(delegate: self)
        avatar2.addInteraction(interactionAvatar2)
        
        avatar3.translatesAutoresizingMaskIntoConstraints = false
        avatar3.backgroundColor = GlobalStruct.pollBar.withAlphaComponent(0.25)
        avatar3.layer.cornerRadius = 16
        avatar3.imageView?.contentMode = .scaleAspectFill
        avatar3.imageView?.layer.masksToBounds = true
        avatar3.layer.masksToBounds = true
        avatar3.alpha = 0
        bgView.addSubview(avatar3)
        avatar3.tag = 2
        let interactionAvatar3 = UIContextMenuInteraction(delegate: self)
        avatar3.addInteraction(interactionAvatar3)
        
        avatar4.translatesAutoresizingMaskIntoConstraints = false
        avatar4.backgroundColor = .clear
        avatar4.setTitleColor(GlobalStruct.secondaryTextColor, for: .normal)
        avatar4.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        avatar4.layer.masksToBounds = true
        avatar4.isUserInteractionEnabled = false
        avatar4.alpha = 0
        bgView.addSubview(avatar4)
        
        time.translatesAutoresizingMaskIntoConstraints = false
        time.textColor = GlobalStruct.secondaryTextColor
        time.textAlignment = .left
        time.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
        time.setContentCompressionResistancePriority(.required, for: .horizontal)
        bgView.addSubview(time)
        
        username.translatesAutoresizingMaskIntoConstraints = false
        username.textColor = .label
        username.textAlignment = .left
        username.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .bold)
        username.isUserInteractionEnabled = false
        username.numberOfLines = 0
        bgView.addSubview(username)
        
        postContents.customize { postContents in
            postContents.translatesAutoresizingMaskIntoConstraints = false
            postContents.textColor = GlobalStruct.secondaryTextColor
            postContents.textAlignment = .left
            postContents.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
            postContents.numberOfLines = 0
            postContents.isUserInteractionEnabled = false
            postContents.enabledTypes = [.mention, .hashtag, .url, .email]
            postContents.mentionColor = GlobalStruct.secondaryTextColor
            postContents.hashtagColor = GlobalStruct.secondaryTextColor
            postContents.URLColor = GlobalStruct.secondaryTextColor
            postContents.emailColor = GlobalStruct.secondaryTextColor
            bgView.addSubview(postContents)
        }
        
        postImage.translatesAutoresizingMaskIntoConstraints = false
        postImage.backgroundColor = GlobalStruct.pollBar.withAlphaComponent(0.25)
        postImage.layer.cornerRadius = 10
        postImage.layer.cornerCurve = .continuous
        postImage.contentMode = .scaleAspectFill
        postImage.layer.masksToBounds = true
        postImage.clipsToBounds = true
        postImage.isUserInteractionEnabled = true
        bgView.addSubview(postImage)
        
        let viewsDict = [
            "bgView" : bgView,
            "typeIndicator" : typeIndicator,
            "avatar1" : avatar1,
            "avatar2" : avatar2,
            "avatar3" : avatar3,
            "avatar4" : avatar4,
            "time" : time,
            "username" : username,
            "postContents" : postContents,
            "postImage" : postImage,
        ]
        let metricsDict: [String: Any] = [
            "offset" : 74 - mostSmallestFontSize - 10
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[bgView]-0-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bgView]-0-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-14-[avatar1(32)]-7-[postImage(50)]-(>=12)-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-14-[avatar2(32)]-(>=12)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-14-[avatar3(32)]-(>=12)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-14-[avatar4(32)]-(>=12)-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[time]-(>=12)-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-14-[typeIndicator(32)]-(>=5)-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-14-[avatar1(32)]-5-[username]-4-[postContents]-14-|", options: [], metrics: nil, views: viewsDict))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=10)-[time]-18-|", options: [], metrics: metricsDict, views: viewsDict))
        
        constraint1.forEach { $0.isActive = false }
        constraint1 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[typeIndicator(44)]-12-[postContents]-18-|", options: [], metrics: nil, views: viewsDict)
        constraint1.forEach { $0.isActive = true }
        
        constraint2.forEach { $0.isActive = false }
        constraint2 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[typeIndicator(44)]-12-[username]-18-|", options: [], metrics: nil, views: viewsDict)
        constraint2.forEach { $0.isActive = true }
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[typeIndicator(44)]-12-[avatar1(32)]-8-[avatar2(32)]-8-[avatar3(32)]-6-[avatar4(32)]", options: [], metrics: metricsDict, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ notification: [AppBskyLexicon.Notification.Notification] = []) {
        avatar1.alpha = notification.count > 0 ? 1 : 0
        avatar2.alpha = notification.count > 1 ? 1 : 0
        avatar3.alpha = notification.count > 2 ? 1 : 0
        avatar4.alpha = notification.count > 3 ? 1 : 0
        if notification.count > 0 {
            currentProfile1 = notification[0].author
        }
        if notification.count > 1 {
            currentProfile2 = notification[1].author
        }
        if notification.count > 2 {
            currentProfile3 = notification[2].author
        }
    }
    
    func setupImages(_ hasImage: Bool = false) {
        let viewsDict = [
            "bgView" : bgView,
            "typeIndicator" : typeIndicator,
            "time" : time,
            "username" : username,
            "postContents" : postContents,
            "postImage" : postImage,
        ]
        if hasImage {
            NSLayoutConstraint.deactivate(constraint1 + constraint2)
            constraint1 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[typeIndicator(44)]-12-[postContents]-12-[postImage(50)]-18-|", options: [], metrics: nil, views: viewsDict)
            constraint2 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[typeIndicator(44)]-12-[username]-12-[postImage(50)]-18-|", options: [], metrics: nil, views: viewsDict)
            NSLayoutConstraint.activate(constraint1 + constraint2)
        } else {
            NSLayoutConstraint.deactivate(constraint1 + constraint2)
            constraint1 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[typeIndicator(44)]-12-[postContents]-18-|", options: [], metrics: nil, views: viewsDict)
            constraint2 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[typeIndicator(44)]-12-[username]-18-|", options: [], metrics: nil, views: viewsDict)
            NSLayoutConstraint.activate(constraint1 + constraint2)
        }
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        if let avatar = interaction.view as? UIButton {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                if avatar.tag == 0 {
                    return createMoreProfileMenu(nil, basicProfile: self.currentProfile1)
                } else if avatar.tag == 1 {
                    return createMoreProfileMenu(nil, basicProfile: self.currentProfile2)
                } else {
                    return createMoreProfileMenu(nil, basicProfile: self.currentProfile3)
                }
            }
        } else {
            return nil
        }
    }
    
}
