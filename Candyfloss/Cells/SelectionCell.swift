//
//  SelectionCell.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 29/04/2025.
//

import Foundation
import UIKit

class SelectionCell: UITableViewCell {
    
    var bgButton = UIButton()
    var theTitle = UILabel()
    var theTitle2 = UILabel()
    
    let defaultFontSize = UIFont.preferredFont(forTextStyle: .title3).pointSize
    let smallerFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        bgButton.translatesAutoresizingMaskIntoConstraints = false
        bgButton.backgroundColor = GlobalStruct.backgroundTint
        contentView.addSubview(bgButton)
        
        theTitle.translatesAutoresizingMaskIntoConstraints = false
        theTitle.textColor = UIColor.label
        theTitle.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
        theTitle.backgroundColor = UIColor.clear
        contentView.addSubview(theTitle)
        
        theTitle2.translatesAutoresizingMaskIntoConstraints = false
        theTitle2.textColor = GlobalStruct.secondaryTextColor
        theTitle2.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
        theTitle2.backgroundColor = UIColor.clear
        contentView.addSubview(theTitle2)
        
        contentView.layer.masksToBounds = false
        
        let viewsDict = [
            "bgButton" : bgButton,
            "theTitle" : theTitle,
            "theTitle2" : theTitle2,
        ]
        let metricsDict = [
            "height" : UIFont.preferredFont(forTextStyle: .body).pointSize + 16
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bgButton]-0-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[bgButton]-0-|", options: [], metrics: metricsDict, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[theTitle]-(>=16)-[theTitle2]-20-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[theTitle]-12-|", options: [], metrics: metricsDict, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[theTitle2]-12-|", options: [], metrics: metricsDict, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


