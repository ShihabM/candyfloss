//
//  TrendingTopicsCell.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 17/04/2025.
//

import Foundation
import UIKit

class TrendingTopicsCell: UITableViewCell {
    
    var bgView = UIView()
    
    var theSubtitle = UILabel()
    var theTitle = UILabel()
    var theIcon = UIButton()
    
    let defaultFontSize = UIFont.preferredFont(forTextStyle: .title3).pointSize
    let smallerFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
    let smallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 2
    let mostSmallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 4
    
    let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        bgView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bgView)
        
        theSubtitle.translatesAutoresizingMaskIntoConstraints = false
        theSubtitle.textColor = .secondaryLabel
        theSubtitle.textAlignment = .left
        theSubtitle.font = UIFont.systemFont(ofSize: defaultFontSize + GlobalStruct.customTextSize, weight: .regular)
        theSubtitle.isUserInteractionEnabled = false
        bgView.addSubview(theSubtitle)
        
        theTitle.translatesAutoresizingMaskIntoConstraints = false
        theTitle.textColor = .label
        theTitle.textAlignment = .left
        theTitle.font = UIFont.systemFont(ofSize: defaultFontSize + GlobalStruct.customTextSize, weight: .semibold)
        theTitle.isUserInteractionEnabled = false
        bgView.addSubview(theTitle)
        
        theIcon.translatesAutoresizingMaskIntoConstraints = false
        theIcon.backgroundColor = UIColor(named: "groupBG")
        theIcon.layer.cornerRadius = 13
        theIcon.imageView?.contentMode = .scaleAspectFill
        theIcon.imageView?.layer.masksToBounds = true
        theIcon.layer.masksToBounds = true
        bgView.addSubview(theIcon)
        
        let viewsDict = [
            "bgView" : bgView,
            "theSubtitle" : theSubtitle,
            "theTitle" : theTitle,
            "theIcon" : theIcon
        ]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[bgView]-0-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bgView]-0-|", options: [], metrics: nil, views: viewsDict))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[theSubtitle]-8-[theTitle]-(>=10)-[theIcon]-18-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[theSubtitle]-12-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[theTitle]-12-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=2)-[theIcon(26)]-(>=2)-|", options: [], metrics: nil, views: viewsDict))
        
        theIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
