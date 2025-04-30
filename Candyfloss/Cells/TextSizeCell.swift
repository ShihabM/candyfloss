//
//  TextSizeCell.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 29/04/2025.
//

import Foundation
import UIKit

class TextSizeCell: UITableViewCell {
    
    let circle1 = UIView()
    var slider = UISlider()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        circle1.frame = CGRect(x: contentView.bounds.width/2 - 3, y: 29, width: 12, height: 12)
        circle1.backgroundColor = GlobalStruct.backgroundTint
        circle1.layer.cornerRadius = 6
        contentView.addSubview(circle1)
        
        slider.frame = CGRect(x: 15, y: 15, width: contentView.bounds.width - 20, height: 40)
        slider.isUserInteractionEnabled = true
        slider.minimumValue = -5
        slider.maximumValue = 5
        slider.isContinuous = true
        slider.tintColor = GlobalStruct.baseTint
        slider.minimumTrackTintColor = GlobalStruct.groupBG
        slider.maximumTrackTintColor = GlobalStruct.groupBG
        slider.value = Float(GlobalStruct.customTextSize)
        contentView.addSubview(slider)
        
        contentView.layer.masksToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSize(_ width: CGFloat) {
        circle1.frame = CGRect(x: (width - 50)/2 - 3, y: 29, width: 12, height: 12)
        slider.frame = CGRect(x: 15, y: 15, width: width - 65, height: 40)
    }
    
}
