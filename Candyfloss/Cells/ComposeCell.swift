//
//  ComposeCell.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 28/03/2025.
//

import Foundation
import UIKit

class ComposeCell: UITableViewCell {
    
    var avatar = UIButton()
    var post = MultilineTextField()
    var topThreadLine = UIView()
    let symbolConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.topThreadLine.alpha = 0
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        topThreadLine.translatesAutoresizingMaskIntoConstraints = false
        topThreadLine.backgroundColor = GlobalStruct.baseTint
        topThreadLine.alpha = 0
        contentView.addSubview(topThreadLine)
        
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.backgroundColor = .clear
        avatar.imageView?.contentMode = .scaleAspectFill
        avatar.layer.masksToBounds = true
        avatar.layer.cornerRadius = 23
        avatar.imageView?.contentMode = .scaleAspectFill
        avatar.contentMode = .scaleAspectFill
        avatar.adjustsImageWhenHighlighted = false
        avatar.accessibilityLabel = "Switch Profile"
        contentView.addSubview(avatar)
        
        post.translatesAutoresizingMaskIntoConstraints = false
        post.placeholder = "What's happening?"
        post.placeholderColor = UIColor.placeholderText
        post.accessibilityLabel = "What's happening?"
        post.backgroundColor = .clear
        post.text = ""
        post.textColor = UIColor.label
        post.isScrollEnabled = true
        post.isEditable = true
        post.isUserInteractionEnabled = true
        post.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
        post.smartDashesType = .no
        if GlobalStruct.keyboardStyle == 0 {
            post.keyboardType = .default
        } else {
            post.keyboardType = .twitter
        }
        contentView.addSubview(post)
        
        contentView.layer.masksToBounds = false
        
        let viewsDict = [
            "avatar" : avatar,
            "topThreadLine" : topThreadLine,
            "post" : post,
        ]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[topThreadLine(2)]", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[topThreadLine(24)]", options: [], metrics: nil, views: viewsDict))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[avatar(46)]", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[avatar(46)]", options: [], metrics: nil, views: viewsDict))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-80-[post]-15-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[post(>=50)]-0-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

