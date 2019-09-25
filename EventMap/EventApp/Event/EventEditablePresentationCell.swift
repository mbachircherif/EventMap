//
//  EventEditablePresentationCell.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 22/01/2018.
//  Copyright © 2018 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit

class EventEditablePresentationCell: UITableViewCell, UITextFieldDelegate {
    
    let label: UITextField
    var tagData : String
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        // Initialisation du label avant l'appelle à super.init
        label = UITextField(frame: CGRect.null)
        tagData = ""
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        label.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        
        self.addSubview(label)
    }
    
    let leftMarginForLabel: CGFloat = 15.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.frame = CGRect(x: leftMarginForLabel, y: 0, width: bounds.size.width - leftMarginForLabel, height: bounds.size.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
