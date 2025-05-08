//
//  FeedTipCell.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 08/05/2025.
//

import Foundation
import UIKit

class FeedTipCell: UITableViewCell {
    
    var bgView = UIView()
    
    var theIcon = UIButton()
    var theTitle = UILabel()
    var theSubtitle = UILabel()
    
    let defaultFontSize = UIFont.preferredFont(forTextStyle: .title3).pointSize
    let smallerFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
    let smallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 2
    let mostSmallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 4
    
    let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.backgroundColor = UIColor(named: "groupBG")
        bgView.layer.cornerRadius = 12
        bgView.layer.cornerCurve = .continuous
        contentView.addSubview(bgView)
        
        theIcon.translatesAutoresizingMaskIntoConstraints = false
        theIcon.backgroundColor = UIColor.clear
        theIcon.setImage(UIImage(systemName: "pin.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal), for: .normal)
        theIcon.imageView?.contentMode = .scaleAspectFill
        theIcon.imageView?.layer.masksToBounds = true
        theIcon.layer.masksToBounds = true
        bgView.addSubview(theIcon)
        
        theTitle.translatesAutoresizingMaskIntoConstraints = false
        theTitle.textColor = .label
        theTitle.textAlignment = .left
        theTitle.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .semibold)
        theTitle.numberOfLines = 0
        theTitle.isUserInteractionEnabled = false
        bgView.addSubview(theTitle)
        
        theSubtitle.translatesAutoresizingMaskIntoConstraints = false
        theSubtitle.textColor = .secondaryLabel
        theSubtitle.textAlignment = .left
        theSubtitle.font = UIFont.systemFont(ofSize: smallestFontSize + GlobalStruct.customTextSize, weight: .regular)
        theSubtitle.numberOfLines = 0
        theSubtitle.isUserInteractionEnabled = false
        bgView.addSubview(theSubtitle)
        
        let viewsDict = [
            "bgView" : bgView,
            "theIcon" : theIcon,
            "theTitle" : theTitle,
            "theSubtitle" : theSubtitle
        ]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[bgView]-0-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[bgView]-12-|", options: [], metrics: nil, views: viewsDict))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[theIcon(26)]-12-[theTitle]-(>=12)-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[theIcon(26)]-12-[theSubtitle]-(>=12)-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[theTitle]-3-[theSubtitle]-12-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=2)-[theIcon(26)]-(>=2)-|", options: [], metrics: nil, views: viewsDict))
        
        theIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
