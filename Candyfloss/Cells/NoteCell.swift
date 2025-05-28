//
//  NoteCell.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 01/05/2025.
//

import Foundation
import UIKit

class NoteCell: UITableViewCell {
    
    var post = MultilineTextField()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        post.translatesAutoresizingMaskIntoConstraints = false
        post.placeholder = "Profile note..."
        post.placeholderColor = UIColor.placeholderText
        post.accessibilityLabel = "Profile note..."
        post.backgroundColor = .clear
        post.text = ""
        post.textColor = UIColor.label
        post.isEditable = true
        post.isUserInteractionEnabled = true
        post.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
        post.smartDashesType = .no
        contentView.addSubview(post)
        
        contentView.layer.masksToBounds = false
        
        let viewsDict = [
            "post" : post,
        ]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[post]-20-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[post(140)]-10-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
