//
//  FeedCell.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 10/04/2025.
//

import Foundation
import UIKit

class FeedCell: UITableViewCell {
    
    var bgView = UIView()
    var avatar = UIButton()
    var theTitle = UILabel()
    var theAuthor = UILabel()
    var theDescription = UILabel()
    
    let defaultFontSize = UIFont.preferredFont(forTextStyle: .title3).pointSize
    let smallerFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
    let smallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 2
    let mostSmallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 4
    
    let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
    
    var detailConstraints: [NSLayoutConstraint] = []
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // reset constraints
        NSLayoutConstraint.deactivate(detailConstraints)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        bgView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bgView)
        
        avatar.sd_imageTransition = .fade
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.backgroundColor = GlobalStruct.blueskyBlue
        avatar.layer.cornerRadius = 22
        avatar.imageView?.contentMode = .scaleAspectFill
        avatar.imageView?.layer.masksToBounds = true
        avatar.layer.masksToBounds = true
        avatar.setContentCompressionResistancePriority(.required, for: .vertical)
        avatar.isUserInteractionEnabled = false
        bgView.addSubview(avatar)
        
        theTitle.translatesAutoresizingMaskIntoConstraints = false
        theTitle.textColor = .label
        theTitle.textAlignment = .left
        theTitle.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .semibold)
        theTitle.isUserInteractionEnabled = false
        bgView.addSubview(theTitle)
        
        theAuthor.translatesAutoresizingMaskIntoConstraints = false
        theAuthor.textColor = .secondaryText
        theAuthor.textAlignment = .left
        theAuthor.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
        theAuthor.isUserInteractionEnabled = false
        bgView.addSubview(theAuthor)
        
        theDescription.translatesAutoresizingMaskIntoConstraints = false
        theDescription.textColor = .text
        theDescription.textAlignment = .left
        theDescription.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
        theDescription.isUserInteractionEnabled = false
        theDescription.numberOfLines = 0
        bgView.addSubview(theDescription)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(_ showingDescriptions: Bool) {
        let viewsDict = [
            "bgView" : bgView,
            "avatar" : avatar,
            "theTitle" : theTitle,
            "theAuthor" : theAuthor,
            "theDescription" : theDescription
        ]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[bgView]-0-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bgView]-0-|", options: [], metrics: nil, views: viewsDict))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[avatar(44)]-12-[theTitle]-18-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[avatar(44)]-12-[theAuthor]-18-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[avatar(44)]-12-[theDescription]-18-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-14-[avatar(44)]-(>=14)-|", options: [], metrics: nil, views: viewsDict))
        
        if showingDescriptions {
            theDescription.isHidden = false
            detailConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[theTitle]-2-[theAuthor]-4-[theDescription]-12-|", options: [], metrics: nil, views: viewsDict)
            NSLayoutConstraint.activate(detailConstraints)
        } else {
            theDescription.isHidden = true
            detailConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[theTitle]-2-[theAuthor]-12-|", options: [], metrics: nil, views: viewsDict)
            NSLayoutConstraint.activate(detailConstraints)
        }
    }
    
}
