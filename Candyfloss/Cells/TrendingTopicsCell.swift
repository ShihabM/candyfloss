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
    
    var theIcon = UIButton()
    var theTitle = UILabel()
    var theSubtitle = UILabel()
    var time = UILabel()
    
    let defaultFontSize = UIFont.preferredFont(forTextStyle: .title3).pointSize
    let smallerFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
    let smallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 2
    let mostSmallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 4
    
    let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        bgView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bgView)
        
        theIcon.translatesAutoresizingMaskIntoConstraints = false
        theIcon.backgroundColor = UIColor(named: "groupBG")
        theIcon.layer.cornerRadius = 22
        theIcon.imageView?.contentMode = .scaleAspectFill
        theIcon.imageView?.layer.masksToBounds = true
        theIcon.layer.masksToBounds = true
        bgView.addSubview(theIcon)
        
        theSubtitle.translatesAutoresizingMaskIntoConstraints = false
        theSubtitle.textColor = .secondaryText
        theSubtitle.textAlignment = .left
        theSubtitle.font = UIFont.systemFont(ofSize: smallestFontSize + GlobalStruct.customTextSize, weight: .regular)
        theSubtitle.isUserInteractionEnabled = false
        bgView.addSubview(theSubtitle)
        
        theTitle.translatesAutoresizingMaskIntoConstraints = false
        theTitle.textColor = .label
        theTitle.textAlignment = .left
        theTitle.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .semibold)
        theTitle.isUserInteractionEnabled = false
        bgView.addSubview(theTitle)
        
        let viewsDict = [
            "bgView" : bgView,
            "theIcon" : theIcon,
            "theSubtitle" : theSubtitle,
            "theTitle" : theTitle
        ]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[bgView]-0-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bgView]-0-|", options: [], metrics: nil, views: viewsDict))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[theIcon(44)]-(>=15)-|", options: [], metrics: nil, views: viewsDict))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[theIcon(44)]-12-[theSubtitle]-18-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[theIcon(44)]-12-[theTitle]-18-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[theSubtitle]-2-[theTitle]-12-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
