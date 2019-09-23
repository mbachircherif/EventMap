//
//  plainImage.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 02/04/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit

class plainImage: UITableViewCell {

    let img = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
        self.textLabel?.textAlignment = .center
        self.textLabel?.numberOfLines = 0
        
        img.contentMode = UIViewContentMode.scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(img)
        
        let viewsDict = [
            "image" : img,
            ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(10)-[image(150)]-(10)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(10)-[image]-(10)-|", options: [], metrics: nil, views: viewsDict))
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
