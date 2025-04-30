//
//  FooterCell.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 07/03/2025.
//

import Foundation
import UIKit

class FooterCell: UITableViewCell {
    
    var bgView = UIView()
    var constraint1: [NSLayoutConstraint] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        NSLayoutConstraint.deactivate(self.constraint1)
        
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.backgroundColor = GlobalStruct.groupBG
        contentView.addSubview(bgView)
        
        let viewsDict = [
            "bgView" : bgView,
        ]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[bgView]-0-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bgView]-0-|", options: [], metrics: nil, views: viewsDict))
        
        let resizableHeightConstraint0 = bgView.heightAnchor.constraint(equalToConstant: 8)
        resizableHeightConstraint0.priority = .defaultHigh
        resizableHeightConstraint0.isActive = true
        
        self.constraint1 = [bgView.heightAnchor.constraint(equalToConstant: 8)]
        for x in self.constraint1 {
            x.priority = .defaultHigh
        }
        NSLayoutConstraint.activate(constraint1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
