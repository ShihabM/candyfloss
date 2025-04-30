//
//  MessageCell.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 09/03/2025.
//

import Foundation
import UIKit
import SDWebImage
import ATProtoKit

class MessageCell: UITableViewCell, SKPhotoBrowserDelegate {
    
    // elements
    var bgView = UIView()
    var avatar = UIButton()
    var time = UILabel()
    var username = UILabel()
    var usertag = UILabel()
    var text = ActiveLabel()
    
    // fonts and symbols
    let defaultFontSize = UIFont.preferredFont(forTextStyle: .title3).pointSize
    let smallerFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
    let smallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 2
    let mostSmallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 4
    
    let biggestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize + 6
    var symbolConfig1 = UIImage.SymbolConfiguration(pointSize: UIFont.systemFont(ofSize: 12, weight: .bold).pointSize)
    let smallestFontSize2 = UIFont.preferredFont(forTextStyle: .body).pointSize - 2 + GlobalStruct.customTextSize
    var symbolConfig3 = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // background view
        bgView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bgView)
        
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
        bgView.addSubview(username)
        
        usertag.translatesAutoresizingMaskIntoConstraints = false
        usertag.textColor = GlobalStruct.secondaryTextColor
        usertag.textAlignment = .left
        usertag.font = UIFont.systemFont(ofSize: smallestFontSize + GlobalStruct.customTextSize, weight: .regular)
        bgView.addSubview(usertag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(post: ChatBskyLexicon.Conversation.MessageViewDefinition) {
        // layouts
        let viewsDict = [
            "bgView" : bgView,
            "avatar" : avatar,
            "time" : time,
            "username" : username,
            "usertag" : usertag,
            "text" : text,
        ]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bgView]-0-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[bgView]-0-|", options: [], metrics: nil, views: viewsDict))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[avatar(44)]-12-[username]-12-[time]-(>=18)-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[avatar(44)]-12-[usertag]-18-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[avatar(44)]-12-[text]-18-|", options: [], metrics: nil, views: viewsDict))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-14-[avatar(44)]-(>=14)-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-14-[time]-(>=14)-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-14-[username]-1-[usertag]-5-[text]-14-|", options: [], metrics: nil, views: viewsDict))
    }
}
