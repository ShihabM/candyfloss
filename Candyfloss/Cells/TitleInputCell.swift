//
//  TitleInputCell.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 27/05/2025.
//

import Foundation
import UIKit

class TitleInputCell: UITableViewCell {
    
    var post = MultilineTextField()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        post.translatesAutoresizingMaskIntoConstraints = false
        post.placeholder = "List title..."
        post.placeholderColor = UIColor.placeholderText
        post.accessibilityLabel = "List title..."
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
        let metricsDict: [String: Any] = [
            "height" : UIFont.preferredFont(forTextStyle: .body).pointSize + 18
        ]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[post]-20-|", options: [], metrics: nil, views: viewsDict))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[post(height)]-10-|", options: [], metrics: metricsDict, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
