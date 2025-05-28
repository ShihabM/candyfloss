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
    var theDescription = UILabel()
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
        theSubtitle.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
        theSubtitle.isUserInteractionEnabled = false
        bgView.addSubview(theSubtitle)
        
        theTitle.translatesAutoresizingMaskIntoConstraints = false
        theTitle.textColor = .label
        theTitle.textAlignment = .left
        theTitle.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .semibold)
        theTitle.isUserInteractionEnabled = false
        bgView.addSubview(theTitle)
        
        theDescription.translatesAutoresizingMaskIntoConstraints = false
        theDescription.textColor = .secondaryLabel
        theDescription.textAlignment = .left
        theDescription.font = UIFont.systemFont(ofSize: smallestFontSize + GlobalStruct.customTextSize, weight: .regular)
        theDescription.isUserInteractionEnabled = false
        bgView.addSubview(theDescription)
        
        theIcon.translatesAutoresizingMaskIntoConstraints = false
        theIcon.backgroundColor = GlobalStruct.groupBG
        theIcon.layer.cornerRadius = 13
        theIcon.imageView?.contentMode = .scaleAspectFill
        theIcon.imageView?.layer.masksToBounds = true
        theIcon.layer.masksToBounds = true
        bgView.addSubview(theIcon)
        
        let viewsDict = [
            "bgView" : bgView,
            "theSubtitle" : theSubtitle,
            "theTitle" : theTitle,
            "theDescription" : theDescription,
            "theIcon" : theIcon
        ]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[bgView]-0-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bgView]-0-|", options: [], metrics: nil, views: viewsDict))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[theSubtitle]-10-[theTitle]-(>=10)-[theIcon]-18-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[theSubtitle]-10-[theDescription]-(>=18)-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[theSubtitle]-2-[theDescription]-12-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[theTitle]-2-[theDescription]-12-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[theIcon(26)]-(>=2)-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
