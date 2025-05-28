//
//  AvatarInputCell.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 28/05/2025.
//

import Foundation
import UIKit

class AvatarInputCell: UITableViewCell {
    
    var avatar = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 52, weight: .regular)
        
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.layer.cornerRadius = 80
        avatar.backgroundColor = GlobalStruct.baseTint
        avatar.clipsToBounds = true
        avatar.setImage(UIImage(systemName: "camera.fill", withConfiguration: symbolConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        contentView.addSubview(avatar)
        
        contentView.layer.masksToBounds = false
        
        let viewsDict = [
            "avatar" : avatar,
        ]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[avatar(160)]", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[avatar(160)]-0-|", options: [], metrics: nil, views: viewsDict))
        
        NSLayoutConstraint.activate([
            avatar.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
