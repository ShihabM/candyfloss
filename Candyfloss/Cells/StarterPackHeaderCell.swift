//
//  StarterPackHeaderCell.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 22/04/2025.
//

import Foundation
import UIKit

class StarterPackHeaderCell: UITableViewCell {
    
    var bgView = UIView()
    var theTitle = UILabel()
    var avatar = UIButton()
    var theAuthor = UILabel()
    var theDescription = UILabel()
    var followAllButton = UIButton()
    var shareButton = UIButton()
    
    let defaultFontSize = UIFont.preferredFont(forTextStyle: .title1).pointSize
    let smallerFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
    let smallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 2
    let mostSmallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 4
    
    let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
    let symbolConfigIcon = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        bgView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bgView)
        
        theTitle.translatesAutoresizingMaskIntoConstraints = false
        theTitle.textColor = .label
        theTitle.textAlignment = .left
        theTitle.font = UIFont.systemFont(ofSize: defaultFontSize + GlobalStruct.customTextSize, weight: .semibold)
        theTitle.isUserInteractionEnabled = false
        theTitle.numberOfLines = 0
        bgView.addSubview(theTitle)
        
        avatar.sd_imageTransition = .fade
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.backgroundColor = GlobalStruct.blueskyBlue
        avatar.layer.cornerRadius = (smallerFontSize + GlobalStruct.customTextSize) / 2
        avatar.imageView?.contentMode = .scaleAspectFill
        avatar.imageView?.layer.masksToBounds = true
        avatar.layer.masksToBounds = true
        avatar.setContentCompressionResistancePriority(.required, for: .vertical)
        avatar.isUserInteractionEnabled = false
        bgView.addSubview(avatar)
        
        theAuthor.translatesAutoresizingMaskIntoConstraints = false
        theAuthor.textColor = .secondaryText
        theAuthor.textAlignment = .left
        theAuthor.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
        theAuthor.isUserInteractionEnabled = false
        theAuthor.numberOfLines = 0
        bgView.addSubview(theAuthor)
        
        theDescription.translatesAutoresizingMaskIntoConstraints = false
        theDescription.textColor = .text
        theDescription.textAlignment = .left
        theDescription.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
        theDescription.isUserInteractionEnabled = false
        theDescription.numberOfLines = 0
        bgView.addSubview(theDescription)
        
        followAllButton.translatesAutoresizingMaskIntoConstraints = false
        followAllButton.backgroundColor = GlobalStruct.baseTint
        followAllButton.layer.cornerRadius = 10
        followAllButton.layer.cornerCurve = .continuous
        followAllButton.setTitle("Follow Everyone Here", for: .normal)
        followAllButton.setTitleColor(.white, for: .normal)
        followAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        bgView.addSubview(followAllButton)
        
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.backgroundColor = GlobalStruct.detailCell
        shareButton.layer.cornerRadius = 10
        shareButton.layer.cornerCurve = .continuous
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up", withConfiguration: symbolConfigIcon)?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal), for: .normal)
        bgView.addSubview(shareButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell() {
        let viewsDict = [
            "bgView" : bgView,
            "theTitle" : theTitle,
            "avatar" : avatar,
            "theAuthor" : theAuthor,
            "theDescription" : theDescription,
            "followAllButton" : followAllButton,
            "shareButton" : shareButton
        ]
        let metricsDict: [String: Any] = [
            "avatarSize" : smallerFontSize + GlobalStruct.customTextSize
        ]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[bgView]-0-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bgView]-0-|", options: [], metrics: nil, views: viewsDict))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[theTitle]-18-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[avatar(avatarSize)]-8-[theAuthor]-18-|", options: [], metrics: metricsDict, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[theDescription]-18-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[followAllButton]-12-[shareButton(44)]-18-|", options: [], metrics: nil, views: viewsDict))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[theTitle]-8-[avatar(avatarSize)]", options: [], metrics: metricsDict, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[theTitle]-5-[theAuthor]-6-[theDescription]-12-[followAllButton(40)]-16-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[theTitle]-5-[theAuthor]-6-[theDescription]-12-[shareButton(40)]-16-|", options: [], metrics: nil, views: viewsDict))
    }
    
}
